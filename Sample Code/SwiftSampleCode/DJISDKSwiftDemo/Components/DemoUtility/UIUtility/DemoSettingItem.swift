//
//  DemoSettingItem.h
//  DJISdkDemo
//
//  Created by DJI on 12/17/15.
//  Copyright © 2015 DJI. All rights reserved.
//
import Foundation
import UIKit

struct DemoSettingItem {
    var itemName: String = ""
    var viewControllerClass:UIViewController.Type? = nil
    
    init(name: String, andClass viewControllerClass: UIViewController.Type?) {
        self.itemName = name
        self.viewControllerClass = viewControllerClass
    }
}