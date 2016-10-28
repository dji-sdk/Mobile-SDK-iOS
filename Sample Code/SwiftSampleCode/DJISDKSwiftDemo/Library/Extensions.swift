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
            let index   = rgba.characters.index(rgba.startIndex, offsetBy: 1)
            let hex     = rgba.substring(from: index)
            let scanner = Scanner(string: hex)
            var hexValue: CUnsignedLongLong = 0
            if scanner.scanHexInt64(&hexValue) {
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

func delay(_ secs : TimeInterval, block: @escaping ()->())
{
    let delayTime = DispatchTime.now() + Double(Int64(secs * Double(NSEC_PER_SEC))) / Double(NSEC_PER_SEC)
    DispatchQueue.main.asyncAfter(deadline: delayTime) {
        block()
    }
}

class blockRepeater : NSObject {
    let localQueue = DispatchQueue(label: "repeaterQueue\(arc4random() % 1000)", attributes: [])
    var repetitions : Int?
    var delay : TimeInterval
    var performQueue : DispatchQueue?
    var performBlock : ()->()
    var isCancelled = false
    
    init(repetitions : Int?, delay : TimeInterval, queue : DispatchQueue?, block: @escaping ()->())
    {
        self.repetitions = repetitions
        self.delay = delay
        self.performQueue = queue
        self.performBlock = block
        super.init()
    }
    
    func repeatBlock()
    {
        localQueue.async { [weak self] in
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
                    (localSelf.performQueue ?? DispatchQueue.main).async(execute: localSelf.performBlock)
                    Thread.sleep(forTimeInterval: localSelf.delay)
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
    return UIApplication.shared.delegate as! AppDelegate
}
