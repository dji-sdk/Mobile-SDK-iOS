//
//  DJIWaypointAnnotationView.swift
//  DJISDKSwiftDemo
//
//  Created by DJI on 15/7/2.
//  Copyright (c) 2015 DJI. All rights reserved.
//
import MapKit
class DJIWaypointAnnotationView: MKAnnotationView {
    var titleLabel: UILabel?=nil

     override init(annotation: MKAnnotation?, reuseIdentifier: String?){
        
        super.init(annotation: annotation, reuseIdentifier: reuseIdentifier)
        
        let wpImage: UIImage = UIImage(named: "waypoint.png")!
        let imgView: UIImageView = UIImageView(image: wpImage)
        var newFrame: CGRect = self.frame
        newFrame.size.width = wpImage.size.width
        newFrame.size.height = wpImage.size.height * 2
        self.frame = newFrame
        var lblFrame: CGRect = imgView.frame
        lblFrame.size.width = wpImage.size.width
        lblFrame.size.height = wpImage.size.height * 0.7
        titleLabel = UILabel(frame: lblFrame)
        titleLabel!.font = UIFont.boldSystemFontOfSize(13)
        titleLabel!.textAlignment = .Center
        imgView.addSubview(self.titleLabel!)
    
        self.enabled = false
        self.draggable = false
        self.addSubview(imgView)
    }

    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)!
    }
    
    required override init(frame: CGRect) {
        super.init(frame: frame)
    }
    
}
//
//  DJIWaypointAnnotationView.m
//  DJISDKSwiftDemo
//
//  Created by DJI on 15/7/2.
//  Copyright (c) 2015 DJI. All rights reserved.
//