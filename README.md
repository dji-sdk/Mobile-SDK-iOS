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

The process may take a long time, please wait. For further installation instructions, please check [this guides](https://guides.cocoapods.org/using/getting-started.html#getting-started).

**2.** Install Git Large File Storage (Git LFS)

Since the **DJISDK.framework** file exceeds the 100 MB limitation of Github file upload, you need to use [Git Large File Storage](https://git-lfs.github.com) to download the SDK file. Enter the following command to install it:

~~~
brew install git-lfs
git lfs install
~~~

Be sure to **restart** your terminal after installing the Git LFS.

**3.** Install SDK with CocoaPods in the Project

Run the following command in the **ObjcSampleCode** and **SwiftSampleCode** folders' directory:

~~~
pod install
~~~

If you install it successfully, you may get the messages similar to the followings:

~~~
Analyzing dependencies
Downloading dependencies
Installing DJI-SDK-iOS (3.4.1)
Generating Pods project
Integrating client project

[!] Please close any current Xcode sessions and use `DJISdkDemo.xcworkspace` for this project from now on.
Pod installation complete! There is 1 dependency from the Podfile and 1 total pod
installed.
~~~

### Run Sample Code

Developers can [run the sample application](https://developer.dji.com/mobile-sdk/documentation/quick-start/index.html) to immediately run code and see how the DJI Mobile SDK can be used.

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

## SDK API Reference

[**iOS SDK API Documentation**](https://developer.dji.com/iframe/mobile-sdk-doc/ios/index.html)

## CocoaPods Support

DJI iOS SDK supports CocoaPods now. Please check this link for details: <https://cocoapods.org/pods/DJI-SDK-iOS>.

## FFmpeg Customization

We have forked the original FFmpeg and added customized features to provide more video frame information including the frame's width and height, frame rate number, etc. These features will help to implement video hardware decoding. 

The SDK Sample Code uses code of [FFmpeg](http://ffmpeg.org) licensed under the [LGPLv2.1](http://www.gnu.org/licenses/old-licenses/lgpl-2.1.html) and its source code can be downloaded from this [Github Page](https://github.com/dji-sdk/FFmpeg).

## Video Hardware Decoder Open Source

Please check the [VideoPreviewer](https://github.com/dji-sdk/Mobile-SDK-iOS/tree/master/Sample%20Code/VideoPreviewer/VideoPreviewer) source code for details.

## Support

You can get support from DJI with the following methods:

- [**DJI Forum**](http://forum.dev.dji.com/en)
- Post questions in [**Stackoverflow**](http://stackoverflow.com) using [**dji-sdk**](http://stackoverflow.com/questions/tagged/dji-sdk) tag
- dev@dji.com

