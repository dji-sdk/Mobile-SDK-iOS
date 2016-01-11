//
//  DJIPOIAnnotationView.h
//  Phantom3
//
//  Created by DJI on 15/7/30.
//  Copyright (c) 2015 DJIDevelopers.com. All rights reserved.
//
import MapKit

class DJIPOIAnnotationView: MKAnnotationView {
    var pinView: UIView?=nil

   override init (annotation: MKAnnotation?, reuseIdentifier: String?) {
    
        super.init(annotation: annotation, reuseIdentifier: reuseIdentifier)
        if (pinView == nil) {
            pinView = UIView(frame: CGRectMake(0.0, 0.0, 54.0, 54.0))
            pinView!.backgroundColor = UIColor.clearColor()
            let pinIcon: UIImageView = UIImageView(image: UIImage(named: "navigation_poi_pin"))
            pinView!.addSubview(pinIcon)
            pinIcon.center = CGPointMake(self.pinView!.center.x, self.pinView!.center.y - pinIcon.frame.size.height * 0.5)
        }

        var frame: CGRect = self.frame
        frame.size = pinView!.frame.size
        self.frame = frame
        self.addSubview(pinView!)
        pinView!.layer.zPosition = 101
    }

   required init?(coder aDecoder: NSCoder) {
       super.init(coder: aDecoder)
   }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
    }
}
