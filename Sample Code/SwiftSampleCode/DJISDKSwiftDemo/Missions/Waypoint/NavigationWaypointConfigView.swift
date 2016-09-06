//
//  NavigationWaypointConfigView.swift
//  DJISDKSwiftDemo
//
//  Created by DJI on 15/8/4.
//  Copyright (c) 2015 DJI. All rights reserved.
//
import UIKit
import DJISDK
protocol NavigationWaypointConfigViewDelegate: NSObjectProtocol {
    func configViewDidDeleteWaypointAtIndex(index: Int)

    func configViewDidDeleteAllWaypoints()
}
class NavigationWaypointConfigView: UIView, UITextFieldDelegate {
    
    weak var delegate: NavigationWaypointConfigViewDelegate?=nil
    @IBOutlet var waypointTableView: UITableView!
    @IBOutlet var actionTableView: UITableView!
    @IBOutlet var altitudeTextField: UITextField!
    @IBOutlet var headingTextField: UITextField!
    @IBOutlet var repeatTimeTextField: UITextField!
    @IBOutlet var turnModeSwitch: UISwitch!
    @IBOutlet var okButton: UIButton!
    var actionView: NavigationWaypointActionView?=nil
    var _waypointList:[AnyObject]=[]
    var waypointList: [AnyObject] {
        get {
            return _waypointList
        }
        set(waypointList) {
            _waypointList = waypointList
            self.waypointTableView.reloadData()
        }
    }

    var _selectedWaypoint:DJIWaypoint? = nil
    var selectedWaypoint: DJIWaypoint? {
        get {
            return _selectedWaypoint
        }
        set (selectedWaypoint) {
            _selectedWaypoint = selectedWaypoint
            self.actionTableView.reloadData()
        }
    }

    var selectedAction: DJIWaypointAction? = nil

    @IBAction func onAddActionButtonClicked(sender: AnyObject) {
        if (self.selectedWaypoint != nil) {
            if self.selectedWaypoint!.waypointActions.count > Int(DJIMaxActionCount) {
                 self.showAlertResult("Action already reached maximum")
            }
            else {
                if self.actionView == nil {
                    self.actionView = NavigationWaypointActionView()
                    self.actionView!.okButton.addTarget(self, action: #selector(NavigationWaypointConfigView.onActionViewOkButtonClicked(_:)), forControlEvents: .TouchUpInside)
                    self.actionView!.alpha = 0
                    var frame = self.actionView!.frame
                    frame.size.width = (self.superview?.frame.width)!
                    self.actionView!.frame = frame
                    
                    frame = self.actionView!.actionTypeScrollView.frame
                    frame.size.width = (self.actionView?.frame.width)! - frame.origin.x * 2
                    self.actionView?.actionTypeScrollView.frame = frame
                    self.actionView!.actionTypeScrollView.contentSize = (self.actionView?.actionType.frame.size)!
                    self.superview!.addSubview(self.actionView!)
                    self.actionView!.center = self.superview!.center
                }
                UIView.animateWithDuration(0.25, animations: {() -> Void in
                    self.actionView!.alpha = 1.0
                })
            }
        }
        else {
            self.showAlertResult("Please select a waypoint first!")
        }
    }

    @IBAction func onDelActionButtonClicked(sender: AnyObject) {
        if self.selectedWaypoint != nil && self.selectedAction != nil {
            self.selectedWaypoint!.removeAction(self.selectedAction!)
            self.actionTableView.reloadData()
        }
    }

    @IBAction func onDelAllWaypointButtonClicked(sender: AnyObject) {
        
        self.waypointList.removeAll()
        
        if (self.delegate != nil) {
            self.delegate!.configViewDidDeleteAllWaypoints()
        }
        self.selectedWaypoint = nil
        self.selectedAction = nil
        self.waypointTableView.reloadData()
        self.actionTableView.reloadData()
    }

    @IBAction func onTurnModeSwitchValueChanged(sender: AnyObject) {
        self.updateWaypoint()
    }
    
    init(){
        super.init(frame: CGRectZero)
        self.initWithNib()
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func initWithNib() -> NavigationWaypointConfigView {
        var objs: [AnyObject] = NSBundle.mainBundle().loadNibNamed("NavigationWaypointConfigView", owner: self, options: nil)
        let mainView: UIView = objs[0] as! UIView
        self.frame = mainView.bounds
        mainView.layer.cornerRadius = 5.0
            mainView.layer.masksToBounds = true
            self.addSubview(mainView)
            self.waypointTableView.registerClass(UITableViewCell.self, forCellReuseIdentifier: "WAYPOINT_REUSE_IDENTIFY")
            self.waypointTableView.reloadData()
        
        return self
    }

    func onActionViewOkButtonClicked(sender: AnyObject) {
        self.actionView!.center = self.center
        UIView.animateWithDuration(0.25, animations: {() -> Void in
            self.actionView!.alpha = 0.0
        }, completion: {(finished: Bool) -> Void in
            if finished {
                if (self.selectedWaypoint != nil) {
                    let actionType:DJIWaypointActionType = DJIWaypointActionType(rawValue: UInt(self.actionView!.actionType.selectedSegmentIndex))!
                    let actionParam: Int16 = Int16((self.actionView!.actionParam.text! as NSString).intValue)
                    let wpAction:DJIWaypointAction = DJIWaypointAction(actionType: actionType, param: actionParam)
                    self.selectedWaypoint!.addAction(wpAction)
                    self.actionTableView.reloadData()
                }
            }
        })
    }

    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if tableView == self.waypointTableView {
            return self.waypointList.count
        }
        else {
            if self.selectedWaypoint != nil {
                return self.selectedWaypoint!.waypointActions.count
            }
            return 0
        }
    }

    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let waypointReuseIdentifier: String = "waypointReuseIdentifier"
        let actionReusedIdentifier: String = "actionReusedIdentifier"
        var cell: UITableViewCell? = nil
        if tableView == self.waypointTableView {
            cell = tableView.dequeueReusableCellWithIdentifier(waypointReuseIdentifier)
            if cell == nil {
                cell = UITableViewCell(style: .Subtitle, reuseIdentifier: waypointReuseIdentifier)
            }
            let wp: DJIWaypoint = self.waypointList[indexPath.row] as! DJIWaypoint
            cell!.textLabel!.text = "Waypoint \(Int(indexPath.row + 1))"
            cell!.textLabel!.font = UIFont.systemFontOfSize(12)
            cell!.detailTextLabel!.text = "{\(wp.coordinate.latitude), \(wp.coordinate.longitude)}"
            cell!.detailTextLabel!.font = UIFont.systemFontOfSize(8)
        }
        else {
            cell = tableView.dequeueReusableCellWithIdentifier(actionReusedIdentifier)
            if cell == nil {
                cell = UITableViewCell(style: .Subtitle, reuseIdentifier: actionReusedIdentifier)
            }
            cell!.textLabel!.font = UIFont.systemFontOfSize(12)
            cell!.detailTextLabel!.font = UIFont.systemFontOfSize(8)
            let action: DJIWaypointAction = self.selectedWaypoint!.waypointActions[indexPath.row] as! DJIWaypointAction
            cell!.textLabel!.text = "Action \(Int(indexPath.row + 1))"
            if action.actionType == DJIWaypointActionType.Stay {
                cell!.detailTextLabel!.text = String(format: "Stay")
            }
            else if action.actionType == DJIWaypointActionType.ShootPhoto {
                cell!.detailTextLabel!.text = String(format: "Take Photo")
            }
            else if action.actionType == DJIWaypointActionType.StartRecord {
                cell!.detailTextLabel!.text = String(format: "Start Record")
            }
            else if action.actionType == DJIWaypointActionType.StopRecord {
                cell!.detailTextLabel!.text = String(format: "Stop Record")
            }
            else if action.actionType == DJIWaypointActionType.RotateAircraft {
                cell!.detailTextLabel!.text = String(format: "Rotate Aircraft")
            }
            else if action.actionType == DJIWaypointActionType.RotateGimbalPitch {
                cell!.detailTextLabel!.text = String(format: "Rotate Gimbal Pitch")
            }
        }
        return cell!
    }

    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        if tableView == self.waypointTableView {
            self.selectedWaypoint = self.waypointList[indexPath.row] as? DJIWaypoint
            self.updateValue()
        }
        else {
            if (self.selectedWaypoint != nil) {
                self.selectedAction = self.selectedWaypoint!.waypointActions[indexPath.row] as? DJIWaypointAction
            }
        }
    }

    func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        return true
    }

    func tableView(tableView: UITableView, editingStyleForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCellEditingStyle {
        return .Delete
    }

    func tableView(tableView: UITableView, titleForDeleteConfirmationButtonForRowAtIndexPath indexPath: NSIndexPath) -> String {
        return "Delete"
    }

    func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        if editingStyle == .Delete {
            if (self.delegate != nil) {
                self.delegate!.configViewDidDeleteWaypointAtIndex(Int(indexPath.row))
            }
            self.waypointList.removeAtIndex(indexPath.row)
            self.selectedWaypoint = nil
            self.selectedAction = nil
            self.waypointTableView.reloadData()
            self.updateValue()
        }
    }

    func updateValue() {
        if (self.selectedWaypoint != nil) {
            self.altitudeTextField.text = String(format: "%0.1f", self.selectedWaypoint!.altitude)
            self.headingTextField.text = String(format: "%0.1f", self.selectedWaypoint!.heading)
            self.repeatTimeTextField.text = "\(Int(self.selectedWaypoint!.actionRepeatTimes))"
            self.turnModeSwitch.on = (self.selectedWaypoint!.turnMode == DJIWaypointTurnMode.Clockwise)
        }
        else {
            self.altitudeTextField.text = ""
            self.headingTextField.text = ""
            self.repeatTimeTextField.text = ""
            self.turnModeSwitch.on = false
        }
    }

    func updateWaypoint() {
        if (self.selectedWaypoint != nil) {
            self.selectedWaypoint!.altitude = CFloat(self.altitudeTextField.text!)!
            self.selectedWaypoint!.heading = CFloat(self.headingTextField.text!)!
            self.selectedWaypoint!.actionRepeatTimes = UInt((self.repeatTimeTextField.text! as NSString).intValue)
            if (self.turnModeSwitch!.on) {
               self.selectedWaypoint!.turnMode =  DJIWaypointTurnMode.Clockwise
            } else {
                self.selectedWaypoint!.turnMode = DJIWaypointTurnMode.CounterClockwise
            }
        }
    }

    func textFieldShouldReturn(textField: UITextField) -> Bool {
        if textField.isFirstResponder() {
            textField.resignFirstResponder()
        }
        self.updateWaypoint()
        return true
    }
    
    func textFieldShouldEndEditing(textField: UITextField) -> Bool {
        if textField.isFirstResponder() {
            textField.resignFirstResponder()
        }
        self.updateWaypoint()
        return true
    }
    
    func showAlertResult(info:String) {
        let alert = UIAlertView()
        alert.title = "Alert"
        alert.message = info
        alert.addButtonWithTitle("OK")
        alert.show()
    }
}
