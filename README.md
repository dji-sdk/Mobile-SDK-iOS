# DJI Mobile SDK for iOS

[English](#what-is-this) | [中文](#这是什么)

## What Is This?

The DJI Mobile SDK enables you to control how your Phantom’s camera, gimbal, and more behaves and interacts with mobile apps you create. Using the Mobile SDK, create a customized mobile app to unlock the full potential of your DJI aerial platform.

## Running the SDK Sample Code

This guide shows you how to setup APP Key and run our DJI Mobile SDK sample project, which you can download from this **Github Page**.

### Prerequisites

- Xcode 7.0+ or higher
- Deployment target of 8.0 or higher

### Registering an App Key

Firstly, please go to your DJI Account's [User Center](http://developer.dji.com/en/user/apps), select the "Mobile SDK" tab on the left, press the "Create App" button and select "iOS" as your operating system. Then type in the info in the pop up dialog.

>Note: Please type in "com.dji.sdkdemo" in the `Identification Code` field, because the default bundle identifier in the sample Xcode project is "com.dji.sdkdemo".

Once you complete it, you may see the following App Key status:

![createAppSuccess](./Images/createAppSuccess.png)

Please record the App Key you just created and we will use it in the following steps.

### Running the Sample Xcode project

Open the "DJISdkDemo.xcodeproj" project in Xcode, modify the **DJIRootViewController.m** file by assigning the App Key string we just created to the **appKey** object like this:

~~~objc

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // disable the connect button by default
    [self.connectButton setEnabled:NO];

    //Register App with key
    NSString* appKey = @"Please enter your App Key here";
    [DJISDKManager registerApp:appKey withDelegate:self];
    
    self.sdkVersionLabel.text = [@"DJI SDK Version: " stringByAppendingString:[DJISDKManager getSDKVersion]];
}

~~~

> Notes:
> 
> - In order to enable your app to connect to the MFI remote controller, you must add "Supported external accessory protocols" items in the info.plist file as shown below:
> ![infoPlist](./Images/infoPlist.png)
> 
> - Since in iOS 9, App Transport Security has blocked a cleartext HTTP (http://) resource load since it is insecure. You must add "App Transport Security Settings" items in the info.plist file as shown below:
> ![appTransportSecurity](./Images/appTransportSecurity.png)
> 
> - In order to prepare your app for App Store submission, create a new "Run Script Phase" in your app's target's "Build Phases" and paste the following snippet in the script text field(see below image): `bash "${BUILT_PRODUCTS_DIR}/${FRAMEWORKS_FOLDER_PATH}/Realm.framework/strip-frameworks.sh"` This step is required to work around an App Store submission bug when archiving universal binaries.
> ![runScript](./Images/runShellScripts.png)

Once you finish it, build and run the project and you can start to try different features in the sample project without any problems.

## DJI Bridge App

DJI Bridge App is a universal app supports both iPhone and iPad. You can use it to debug app for Phantom 3 Professional, Phantom 3 Advanced, Inspire 1, M100 and other products using USB/MFI connection between RC and your app.

For more details, please check the [**DJI Bridge App Tutorial**](./DJIBridgeAppDemo/README.md).

You can download the DJI Bridge App source code from here: <https://github.com/dji-sdk/DJI-Bridge-App>.

## DJI Remote Logger

DJI Remote Logger is a tool to show the log messages in your source code on a webpage. It use Ruby log server to show log contents.

For more details, please check the [**DJI Remote Logger Tutorial**](./DJIRemoteLoggerDemo/README.md)

## FFmpeg Customization

We have forked the original FFmpeg and add customized features to provide more infos of video frame, including frame's width and height, frame rate number, etc. These features will help to implement video hardware decoding. For more details, please check the AVCodecParserContext struct of avcodec.h file from this [Github Page](https://github.com/dji-sdk/FFmpeg).

## Concepts

- [**DJI Mobile SDK Framework Handbook**](https://github.com/dji-sdk/Mobile-SDK-Handbook): 
This handbook provides a high level overview of the different components that make up the SDK, so that developers can get a feel for the SDK's structure and its different components. This handbook does not aim to provide specific information that can be found in the SDK. After reading through this handbook, developers should be able to begin working closely with the SDK.

- [**Virtual Stick User Guide**](http://developer.dji.com/mobile-sdk/get-started/Virtual-Stick-User-Guide):
This guide provides functionality to turn your mobile device into an intelligent remote controller, through which you can program a more flexible trajectory than using Waypoint missions would allow.

## Sample Projects - Basic

- [**Creating a Camera Application**](https://github.com/DJI-Mobile-SDK/iOS-FPVDemo): Our introductory tutorial, which guides you through connecting to your drone's camera to display a live video feed in your app, through which you can take photos and videos.

## Sample Projects - Advanced

- [**Creating a Photo and Video Playback Application**](https://github.com/DJI-Mobile-SDK/iOS-PlaybackDemo): A follow up to the FPV tutorial, this tutorial teaches you how to construct an application to view media files onboard a DJI drone's SD card, specifically for **Phantom 3 Professional** and **Inspire 1**.

## Gitbook

For an improved reading experience of DJI Mobile SDK Tutorials, please check our [**Gitbook**](https://dji-dev.gitbooks.io/mobile-sdk-tutorials/).

## SDK Reference

[**iOS SDK API Documentation**](http://developer.dji.com/mobile-sdk/documentation/)

## MFi Application Process

Please check this [**tutorial**](./MFi Application Process/README.md) for MFi Approval Process details.

## Support

You can get support from DJI with the following methods:

- [**DJI Forum**](http://forum.dev.dji.com/en)
- Post questions in [**Stackoverflow**](http://stackoverflow.com) using [**dji-sdk**](http://stackoverflow.com/questions/tagged/dji-sdk) tag
- dev@dji.com

---

## 这是什么?

使用DJI Mobile SDK开发App, 可以控制Phantom的相机，云台等更多部件实现个性化的航拍体验。你可以为DJI飞行平台量身定做移动APP，发挥出飞行器的最大潜力。关于飞行的一切创意，均可成为现实。

## 运行SDK示例代码

本教程展示了如何配置APP Key, 如何运行DJI Mobile SDK的示例代码，示例代码可以在当前的**Github Page**中下载。

### 开发工具版本要求

- Xcode 7.0+ or higher
- Deployment target of 8.0 or higher

### 注册App Key

首先, 请来到你的DJI 账号的[用户中心](http://developer.dji.com/cn/user/apps/), 选择左侧的 "Mobile SDK" 选项，然后点击“创建App”按钮，并且选择“iOS”作为开发平台. 接着在弹出的对话框中输入信息.

>注意: 请在`标识码`栏中输入"com.dji.sdkdemo", 因为示例代码中的默认bundle identifier就是 "com.dji.sdk".

一旦你完成了注册，你将看到以下App Key的状态截图:

![createAppSuccess](./Images/createAppSuccessful_cn.png)

请记下刚刚创建好的App Key，我们会在接下来的步骤中用到。

### 运行Xcode示例代码

在Xcode中打开 "DJISdkDemo.xcodeproj"工程, 修改 **DJIRootViewController.m** 文件，将刚创建好的App Key字符串赋值给 **appKey** 对象，如下所示:

~~~objc

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // disable the connect button by default
    [self.connectButton setEnabled:NO];

    //Register App with key
    NSString* appKey = @"Please enter your App Key here";
    [DJISDKManager registerApp:appKey withDelegate:self];
    
    self.sdkVersionLabel.text = [@"DJI SDK Version: " stringByAppendingString:[DJISDKManager getSDKVersion]];
}

~~~

>注意:
>
> - 如果你要让app支持MFI遥控器连接，你必须在info.plist文件中添加"Supported external accessory protocols"选项，如下图所示：
> ![infoPlist](./Images/infoPlist.png)
> 
> - 因为在 iOS 9, App Transport Security 已经限制了一个 cleartext HTTP (http://) resource load, 因为它是不安全的. 你必须在info.plist文件中添加"App Transport Security Settings" 项，如下所示:
> ![appTransportSecurity](./Images/appTransportSecurity.png)
> 
> - 准备提交app到App Store审核时, 请在你的app target的"Build Phases" 里面新建一个"Run Script Phase", 然后粘贴以下脚本内容: `bash "${BUILT_PRODUCTS_DIR}/${FRAMEWORKS_FOLDER_PATH}/Realm.framework/strip-frameworks.sh"` 这一步是必须的，可以帮你解决在归档通用二进制文件时，提交App Store审核的bug.
> ![runScript](./Images/runShellScripts.png)

最后编译运行该工程，你就可以开始流畅地体验实例代码中的不同功能了。

## DJI Bridge App

DJI Bridge App 是一个同时支持iPhone和iPad的通用应用程序。你可以使用它来为Phantom 3 Professional, Phantom 3 Advanced， Inspire 1, M100 和其它产品进行应用程序调试操作。它使用了USB 或者MFI，将遥控器和你的应用程序连接起来.

想了解更多信息，请查看: [**DJI Bridge App 教程**](./DJIBridgeAppDemo/README.md).

你可以从这里下载到 DJI Bridge App 的源代码: <https://github.com/dji-sdk/DJI-Bridge-App>.

## DJI Remote Logger

DJI Remote Logger 是一个可以将源代码中的日志信息展示到网页上的工具。它使用了Ruby 服务器脚本进行日志展示。

想了解更多信息，请查看: [**DJI Remote Logger Tutorial**](./DJIRemoteLoggerDemo/README.md)

## 基本概念

- [**DJI Mobile SDK Framework 指南**](https://github.com/dji-sdk/Mobile-SDK-Handbook): 

本指南针对SDK的各种抽象概念进行了解释，方便开发者对SDK的架构和各种概念有一个清晰的理解。 本指南不会提供SDK的详细信息，具体您可以直接在SDK中了解。在阅读完本指南后，开发者可以更容易上手我们的SDK。

- [**虚拟摇杆使用指南**](http://developer.dji.com/cn/mobile-sdk/get-started/Virtual-Stick-User-Guide/)

本指南针对虚拟摇杆的原理进行了解释，目的是让开发者使用程序进行飞行控制，可以通过SDK实现遥控器模拟。相比于Waypoint的功能，虚拟摇杆显得更加灵活。

## 示例教程 - 基础

- [**创建航拍相机App**](https://github.com/DJI-Mobile-SDK/iOS-FPVDemo): 这是我们的入门教程, 该教材会指导你如何连接飞行器的相机，在app上显示实时画面，以及如何进行拍摄和录像操作。

## 示例教程 - 高级

- [**创建照片和视频回放应用**](https://github.com/DJI-Mobile-SDK/iOS-PlaybackDemo): 你将会学到如何使用DJI Mobile SDK去访问飞机相机上的SD卡媒体资源。当你完成本教程后，你将开发出一款app，具备预览照片，播放视频，下载或者删除文件等功能. 该教材目前只针对**Phantom 3 Professional** 和 **Inspire 1**.

## Gitbook

如果你想拥有更好的阅读体验，可以看下我们的DJI Mobile SDK Tutorials [**Gitbook**](https://dji-dev.gitbooks.io/mobile-sdk-tutorials/).

## SDK API 文档

[**iOS SDK API 文档**](http://developer.dji.com/mobile-sdk/documentation/)

## MFi 认证申请流程

请查看本 [**教程**](./MFi Application Process/README.md) 了解 MFi 认证申请流程细节.

## 技术支持

你可以从以下方式获得DJI的技术支持：

- [**DJI论坛**](http://forum.dev.dji.com/cn)
- [**Stackoverflow**](http://stackoverflow.com) 
- 请在 [**Stackoverflow**](http://stackoverflow.com)上使用 [**dji-sdk**](http://stackoverflow.com/questions/tagged/dji-sdk) tag提问题
- dev@dji.com

