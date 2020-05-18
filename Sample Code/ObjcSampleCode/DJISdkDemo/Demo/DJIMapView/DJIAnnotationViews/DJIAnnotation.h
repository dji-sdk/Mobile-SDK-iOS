//
//  DJIAnnotation.h
//

#import <Foundation/Foundation.h>
#import <MapKit/MapKit.h>
#import <CoreLocation/CoreLocation.h>


@class DJIAnnotationView;

@interface DJIAnnotation : NSObject <MKAnnotation>

/**
 *  序号
 */
@property (copy, nonatomic) NSString *index;

/**
 *  经纬度
 */
@property (nonatomic) CLLocationCoordinate2D coordinate;


@property (nonatomic, weak) MKAnnotationView *annotationView;


@property (nonatomic, strong) DJIAnnotation *backGroundAnnotation;

@property (nonatomic, weak) MKMapView *mapView;

@property (nonatomic, assign) BOOL isBackgroundAnnotation;


+ (instancetype)annotationWithCoordinate:(CLLocationCoordinate2D)coordinate;


- (void)createBackgroundAnnotation;
- (void)setCoordinate:(CLLocationCoordinate2D)coordinate animation:(bool)animation;
@end
