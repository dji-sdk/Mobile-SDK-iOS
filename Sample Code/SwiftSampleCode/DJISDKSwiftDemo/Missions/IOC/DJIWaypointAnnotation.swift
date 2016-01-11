//
//  DJIWaypointAnnotation.h
//  DJISdkDemo
//
//  Created by DJI on 15/7/2.
//  Copyright (c) 2015 DJI. All rights reserved.
//
import MapKit
class DJIWaypointAnnotation: NSObject, MKAnnotation {
    var text: String?=nil
    var _coordinate:CLLocationCoordinate2D?=nil
    var coordinate: CLLocationCoordinate2D {
        get {
            return _coordinate!
        }
        set(newCoordinate) {
            _coordinate = newCoordinate
        }
    }

    

    convenience init(coordinate: CLLocationCoordinate2D) {
        self.init()
        _coordinate = coordinate
    }
    
}
