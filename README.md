# DJI Mobile SDK for iOS

## What Is This?

The DJI Mobile SDK enables you to control how your Phantom’s camera, gimbal, and more behaves and interacts with mobile apps you create.Using the Mobile SDK, create a customized mobile app to unlock the full potential of your DJI aerial platform.

## Running the SDK Sample Code

This guide shows you how to setup APP Key and run our DJI Mobile SDK sample project, which you can download it from this **Github Page**.

### Prerequisites

- Xcode 6.4+ or higher
- Deployment target of 6.0 or higher

### Registering a App Key

Firstly, please go to your DJI Account's [User Center](http://developer.dji.com/en/user/mobile-sdk/), select the "Mobile SDK" tab on the left, press the "Create App" button and select "iOS" as your operating system. Then type in the info in the pop up dialog.

>Note: Please type in "com.dji.sdk" in the `Identification Code` field, because the default bundle identifier in the sample Xcode project is "com.dji.sdk".

Once you complete it, you may see the following App Key status:

![sdkDemoApp_Key](./Images/sdkDemoApp_Key.png)

Please record the App Key you just created and we will use it in the following steps.

### Running the Sample Xcode project

Open the "DJISdkDemo.xcodeproj" project in Xcode, modify the **AppDelegate.m** file by assigning the App Key string we just created to the **appKey** object like this:

~~~objc

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    //Enter the App Key here
    NSString* appKey = @"**********************";
    [DJIAppManager registerApp:appKey withDelegate:self];
    
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    UINavigationController* rootViewController = [[UINavigationController alloc] initWithRootViewController:[[DJIRootViewController alloc] initWithNibName:@"DJIRootViewController" bundle:nil]];
    [rootViewController.navigationBar setBackgroundColor:[UIColor blackColor]];
    [rootViewController setToolbarHidden:YES];
    self.window.rootViewController = rootViewController;
    // Override point for customization after application launch.
    self.window.backgroundColor = [UIColor whiteColor];
    [self.window makeKeyAndVisible];
    return YES;
}

~~~

>Note: If you are running the sample project with Xcode 7.0 above, please set "Enable Bitcode" value to No in the Build Settings as shown below:
>![bitcode](./Images/disable_bitcode.png)

Once you finish it, build and run the project and you can start to try different features in the sample project without any problems.

## Concepts

- [**DJI Mobile SDK Framework Handbook**](https://github.com/dji-sdk/Mobile-SDK-Handbook): 
This handbook provides a high level overview of the different components that make up the SDK, so that developers can get a feel for the SDK's structure and its different components. This handbook does not aim to provide specific information that can be found in the SDK. After reading through this handbook, developers should be able to begin working closely with the SDK.

## Sample Projects - Basic

- [**Creating a Camera Application**](https://github.com/DJI-Mobile-SDK/iOS-FPVDemo): Our introductory tutorial, which guides you through connecting to your drone's camera to display a live video feed in your app, through which you can take photos and videos.

## Sample Projects - Advanced

- [**Creating a Photo and Video Playback Application**](https://github.com/DJI-Mobile-SDK/iOS-PlaybackDemo): A follow up to the FPV tutorial, this tutorial teaches you how to construct an application to view media files onboard a DJI drone's SD card, specifically for **Phantom 3 Professional** and **Inspire 1**.

- [**Creating a MapView and Waypoint Application**](https://github.com/DJI-Mobile-SDK/iOS-GSDemo): Teaches you how to construct a Groundstation app, which allows you to plot a flight route for your drone by placing waypoints on a map.

- [**Creating a Panorama Application**](https://github.com/DJI-Mobile-SDK/iOS-PanoramaDemo):
Learn how to build a cool panorama app. With the help of the powerful DJI SDK and OpenCV libraries, it is actually easy. you will use the Waypoint feature of Intelligent Navigation and Joystick to rotate the aircraft to take photos.

## Gitbook

For better reading experience of DJI Mobile SDK Tutorials, please check our [**Gitbook**](https://dji-dev.gitbooks.io/mobile-sdk-tutorials/).

## SDK Reference

[**iOS SDK API Documentation**](http://developer.dji.com/mobile-sdk/documentation/)

## Support

You can get support from DJI with the following methods:

- [**DJI Forum**](http://forum.dev.dji.com/en)
- [**Stackoverflow**](http://stackoverflow.com) 
- dev@dji.com
