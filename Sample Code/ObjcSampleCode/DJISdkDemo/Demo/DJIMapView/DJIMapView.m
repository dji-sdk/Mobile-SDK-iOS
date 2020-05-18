//
//  DJIMapView.m
//  Phantom3
//
//  Created by Jayce Yang on 14-4-10.
//  Copyright (c) 2014年 Jerome.zhang. All rights reserved.
//

#import <DJISDK/DJISDK.h>
#import <CoreLocation/CoreLocation.h>
#import "DJIMapView.h"

#import "DJIAircraftAnnotationView.h"
#import "DJIFlyLimitCircleView.h"
#import "DJIFlyLimitCircle.h"
#import "DJIWaypointAnnotation.h"
#import "DJIWaypointAnnotationView.h"
#import "DJIPOIAnnotationView.h"
#import "DJIWhitelistOverlay.h"

#import "DJILimitSpaceOverlay.h"
#import "DJIMapPolygon.h"
#import "DJIFlyLimitPolygonView.h"
#import "DJICircle.h"
#import "DJIWaypointV2FlightPathOverlays.h"
#import "DemoUtilityMacro.h"
#import "DemoAlertView.h"

#define kDJIMapViewZoomInSpan (3000.0f)
#define kDJIMapViewUpdateFlightLimitZoneDistance (1000.0)
#define RADIAN(x) ((x)*M_PI/180.0)
#define kNFZQueryScope  (50000)
#define HOMEPOINT_VALID_OFFSET  (30)
#define UPDATETIMESTAMP (10)

@interface CLLocation (Calculate)

+ (double)distanceFrom:(CLLocationCoordinate2D)coordinate to:(CLLocationCoordinate2D)anotherCoordinate;

@end


@implementation CLLocation (Calculate)

+ (double)distanceFrom:(CLLocationCoordinate2D)coordinate to:(CLLocationCoordinate2D)anotherCoordinate{
    CLLocation *location = [[CLLocation alloc] initWithLatitude:coordinate.latitude longitude:coordinate.longitude];
    CLLocation *otherLocation = [[CLLocation alloc] initWithLatitude:anotherCoordinate.latitude longitude:anotherCoordinate.longitude];
    return [location distanceFromLocation:otherLocation];
}

@end

@interface DJIMapView () <UIGestureRecognizerDelegate>

@property (nonatomic) CLLocationCoordinate2D aircraftCoordinate;

@property (nonatomic) CLLocationCoordinate2D homeCoordinate;

@property (nonatomic, assign) CLLocationCoordinate2D lastAircraftLineCoordinate;


@property (nonatomic, assign) BOOL isRegionChanging;


@property (nonatomic, strong) MKCircle *limitCircle; //this is the cirle of limit radius

@property (nonatomic, strong) NSOperationQueue *updateFlightZoneQueue; //it's used to update flight zones

@property (nonatomic, assign) CLLocationCoordinate2D preMapCenter;

@property (nonatomic, strong) NSMutableArray *currentLimitCircles;

@property (strong, nonatomic) MKCircle *poiCircle;
@property (strong, nonatomic) MKPointAnnotation *hotPointAnnotation;


@property (weak, nonatomic) MKMapView *mapView;

@property (nonatomic, strong) MKCircle *hpAircraftCycle;
@property (nonatomic, strong) MKCircle *hpRCLocationCycle;
@property (nonatomic, strong) MKCircle *hpInitialLocationCycle;
@property (nonatomic, strong) MKCircle *hpMobileLocationCycle;

@property (nonatomic, assign) NSTimeInterval lastUpdateTime;

@property (nonatomic, strong) NSMutableArray<DJIMapOverlay *> *mapOverlays;
@property (nonatomic, strong) NSMutableArray<DJIMapOverlay *> *whitelistOverlays;
@property (nonatomic, strong) NSMutableArray<DJIWaypointV2FlightPathOverlays *> *flightPathOverlays;

@property (nonatomic, strong) NSMutableArray *flightLimitZones;
@property (nonatomic) NSLock *flyZonesLock;

@end

@implementation DJIMapView

- (id)initWithMap:(MKMapView*)mapView{
    if (nil != mapView) {
        self = [super init];//initWithFrame:mapView.superview.frame];
        if (self) {
            _mapView = mapView;
            [self setupDefaults];
        }
        
        return self;
    }
    
    return nil;
}


- (id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if (self) {
        // Initialization code
        
        [self setupDefaults];
    }
    return self;
}

- (void)dealloc
{
    if (_hpInitialLocationCycle){
        _hpInitialLocationCycle = nil;
    }
    if (_hpMobileLocationCycle) {
        _hpMobileLocationCycle = nil;
    }
    if (_hpAircraftCycle) {
        _hpAircraftCycle = nil;
    }
    if (_hpRCLocationCycle) {
        _hpRCLocationCycle = nil;
    }
    
    self.mapView.delegate = nil;
    self.mapView = nil;
    
}



#pragma mark - POI
- (void)addPOICoordinate:(CLLocationCoordinate2D)coordinate withRadius:(CGFloat)radius{
    [self transformWGSCoordinateToGCJ02IfNeeded:&coordinate];

    if(self.poiCircle){
        [self.mapView removeOverlay:self.poiCircle];
    }
    
    
    if(self.hotPointAnnotation){
        [self.mapView removeAnnotation:self.hotPointAnnotation];
    }
    else{
        self.hotPointAnnotation = [[MKPointAnnotation alloc] init];
    }
   // coordinate = [GISCoordinateConverter gcjFromWGS84:coordinate];
    self.poiCircle = [MKCircle circleWithCenterCoordinate:coordinate radius:radius];
    [self.hotPointAnnotation setCoordinate:coordinate];
    
    [self.mapView addOverlay:self.poiCircle];
    [self.mapView addAnnotation:self.hotPointAnnotation];
    
    self.hotPointAnnotation.title = [NSString stringWithFormat:@"{%0.6f, %0.6f}", coordinate.latitude, coordinate.longitude];
    
}

- (void)clearPOIAndPOICircle{
    if(self.poiCircle){
        [self.mapView removeOverlay:self.poiCircle];
        self.poiCircle = nil;
    }
    
    if(self.hotPointAnnotation){
        [self.mapView removeAnnotation:self.hotPointAnnotation];
        self.homeAnnotation = nil;
    }
}

-(void) updateAircraftLocation:(CLLocationCoordinate2D)coordinate withHeading:(CGFloat)heading {
    [self transformWGSCoordinateToGCJ02IfNeeded:&coordinate];

    if (CLLocationCoordinate2DIsValid(coordinate)) {
        
        _aircraftCoordinate = coordinate;

        if (_aircraftAnnotation == nil) {
            _aircraftAnnotation =  [DJIAircraftAnnotation annotationWithCoordinate:coordinate heading:heading];
            [self.mapView addAnnotation:_aircraftAnnotation];
            MKCoordinateRegion viewRegion = MKCoordinateRegionMakeWithDistance(coordinate, 500, 500);
            MKCoordinateRegion adjustedRegion = [self.mapView regionThatFits:viewRegion];
            [self.mapView setRegion:adjustedRegion animated:YES];
            [self updateLimitFlyZone];
        } else {
            [_aircraftAnnotation setCoordinate:coordinate];
            DJIAircraftAnnotationView *annotationView = (DJIAircraftAnnotationView *)[_mapView viewForAnnotation:_aircraftAnnotation];
            [annotationView updateHeading:heading];
            [self updateLimitFlyZone];
        }
        
        // Below logic is used the draw or clean the cycle around current aircraft location to show the user
        // that valid area of homepoint.
        MKCircle* localCycle = _hpAircraftCycle;
        [self updateCircle:&localCycle from:coordinate];
        _hpAircraftCycle = localCycle;
    }
}

- (void)updateHomeLocation:(CLLocationCoordinate2D)homecoordinate {
    [self transformWGSCoordinateToGCJ02IfNeeded:&homecoordinate];

    if (CLLocationCoordinate2DIsValid(homecoordinate)) {
        
        if (!_homeAnnotation) {
            _homeAnnotation = [[DJIWaypointAnnotation alloc] initWithCoordinate:homecoordinate];
            _homeAnnotation.text = @"H";
            [self.mapView addAnnotation:_homeAnnotation];
        } else {
            CLLocationCoordinate2D currentCoordinate = _homeAnnotation.coordinate;
            
            if (fabs(currentCoordinate.latitude - homecoordinate.latitude) > 1e-7 || fabs(currentCoordinate.longitude - homecoordinate.longitude) > 1e-7) {
                [_homeAnnotation setCoordinate:homecoordinate];
                
                [self.mapView addAnnotation:_homeAnnotation];
            }
        }
    }
}


-(void) updateCircle:(MKCircle**) circle from:(CLLocationCoordinate2D)coordinate {
    [self transformWGSCoordinateToGCJ02IfNeeded:&coordinate];

    if (self.showValidHomepointCycle) {
        if (*circle != nil) {
            if (fabs((*circle).coordinate.latitude - coordinate.latitude) > 1e-6 || fabs((*circle).coordinate.longitude - coordinate.longitude) > 1e-6) {
                MKCircle* newCircle = [MKCircle circleWithCenterCoordinate:coordinate radius:HOMEPOINT_VALID_OFFSET];
                [self.mapView addOverlay:newCircle];
                [self.mapView removeOverlay:*circle];
                *circle = newCircle;
            }
            
        } else {
            *circle = [MKCircle circleWithCenterCoordinate:coordinate radius:HOMEPOINT_VALID_OFFSET];
            [self.mapView addOverlay:*circle];
        }
        
    } else {
        if (*circle != nil) {
            [self.mapView removeOverlay:*circle];
            *circle = nil;
        }
    }

}

- (void)updateUserLocation:(CLLocationCoordinate2D)usercoordinate{
    [self transformWGSCoordinateToGCJ02IfNeeded:&usercoordinate];

    MKCircle* localCycle = _hpMobileLocationCycle;
    [self updateCircle:&localCycle from:usercoordinate];
    _hpMobileLocationCycle = localCycle;
    
}

- (void)updateRCLocation:(CLLocationCoordinate2D)rccoordinate isValid:(BOOL)isValid{
    [self transformWGSCoordinateToGCJ02IfNeeded:&rccoordinate];

    if (CLLocationCoordinate2DIsValid(rccoordinate)) {
        
        if (!_rcAnnotation) {
            _rcAnnotation = [[DJIWaypointAnnotation alloc] initWithCoordinate:rccoordinate];
            _rcAnnotation.text = @"RC";
            [self.mapView addAnnotation:_rcAnnotation];
        } else {
            CLLocationCoordinate2D currentCoordinate = _rcAnnotation.coordinate;
            
            if (fabs(currentCoordinate.latitude - rccoordinate.latitude) > 1e-7 || fabs(currentCoordinate.longitude - rccoordinate.longitude) > 1e-7) {
                [_rcAnnotation setCoordinate:rccoordinate];
                
                [self.mapView addAnnotation:_rcAnnotation];
            }
        }
    }
    
    
    MKCircle* localCycle = _hpRCLocationCycle;
    [self updateCircle:&localCycle from:rccoordinate];
    _hpRCLocationCycle = localCycle;
}

- (void)updateAircraftInitialLocation:(CLLocationCoordinate2D)initcoordinate{
    [self transformWGSCoordinateToGCJ02IfNeeded:&initcoordinate];

    if (CLLocationCoordinate2DIsValid(initcoordinate)) {
        
        if (!_takeoffLocationAnnotation) {
            _takeoffLocationAnnotation = [[DJIWaypointAnnotation alloc] initWithCoordinate:initcoordinate];
            _takeoffLocationAnnotation.text = @"I";
            [self.mapView addAnnotation:_takeoffLocationAnnotation];
        } else {
            CLLocationCoordinate2D currentCoordinate = _takeoffLocationAnnotation.coordinate;
            
            if (fabs(currentCoordinate.latitude - initcoordinate.latitude) > 1e-7 || fabs(currentCoordinate.longitude - initcoordinate.longitude) > 1e-7) {
                [_takeoffLocationAnnotation setCoordinate:initcoordinate];
                
                [self.mapView addAnnotation:_takeoffLocationAnnotation];
            }
        }
    }
    
    MKCircle* localCycle = _hpInitialLocationCycle;
    [self updateCircle:&localCycle from:initcoordinate];
    _hpInitialLocationCycle = localCycle;
}

-(void)updateFakeLocation:(CLLocationCoordinate2D)coordinate {
    [self transformWGSCoordinateToGCJ02IfNeeded:&coordinate];

    if (CLLocationCoordinate2DIsValid(coordinate)) {

        if (self.fakeLocationAnnotation == nil) {
            self.fakeLocationAnnotation = [[DJIWaypointAnnotation alloc] initWithCoordinate:coordinate];
            self.fakeLocationAnnotation.text = @"F";
            if (CLLocationCoordinate2DIsValid(coordinate)) {
                [self.mapView addAnnotation:self.fakeLocationAnnotation];
            }
        } else {
            CLLocationCoordinate2D currentCoordinate = self.fakeLocationAnnotation.coordinate;

            if (fabs(currentCoordinate.latitude - coordinate.latitude) > 1e-7 || fabs(currentCoordinate.longitude - coordinate.longitude) > 1e-7) {
                [self.fakeLocationAnnotation setCoordinate:coordinate];

                if (CLLocationCoordinate2DIsValid(coordinate)) {
                    [self.mapView addAnnotation:self.fakeLocationAnnotation];
                }
                else {
                    [self.mapView removeAnnotation:self.fakeLocationAnnotation];
                }
            }
        }
    }
}

-(void)updateMobileLocation:(CLLocationCoordinate2D)coordinate {
    [self transformWGSCoordinateToGCJ02IfNeeded:&coordinate];
    if (CLLocationCoordinate2DIsValid(coordinate)) {
        if (self.mobileLocationAnnotation == nil) {
            self.mobileLocationAnnotation = [[DJIWaypointAnnotation alloc] initWithCoordinate:coordinate];
            self.mobileLocationAnnotation.text = @"📱";
            [self.mapView addAnnotation:self.mobileLocationAnnotation];
        } else {
            CLLocationCoordinate2D currentCoordinate = self.mobileLocationAnnotation.coordinate;

            if (fabs(currentCoordinate.latitude - coordinate.latitude) > 1e-7 || fabs(currentCoordinate.longitude - coordinate.longitude) > 1e-7) {
                [self.mobileLocationAnnotation setCoordinate:coordinate];

                if (CLLocationCoordinate2DIsValid(coordinate)) {
                    [self.mapView addAnnotation:self.mobileLocationAnnotation];
                }
                else {
                    [self.mapView removeAnnotation:self.mobileLocationAnnotation];
                }
            }
        }
    }
}

-(void)updateAirplanes:(NSArray<DJIAirSenseAirplaneState *> *)airplanes {
    if (self.airplaneAnnotations == nil) {
        self.airplaneAnnotations = [NSMutableArray array];
    }

    [self.mapView removeAnnotations:self.airplaneAnnotations];
    [self.airplaneAnnotations removeAllObjects];

    for (DJIAirSenseAirplaneState *state in airplanes) {
        CLLocationCoordinate2D estimated = [self estimateLocationFromAirSenseState:state];
        if (CLLocationCoordinate2DIsValid(estimated)) {
            DJIAircraftAnnotation *airplaneAnnotation =  [DJIAircraftAnnotation annotationWithCoordinate:estimated
                                                                                                 heading:state.heading];
            airplaneAnnotation.state = state;
            [self.airplaneAnnotations addObject:airplaneAnnotation];
        }
    }

    [self.mapView addAnnotations:self.airplaneAnnotations];
}

-(CLLocationCoordinate2D)estimateLocationFromAirSenseState:(DJIAirSenseAirplaneState *)state {
    if (state == nil ||
        state.relativeDirection == DJIAirSenseDirectionUnknown ||
        !CLLocationCoordinate2DIsValid(_aircraftCoordinate)) {
        return kCLLocationCoordinate2DInvalid;
    }

    CLLocationCoordinate2D offset = {0, 0};
    switch (state.relativeDirection) {
        case DJIAirSenseDirectionNorth:
            offset.latitude = 0.090440;
            offset.longitude = 0;
            break;
        case DJIAirSenseDirectionNorthEast:
            offset.latitude = 0.063950;
            offset.longitude = 0.063950;
            break;
        case DJIAirSenseDirectionEast:
            offset.latitude = 0;
            offset.longitude = 0.090440;
            break;
        case DJIAirSenseDirectionSouthEast:
            offset.latitude = -0.063950;
            offset.longitude = 0.063950;
            break;
        case DJIAirSenseDirectionSouth:
            offset.latitude = -0.090440;
            offset.longitude = 0;
            break;
        case DJIAirSenseDirectionSouthWest:
            offset.latitude = -0.063950;
            offset.longitude = -0.063950;
            break;
        case DJIAirSenseDirectionWest:
            offset.latitude = 0;
            offset.longitude = -0.090440;
            break;
        case DJIAirSenseDirectionNorthWest:
            offset.latitude = 0.063950;
            offset.longitude = -0.063950;
            break;
        case DJIAirSenseDirectionUnknown:
            break;
    }

    offset.latitude *= state.distance * 0.0001;
    offset.longitude *= state.distance * 0.0001;

//    switch (state.warningLevel) {
//        case DJIAirSenseWarningLevel0:
//            offset.latitude *= 5;
//            offset.longitude *= 5;
//            break;
//        case DJIAirSenseWarningLevel1:
//            offset.latitude *= 4;
//            offset.longitude *= 4;
//            break;
//        case DJIAirSenseWarningLevel2:
//            offset.latitude *= 3;
//            offset.longitude *= 3;
//            break;
//        case DJIAirSenseWarningLevel3:
//            offset.latitude *= 2;
//            offset.longitude *= 2;
//            break;
//        case DJIAirSenseWarningLevel4:
//        case DJIAirSenseWarningLevelUnknown:
//            break;
//    }
    return CLLocationCoordinate2DMake(_aircraftCoordinate.latitude + offset.latitude, _aircraftCoordinate.longitude + offset.longitude);
}

#pragma mark - Private

/**
 *  Set the delegate for the mapView and initial the NFZ releated objects.
 */
- (void)setupDefaults
{
    self.mapView.delegate = self;
    self.updateFlightZoneQueue = [[NSOperationQueue alloc] init];
    self.updateFlightZoneQueue.maxConcurrentOperationCount = 1;
    
    self.flightLimitZones = [NSMutableArray array];
    self.flyZonesLock = [NSLock new];
    self.showValidHomepointCycle = NO;
    
    _mapOverlays = [NSMutableArray array];
    _whitelistOverlays = [NSMutableArray array];
	_flightPathOverlays = [NSMutableArray array];
    [self forceRefreshLimitSpaces];
}

#pragma mark - MKMapViewDelegate

- (MKAnnotationView *)mapView:(MKMapView *)mapView viewForAnnotation:(id <MKAnnotation>)annotation
{
    
    // Hotpoint
    if ([annotation isKindOfClass:[MKUserLocation class]]) {
        return nil;
    } else if(annotation == self.hotPointAnnotation){
        DJIPOIAnnotationView *annotationView = (DJIPOIAnnotationView *)[mapView dequeueReusableAnnotationViewWithIdentifier:@"HotPointAnnotation"];
        if (annotationView == nil) {
            annotationView = [[DJIPOIAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:@"HotPointAnnotation"];
            annotationView.draggable = NO;
        } else {
            annotationView.annotation = annotation;
        }
        return annotationView;
        
    } else if ([annotation isKindOfClass:[DJIAircraftAnnotation class]])
    {
        DJIAircraftAnnotation *aircraftAnnotation = (DJIAircraftAnnotation *)annotation;
        [aircraftAnnotation setAnnotationTitle:@"W"];
        static NSString* aircraftReuseIdentifier = @"DJI_AIRCRAFT_ANNOTATION_VIEW";
        DJIAircraftAnnotationView* aircraftAnno = (DJIAircraftAnnotationView*)[self.mapView dequeueReusableAnnotationViewWithIdentifier:aircraftReuseIdentifier];
        if (aircraftAnno == nil) {
            aircraftAnno = [[DJIAircraftAnnotationView alloc] initWithAnnotation:annotation
                                                                           alpha:aircraftAnnotation.state ? 0.5 : 1.0
                                                                 reuseIdentifier:aircraftReuseIdentifier];
        }
        aircraftAnno.alpha = aircraftAnnotation.state ? 0.5 : 1.0;
        aircraftAnno.canShowCallout = aircraftAnnotation.state != nil;
        aircraftAnno.enabled = aircraftAnnotation.state != nil;
        [aircraftAnno updateHeading:aircraftAnnotation.heading];
        return aircraftAnno;
    } else if ([annotation isKindOfClass:[DJIWaypointAnnotation class]]) {
        static NSString* waypointReuseIdentifier = @"DJI_WAYPOINT_ANNOTATION_VIEW";
        static NSString* homepointReuseIdentifier = @"DJI_HOME_POINT_ANNOTATION_VIEW";
        static NSString* rcpointReuseIdentifier = @"DJI_RC_POINT_ANNOTATION_VIEW";
        static NSString* takeOffReuseIdentifier = @"DJI_TAKEOFF_POINT_ANNOTATION_VIEW";
        NSString* reuseIdentifier = waypointReuseIdentifier;
        if (annotation == self.homeAnnotation) {
            reuseIdentifier = homepointReuseIdentifier;
        } else if (annotation == self.rcAnnotation) {
            reuseIdentifier = rcpointReuseIdentifier;
        } else if (annotation == self.takeoffLocationAnnotation) {
            reuseIdentifier = takeOffReuseIdentifier;
        }
        
        DJIWaypointAnnotation* wpAnnotation = (DJIWaypointAnnotation*)annotation;
        DJIWaypointAnnotationView* annoView = (DJIWaypointAnnotationView*)[self.mapView dequeueReusableAnnotationViewWithIdentifier:reuseIdentifier];
        if (annoView == nil) {
            annoView = [[DJIWaypointAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:reuseIdentifier];
        }
       
        annoView.titleLabel.text = wpAnnotation.text;
        
        return annoView;
    }

    return nil;
}

#define UIColorFromRGBA(rgbValue, a) \
[UIColor colorWithRed:((float)((rgbValue & 0xFF0000) >> 16))/255.0 \
green:((float)((rgbValue & 0x00FF00) >>  8))/255.0 \
blue:((float)((rgbValue & 0x0000FF) >>  0))/255.0 \
alpha:a]

- (MKOverlayRenderer *)mapView:(MKMapView *)mapView rendererForOverlay:(id <MKOverlay>)overlay
{
   if ([overlay isKindOfClass:[DJIFlyLimitCircle class]]) {
        DJIFlyLimitCircleView* circleView = [[DJIFlyLimitCircleView alloc] initWithCircle:overlay];
        return circleView;
    } else if (overlay == self.poiCircle){
            MKCircleRenderer* circleView = [[MKCircleRenderer alloc] initWithOverlay:overlay];
            circleView.fillColor = UIColorFromRGBA(0xACDF31, 0);
            circleView.strokeColor = UIColorFromRGBA(0xACDF31, 1.0);
            return circleView;

    } else if (
       overlay == self.hpAircraftCycle ||
       overlay == self.hpInitialLocationCycle ||
       overlay == self.hpMobileLocationCycle ||
       overlay == self.hpRCLocationCycle) {
        MKCircleRenderer* circleView = [[MKCircleRenderer alloc] initWithOverlay:overlay];
        circleView.fillColor = UIColorFromRGBA(0xACDF31, 0.5);
        //circleView.strokeColor = UIColorFromRGBA(0xACDF31, 1.0);
        //circleView
        return circleView;
    } else if ([overlay isKindOfClass:[DJIPolygon class]]) {
        DJIFlyLimitPolygonView *polygonRender = [[DJIFlyLimitPolygonView alloc] initWithPolygon:(DJIPolygon *)overlay];
        return polygonRender;
    } else if ([overlay isKindOfClass:[DJIMapPolygon class]]) {
        MKPolygonRenderer *polygonRender = [[MKPolygonRenderer alloc] initWithPolygon:(MKPolygon *)overlay];
        DJIMapPolygon *polygon = (DJIMapPolygon *)overlay;
        polygonRender.strokeColor = polygon.strokeColor;
        polygonRender.lineWidth = polygon.lineWidth;
        polygonRender.lineDashPattern = polygon.lineDashPattern;
        polygonRender.lineJoin = polygon.lineJoin;
        polygonRender.lineCap = polygon.lineCap;
        polygonRender.fillColor = polygon.fillColor;
        return polygonRender;
    } else if ([overlay isKindOfClass:[DJICircle class]]) {
        DJICircle *circle = (DJICircle *)overlay;
        MKCircleRenderer *circleRender = [[MKCircleRenderer alloc] initWithCircle:circle];
        circleRender.strokeColor = circle.strokeColor;
        circleRender.lineWidth = circle.lineWidth;
        circleRender.fillColor = circle.fillColor;
        return circleRender;
	} else if ([overlay isKindOfClass:[MKPolyline class]]) {
		MKPolylineRenderer *renderer = [[MKPolylineRenderer alloc] initWithPolyline: overlay];
		renderer.strokeColor = [UIColor colorWithRed:69.0f/255.0f green:212.0f/255.0f blue:255.0f/255.0f alpha:1];
		renderer.lineWidth = 1;
		return renderer;
	}

    return nil;
}


#pragma mark - NFZ safe flight space



-(void) updateLimitFlyZone
{
    if ([self canUpdateLimitFlyZoneWithCoordinate]) {
        [self updateLimitFlyZoneInSurroundingArea];
        [self updateWhitelistFlyzone];
    }
}

- (void)forceRefreshLimitSpaces
{
    [self updateLimitFlyZoneInSurroundingArea];
    [self updateWhitelistFlyzone];
}

- (void) updateWhitelistFlyzone
{
    WeakRef(target);
	NSArray* zones = [[DJISDKManager flyZoneManager] getCustomUnlockZonesFromAircraft];
	
	if (zones.count > 0) {
		[[DJISDKManager flyZoneManager] getEnabledCustomUnlockZoneWithCompletion:^(DJICustomUnlockZone * _Nullable zone, NSError * _Nullable error) {
			if (error) {
				ShowResult(@"Get Enabled Zone ERROR: %@", error.description);
			}
			else {
				if (zone) {
					[target updateWhitelistWithSpaces:@[zone] andEnabledZone:zone];
				}
			}
		}];
	} else {
		if (target.whitelistOverlays.count > 0) {
			[target removeMapOverlays:self.whitelistOverlays];
		}
	}
}

-(void) updateLimitFlyZoneInSurroundingArea
{
    WeakRef(target);
    [[DJISDKManager flyZoneManager] getFlyZonesInSurroundingAreaWithCompletion:^(NSArray<DJIFlyZoneInformation *> * _Nullable infos, NSError * _Nullable error) {
        WeakReturn(target);
        if (nil == error && infos.count > 0) {
            [target updateLimitFlyZoneWithSpaces:infos];
        }
        else {
            NSLog(@"Get fly zone falied: %@", error.description);
            if (target.mapOverlays.count > 0)
            	[target removeMapOverlays:target.mapOverlays];

            {
                [self.flyZonesLock lock];
                if (target.flightLimitZones.count > 0)
                    [target.flightLimitZones removeAllObjects];
                [self.flyZonesLock unlock];
            }

        }
    }];
}

-(BOOL) canUpdateLimitFlyZoneWithCoordinate
{
    NSTimeInterval currentTime = [NSDate timeIntervalSinceReferenceDate];
    
    if ((currentTime - _lastUpdateTime) < UPDATETIMESTAMP) {
        return NO;
    }
    
    
    _lastUpdateTime = [NSDate timeIntervalSinceReferenceDate];
    return YES;
}

- (void)updateWhitelistWithSpaces:(NSArray<DJICustomUnlockZone *> * _Nullable)spaceInfos andEnabledZone:(DJICustomUnlockZone *)enabledZone
{
    if (spaceInfos && spaceInfos.count > 0) {
        NSMutableArray *overlays = [NSMutableArray array];

        for (int i = 0; i < spaceInfos.count; i++) {
            DJICustomUnlockZone *flyZoneLimitInfo = [spaceInfos objectAtIndex:i];
            DJIWhitelistOverlay *aOverlay = nil;
            for (DJIWhitelistOverlay *aWhitelistOverlay in _whitelistOverlays) {
                if (aWhitelistOverlay.whitelistInformation.ID == flyZoneLimitInfo.ID) {
                    //&& aWhitelistOverlay.whitelistInformation.license.enabled == flyZoneLimitInfo.license.enabled) {
                    aOverlay = aWhitelistOverlay;
                    break;
                }
            }
            if (!aOverlay) {
                //TODO
                BOOL enabled = [flyZoneLimitInfo isEqual:enabledZone];
                aOverlay = [[DJIWhitelistOverlay alloc] initWithWhitelistInformation:flyZoneLimitInfo andEnabled:enabled];
            }
            [overlays addObject:aOverlay];
        }
        [self removeWhitelistOverlays:self.whitelistOverlays];
        [self addWhitelistOverlays:overlays];
    }
}

- (void)updateLimitFlyZoneWithSpaces:(NSArray<DJIFlyZoneInformation*> *_Nullable)spaceInfos
{
    if (spaceInfos && spaceInfos.count > 0) {
        dispatch_block_t block = ^{
            NSMutableArray *overlays = [NSMutableArray array];
            NSMutableArray *flyZones = [NSMutableArray array];
    
            for (int i = 0; i < spaceInfos.count; i++) {
                DJIFlyZoneInformation *flyZoneLimitInfo = [spaceInfos objectAtIndex:i];
                                      DJILimitSpaceOverlay *aOverlay = nil;
                    for (DJILimitSpaceOverlay *aMapOverlay in self.mapOverlays) {
                        if (aMapOverlay.limitSpaceInfo.flyZoneID == flyZoneLimitInfo.flyZoneID &&
                            (aMapOverlay.limitSpaceInfo.subFlyZones.count == flyZoneLimitInfo.subFlyZones.count)) {
                            aOverlay = aMapOverlay;
                            break;
                        }
                    }
                    if (!aOverlay) {
                        aOverlay = [[DJILimitSpaceOverlay alloc] initWithLimitSpace:flyZoneLimitInfo];
                    }
                    [overlays addObject:aOverlay];
                	[flyZones addObject:flyZoneLimitInfo];
            }
            [self removeMapOverlays:self.mapOverlays];
            [self addMapOverlays:overlays];

            [self.flyZonesLock lock];
            [self.flightLimitZones removeAllObjects];
            [self.flightLimitZones addObjectsFromArray:flyZones];
            [self.flyZonesLock unlock];
        };
        if ([NSThread currentThread].isMainThread) {
            block();
        } else {
            dispatch_sync(dispatch_get_main_queue(), ^{
                block();
            });
        }
    }
}

- (void)updateWaypointFlightPath:(const CLLocationCoordinate2D *)coords count:(NSUInteger)count  {
	[self removeFlightPathOverlays:self.flightPathOverlays];
	
	if ([NSThread currentThread].isMainThread) {
		DJIWaypointV2FlightPathOverlays *overLays = [[DJIWaypointV2FlightPathOverlays alloc] initWithWaypointFlightPath:coords count:count];
		[self addFlightPathOverlays:@[overLays]];
	} else {
		dispatch_sync(dispatch_get_main_queue(), ^{
			DJIWaypointV2FlightPathOverlays *overLays = [[DJIWaypointV2FlightPathOverlays alloc] initWithWaypointFlightPath:coords count:count];
			[self addFlightPathOverlays:@[overLays]];
		});
	}
}

- (void)setMapType:(MKMapType)mapType
{
    self.mapView.mapType = mapType;
}

- (void)refreshMapViewRegion
{
    MKCoordinateRegion viewRegion = MKCoordinateRegionMakeWithDistance(_aircraftCoordinate, 500, 500);
    MKCoordinateRegion adjustedRegion = [self.mapView regionThatFits:viewRegion];
    [self.mapView setRegion:adjustedRegion animated:YES];
}

- (void)addMapOverlays:(NSArray *)objects
{
    if (objects.count <= 0) {
        return;
    }
    NSMutableArray *overlays = [NSMutableArray array];
    for (DJIMapOverlay *aMapOverlay in objects) {
        for (id<MKOverlay> aOverlay in aMapOverlay.subOverlays) {
            [overlays addObject:aOverlay];
        }
    }
    
    if ([NSThread isMainThread]) {
        [self.mapOverlays addObjectsFromArray:objects];
        [self.mapView addOverlays:overlays];
    } else {
        dispatch_sync(dispatch_get_main_queue(), ^{
            [self.mapOverlays addObjectsFromArray:objects];
            [self.mapView addOverlays:overlays];
        });
    }
}

- (void)addWhitelistOverlays:(NSArray *)objects
{
    if (objects.count <= 0) {
        return;
    }
    NSMutableArray *overlays = [NSMutableArray array];
    for (DJIMapOverlay *aMapOverlay in objects) {
        for (id<MKOverlay> aOverlay in aMapOverlay.subOverlays) {
            [overlays addObject:aOverlay];
        }
    }
    
    if ([NSThread isMainThread]) {
        [self.whitelistOverlays addObjectsFromArray:objects];
        [self.mapView addOverlays:overlays];
    } else {
        dispatch_sync(dispatch_get_main_queue(), ^{
            [self.whitelistOverlays addObjectsFromArray:objects];
            [self.mapView addOverlays:overlays];
        });
    }
}

- (void)removeMapOverlays:(NSArray *)objects
{
    if (objects.count <= 0) {
        return;
    }
    NSMutableArray *overlays = [NSMutableArray array];
    for (DJIMapOverlay *aMapOverlay in objects) {
        for (id<MKOverlay> aOverlay in aMapOverlay.subOverlays) {
            [overlays addObject:aOverlay];
        }
    }
    if ([NSThread isMainThread]) {
        [self.mapOverlays removeObjectsInArray:objects];
        [self.mapView removeOverlays:overlays];
    } else {
        dispatch_sync(dispatch_get_main_queue(), ^{
            [self.mapOverlays removeObjectsInArray:objects];
            [self.mapView removeOverlays:overlays];
        });
    }
}

- (void)removeWhitelistOverlays:(NSArray *)objects
{
    if (objects.count <= 0) {
        return;
    }
    NSMutableArray *overlays = [NSMutableArray array];
    for (DJIMapOverlay *aMapOverlay in objects) {
        for (id<MKOverlay> aOverlay in aMapOverlay.subOverlays) {
            [overlays addObject:aOverlay];
        }
    }
    if ([NSThread isMainThread]) {
        [self.whitelistOverlays removeObjectsInArray:objects];
        [self.mapView removeOverlays:overlays];
    } else {
        dispatch_sync(dispatch_get_main_queue(), ^{
            [self.whitelistOverlays removeObjectsInArray:objects];
            [self.mapView removeOverlays:overlays];
        });
    }
}

- (void)addFlightPathOverlays:(NSArray *)objects
{
	if (objects.count <= 0) {
		return;
	}
	NSMutableArray *overlays = [NSMutableArray array];
	for (DJIMapOverlay *aMapOverlay in objects) {
		for (id<MKOverlay> aOverlay in aMapOverlay.subOverlays) {
			[overlays addObject:aOverlay];
		}
	}
	
	if ([NSThread isMainThread]) {
		[self.flightPathOverlays addObjectsFromArray:objects];
		[self.mapView addOverlays:overlays];
	} else {
		dispatch_sync(dispatch_get_main_queue(), ^{
			[self.flightPathOverlays addObjectsFromArray:objects];
			[self.mapView addOverlays:overlays];
		});
	}
}

- (void)removeFlightPathOverlays:(NSArray *)objects
{
	if (objects.count <= 0) {
		return;
	}
	NSMutableArray *overlays = [NSMutableArray array];
	for (DJIMapOverlay *aMapOverlay in objects) {
		for (id<MKOverlay> aOverlay in aMapOverlay.subOverlays) {
			[overlays addObject:aOverlay];
		}
	}
	if ([NSThread isMainThread]) {
		[self.flightPathOverlays removeObjectsInArray:objects];
		[self.mapView removeOverlays:overlays];
	} else {
		dispatch_sync(dispatch_get_main_queue(), ^{
			[self.flightPathOverlays removeObjectsInArray:objects];
			[self.mapView removeOverlays:overlays];
		});
	}
}

-(void)mapView:(MKMapView *)mapView didSelectAnnotationView:(MKAnnotationView *)view {
    [mapView deselectAnnotation:view.annotation animated:NO];
    if (self.delegate && [self.delegate respondsToSelector:@selector(mapView:didSelectAnnotationWithAirplaneState:)]) {
        if (view.annotation && [view.annotation isKindOfClass:[DJIAircraftAnnotation class]]) {
            DJIAircraftAnnotation *annotation = (DJIAircraftAnnotation *)view.annotation;
            if (annotation.state) {
                [self.delegate mapView:self didSelectAnnotationWithAirplaneState:annotation.state];
            }
        }
    }
}

-(NSArray *)flyZonesCopy {
    [self.flyZonesLock lock];
    NSArray *zones = [self.flightLimitZones copy];
    [self.flyZonesLock unlock];
    return zones; 
}

#pragma mark - WGS84->GCJ02
- (void)transformWGSCoordinateToGCJ02IfNeeded:(CLLocationCoordinate2D *)wgsCoordinate {
    if (self.isSimulating) {
        return;
    }
    // a = 6378245.0, 1/f = 298.3
    // b = a * (1 - f)
    // ee = (a^2 - b^2) / a^2;
    const double a = 6378245.0;
    const double ee = 0.00669342162296594323;
    if ([[self class] outOfChina:wgsCoordinate]) {
        return;
    }
    double dLat = [[self class] transformLatWithX:wgsCoordinate->longitude - 105.0 y:wgsCoordinate->latitude - 35.0];
    double dLon = [[self class] transformLonWithX:wgsCoordinate->longitude - 105.0 y:wgsCoordinate->latitude - 35.0];
    double radLat = wgsCoordinate->latitude / 180.0 * M_PI;
    double magic = sin(radLat);
    magic = 1 - ee * magic * magic;
    double sqrtMagic = sqrt(magic);
    dLat = (dLat * 180.0) / ((a * (1 - ee)) / (magic * sqrtMagic) * M_PI);
    dLon = (dLon * 180.0) / (a / sqrtMagic * cos(radLat) * M_PI);
    wgsCoordinate->latitude += dLat;
    wgsCoordinate->longitude += dLon;
}

+ (BOOL)outOfChina:(CLLocationCoordinate2D *)coordinate {
    if (coordinate->longitude < 72.004 || coordinate->longitude > 137.8347) {
        return YES;
    }
    if (coordinate->latitude < 0.8293 || coordinate->latitude > 55.8271) {
        return YES;
    }
    return NO;
}

+ (double)transformLatWithX:(double)x y:(double)y {
    double ret = -100.0 + 2.0 * x + 3.0 * y + 0.2 * y * y + 0.1 * x * y + 0.2 * sqrt(fabs(x));
    ret += (20.0 * sin(6.0 * x * M_PI) + 20.0 * sin(2.0 * x * M_PI)) * 2.0 / 3.0;
    ret += (20.0 * sin(y * M_PI) + 40.0 * sin(y / 3.0 * M_PI)) * 2.0 / 3.0;
    ret += (160.0 * sin(y / 12.0 * M_PI) + 320 * sin(y * M_PI / 30.0)) * 2.0 / 3.0;
    return ret;
}

+ (double)transformLonWithX:(double)x y:(double)y {
    double ret = 300.0 + x + 2.0 * y + 0.1 * x * x + 0.1 * x * y + 0.1 * sqrt(fabs(x));
    ret += (20.0 * sin(6.0 * x * M_PI) + 20.0 * sin(2.0 * x * M_PI)) * 2.0 / 3.0;
    ret += (20.0 * sin(x * M_PI) + 40.0 * sin(x / 3.0 * M_PI)) * 2.0 / 3.0;
    ret += (150.0 * sin(x / 12.0 * M_PI) + 300.0 * sin(x / 30.0 * M_PI)) * 2.0 / 3.0;
    return ret;
}

@end
