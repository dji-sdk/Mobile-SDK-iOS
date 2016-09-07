//
//  NavigationWaypointActionView.swift
//  DJISDKSwiftDemo
//
//  Created by DJI on 15/8/4.
//  Copyright (c) 2015 DJI. All rights reserved.
//
import UIKit
class NavigationWaypointActionView: UIView, UITextFieldDelegate {
    @IBOutlet var actionType: UISegmentedControl!
    @IBOutlet var actionParam: UITextField!
    @IBOutlet var okButton: UIButton!
    @IBOutlet var actionTypeScrollView: UIScrollView!
    @IBOutlet var actionTypeSeg: UISegmentedControl!
    init() {
        super.init(frame: CGRectZero)
        self.initWithNib()
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }


    func initWithNib() -> NavigationWaypointActionView {
        var objs: [AnyObject] = NSBundle.mainBundle().loadNibNamed("NavigationWaypointActionView", owner: self, options: nil)
        let mainView:UIView = objs[0] as! UIView
        self.frame = mainView.bounds
        self.okButton.layer.cornerRadius = 4.0
        self.okButton.layer.borderColor = UIColor.blueColor().CGColor
        self.okButton.layer.borderWidth = 1.2
        mainView.layer.cornerRadius = 5.0
        mainView.layer.masksToBounds = true
        self.backgroundColor = UIColor.lightGrayColor().colorWithAlphaComponent(0.7)
        self.addSubview(mainView)
        
        return self
    }

    func textFieldShouldReturn(textField: UITextField) -> Bool {
        if textField.isFirstResponder() {
            textField.resignFirstResponder()
        }
        return true
    }
}
