//
//  DJIAnnotation.swift
//  DJISDKSwiftDemo
//
import Foundation
import MapKit
import CoreLocation
class DJIAnnotation: NSObject, MKAnnotation {
    /**
     *  Index of the annotation
     */
    var index: String? = nil
    weak var annotationView: MKAnnotationView? = nil
    var backGroundAnnotation: DJIAnnotation? = nil
    weak var mapView: MKMapView?=nil
    var isBackgroundAnnotation: Bool?

    var _coordinate:CLLocationCoordinate2D
    dynamic var coordinate: CLLocationCoordinate2D{
        get {
            return _coordinate
        }
        set (coordinate){
            _coordinate = coordinate
            if backGroundAnnotation != nil  {
                backGroundAnnotation!.coordinate = coordinate
            }
        }
    }



    init(coordinate: CLLocationCoordinate2D) {
        _coordinate = coordinate
        super.init()
    }

    func createBackgroundAnnotation() {
        let annotation: DJIAnnotation = DJIAnnotation(coordinate:_coordinate)
        annotation.isBackgroundAnnotation = true
        if mapView != nil {
            mapView!.addAnnotation(annotation)
        }
        self.backGroundAnnotation = annotation
    }

    func setCoordinate(coordinate: CLLocationCoordinate2D, animation: Bool) {
        self.coordinate = coordinate
        if backGroundAnnotation != nil {
            backGroundAnnotation!.setCoordinate(coordinate, animation: animation)
        }
    }

    deinit {
        if backGroundAnnotation != nil && mapView != nil {
            if NSThread.isMainThread() {
                mapView!.removeAnnotation(backGroundAnnotation!)
            }
            else {
                dispatch_sync(dispatch_get_main_queue(), {[weak self] () -> Void in
                    self?.mapView!.removeAnnotation(self!.backGroundAnnotation!)
                })
            }
        }
    }

}
