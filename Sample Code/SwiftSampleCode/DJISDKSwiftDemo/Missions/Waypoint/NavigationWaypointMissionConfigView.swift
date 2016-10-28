//
//  NavigationWaypointMissionConfigView.swift
//  DJISDKSwiftDemo
//
//  Created by DJI on 15/8/4.
//  Copyright (c) 2015 DJI. All rights reserved.
//
import UIKit
class NavigationWaypointMissionConfigView: UIView, UITextFieldDelegate {
    @IBOutlet var autoFlightSpeed: UITextField!
    @IBOutlet var maxFlightSpeed: UITextField!
    @IBOutlet var finishedAction: UISegmentedControl!
    @IBOutlet var headingMode: UISegmentedControl!
    @IBOutlet var airlineMode: UISegmentedControl!
    @IBOutlet var okButton: UIButton!
    @IBOutlet var finishActionScroll:UIScrollView!
    @IBOutlet var finishActionSeg:UISegmentedControl!

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    func initWithNib() -> NavigationWaypointMissionConfigView {
     
        var objs: [AnyObject] = Bundle.main.loadNibNamed("NavigationWaypointMissionConfigView", owner: self, options: nil) as! [AnyObject]
        let mainView: UIView = objs[0] as! UIView
        self.frame = mainView.bounds
        mainView.layer.cornerRadius = 5.0
            mainView.layer.masksToBounds = true
            self.addSubview(mainView)
        
       return self
    }

    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if textField.isFirstResponder {
            textField.resignFirstResponder()
        }
        return true
    }
}
