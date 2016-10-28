//
//  AppDelegate.swift
//  DJISDKSwiftDemo
//
//  Created by DJI on 11/13/15.
//  Copyright © 2015 DJI. All rights reserved.
//

import UIKit
import DJISDK

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?
    
    let remoteLoggerServerURL = "http://192.168.1.132:4567"

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {

        DJISDKManager.enableRemoteLogging(withDeviceID: "DJISampleAppDevice1", logServerURLString: remoteLoggerServerURL)
        DJIRemoteLogger.setCurrentLogLevel(.verbose)
        
        customizeApperance()
        
        return true
    }
    
    func customizeApperance()
    {
        UINavigationBar.appearance().barTintColor = UIColor.DJIBrandColor()
        UINavigationBar.appearance().tintColor = UIColor.white
        UINavigationBar.appearance().titleTextAttributes =  [NSForegroundColorAttributeName: UIColor.white]
    }
}
