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
    
    override init(frame: CGRect) {
        super.init(frame: frame)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }


    func initWithNib() -> NavigationWaypointActionView {
        var objs: [AnyObject] = Bundle.main.loadNibNamed("NavigationWaypointActionView", owner: self, options: nil) as! [AnyObject]
        let mainView:UIView = objs[0] as! UIView
        self.frame = mainView.bounds
        self.okButton.layer.cornerRadius = 4.0
        self.okButton.layer.borderColor = UIColor.blue.cgColor
        self.okButton.layer.borderWidth = 1.2
        mainView.layer.cornerRadius = 5.0
        mainView.layer.masksToBounds = true
        self.backgroundColor = UIColor.lightGray.withAlphaComponent(0.7)
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
