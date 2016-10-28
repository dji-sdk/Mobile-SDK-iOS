//
//  DJIAircraftAnnotationView.swift
//  DJISDKSwiftDemo
//
//  Created by DJI on 15/4/27.
//  Copyright (c) 2015 DJI. All rights reserved.
//
import MapKit
class DJIAircraftAnnotationView: MKAnnotationView {
    override init(annotation: MKAnnotation?, reuseIdentifier: String?){
        super.init(annotation: annotation, reuseIdentifier: reuseIdentifier)
        self.isEnabled = false
        self.isDraggable = false
        self.image = UIImage(named: "aircraft.png")
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func updateHeading(_ heading: Double) {
        self.transform = CGAffineTransform.identity
        self.transform = CGAffineTransform(rotationAngle: CGFloat(heading))
    }
}
