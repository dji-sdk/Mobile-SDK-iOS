# DJI Mobile SDK for iOS

## What Is This?

The DJI Mobile SDK enables you to automate your DJI Product. You can control flight, and many subsystems of the product including the camera and gimbal. Using the Mobile SDK, create a customized mobile app to unlock the full potential of your DJI aerial platform.

## Get Started Immediately

Developers can [run the sample application](https://developer.dji.com/mobile-sdk/documentation/quick-start/index.html) to immediately run code and see how the DJI Mobile SDK can be used.

One of DJI's aircraft or handheld cameras will be required to run the sample application.

> Note: Since the "DJISDK.framework" supports **Bitcode** now, the size of it becomes much bigger(**146.1MB**), which exceeds GitHub's file size limit of 100 MB for pushing. So we use [Git LFS](https://git-lfs.github.com) to upload the framework. 
> 
> Therefore, we suggest you to use `git clone` command to clone the sample code rather than downloading the ZIP file directly. Otherwise, you may not be able to get the framework file and build the project successfully. It may take time for you to clone the entire sample code project. 

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

