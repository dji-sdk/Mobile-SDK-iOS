//
//  DJIAircraftAnnotationView.h
//  DJISdkDemo
//
//  Created by DJI on 15/4/27.
//  Copyright (c) 2015 DJI. All rights reserved.
//
import MapKit
class DJIAircraftAnnotationView: MKAnnotationView {
    override init(annotation: MKAnnotation?, reuseIdentifier: String?){
        super.init(annotation: annotation, reuseIdentifier: reuseIdentifier)
        self.enabled = false
        self.draggable = false
        self.image = UIImage(named: "aircraft.png")
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    required override init(frame: CGRect) {
        super.init(frame: frame);
    }
    func updateHeading(heading: Double) {
        self.transform = CGAffineTransformIdentity
        self.transform = CGAffineTransformMakeRotation(CGFloat(heading))
    }
}
