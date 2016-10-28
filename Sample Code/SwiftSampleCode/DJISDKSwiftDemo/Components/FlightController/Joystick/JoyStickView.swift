//
//  JoyStickView.swift
//  DJISDKSwiftDemo
//
//  Created by DJI on 13-4-26.
//  Copyright (c) 2013. All rights reserved.
//
import UIKit


let STICK_CENTER_TARGET_POS_LEN = 20.0

class JoyStickView: UIView {

    @IBOutlet var stickView: UIImageView!
    var imgStickNormal: UIImage?=nil
    var imgStickHold: UIImage?=nil
    var mCenter: CGPoint = CGPoint.zero
    var mUpdateTimer: Timer? = nil
    var mTouchPoint: CGPoint = CGPoint.zero


    func initStick() {
        imgStickNormal = UIImage(named: "stick_normal.png")!
        imgStickHold = UIImage(named: "stick_hold.png")!
        mCenter.x = 64
        mCenter.y = 64
    }

    override init(frame: CGRect) {
        super.init(frame: frame)
        // Initialization code
            self.initStick()
    }

    func onPanGesture(_ sender: AnyObject) {
    }

     required init(coder: NSCoder) {
        super.init(coder: coder)!
        // Initialization code
            self.initStick()
    }

    func notifyDir(_ dir: CGPoint) {
        let vdir: NSValue = NSValue(cgPoint: dir)
        let userInfo: [AnyHashable: Any] = [
            "dir" : vdir
        ]

        let notificationCenter: NotificationCenter = NotificationCenter.default
        notificationCenter.post(name: Notification.Name(rawValue: "StickChanged"), object: self, userInfo: userInfo)
    }

    func stickMoveTo(_ deltaToCenter: CGPoint) {
        var fr: CGRect = stickView.frame
        fr.origin.x = deltaToCenter.x
        fr.origin.y = deltaToCenter.y
        stickView.frame = fr
    }

    func touchEvent(_ touches: Set<UITouch>) {
        if touches.count != 1 {
            return
        }
        let touch: UITouch = touches.first!
        let view: UIView = touch.view!
        if view != self {
            return
        }
        let touchPoint: CGPoint = touch.location(in: view)
        var dtarget: CGPoint = CGPoint.zero
        var dir:CGPoint = CGPoint.zero
        dir.x = touchPoint.x - mCenter.x
        dir.y = touchPoint.y - mCenter.y
        let len: Double = sqrt(Double(dir.x * dir.x + dir.y * dir.y))
        if len < 10.0 && len > -10.0 {
            // center pos
            dtarget.x = 0.0
            dtarget.y = 0.0
            dir.x = 0
            dir.y = 0
        }
        else {
            let len_inv: Double = (1.0 / len)
            dir.x *= CGFloat(len_inv)
            dir.y *= CGFloat(len_inv)
            dtarget.x = dir.x * CGFloat(STICK_CENTER_TARGET_POS_LEN)
            dtarget.y = dir.y * CGFloat(STICK_CENTER_TARGET_POS_LEN)
        }
        self.stickMoveTo(dtarget)
        self.notifyDir(dir)
    }

    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        stickView.image = imgStickHold
        if touches.count != 1 {
            return
        }
        let touch: UITouch = touches.first!
        let view: UIView = touch.view!
        if view != self {
            return
        }
        mTouchPoint = touch.location(in: view)
        self.startUpdateTimer()
        //    [self touchEvent:touches];
    }

    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        if touches.count != 1 {
            return
        }
        let touch: UITouch = touches.first!
        let view: UIView = touch.view!
        if view != self {
            return
        }
        mTouchPoint = touch.location(in: view)
    }

    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        stickView.image = imgStickNormal!
        let dtarget: CGPoint = CGPoint.zero
        let dir: CGPoint = CGPoint.zero
        self.stickMoveTo(dtarget)
        self.notifyDir(dir)
        self.stopUpdateTimer()
    }

    override func touchesCancelled(_ touches: Set<UITouch>?, with event: UIEvent?) {
        stickView.image = imgStickNormal!
        let dtarget: CGPoint = CGPoint.zero
        let dir: CGPoint = CGPoint.zero

        self.stickMoveTo(dtarget)
        self.notifyDir(dir)
        self.stopUpdateTimer()
    }

    func onUpdateTimerTicked(_ sender: AnyObject) {
        let touchPoint: CGPoint = mTouchPoint
        var dtarget:CGPoint=CGPoint.zero
        var dir:CGPoint=CGPoint.zero
        dir.x = touchPoint.x - mCenter.x
        dir.y = touchPoint.y - mCenter.y
        let len: Double = sqrt( Double(dir.x * dir.x + dir.y * dir.y))
        if len > STICK_CENTER_TARGET_POS_LEN {
            let len_inv: Double = (1.0 / len)
            dir.x *= CGFloat(len_inv)
            dir.y *= CGFloat(len_inv)
            dtarget.x = dir.x * CGFloat(STICK_CENTER_TARGET_POS_LEN)
            dtarget.y = dir.y * CGFloat(STICK_CENTER_TARGET_POS_LEN)
        }
        else {
            dtarget.x = dir.x
            dtarget.y = dir.y
        }
        dir.x = dtarget.x / CGFloat(STICK_CENTER_TARGET_POS_LEN)
        dir.y = dtarget.y / CGFloat(STICK_CENTER_TARGET_POS_LEN)
        self.stickMoveTo(dtarget)
        self.notifyDir(dir)
    }

    func startUpdateTimer() {
        if mUpdateTimer == nil {
            mUpdateTimer = Timer.scheduledTimer(timeInterval: 0.05, target: self, selector: #selector(JoyStickView.onUpdateTimerTicked(_:)), userInfo: nil, repeats: true)
            mUpdateTimer!.fire()
        }
    }

    func stopUpdateTimer() {
        if mUpdateTimer != nil {
            mUpdateTimer!.invalidate()
            mUpdateTimer = nil
        }
    }
}

