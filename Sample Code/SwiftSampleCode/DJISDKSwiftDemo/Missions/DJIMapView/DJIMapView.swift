//
//  DJIMapView.swift
//  DJISDKSwiftDemo
//
import UIKit
import MapKit
import DJISDK
import CoreLocation


let kDJIMapViewZoomInSpan = (3000.0)
let kDJIMapViewUpdateFlightLimitZoneDistance = (1000.0)
//#define RADIAN(x) ((x)*M_PI/180.0)
let kNFZQueryScope = (50000)
extension CLLocation {
    class func distanceFrom(_ coordinate: CLLocationCoordinate2D, to anotherCoordinate: CLLocationCoordinate2D) -> Double {
        let location: CLLocation = CLLocation(latitude: coordinate.latitude, longitude: coordinate.longitude)
        let otherLocation: CLLocation = CLLocation(latitude: anotherCoordinate.latitude, longitude: anotherCoordinate.longitude)
        return location.distance(from: otherLocation)
    }
}
//#define UIColorFromRGBA(rgbValue, a) \

class DJIMapView: UIView, MKMapViewDelegate {
    var aircraftAnnotation: DJIAircraftAnnotation?=nil
    var homeAnnotation: DJIWaypointAnnotation?=nil
    var aircraftCoordinate: CLLocationCoordinate2D?=nil
    var homeCoordinate: CLLocationCoordinate2D?=nil
    var lastAircraftLineCoordinate: CLLocationCoordinate2D?=nil
    var isRegionChanging: Bool?=false
    var limitCircle: MKCircle? = nil
    //this is the cirle of limit radius
    var updateFlightZoneQueue: OperationQueue?=nil
    //it's used to update flight zones
    var preMapCenter: CLLocationCoordinate2D?=nil
    var flightLimitZones: [AnyObject]?=nil
    var currentLimitCircles: [AnyObject]?=nil
    var poiCircle: MKCircle?=nil
    var hotPointAnnotation: MKPointAnnotation?=nil
    var flyspaceUpdateCenterCoordinate: CLLocationCoordinate2D?=nil
    var mobileLocation: CLLocation?=nil
    
    weak var _mapView:MKMapView? = nil

    convenience init(mapView:MKMapView?) {
        self.init()
        if (mapView != nil) {
            //initWithFrame:mapView.superview.frame];
            _mapView = mapView
            self.setupDefaults()
        }
    }
    
    /**
     *  Add POI coordinate
     *
     *  @param coordinate of POI
     *  @param radius
     */

    func addPOICoordinate(_ coordinate: CLLocationCoordinate2D, radius: CGFloat) {
        if (poiCircle != nil) {
            _mapView!.remove(poiCircle!)
        }
        if (hotPointAnnotation != nil) {
            _mapView!.removeAnnotation(hotPointAnnotation!)
        }
        else {
            self.hotPointAnnotation = MKPointAnnotation()
        }
        // coordinate = [GISCoordinateConverter gcjFromWGS84:coordinate];
    
        poiCircle = MKCircle.init(center: coordinate,radius:Double(radius))
        
        hotPointAnnotation!.coordinate = coordinate
        _mapView!.add(poiCircle!)
        _mapView!.addAnnotation(hotPointAnnotation!)
        hotPointAnnotation!.title = String(format: "{%0.6f, %0.6f}", coordinate.latitude, coordinate.longitude)
    }
    /**
     *  Update aircraft location and heading.
     *
     *  @param coordinate Aircraft location
     *  @param heading    Aircraft heading
     */

    func updateAircraftLocation(_ coordinate: CLLocationCoordinate2D, withHeading heading: Double) {
        // coordinate = [GISCoordinateConverter gcjFromWGS84:coordinate];
        if CLLocationCoordinate2DIsValid(coordinate) {
            if aircraftAnnotation == nil {
                aircraftAnnotation = DJIAircraftAnnotation(coordinate: coordinate, heading: heading)
                _mapView!.addAnnotation(aircraftAnnotation!)
                let viewRegion: MKCoordinateRegion = MKCoordinateRegionMakeWithDistance(coordinate, 500, 500)
                let adjustedRegion: MKCoordinateRegion = _mapView!.regionThatFits(viewRegion)
                _mapView!.setRegion(adjustedRegion, animated: true)
            }
            else {
                aircraftAnnotation!.setCoordinate(coordinate, animation:true)
                var annotationView: DJIAircraftAnnotationView? = nil
                annotationView = _mapView!.view(for: aircraftAnnotation!) as? DJIAircraftAnnotationView
                if (annotationView != nil) {
                    annotationView!.updateHeading(heading)
                }
            }
        }
    }

    func updateHomeLocation(_ homecoordinate: CLLocationCoordinate2D) {
        if CLLocationCoordinate2DIsValid(homecoordinate) {
            _mapView!.showsUserLocation = false
            if (homeAnnotation == nil) {
                homeAnnotation = DJIWaypointAnnotation(coordinate: homecoordinate)
                homeAnnotation!.text = "H"
                _mapView!.addAnnotation(homeAnnotation!)
                self.updateLimitFlyZoneWithCoordinate(homecoordinate)
            }
            else {
                let currentCoordinate: CLLocationCoordinate2D = homeAnnotation!.coordinate
                if fabs(currentCoordinate.latitude - homecoordinate.latitude) > 1e-7 || fabs(currentCoordinate.longitude - homecoordinate.longitude) > 1e-7 {
                    homeAnnotation!.coordinate = homecoordinate
                    _mapView!.addAnnotation(homeAnnotation!)
                    self.updateLimitFlyZoneWithCoordinate(homecoordinate)
                }
            }
        }
    }
    /**
     *  Update the no fly zone with the given coordinate
     **/

    func updateLimitFlyZoneWithCoordinate(_ flyspaceUpdateCenterCoordinate: CLLocationCoordinate2D) {
    }

    func forceRefreshLimitSpaces() {
    }

    func addFlightLimitSpaces(_ spaces: [AnyObject]) {
    }

    func setMapType(_ mapType: MKMapType) {
    }

    convenience required init(coder aDecoder: NSCoder) {
        self.init(coder: aDecoder)
        // Initialization code
            self.setupDefaults()
    }


    /**
     *  Set the delegate for the mapView and initial the NFZ releated objects.
     */

    func setupDefaults() {
        self.flyspaceUpdateCenterCoordinate = kCLLocationCoordinate2DInvalid
        _mapView!.delegate = self
        self.updateFlightZoneQueue = OperationQueue()
        self.updateFlightZoneQueue!.maxConcurrentOperationCount = 1
        self.flightLimitZones = [AnyObject]()
    }
 
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        // Hotpoint
        if (annotation is MKUserLocation) {
            return nil
        }
        else if (annotation.isEqual(hotPointAnnotation)) {
            var annotationView: DJIPOIAnnotationView? = _mapView!.dequeueReusableAnnotationView(withIdentifier: "HotPointAnnotation") as? DJIPOIAnnotationView
            if (annotationView == nil) {
                annotationView = DJIPOIAnnotationView(annotation: annotation, reuseIdentifier: "HotPointAnnotation")
                annotationView!.isDraggable = false
            }
            else {
                annotationView!.annotation = annotation
            }
            return annotationView
        }
        else if (annotation is DJIAircraftAnnotation) {
            let aircraftReuseIdentifier: String = "DJI_AIRCRAFT_ANNOTATION_VIEW"
            var aircraftAnno: DJIAircraftAnnotationView? = _mapView!.dequeueReusableAnnotationView(withIdentifier: aircraftReuseIdentifier) as? DJIAircraftAnnotationView
            if aircraftAnno == nil {
                aircraftAnno = DJIAircraftAnnotationView(annotation: annotation, reuseIdentifier: aircraftReuseIdentifier)
            }
            return aircraftAnno
        }
        else if (annotation is DJIWaypointAnnotation) {
            let waypointReuseIdentifier: String = "DJI_WAYPOINT_ANNOTATION_VIEW"
            let homepointReuseIdentifier: String = "DJI_HOME_POINT_ANNOTATION_VIEW"
            var reuseIdentifier: String = waypointReuseIdentifier
            if annotation.isEqual(homeAnnotation) {
                reuseIdentifier = homepointReuseIdentifier
            }
            let wpAnnotation: DJIWaypointAnnotation = annotation as! DJIWaypointAnnotation
            var annoView: DJIWaypointAnnotationView? = _mapView!.dequeueReusableAnnotationView(withIdentifier: reuseIdentifier) as? DJIWaypointAnnotationView
            if annoView == nil {
                annoView = DJIWaypointAnnotationView(annotation: annotation, reuseIdentifier: reuseIdentifier)
            }
            if annotation.isEqual(homeAnnotation) {
                annoView!.titleLabel!.text = "H"
            }
            else {
                annoView!.titleLabel!.text = wpAnnotation.text!
            }
            return annoView
        }

        return nil
    }

}
