//
//  AppDelegate.swift
//  DJISDKSwiftDemo
//
//  Created by Dhanush Balachandran on 11/13/15.
//  Copyright © 2015 DJI. All rights reserved.
//

import UIKit
import DJISDK

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?
    
    let remoteLoggerServerURL = "http://192.168.1.132:4567"

    func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {

        DJISDKManager.enableRemoteLoggingWithDeviceID("DJISampleAppDevice1", logServerURLString: remoteLoggerServerURL)
        DJIRemoteLogger.setCurrentLogLevel(.Verbose)
        
        customizeApperance()
        
        return true
    }
    
    func customizeApperance()
    {
        UINavigationBar.appearance().barTintColor = UIColor.DJIBrandColor()
        UINavigationBar.appearance().tintColor = UIColor.whiteColor()
        UINavigationBar.appearance().titleTextAttributes =  [NSForegroundColorAttributeName: UIColor.whiteColor()]
        UIApplication.sharedApplication().setStatusBarStyle(.LightContent, animated: false)
    }
}
