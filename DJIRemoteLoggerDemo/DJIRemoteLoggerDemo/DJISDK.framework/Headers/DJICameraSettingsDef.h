/*
 *  DJI iOS Mobile SDK Framework
 *  DJICameraSettingsDef.h
 *
 *  Copyright (c) 2015, DJI.
 *  All rights reserved.
 *
 */

#import <Foundation/Foundation.h>
#import <DJISDK/DJIBaseProduct.h>

NS_ASSUME_NONNULL_BEGIN

DJI_API_EXTERN const int DJICameraFocusAreaRow;           // 12
DJI_API_EXTERN const int DJICameraFocusAreaColumn;        // 8
DJI_API_EXTERN const int DJICameraSpotMeteringAreaRow;    // 12
DJI_API_EXTERN const int DJICameraSpotMeteringAreaColumn; // 8

/*********************************************************************************/
#pragma mark - Camera Modes
/*********************************************************************************/

//-----------------------------------------------------------------
#pragma mark DJICameraMode
//-----------------------------------------------------------------
/**
 *  Camera work modes. Modes in this typedef are suppported for the Phantom 3 (Standard, Advanced and Professional) and X3/X5 (Inspire 1, Inspire 1 Pro, M100, Osmo).
 *
 */
typedef NS_ENUM(NSUInteger, DJICameraMode){
    /**
     *  Capture mode. In this mode, the user can capture pictures.
     */
    DJICameraModeShootPhoto                = 0x00,
    /**
     *  Record mode. In this mode, the user can record videos.
     */
    DJICameraModeRecordVideo               = 0x01,
    /**
     *  Playback mode. In this mode, the user can preview photos and videos, and
     *  they can delete files.
     */
    DJICameraModePlaybackPreview           = 0x02,
    /**
     *  Download mode. In this mode, the user can download selected files from
     *  the SD card.
     */
    DJICameraModePlaybackDownload          = 0x03,

    /**
     *  New download mode for Inspire 1/Phantom3 Professional. In this mode, user can use the api 'fetchMediaList:' to download media files.
     *
     */
    DJICameraModeMediaDownload             = 0x04,

    /**
     *  The camera work mode is unknown.
     */
    DJICameraModeUnknown                   = 0xFF
};

//-----------------------------------------------------------------
#pragma mark DJICameraShootPhotoMode
//-----------------------------------------------------------------
/**
 *  Camera work mode ShootPhoto itself can have several modes. The default value is DJICameraShootPhotoModeSingle.
 */
typedef NS_ENUM(NSUInteger, DJICameraShootPhotoMode){
    /**
     *  Sets the camera to take a single photo.
     */
    DJICameraShootPhotoModeSingle,
    /**
     *  Sets the camera to take a HDR photo.
     *
     */
    DJICameraShootPhotoModeHDR,
    /**
     *  Set the camera to take multiple photos at once.
     *
     */
    DJICameraShootPhotoModeMultiple,
    /**
     *  Automatic Exposure Bracketing (AEB) capture. In this mode you can
     *  quickly take multiple shots (the default is 3) at different exposures
     *  without having to manually change any settings between frames.
     */
    DJICameraShootPhotoModeAEB,
    /**
     *  Sets the camera to take a picture (or multiple pictures) continuously at a set time interval.
     *  The minimum interval for JPEG format of any quality is 2s.
     *  The minimum interval for Raw or Raw+JPEG format is 10s.
     */
    DJICameraShootPhotoModeInterval,
    /**
     *  Sets the camera to take a picture (or multiple pictures) continuously at a set time interval.
     *  The camera will merge the photo sequence and the output is a video.
     *  The minimum interval for Video only format is 1 s.
     *  The minimum interval for Video+Photo format is 2 s.
     *  Supported only by OSMO camera.
     */
    DJICameraShootPhotoModeTimeLapse
};

//-----------------------------------------------------------------
#pragma mark DJICameraExposureMode
//-----------------------------------------------------------------
/**
 *  Camera exposure modes. The default value is DJICameraExposureModeProgram.
 *
 */
typedef NS_ENUM(NSUInteger, DJICameraExposureMode){
    /**
     *  Program mode. The user can set EV value in Program mode and ISO/Shutter is calculated automatically. The camera will automatically set the exposure settings.
     */
    DJICameraExposureModeProgram,
    /**
     *  Shutter-priority mode. In this mode, the user can set the shutter speed but
     *  cannot set any of the other values.
     */
    DJICameraExposureModeShutter,
    /**
     *  Aperture-priority mode. In this mode, the user can set the Aperture but
     *  cannot set any of the other values. Only the camera supporting adjustable
     *  aperture can use this mode.
     */
    DJICameraExposureModeAperture,
    /**
     *  Manual mode. In this mode, the user can set ISO and shutter values.
     */
    DJICameraExposureModeManual,
    /**
     *  The camera exposure mode is unknown.
     */
    DJICameraExposureModeUnknown               = 0xFF
};

/*********************************************************************************/
#pragma mark - Video Related
/*********************************************************************************/

//-----------------------------------------------------------------
#pragma mark DJICameraVideoFileFormat
//-----------------------------------------------------------------
/**
 *  Video storage formats.
 */
typedef NS_ENUM(NSUInteger, DJICameraVideoFileFormat){
    /**
     *  The video storage format is MOV.
     */
    DJICameraVideoFileFormatMOV,
    /**
     *  The video storage format is MP4.
     */
    DJICameraVideoFileFormatMP4,
    /**
     *  The video storage format is unknown.
     */
    DJICameraVideoFileFormatUnknown = 0xFF
};

//-----------------------------------------------------------------
#pragma mark DJICameraVideoResolution
//-----------------------------------------------------------------
/**
 *  Camera video resolution values. This typedef is only supported for the
 *  Phantom 3 Professional and the Inspire 1. The default value for the
 *  Phantom 3 Professional and the Inspire 1 is
 *  CameraRecordingResolution3840x2160. The default value for
 *  the Phantom 3 Advanced is CameraRecordingResolution1920x1080.
 *
 */
typedef NS_ENUM(NSUInteger, DJICameraVideoResolution){
    /**
     *  The camera's video resolution is 2704x1520.
     */
    DJICameraVideoResolution2704x1520,
    /**
     *  The camera's video resolution is 1280x720.
     */
    DJICameraVideoResolution1280x720,
    /**
     *  The camera's video resolution is 1920x1080.
     */
    DJICameraVideoResolution1920x1080,
    /**
     *  The camera's video resolution is 3840x2160.
     */
    DJICameraVideoResolution3840x2160,
    /**
     *  The camera's video resolution is 4096x2160.
     */
    DJICameraVideoResolution4096x2160,
    /**
     *  The camera's video resolution is unknown.
     */
    DJICameraVideoResolutionUnknown,
};

//-----------------------------------------------------------------
#pragma mark DJICameraVideoFrameRate
//-----------------------------------------------------------------
/**
 *  Camera video frame rate values.
 */
typedef NS_ENUM(NSUInteger, DJICameraVideoFrameRate){
    /**
     *  The camera's video frame rate is 24fps (frames per second).
     */
    DJICameraVideoFrameRate24fps = 0x00,
    /**
     *  The camera's video frame rate is 25fps (frames per second).
     */
    DJICameraVideoFrameRate25fps,
    /**
     *  The camera's video frame rate is 30fps (frames per second).
     */
    DJICameraVideoFrameRate30fps,
    /**
     *  The camera's video frame rate is 48fps (frames per second).
     */
    DJICameraVideoFrameRate48fps,
    /**
     *  The camera's video frame rate is 50fps (frames per second).
     */
    DJICameraVideoFrameRate50fps,
    /**
     *  The camera's video frame rate is 60fps (frames per second).
     */
    DJICameraVideoFrameRate60fps,
    /**
     *  The camera's video frame rate is 120fps (frames per second).
     *  The frame rate can only be used when slow motion enabled.
     */
    DJICameraVideoFrameRate120fps,
    /**
     *  The camera's video frame rate is unknown.
     */
    DJICameraVideoFrameRateUnknown = 0xFF
};

//-----------------------------------------------------------------
#pragma mark DJICameraVideoStandard
//-----------------------------------------------------------------
/**
 *  Video standard values. The default value is NTSC.
 */
typedef NS_ENUM(NSUInteger, DJICameraVideoStandard){
    /**
     *  The camera video standard value is set to PAL.
     */
    DJICameraVideoStandardPAL,
    /**
     *  The camera video standard value is set to NTSC.
     */
    DJICameraVideoStandardNTSC,
    /**
     *  The camera video standard value is unknown.
     */
    DJICameraVideoStandardUnknown = 0xFF
};

/*********************************************************************************/
#pragma mark - Photo related
/*********************************************************************************/

//-----------------------------------------------------------------
#pragma mark DJICameraPhotoFileFormat
//-----------------------------------------------------------------
/**
 *  Camera photo file formats. The default value is CameraPhotoJPEG.
 */
typedef NS_ENUM(NSUInteger, DJICameraPhotoFileFormat){
    /**
     *  The camera's photo storage format is RAW.
     */
    DJICameraPhotoFileFormatRAW                          = 0x00,
    /**
     *  The camera's photo storage format is JPEG.
     */
    DJICameraPhotoFileFormatJPEG                         = 0x01,
    /**
     *  The camera's photo storage format stores both the RAW and JPEG
     *  formats of the photo.
     */
    DJICameraPhotoFileFormatRAWAndJPEG                   = 0x02,
    /**
     *  The camera's photo storage format is unknown.
     */
    DJICameraPhotoFileFormatUnknown                = 0xFF
};

//-----------------------------------------------------------------
#pragma mark DJICameraPhotoTimeLapseFileFormat
//-----------------------------------------------------------------
/**
 *  File format for camera when it is in time-lapse mode. The
 *  default file format is video. If video+JPEG is selected the minimum interval will be 2 seconds.
 */
typedef NS_ENUM(NSUInteger, DJICameraPhotoTimeLapseFileFormat) {
    /**
     *  The camera in time-lapse mode will generate video
     */
    DJICameraPhotoTimeLapseFileFormatVideo              = 0x00,
    /**
     *  The camera in time-lapse mode will generate video and JPEG
     */
    DJICameraPhotoTimeLapseFileFormatVideoAndJPEG,
    /**
     *  The file format is unknown
     */
    DJICameraPhotoTimeLapseFileFormatUnknown            = 0xFF
};

//-----------------------------------------------------------------
#pragma mark DJICameraPhotoQuality
//-----------------------------------------------------------------
/**
 *  Photo quality of the JPEG image. Higher photo quality results in larger file size.
 *  The default value is CameraPhotoQualityExcellent.
 */
typedef NS_ENUM(NSUInteger, DJICameraPhotoQuality){
    /**
     *  The photo quality is normal.
     */
    DJICameraPhotoQualityNormal,
    /**
     *  The photo quality is fine.
     */
    DJICameraPhotoQualityFine,
    /**
     *  The photo quality is excellent.
     */
    DJICameraPhotoQualityExcellent,
    /**
     *  The photo quality is unknown.
     */
    DJICameraPhotoQualityUnknown = 0xFF
};

//-----------------------------------------------------------------
#pragma mark DJICameraPhotoAspectRatio
//-----------------------------------------------------------------
/**
 *  Photo aspect ratio, where the first value is the width and the
 *  second value is the height. The default value is CameraPhotoRatio4_3.
 */
typedef NS_ENUM(NSUInteger, DJICameraPhotoAspectRatio){
    /**
     *  The camera's photo ratio is 4 : 3.
     */
    DJICameraPhotoAspectRatio4_3,
    /**
     *  The camera's photo ratio is 16 : 9.
     */
    DJICameraPhotoAspectRatio16_9,
    /**
     *  The camera's photo ratio is unknown.
     */
    DJICameraPhotoAspectRatioUnknown = 0xFF
};


//-----------------------------------------------------------------
#pragma mark DJICameraPhotoMultipleCount
//-----------------------------------------------------------------
/**
 *  Camera multiple capture count values.
 *
 */
typedef NS_ENUM(NSUInteger, DJICameraPhotoMultipleCount)
{
    /**
     *  The camera multiple capture count is set to capture 3 at once pictures when the camera
     *  takes a photo.
     */
    DJICameraPhotoMultipleCount3                     = 0x03,
    /**
     *  The camera multiple capture count is set to capture 5 at once pictures when the camera
     *  takes a photo.
     */
    DJICameraPhotoMultipleCount5                     = 0x05,
    /**
     *  The camera multiple capture count is set to capture 7 at once pictures when the camera
     *  takes a photo. This value is only supported for the Phantom 3 Professional & the Inspire 1.
     */
    DJICameraPhotoMultipleCount7                     = 0x07,
    /**
     *  The camera multiple capture count value is unknown.
     */
    DJICameraPhotoMultipleCountUnknown               = 0xFF
};

//-----------------------------------------------------------------
#pragma mark DJICameraPhotoAEBParam
//-----------------------------------------------------------------
/**
 *  AEB continue capture parameter values.
 *
 */
typedef struct
{
    /**
     *  Exposure offset value can be set in the range of [1, 10] : 1 = 0ev, 2 = 0.3ev, 3 = 0.7ev,
     *  4 = 1.0ev .... 10 = 3.0ev. The default value is 2.3ev.
     */
    uint8_t exposureOffset;
    /**
     *  The number of pictures to continuosly take at one time. The default value is 3.
     */
    uint8_t captureCount;
} DJICameraPhotoAEBParam;

//-----------------------------------------------------------------
#pragma mark DJICameraPhotoIntervalParam
//-----------------------------------------------------------------
/**
 *  Sets the number of pictures, and the time interval between pictures for the continuous capture shoot photo mode.
 */
typedef struct
{
    /**
     *  Number of pictures to capture. Range is [2, 255]. If 255 is selected, then the camera will continue to take pictures until a manual photo is triggered.
     *
     *  Rob comment: stopping a capture is inconsisten with the documentation in DJICamera.h where it says we should use stopShootPhotoWithCompletion to halt a continous capture.
     */
    uint8_t captureCount;

    /**
     *  The time interval between pictures. The range is [2, 30] for JPEG and [5, 30] for JPEG+RAW.
     *
     *  Rob comment: Confirm time intervals.
     */
    uint16_t timeIntervalInSeconds;
} DJICameraPhotoIntervalParam;

/*********************************************************************************/
#pragma mark - Camera advanced settings
/*********************************************************************************/
//-----------------------------------------------------------------
#pragma mark DJICameraShutterSpeed
//-----------------------------------------------------------------
/**
 *  Camera's shutter speed options.
 */
typedef NS_ENUM(NSUInteger, DJICameraShutterSpeed) {
    DJICameraShutterSpeed1_8000     = 0x00, // 1/8000 s
    DJICameraShutterSpeed1_6400     = 0x01, // 1/6400 s
    DJICameraShutterSpeed1_5000     = 0x02, // 1/5000 s
    DJICameraShutterSpeed1_4000     = 0x03, // 1/4000 s
    DJICameraShutterSpeed1_3200     = 0x04, // 1/3200 s
    DJICameraShutterSpeed1_2500     = 0x05, // 1/2500 s
    DJICameraShutterSpeed1_2000     = 0x06, // 1/2000 s
    DJICameraShutterSpeed1_1600     = 0x07, // 1/1600 s
    DJICameraShutterSpeed1_1250     = 0x08, // 1/1250 s
    DJICameraShutterSpeed1_1000     = 0x09, // 1/1000 s
    DJICameraShutterSpeed1_800      = 0x0A, // 1/800 s
    DJICameraShutterSpeed1_640      = 0x0B, // 1/640 s
    DJICameraShutterSpeed1_500      = 0x0C, // 1/500 s
    DJICameraShutterSpeed1_400      = 0x0D, // 1/400 s
    DJICameraShutterSpeed1_320      = 0x0E, // 1/320 s
    DJICameraShutterSpeed1_240      = 0x0F, // 1/240 s
    DJICameraShutterSpeed1_200      = 0x10, // 1/200 s
    DJICameraShutterSpeed1_160      = 0x11, // 1/160 s
    DJICameraShutterSpeed1_120      = 0x12, // 1/120 s
    DJICameraShutterSpeed1_100      = 0x13, // 1/100 s
    DJICameraShutterSpeed1_80       = 0x14, // 1/80 s
    DJICameraShutterSpeed1_60       = 0x15, // 1/60 s
    DJICameraShutterSpeed1_50       = 0x16, // 1/50 s
    DJICameraShutterSpeed1_40       = 0x17, // 1/40 s
    DJICameraShutterSpeed1_30       = 0x18, // 1/30 s
    DJICameraShutterSpeed1_25       = 0x19, // 1/25 s
    DJICameraShutterSpeed1_20       = 0x1A, // 1/20 s
    DJICameraShutterSpeed1_15       = 0x1B, // 1/15 s
    DJICameraShutterSpeed1_12p5     = 0x1C, // 1/12.5 s
    DJICameraShutterSpeed1_10       = 0x1D, // 1/10 s
    DJICameraShutterSpeed1_8        = 0x1E, // 1/8 s
    DJICameraShutterSpeed1_6p25     = 0x1F, // 1/6.25 s
    DJICameraShutterSpeed1_5        = 0x20, // 1/5 s
    DJICameraShutterSpeed1_4        = 0x21, // 1/4 s
    DJICameraShutterSpeed1_3        = 0x22, // 1/3 s
    DJICameraShutterSpeed1_2p5      = 0x23, // 1/2.5 s
    DJICameraShutterSpeed1_2        = 0x24, // 1/2 s
    DJICameraShutterSpeed1_1p67     = 0x25, // 1/1.67 s
    DJICameraShutterSpeed1_1p25     = 0x26, // 1/1.25 s
    DJICameraShutterSpeed1p0        = 0x27, // 1.0 s
    DJICameraShutterSpeed1p3        = 0x28, // 1.3 s
    DJICameraShutterSpeed1p6        = 0x29, // 1.6 s
    DJICameraShutterSpeed2p0        = 0x2A, // 2.0 s
    DJICameraShutterSpeed2p5        = 0x2B, // 2.5 s
    DJICameraShutterSpeed3p0        = 0x2C, // 3.0 s
    DJICameraShutterSpeed3p2        = 0x2D, // 3.2 s
    DJICameraShutterSpeed4p0        = 0x2E, // 4.0 s
    DJICameraShutterSpeed5p0        = 0x2F, // 5.0 s
    DJICameraShutterSpeed6p0        = 0x30, // 6.0 s
    DJICameraShutterSpeed7p0        = 0x31, // 7.0 s
    DJICameraShutterSpeed8p0        = 0x32, // 8.0 s
    DJICameraShutterSpeed9p0        = 0x33, // 9.0 s
    DJICameraShutterSpeed10p0       = 0x34, // 10.0 s
    DJICameraShutterSpeed13p0       = 0x35, // 13.0 s
    DJICameraShutterSpeed15p0       = 0x36, // 15.0 s
    DJICameraShutterSpeed20p0       = 0x37, // 20.0 s
    DJICameraShutterSpeed25p0       = 0x38, // 25.0 s
    DJICameraShutterSpeed30p0       = 0x39, // 30.0 s

    DJICameraShutterSpeedUnknown = 0xFF
};

//-----------------------------------------------------------------
#pragma mark DJICameraISO
//-----------------------------------------------------------------
/**
 *  Camera ISO values. The default value is CameraISOAuto.
 */
typedef NS_ENUM(NSUInteger, DJICameraISO){
    /**
     *  The ISO value is automatically set.
     */
    DJICameraISOAuto                           = 0x00,
    /**
     *  The ISO value is set to 100.
     */
    DJICameraISO100                            = 0x01,
    /**
     *  The ISO value is set to 200.
     */
    DJICameraISO200                            = 0x02,
    /**
     *  The ISO value is set to 400.
     */
    DJICameraISO400                            = 0x03,
    /**
     *  The ISO value is set to 800.
     */
    DJICameraISO800                            = 0x04,
    /**
     *  The ISO value is set to 1600.
     */
    DJICameraISO1600                           = 0x05,
    /**
     *  The ISO value is set to 3200.
     */
    DJICameraISO3200                           = 0x06,
    /**
     *  The ISO value is set to 6400.
     */
    DJICameraISO6400                           = 0x07,
    /**
     *  The ISO value is set to 12800.
     */
    DJICameraISO12800                          = 0x08,
    /**
     *  The ISO value is set to 25600.
     */
    DJICameraISO25600                          = 0x09,
    /**
     *  The ISO value is set to an unknown value.
     */
    DJICameraISOUnknown                        = 0xFF
};

//-----------------------------------------------------------------
#pragma mark DJICameraAperture
//-----------------------------------------------------------------
/**
 *  Camera aperture values. Currently, only X5 and X5 Raw support
 *  this setting.
 *
 */
typedef NS_ENUM(NSUInteger, DJICameraAperture) {
    DJICameraApertureF1p7,      // f/1.7
    DJICameraApertureF1p8,      // f/1.8
    DJICameraApertureF2,        // f/2
    DJICameraApertureF2p2,      // f/2.2
    DJICameraApertureF2p5,      // f/2.5
    DJICameraApertureF2p8,      // f/2.8
    DJICameraApertureF3p2,      // f/3.2
    DJICameraApertureF3p5,      // f/3.5
    DJICameraApertureF4,        // f/4
    DJICameraApertureF4p5,      // f/4.5
    DJICameraApertureF5,        // f/5
    DJICameraApertureF5p6,      // f/5.6
    DJICameraApertureF6p3,      // f/6.3
    DJICameraApertureF7p1,      // f/7.1
    DJICameraApertureF8,        // f/8
    DJICameraApertureF9,        // f/9
    DJICameraApertureF10,       // f/10
    DJICameraApertureF11,       // f/11
    DJICameraApertureF13,       // f/13
    DJICameraApertureF14,       // f/14
    DJICameraApertureF16,       // f/16
    DJICameraApertureF18,       // f/18
    DJICameraApertureF20,       // f/20
    DJICameraApertureF22,       // f/22
    DJICameraApertureUnknown = 0xFF
};

//-----------------------------------------------------------------
#pragma mark DJICameraWhiteBalance
//-----------------------------------------------------------------
/**
 *  Camera white balance. The default value is CameraWhiteBalanceAuto.
 */
typedef NS_ENUM(NSUInteger, DJICameraWhiteBalance){
    /**
     *  The camera's white balance is automatically set.
     */
    DJICameraWhiteBalanceAuto                  = 0x00,
    /**
     *  The camera's white balance is set to sunny.
     */
    DJICameraWhiteBalanceSunny                 = 0x01,
    /**
     *  The camera's white balance is set to cloudy.
     */
    DJICameraWhiteBalanceCloudy                = 0x02,
    /**
     *  The camera's white balance is set to water surface. This white
     *  balance value is only supported for the Phantom 3 Advanced, Phantom 3
     *  Professional, and the Inspire 1.
     *
     */
    DJICameraWhiteBalanceWaterSuface           = 0x03,
    /**
     *  The camera's white balance is set to indoors and incandescent light.
     *  This white balance is only supported for the Phantom 3 Advanced,
     *  Phantom 3 Professional, and the Inspire 1.
     *
     */
    DJICameraWhiteBalanceIndoorsIncandescent   = 0x04,
    /**
     *  The camera's white balance is set to indoors and fluorescent light.
     *  This white balance is only supported for the Phantom 3 Advanced,
     *  Phantom 3 Professional, and the Inspire 1.
     *
     */
    DJICameraWhiteBalanceIndoorsFluorescent    = 0x05,
    /**
     *  The camera's white balance is unknown.
     */
    DJICameraWhiteBalanceUnknown               = 0xFF
};

//-----------------------------------------------------------------
#pragma mark DJICameraMeteringMode
//-----------------------------------------------------------------
/**
 *  Camera exposure metering. The default value is CameraExposureMeteringCenter.
 */
typedef NS_ENUM(NSUInteger, DJICameraMeteringMode){
    /**
     *  The camera's exposure metering is set to the center.
     */
    DJICameraMeteringModeCenter            = 0x00,
    /**
     *  The camera's exposure metering is set to average.
     */
    DJICameraMeteringModeAverage           = 0x01,
    /**
     *  The camera's exposure metering is set to a single spot.
     */
    DJICameraMeteringModeSpot             = 0x02,
    /**
     *  The camera's exposure metering is unknown.
     */
    DJICameraMeteringModeUnknown           = 0xFF
};

//-----------------------------------------------------------------
#pragma mark DJICameraExposureCompensation
//-----------------------------------------------------------------
/**
 *  Camera exposure compensation.
 */
typedef NS_ENUM(NSUInteger, DJICameraExposureCompensation){
    /**
     *  Default.
     */
    DJICameraExposureCompensationDefault       = 0x00,
    /**
     *  The camera's exposure compensation is -2.0ev.
     */
    DJICameraExposureCompensationN20           = 0x01,
    /**
     *  The camera's exposure compensation is -1.7ev.
     */
    DJICameraExposureCompensationN17           = 0x02,
    /**
     *  The camera's exposure compensation is -1.3ev.
     */
    DJICameraExposureCompensationN13           = 0x03,
    /**
     *  The camera's exposure compensation is -1.0ev.
     */
    DJICameraExposureCompensationN10           = 0x04,
    /**
     *  The camera's exposure compensation is -0.7ev.
     */
    DJICameraExposureCompensationN07           = 0x05,
    /**
     *  The camera's exposure compensation is -0.3ev.
     */
    DJICameraExposureCompensationN03           = 0x06,
    /**
     *  The camera's exposure compensation is 0.0ev.
     */
    DJICameraExposureCompensationN00           = 0x07,
    /**
     *  The camera's exposure compensation is +0.3ev.
     */
    DJICameraExposureCompensationP03           = 0x08,
    /**
     *  The camera's exposure compensation is +0.7ev.
     */
    DJICameraExposureCompensationP07           = 0x09,
    /**
     *  The camera's exposure compensation is +1.0ev.
     */
    DJICameraExposureCompensationP10           = 0x0A,
    /**
     *  The camera's exposure compensation is +1.3ev.
     */
    DJICameraExposureCompensationP13           = 0x0B,
    /**
     *  The camera's exposure compensation is +1.7ev.
     */
    DJICameraExposureCompensationP17           = 0x0C,
    /**
     *  The camera's exposure compensation is +2.0ev.
     */
    DJICameraExposureCompensationP20           = 0x0D,
    /**
     *  The camera's exposure compensation is +2.3ev.
     *  This value is only supported by the Phantom 3
     *  Advanced, Phantom 3 Professional, and the Inspire 1.
     *
     */
    DJICameraExposureCompensationP23           = 0x0E,
    /**
     *  The camera's exposure compensation is +2.7ev.
     *  This value is only supported by the Phantom 3
     *  Advanced, Phantom 3 Professional, and the Inspire 1.
     */
    DJICameraExposureCompensationP27           = 0x0F,
    /**
     *  The camera's exposure compensation is +3.0ev.
     *  This value is only supported by the Phantom 3
     *  Advanced, Phantom 3 Professional, and the Inspire 1.
     */
    DJICameraExposureCompensationP30           = 0x10,
    /**
     *  The camera's exposure compensation is -3.0ev.
     *  This value is only supported by the Phantom 3
     *  Advanced, Phantom 3 Professional, and the Inspire 1.
     */
    DJICameraExposureCompensationN30           = 0x11,
    /**
     *  The camera's exposure compensation is -2.7ev.
     *  This value is only supported by the Phantom 3
     *  Advanced, Phantom 3 Professional, and the Inspire 1.
     */
    DJICameraExposureCompensationN27           = 0x12,
    /**
     *  The camera's exposure compensation is -2.3ev.
     *  This value is only supported by the Phantom 3
     *  Advanced, Phantom 3 Professional, and the Inspire 1.
     */
    DJICameraExposureCompensationN23           = 0x13,
    /**
     *  The camera's exposure compensation is unknown.
     */
    DJICameraExposureCompensationUnknown       = 0xFF
};

//-----------------------------------------------------------------
#pragma mark DJICameraAntiFlicker
//-----------------------------------------------------------------
/**
 *  Camera anti-flickers. The default value is CameraAntiFlicker50Hz.
 */
typedef NS_ENUM(NSUInteger, DJICameraAntiFlicker)
{
    /**
     *  The camera's anti-flicker is automatically set.
     */
    DJICameraAntiFlickerAuto                   = 0x00,
    /**
     *  The camera's anti-flicker is 60 Hz.
     */
    DJICameraAntiFlicker60Hz                   = 0x01,
    /**
     *  The camera's anti-flicker is 50 Hz.
     */
    DJICameraAntiFlicker50Hz                   = 0x02,
    /**
     *  The camera's anti-flicker is unknown.
     */
    DJICameraAntiFlickerUnknown                = 0xFF
};

//-----------------------------------------------------------------
#pragma mark DJICameraSharpness
//-----------------------------------------------------------------
/**
 *  Camera sharpnesss. The default value is CameraSharpnessStandard.
 */
typedef NS_ENUM(NSUInteger, DJICameraSharpness)
{
    /**
     *  The camera's sharpness is set to standard.
     */
    DJICameraSharpnessStandard                 = 0x00,
    /**
     *  The camera's sharpness is set to hard.
     */
    DJICameraSharpnessHard                     = 0x01,
    /**
     *  The camera's sharpness is set to soft.
     */
    DJICameraSharpnessSoft                     = 0x02,
    /**
     *  The camera's sharpness is set to unknown.
     */
    DJICameraSharpnessUnknown                  = 0xFF
};

//-----------------------------------------------------------------
#pragma mark DJICameraContrast
//-----------------------------------------------------------------
/**
 *  Camera contrast. The default value is CameraContrastStandard.
 */
typedef NS_ENUM(NSUInteger, DJICameraContrast)
{
    /**
     *  The camera's contrast is set to standard.
     */
    DJICameraContrastStandard                  = 0x00,
    /**
     *  The camera's contrast is set to hard.
     */
    DJICameraContrastHard                      = 0x01,
    /**
     *  The camera's contrast is set to soft.
     */
    DJICameraContrastSoft                      = 0x02,
    /**
     *  The camera's contrast is unknown.
     */
    DJICameraContrastUnknown                   = 0xFF
};

/*********************************************************************************/
#pragma mark - Lens related
/*********************************************************************************/

//-----------------------------------------------------------------
#pragma mark DJICameraLensFocusMode
//-----------------------------------------------------------------
/**
 *  Camera focusing mode.
 *  It is settable only when IsAdjustableFocalPointSupported returns YES.
 */
typedef NS_ENUM(NSUInteger, DJICameraLensFocusMode)
{
    /*
     *  The camera's focus mode is set to manual.
     *  In this mode, user sets the focus ring value to adjust the focal distance.
     */
    DJICameraLensFocusModeManual,
    /*
     *  The camera's focus mode is set to auto.
     *  In this mode, user sets the lens focus target to adjust the focal point.
     */
    DJICameraLensFocusModeAFOneShot,
    /*
     *  The camera's focus mode is unkown.
     */
    DJICameraLensFocusModeUnknown = 0xFF
};

/*********************************************************************************/
#pragma mark - Others
/*********************************************************************************/

//-----------------------------------------------------------------
#pragma mark DJICameraPhotoQuickViewParam
//-----------------------------------------------------------------
typedef struct
{
    /**
     *  This value defines the amount of time a photo is shown as a preview after it is taken before the
     *  camera returns back to the live camera view. This value must be set in the range of [0, 127]
     *  seconds. The default value is 0 seconds.
     */
    uint8_t duration;
    /**
     *  Whether or not you set the ability to view the photo for a short duration of time after it is taken.
     *  The default value is NO.
     */
    bool enable;
} DJICameraPhotoQuickViewParam;

//-----------------------------------------------------------------
#pragma mark DJICameraFileIndexMode
//-----------------------------------------------------------------
/**
 *  File index modes.
 */
typedef NS_ENUM(NSUInteger, DJICameraFileIndexMode){
    /**
     *  Camera will reset the newest file's index to be one larger than the largest number of photos
     *  taken on the SD card.
     */
    DJICameraFileIndexModeReset,
    /**
     *  Camera will set the newest file's index to the larger of either the maximum number of photos
     *  taken on the SD card or the camera.
     */
    DJICameraFileIndexModeSequence,
    /**
     *  The mode is unknown.
     */
    DJICameraFileIndexModeUnknown = 0xFF
};

//-----------------------------------------------------------------
#pragma mark DJICameraCustomSettings
//-----------------------------------------------------------------
/**
 *  Camera user settings. A user can save or load camera settings to or from the specified user.
 */
typedef NS_ENUM(NSUInteger, DJICameraCustomSettings){
    /**
     *  Default user.
     */
    DJICameraCustomSettingsDefault,
    /**
     *  Settings for user 1.
     */
    DJICameraCustomSettingsProfile1,
    /**
     *  Settings for user 2.
     */
    DJICameraCustomSettingsProfile2,
    /**
     *  Settings for user 3.
     */
    DJICameraCustomSettingsProfile3,
    /**
     *  Settings for user 4.
     */
    DJICameraCustomSettingsProfile4,
    /**
     *  The user is unknown.
     */
    DJICameraCustomSettingsUnknown = 0xFF
};

//-----------------------------------------------------------------
#pragma mark DJICameraDigitalFilter
//-----------------------------------------------------------------
/**
 *  Camera digital filters. The default value is DJICameraDigitalFilterNone.
 */
typedef NS_ENUM(NSUInteger, DJICameraDigitalFilter){
    /**
     *  The digital filter is set to none or no filter.
     */
    DJICameraDigitalFilterNone,
    /**
     *  The digital filter is set to art.
     */
    DJICameraDigitalFilterArt,
    /**
     *  The digital filter is set to reminiscence.
     */
    DJICameraDigitalFilterReminiscence,
    /**
     *  The digital filter is set to inverse.
     */
    DJICameraDigitalFilterInverse,
    /**
     *  The digital filter is set to black and white.
     */
    DJICameraDigitalFilterBlackAndWhite,
    /**
     *  The digital filter is set to bright.
     */
    DJICameraDigitalFilterBright,
    /**
     *  The digital filter is set to movie.
     */
    DJICameraDigitalFilterMovie,
    /**
     *  This digital filter is currently not supported.
     */
    DJICameraDigitalFilterPunk,
    /**
     *  This digital filter is currently not supported.
     */
    DJICameraDigitalFilterPopArt,
    /**
     *  This digital filter is currently not supported.
     */
    DJICameraDigitalFilterWedding,
    /**
     *  This digital filter is currently not supported.
     */
    DJICameraDigitalFilterTinyHole,
    /**
     *  This digital filter is currently not supported.
     */
    DJICameraDigitalFilterMiniature,
    /**
     *  This digital filter is currently not supported.
     */
    DJICameraDigitalFilterOilPainting,
    /**
     *  This digital filter is currently not supported.
     */
    DJICameraDigitalFilterWaterColor,
    /**
     *  The digital filter is set to M31.
     */
    DJICameraDigitalFilterM31,
    /**
     *  The digital filter is set to delta.
     */
    DJICameraDigitalFilterDelta,
    /**
     *  The digital filter is set to kDX.
     */
    DJICameraDigitalFilterkDX,
    /**
     *  The digital filter is set to DK79.
     */
    DJICameraDigitalFilterDK79,
    /**
     *  The digital filter is set to prismo.
     */
    DJICameraDigitalFilterPrismo,
    /**
     *  The digital filter is set to jugo.
     */
    DJICameraDigitalFilterJugo,
    /**
     *  The digital filter is set to vision 4.
     */
    DJICameraDigitalFilterVision4,
    /**
     *  The digital filter is set to vision 6.
     */
    DJICameraDigitalFilterVision6,
    /**
     *  The digital filter is set to vision x.
     */
    DJICameraDigitalFilterVisionX,
    /**
     *  The digital filter is set to neutral.
     */
    DJICameraDigitalFilterNeutral,
    /**
     *  The digital filter is unknown.
     */
    DJICameraDigitalFilterUnknown = 0xFF
};

//-----------------------------------------------------------------
#pragma mark DJIDownloadFileType
//-----------------------------------------------------------------
/**
 *  Download file types. This typedef is only supported for the Phantom 3
 *  Professional and the Inspire 1.
 */
typedef NS_ENUM(NSUInteger, DJIDownloadFileType)
{
    /**
     *  The file to be download is a photo file type.
     */
    DJIDownloadFileTypePhoto,
    /**
     *  The file to be downloaded is a RAW type in DNG format.
     */
    DJIDownloadFileTypeRAWDNG,
    /**
     *  The file to be downloaded is a video file in 720P.
     */
    DJIDownloadFileTypeVideo720P,
    /**
     *  The file to be downloaded is a video file in 1080P.
     */
    DJIDownloadFileTypeVideo1080P,
    /**
     *  The file to be downloaded is a video file in 4K.
     */
    DJIDownloadFileTypeVideo4K,
    /**
     *  The file to be downloaded is unknown.
     */
    DJIDownloadFileTypeUnknown
};

NS_ASSUME_NONNULL_END
