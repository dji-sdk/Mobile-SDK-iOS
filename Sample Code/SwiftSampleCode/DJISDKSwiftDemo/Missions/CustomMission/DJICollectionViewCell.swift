//
//  DJICollectionViewCell.swift
//  DJISDKSwiftDemo
//
//  Created by DJI on 15/12/18.
//  Copyright © 2015 DJI. All rights reserved.
//
import UIKit

enum DJICollectionViewCellType : Int {
    case takeoff
    case gohome
    case goto
    case gimbalAttitude
    case singleShootPhoto
    case continousShootPhoto
    case recordVideoDruation
    case recordVideoStart
    case recordVideoStop
    case waypointMission
    case hotpointMission
    case followmeMission
    
    static let allValues = [takeoff, gohome, goto, gimbalAttitude, singleShootPhoto, continousShootPhoto,
        recordVideoDruation, recordVideoStart, recordVideoStop, waypointMission, hotpointMission, followmeMission]
}

class DJICollectionViewCell: UICollectionViewCell {
    @IBOutlet weak var titleLabel: UILabel!
    var indicatorView: UIActivityIndicatorView?
    var attachedObject: NSObject? = nil
    var isShow: Bool? = false
    var _cellType:DJICollectionViewCellType? = .takeoff
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
        var objs: [AnyObject] = Bundle.main.loadNibNamed("DJICollectionViewCell", owner: self, options: nil) as! [AnyObject]
        if (objs.count > 0) {
            let mainView: UIView = objs[0] as! UIView
            return mainView as? DJICollectionViewCell
        }
        return nil
    }

    



    func showProgress(_ show: Bool) {
        if isShow == show {
            return
        }
        self.isShow = show
        if show {
            self.indicatorView = UIActivityIndicatorView(activityIndicatorStyle: .gray)
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

    func setBorderColor(_ color: UIColor) {
        self.layer.borderColor = color.cgColor
        self.setNeedsDisplay()
    }

    override func awakeFromNib() {
        // Initialization code
        self.layer.cornerRadius = 25
        self.layer.masksToBounds = true
        self.layer.borderWidth = 1.4
        self.layer.borderColor = UIColor.red.cgColor
        let title: String? = self.titleForCellType(cellType)
        self.titleLabel.text = title
    }

    func titleForCellType(_ type: DJICollectionViewCellType) -> String? {
        switch type {
            case .takeoff:
                                return "Takeoff"

            case .gohome:
                                return "GoHome"

            case .goto:
                                return "GoTo"

            case .gimbalAttitude:
                                return "G-Atti"

            case .singleShootPhoto:
                                return "Shoot1"

            case .continousShootPhoto:
                                return "ShootN"

            case .recordVideoDruation:
                                return "REC."

            case .recordVideoStart:
                                return "REC.S"

            case .recordVideoStop:
                                return "REC.E"

            case .waypointMission:
                                return "WP"

            case .hotpointMission:
                                return "HP"

            case .followmeMission:
                                return "FM"

        }
    }

    override func setValue(_ value: Any?, forUndefinedKey key: String) {
        super.setValue(value, forUndefinedKey: key)
    }
    
}
