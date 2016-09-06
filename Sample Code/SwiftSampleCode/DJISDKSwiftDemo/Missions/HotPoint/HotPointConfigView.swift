//
//  HotPointConfigView.swift
//  DJISDKSwiftDemo
//
//  Created by DJI on 15/6/3.
//  Copyright (c) 2015 DJI. All rights reserved.
//
import UIKit
import DJISDK
protocol HotPointConfigViewDelegate: UITextFieldDelegate {
    func configViewWillDisappear()
}
class HotPointConfigView: UIView {
    
    @IBOutlet weak var altitudeInputBox: UITextField!
    @IBOutlet weak var radiusInputBox: UITextField!
    @IBOutlet weak var speedInputBox: UITextField!
    @IBOutlet weak var headingControl: UISegmentedControl!
    @IBOutlet weak var entryControl: UISegmentedControl!
    @IBOutlet weak var clockwiseSwitch: UISwitch!
    
    weak var delegate: HotPointConfigViewDelegate? = nil

    
    var startPoint:DJIHotPointStartPoint {
        get {
            return DJIHotPointStartPoint(rawValue: UInt(self.entryControl.selectedSegmentIndex))!
        }
        
        set(startPoint) {
            self.entryControl.selectedSegmentIndex = Int(startPoint.rawValue)
        }
    
    }//=
    var heading:DJIHotPointHeading {
        get {
            return DJIHotPointHeading(rawValue: UInt(self.headingControl.selectedSegmentIndex))!
        }
        
        set(heading) {
            self.headingControl.selectedSegmentIndex = Int(heading.rawValue)
        }
    
    } //=
    
    var altitude: CGFloat {
        get {
            return CGFloat((self.altitudeInputBox.text! as NSString).floatValue)
        }
        set (altitude) {
            self.altitudeInputBox.text = String(format: "%0.1f", altitude)
        }
    }

    var radius: CGFloat {
        get {
            return  CGFloat((self.radiusInputBox.text! as NSString).floatValue)
        }
        
        set(radius) {
            self.radiusInputBox.text = String(format: "%0.1f", radius)
        }
    }

    var speed: Int {
        get {
            return Int((self.speedInputBox.text! as NSString).intValue)
        }
        
        set(speed) {
            self.speedInputBox.text = "\(speed)"
        }
    }

    var clockwise: Bool {
        get {
            return self.clockwiseSwitch.on
        }
        
        set (clockwise) {
            self.clockwiseSwitch.on = clockwise
        }
    }

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

    func initWithNib() -> HotPointConfigView {
        let mainView: UIView = NSBundle.mainBundle().loadNibNamed("HotPointConfigView", owner: self, options: nil)[0] as! UIView
        self.frame = mainView.bounds
        self.addSubview(mainView)
        self.altitude = 50.0
        self.radius = 20.0
        self.speed = 20
        self.clockwise = true
        self.startPoint = DJIHotPointStartPoint.North
        self.heading = DJIHotPointHeading.AlongCircleLookingForward
        return self
    }


    @IBAction func onOkButtonClicked(sender: AnyObject) {
      
        self.delegate?.configViewWillDisappear()
        UIView.animateWithDuration(0.2, animations: {() -> Void in
            self.alpha = 0.0
        })
    }

    func textFieldShouldReturn(textField: UITextField) -> Bool {
        if self.altitudeInputBox.isFirstResponder() {
            self.altitudeInputBox.resignFirstResponder()
        }
        if self.radiusInputBox.isFirstResponder() {
            self.radiusInputBox.resignFirstResponder()
        }
        if self.speedInputBox.isFirstResponder() {
            self.speedInputBox.resignFirstResponder()
        }
        return true
    }

}
