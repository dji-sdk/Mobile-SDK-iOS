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
    var imgStickNormal: UIImage? = nil
    var imgStickHold: UIImage? = nil
    var mCenter: CGPoint = CGPointZero
    var mUpdateTimer: NSTimer? = nil
    var mTouchPoint: CGPoint = CGPointZero


    func initStick() {
        imgStickNormal = UIImage(named: "stick_normal.png")!
        imgStickHold = UIImage(named: "stick_hold.png")!
        mCenter.x = 64
        mCenter.y = 64
    }

    override init(frame: CGRect) {
        super.init(frame: frame)
        self.initStick()
    }

    func onPanGesture(sender: AnyObject) {
    }

    required init(coder: NSCoder) {
        super.init(coder: coder)!
        self.initStick()
    }

    func notifyDir(dir: CGPoint) {
        let vdir = NSValue(CGPoint: dir)
        let userInfo = [ "dir" : vdir ]
        let notificationCenter: NSNotificationCenter = NSNotificationCenter.defaultCenter()
        notificationCenter.postNotificationName("StickChanged", object: self, userInfo: userInfo)
    }

    func stickMoveTo(deltaToCenter: CGPoint) {
        var fr = stickView.frame
        fr.origin.x = deltaToCenter.x
        fr.origin.y = deltaToCenter.y
        stickView.frame = fr
    }

    func touchEvent(touches: Set<UITouch>) {
        guard touches.count == 1 else { return }
        let touch = touches.first!
        let view = touch.view!
        guard view == self else { return }
        let touchPoint = touch.locationInView(view)
        var dtarget = CGPointZero
        var dir = CGPointZero
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

    override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
        stickView.image = imgStickHold
        guard touches.count == 1 else { return }
        let touch = touches.first!
        let view = touch.view!
        guard view == self else { return }
        mTouchPoint = touch.locationInView(view)
        self.startUpdateTimer()
        //    [self touchEvent:touches];
    }

    override func touchesMoved(touches: Set<UITouch>, withEvent event: UIEvent?) {
        guard touches.count == 1 else { return }
        let touch = touches.first!
        let view = touch.view!
        guard view == self else { return }
        mTouchPoint = touch.locationInView(view)
    }

    override func touchesEnded(touches: Set<UITouch>, withEvent event: UIEvent?) {
        stickView.image = imgStickNormal!
        let dtarget = CGPointZero
        let dir = CGPointZero
        self.stickMoveTo(dtarget)
        self.notifyDir(dir)
        self.stopUpdateTimer()
    }

    override func touchesCancelled(touches: Set<UITouch>?, withEvent event: UIEvent?) {
        stickView.image = imgStickNormal!
        let dtarget = CGPointZero
        let dir = CGPointZero

        self.stickMoveTo(dtarget)
        self.notifyDir(dir)
        self.stopUpdateTimer()
    }

    func onUpdateTimerTicked(sender: AnyObject) {
        let touchPoint = mTouchPoint
        var dtarget = CGPointZero
        var dir = CGPointZero
        dir.x = touchPoint.x - mCenter.x
        dir.y = touchPoint.y - mCenter.y
        let len = sqrt(Double(dir.x * dir.x + dir.y * dir.y))
        if len > STICK_CENTER_TARGET_POS_LEN {
            let len_inv: Double = 1.0 / len
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
        if let _ = mUpdateTimer {
            mUpdateTimer = NSTimer.scheduledTimerWithTimeInterval(0.05, target: self, selector: #selector(JoyStickView.onUpdateTimerTicked(_:)), userInfo: nil, repeats: true)
            mUpdateTimer!.fire()
        }
    }

    func stopUpdateTimer() {
        if let _ = mUpdateTimer {
            mUpdateTimer!.invalidate()
            mUpdateTimer = nil
        }
    }
}

