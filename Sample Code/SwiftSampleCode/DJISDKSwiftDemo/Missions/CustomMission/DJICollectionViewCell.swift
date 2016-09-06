//
//  DJICollectionViewCell.swift
//  DJISDKSwiftDemo
//
//  Created by DJI on 15/12/18.
//  Copyright © 2015 DJI. All rights reserved.
//
import UIKit

enum DJICollectionViewCellType : Int {
    case Takeoff
    case Gohome
    case Goto
    case GimbalAttitude
    case SingleShootPhoto
    case ContinousShootPhoto
    case RecordVideoDruation
    case RecordVideoStart
    case RecordVideoStop
    case WaypointMission
    case HotpointMission
    case FollowmeMission
    
    static let allValues = [Takeoff, Gohome, Goto, GimbalAttitude, SingleShootPhoto, ContinousShootPhoto,
        RecordVideoDruation, RecordVideoStart, RecordVideoStop, WaypointMission, HotpointMission, FollowmeMission]
}

class DJICollectionViewCell: UICollectionViewCell {
    @IBOutlet weak var titleLabel: UILabel!
    var indicatorView: UIActivityIndicatorView?
    var attachedObject: NSObject? = nil
    var isShow: Bool? = false
    var _cellType:DJICollectionViewCellType? = .Takeoff
    var cellType: DJICollectionViewCellType{
        get {
            return _cellType!
        }
        set (cellType){
            let title: String? = self.titleForCellType(cellType)
            self.titleLabel.text = title
            _cellType = cellType
        }
    }
    
    class func collectionViewCell() -> DJICollectionViewCell? {
        var objs: [AnyObject] = NSBundle.mainBundle().loadNibNamed("DJICollectionViewCell", owner: self, options: nil)
        if (objs.count > 0) {
            let mainView: UIView = objs[0] as! UIView
            return mainView as? DJICollectionViewCell
        }
        return nil
    }

    



    func showProgress(show: Bool) {
        if isShow == show {
            return
        }
        self.isShow = show
        if show {
            self.indicatorView = UIActivityIndicatorView(activityIndicatorStyle: .Gray)
            self.indicatorView!.center = self.titleLabel.center
            self.indicatorView!.startAnimating()
            self.addSubview(self.indicatorView!)
        }
        else {
            self.indicatorView!.stopAnimating()
            self.indicatorView!.removeFromSuperview()
            self.indicatorView = nil
        }
    }

    func setBorderColor(color: UIColor) {
        self.layer.borderColor = color.CGColor
        self.setNeedsDisplay()
    }

    override func awakeFromNib() {
        // Initialization code
        self.layer.cornerRadius = 25
        self.layer.masksToBounds = true
        self.layer.borderWidth = 1.4
        self.layer.borderColor = UIColor.redColor().CGColor
        let title: String? = self.titleForCellType(cellType)
        self.titleLabel.text = title
    }

    func titleForCellType(type: DJICollectionViewCellType) -> String? {
        switch type {
            case .Takeoff:
                                return "Takeoff"

            case .Gohome:
                                return "GoHome"

            case .Goto:
                                return "GoTo"

            case .GimbalAttitude:
                                return "G-Atti"

            case .SingleShootPhoto:
                                return "Shoot1"

            case .ContinousShootPhoto:
                                return "ShootN"

            case .RecordVideoDruation:
                                return "REC."

            case .RecordVideoStart:
                                return "REC.S"

            case .RecordVideoStop:
                                return "REC.E"

            case .WaypointMission:
                                return "WP"

            case .HotpointMission:
                                return "HP"

            case .FollowmeMission:
                                return "FM"

        }
    }

    override func setValue(value: AnyObject?, forUndefinedKey key: String) {
        super.setValue(value, forUndefinedKey: key)
    }
    
}
