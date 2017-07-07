# DJI Mobile SDK for iOS

## What Is This?

The DJI Mobile SDK enables you to automate your DJI Product. You can control flight, and many subsystems of the product including the camera and gimbal. Using the Mobile SDK, create a customized mobile app to unlock the full potential of your DJI aerial platform.

## Get Started Immediately

### SDK Installation with CocoaPods

Since this project has been integrated with [DJI iOS SDK CocoaPods](https://cocoapods.org/pods/DJI-SDK-iOS) now, please check the following steps to install **DJISDK.framework** using CocoaPods after you downloading this project:

**1.** Install CocoaPods

Open Terminal and change to the download project's directory, enter the following command to install it:

~~~
sudo gem install cocoapods
~~~

The process may take a long time, please wait. For further installation instructions, please check [this guide](https://guides.cocoapods.org/using/getting-started.html#getting-started).

**2.** Install SDK with CocoaPods in the Project

Run the following command in the **ObjcSampleCode** and **SwiftSampleCode** paths:

~~~
pod install
~~~

If you install it successfully, you should get the messages similar to the following:

~~~
Analyzing dependencies
Downloading dependencies
Installing DJI-SDK-iOS (4.2.2)
Generating Pods project
Integrating client project

[!] Please close any current Xcode sessions and use `DJISdkDemo.xcworkspace` for this project from now on.
Pod installation complete! There is 1 dependency from the Podfile and 1 total pod
installed.
~~~

> **Note**: If you saw "Unable to satisfy the following requirements" issue during pod install, please run the following commands to update your pod repo and install the pod again:
> 
> ~~~
> pod repo update
> pod install
> ~~~

### Run Sample Code

Developers will need to setup the App Key by editing the sample code's info.plist, [after generating their unique App Key](https://developer.dji.com/mobile-sdk/documentation/quick-start/index.html#generate-an-app-key).

For the Objective-C sample app, the key value **DJISDKAppKey** should to be added to DJISdkDemo-Info.plist with your unique app key as a string.  (It is no longer necessary to edit the "DJIRootViewController.m" as in previous versions of the DJI SDK.)

For the Swift sample app, the DJISDKAppKey is present in the Info.plist - developers just need to add their unique key.
In both cases developers will still need to update the [Bundle Identifier](http://developer.dji.com/user/mobile-sdk/ios-configuration/) .


One of DJI's aircraft or handheld cameras will be required to run the sample application.  

## Development Workflow 

From registering as a developer, to deploying an application, the following will take you through the full Mobile SDK Application development process:

- [Prerequisites](https://developer.dji.com/mobile-sdk/documentation/application-development-workflow/workflow-prerequisits.html)
- [Register as DJI Developer & Download SDK](https://developer.dji.com/mobile-sdk/documentation/application-development-workflow/workflow-register.html)
- [Integrate SDK into Application](https://developer.dji.com/mobile-sdk/documentation/application-development-workflow/workflow-integrate.html)
- [Run Application](https://developer.dji.com/mobile-sdk/documentation/application-development-workflow/workflow-run.html)
- [Testing, Profiling & Debugging](https://developer.dji.com/mobile-sdk/documentation/application-development-workflow/workflow-testing.html)
- [Deploy](https://developer.dji.com/mobile-sdk/documentation/application-development-workflow/workflow-deploy.html)

## Sample Projects & Tutorials

Several iOS tutorials are provided as examples on how to use different features of the Mobile SDK and debug tools includes:

- [Camera Application](https://developer.dji.com/mobile-sdk/documentation/ios-tutorials/index.html)
- [Photo and Video Playback Application](https://developer.dji.com/mobile-sdk/documentation/ios-tutorials/PlaybackDemo.html)
- [MapView And Waypoint Application](https://developer.dji.com/mobile-sdk/documentation/ios-tutorials/GSDemo.html)
- [Panorama Appliation](https://developer.dji.com/mobile-sdk/documentation/ios-tutorials/PanoDemo.html)
- [TapFly and ActiveTrack Appliation](https://developer.dji.com/mobile-sdk/documentation/ios-tutorials/P4MissionsDemo.html)
- [Simulator Application](http://developer.dji.com/mobile-sdk/documentation/ios-tutorials/SimulatorDemo.html)
- [GEO System Application](http://developer.dji.com/mobile-sdk/documentation/ios-tutorials/GEODemo.html)
- [Using the Bridge App](https://developer.dji.com/mobile-sdk/documentation/ios-tutorials/BridgeAppDemo.html)
- [Using the Remote Logger](https://developer.dji.com/mobile-sdk/documentation/ios-tutorials/RemoteLoggerDemo.html)

## Learn More about DJI Products and the Mobile SDK

Please visit [DJI Mobile SDK Documentation](https://developer.dji.com/mobile-sdk/documentation/introduction/index.html) for more details.

## DJI Mobile UI Library

DJI Mobile UILibrary is a suite of product agnostic UI objects that fast tracks the development of iOS applications using the DJI Mobile SDK. For more details, please check [here](https://github.com/dji-sdk/Mobile-UILibrary-iOS).

## SDK Keys

SDK Keys can be used as an alternative interface to access the product.

A detailed introduction for SDK Keys is [here](./docs/README-KeyedInterface.md).

## Missions Refactor

Missions are an important part of the SDK as they allow developers to automate DJI's products using a simple, high level interface. In 4.0.1, missions are being refactored to be more robust and easier to manage.

A detailed introduction for missions is [here](./docs/README-Mission.md).

## SDK API Reference

[**iOS SDK API Documentation**](http://developer.dji.com/api-reference/ios-api/index.html)

## FFmpeg Customization

We have forked the original FFmpeg and added customized features to provide more video frame information including the frame's width and height, frame rate number, etc. These features will help to implement video hardware decoding. 

The SDK Sample Code is dynamically linked with unmodified libraries of <a href=http://ffmpeg.org>FFmpeg</a> licensed under the <a href=http://www.gnu.org/licenses/old-licenses/lgpl-2.1.html>LGPLv2.1</a>. The source code of these FFmpeg libraries, the compilation instructions, and the LGPL v2.1 license are provided in [Github](https://github.com/dji-sdk/FFmpeg).

## Support

You can get support from DJI with the following methods:

- [**DJI Forum**](http://forum.dev.dji.com/en)
- Post questions in [**Stackoverflow**](http://stackoverflow.com) using [**dji-sdk**](http://stackoverflow.com/questions/tagged/dji-sdk) tag
- dev@dji.com

