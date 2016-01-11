//
//  DJIAircraftAnnotation.h
//
//  Created by DJI on 14-8-21.
//
import CoreLocation
import CoreGraphics

class DJIAircraftAnnotation: DJIAnnotation {
    var heading:Double?=nil
    var annotationTitle:String?=nil
   
 
    init(coordinate: CLLocationCoordinate2D, heading:Double) {
        self.heading = heading;
        super.init(coordinate: coordinate)
    }
    

    func title() -> String {
        return annotationTitle!
    }
}
