//
//  Extensions.swift
//  DJISDKSwiftDemo
//
//  Created by DJI on 8/24/15.
//  Copyright © 2015 DJI. All rights reserved.
//

import Foundation
import UIKit

extension UIColor {
    public convenience init(rgba: String) {
        var red:   CGFloat = 0.0
        var green: CGFloat = 0.0
        var blue:  CGFloat = 0.0
        var alpha: CGFloat = 1.0
        
        if rgba.hasPrefix("#") {
            let index   = rgba.startIndex.advancedBy(1)
            let hex     = rgba.substringFromIndex(index)
            let scanner = NSScanner(string: hex)
            var hexValue: CUnsignedLongLong = 0
            if scanner.scanHexLongLong(&hexValue) {
                switch hex.characters.count {
                case 3:
                    red   = CGFloat((hexValue & 0xF00) >> 8)       / 15.0
                    green = CGFloat((hexValue & 0x0F0) >> 4)       / 15.0
                    blue  = CGFloat(hexValue & 0x00F)              / 15.0
                case 4:
                    red   = CGFloat((hexValue & 0xF000) >> 12)     / 15.0
                    green = CGFloat((hexValue & 0x0F00) >> 8)      / 15.0
                    blue  = CGFloat((hexValue & 0x00F0) >> 4)      / 15.0
                    alpha = CGFloat(hexValue & 0x000F)             / 15.0
                case 6:
                    red   = CGFloat((hexValue & 0xFF0000) >> 16)   / 255.0
                    green = CGFloat((hexValue & 0x00FF00) >> 8)    / 255.0
                    blue  = CGFloat(hexValue & 0x0000FF)           / 255.0
                case 8:
                    red   = CGFloat((hexValue & 0xFF000000) >> 24) / 255.0
                    green = CGFloat((hexValue & 0x00FF0000) >> 16) / 255.0
                    blue  = CGFloat((hexValue & 0x0000FF00) >> 8)  / 255.0
                    alpha = CGFloat(hexValue & 0x000000FF)         / 255.0
                default:
                    print("Invalid RGB string, number of characters after '#' should be either 3, 4, 6 or 8")
                }
            } else {
                print("Scan hex error")
            }
        } else {
            print("Invalid RGB string, missing '#' as prefix")
        }
        self.init(red:red, green:green, blue:blue, alpha:alpha)
    }
    
    class func DJIBrandColor() -> UIColor
    {
        return UIColor(rgba: "#2A3B55")
    }
}

func delay(secs : NSTimeInterval, block: ()->())
{
    let delayTime = dispatch_time(DISPATCH_TIME_NOW,
        Int64(secs * Double(NSEC_PER_SEC)))
    dispatch_after(delayTime, dispatch_get_main_queue()) {
        block()
    }
}

class blockRepeater : NSObject {
    let localQueue = dispatch_queue_create("repeaterQueue\(srand(1000))", DISPATCH_QUEUE_SERIAL)
    var repetitions : Int?
    var delay : NSTimeInterval
    var performQueue : dispatch_queue_t?
    var performBlock : ()->()
    var isCancelled = false
    
    init(repetitions : Int?, delay : NSTimeInterval, queue : dispatch_queue_t?, block: ()->())
    {
        self.repetitions = repetitions
        self.delay = delay
        self.performQueue = queue
        self.performBlock = block
        super.init()
    }
    
    func repeatBlock()
    {
        dispatch_async(localQueue) { [weak self] in
            func checkReps() -> Bool
            {
                if let localReps = self?.repetitions
                {
                    if localReps > 0
                    {
                        self?.repetitions = localReps - 1
                        return true
                    }
                    else
                    {
                        return false
                    }
                }
                return true
            }
            
            while (self?.isCancelled == false && checkReps())
            {
                if let localSelf = self
                {
                    dispatch_async(localSelf.performQueue ?? dispatch_get_main_queue(), localSelf.performBlock)
                    NSThread.sleepForTimeInterval(localSelf.delay)
                }
            }
        }
    }
    
    func cancelRepetition()
    {
        isCancelled = true
    }
}

func appDelegate() -> AppDelegate
{
    return UIApplication.sharedApplication().delegate as! AppDelegate
}