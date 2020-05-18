//
//  DJIMapView.h
//

#import <UIKit/UIKit.h>
#import <MapKit/MapKit.h>
#import <DJISDK/DJISDK.h>
#import <CoreLocation/CoreLocation.h>
#import "DJIAircraftAnnotation.h"
#import "DJIWaypointAnnotation.h"

@class DJIMapView;


@protocol DJIMapViewDelegate <NSObject>

-(void)mapView:(DJIMapView *)mapView didSelectAnnotationWithAirplaneState:(DJIAirSenseAirplaneState *)state;

@end

@interface DJIMapView : UIView<MKMapViewDelegate>
{
    DJIAircraftAnnotation* _aircraftAnnotation;
    DJIWaypointAnnotation *_homeAnnotation;
}

@property (weak) id<DJIMapViewDelegate> delegate; 

@property (nonatomic, strong) CLLocation *mobileLocation;
@property (nonatomic, strong) DJIWaypointAnnotation* homeAnnotation;
@property (nonatomic, strong) DJIWaypointAnnotation* rcAnnotation;
@property (nonatomic, strong) DJIWaypointAnnotation* takeoffLocationAnnotation;

@property (nonatomic) DJIWaypointAnnotation *fakeLocationAnnotation;
@property (nonatomic) DJIWaypointAnnotation *mobileLocationAnnotation;

@property (nonatomic) NSMutableArray<DJIAircraftAnnotation *> *airplaneAnnotations;

@property (nonatomic, assign) BOOL showValidHomepointCycle;
// Only convert coordinate system from WGS to GCJ when GPS signal is real.
@property (nonatomic, assign, getter=isSimulating) BOOL simulating;

- (id)initWithMap:(MKMapView*)mapView;
/**
 *  Add POI coordinate
 *
 *  @param coordinate of POI
 *  @param radius
 */
- (void)addPOICoordinate:(CLLocationCoordinate2D)coordinate withRadius:(CGFloat)radius;

- (void)clearPOIAndPOICircle;
/**
 *  Update aircraft location and heading.
 *
 *  @param coordinate Aircraft location
 *  @param heading    Aircraft heading
 */
-(void) updateAircraftLocation:(CLLocationCoordinate2D)coordinate withHeading:(CGFloat)heading;


- (void)updateHomeLocation:(CLLocationCoordinate2D)homecoordinate;

// Only used for the SetHome feature to show the circly of valid homepint area.
- (void)updateUserLocation:(CLLocationCoordinate2D)usercoordinate;

- (void)updateRCLocation:(CLLocationCoordinate2D)rccoordinate isValid:(BOOL)isValid;

- (void)updateAircraftInitialLocation:(CLLocationCoordinate2D)initcoordinate;

- (void)updateFakeLocation:(CLLocationCoordinate2D)coordinate;

- (void)updateMobileLocation:(CLLocationCoordinate2D)coordinate;

- (void)updateAirplanes:(NSArray<DJIAirSenseAirplaneState *> *)airplanes; 

- (void)updateWaypointFlightPath:(const CLLocationCoordinate2D *)coords count:(NSUInteger)count;

/**
 *  Update the no fly zone with the given coordinate
 **/

- (void)forceRefreshLimitSpaces;

- (void)refreshMapViewRegion;

- (void)setMapType:(MKMapType)mapType;

-(NSArray *)flyZonesCopy;

@end
