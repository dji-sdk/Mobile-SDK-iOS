//
//  DJITypeDef.h
//  DJISDK
//
//  Copyright (c) 2015 DJI. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <DJISDK/DJIFoundation.h>

DJI_API_EXTERN const int DJICameraFocusAreaRow;           // 12
DJI_API_EXTERN const int DJICameraFocusAreaColumn;        // 8
DJI_API_EXTERN const int DJICameraSpotMeteringAreaRow;    // 12
DJI_API_EXTERN const int DJICameraSpotMeteringAreaColumn; // 8

/**
 *  Camera's Shutter speed
 */
DJI_API_EXTERN const double DJICameraShutterSpeed0;    // 1/8000 s
DJI_API_EXTERN const double DJICameraShutterSpeed1;    // 1/6400 s
DJI_API_EXTERN const double DJICameraShutterSpeed2;    // 1/5000 s
DJI_API_EXTERN const double DJICameraShutterSpeed3;    // 1/4000 s
DJI_API_EXTERN const double DJICameraShutterSpeed4;    // 1/3200 s
DJI_API_EXTERN const double DJICameraShutterSpeed5;    // 1/2500 s
DJI_API_EXTERN const double DJICameraShutterSpeed6;    // 1/2000 s
DJI_API_EXTERN const double DJICameraShutterSpeed7;    // 1/1600 s
DJI_API_EXTERN const double DJICameraShutterSpeed8;    // 1/1250 s
DJI_API_EXTERN const double DJICameraShutterSpeed9;    // 1/1000 s
DJI_API_EXTERN const double DJICameraShutterSpeed10;   // 1/800 s
DJI_API_EXTERN const double DJICameraShutterSpeed11;   // 1/640 s
DJI_API_EXTERN const double DJICameraShutterSpeed12;   // 1/500 s
DJI_API_EXTERN const double DJICameraShutterSpeed13;   // 1/400 s
DJI_API_EXTERN const double DJICameraShutterSpeed14;   // 1/320 s
DJI_API_EXTERN const double DJICameraShutterSpeed15;   // 1/240 s
DJI_API_EXTERN const double DJICameraShutterSpeed16;   // 1/200 s
DJI_API_EXTERN const double DJICameraShutterSpeed17;   // 1/160 s
DJI_API_EXTERN const double DJICameraShutterSpeed18;   // 1/120 s
DJI_API_EXTERN const double DJICameraShutterSpeed19;   // 1/100 s
DJI_API_EXTERN const double DJICameraShutterSpeed20;   // 1/80 s
DJI_API_EXTERN const double DJICameraShutterSpeed21;   // 1/60 s
DJI_API_EXTERN const double DJICameraShutterSpeed22;   // 1/50 s
DJI_API_EXTERN const double DJICameraShutterSpeed23;   // 1/40 s
DJI_API_EXTERN const double DJICameraShutterSpeed24;   // 1/30 s
DJI_API_EXTERN const double DJICameraShutterSpeed25;   // 1/25 s
DJI_API_EXTERN const double DJICameraShutterSpeed26;   // 1/20 s
DJI_API_EXTERN const double DJICameraShutterSpeed27;   // 1/15 s
DJI_API_EXTERN const double DJICameraShutterSpeed28;   // 1/12.5 s
DJI_API_EXTERN const double DJICameraShutterSpeed29;   // 1/10 s
DJI_API_EXTERN const double DJICameraShutterSpeed30;   // 1/8 s
DJI_API_EXTERN const double DJICameraShutterSpeed31;   // 1/6.25 s
DJI_API_EXTERN const double DJICameraShutterSpeed32;   // 1/5 s
DJI_API_EXTERN const double DJICameraShutterSpeed33;   // 1/4 s
DJI_API_EXTERN const double DJICameraShutterSpeed34;   // 1/3 s
DJI_API_EXTERN const double DJICameraShutterSpeed35;   // 1/2.5 s
DJI_API_EXTERN const double DJICameraShutterSpeed36;   // 1/2 s
DJI_API_EXTERN const double DJICameraShutterSpeed37;   // 1/1.67 s
DJI_API_EXTERN const double DJICameraShutterSpeed38;   // 1/1.25 s
DJI_API_EXTERN const double DJICameraShutterSpeed39;   // 1.0 s
DJI_API_EXTERN const double DJICameraShutterSpeed40;   // 1.3 s
DJI_API_EXTERN const double DJICameraShutterSpeed41;   // 1.6 s
DJI_API_EXTERN const double DJICameraShutterSpeed42;   // 2.0 s
DJI_API_EXTERN const double DJICameraShutterSpeed43;   // 2.5 s
DJI_API_EXTERN const double DJICameraShutterSpeed44;   // 3.0 s
DJI_API_EXTERN const double DJICameraShutterSpeed45;   // 3.2 s
DJI_API_EXTERN const double DJICameraShutterSpeed46;   // 4.0 s
DJI_API_EXTERN const double DJICameraShutterSpeed47;   // 5.0 s
DJI_API_EXTERN const double DJICameraShutterSpeed48;   // 6.0 s
DJI_API_EXTERN const double DJICameraShutterSpeed49;   // 7.0 s
DJI_API_EXTERN const double DJICameraShutterSpeed50;   // 8.0 s

/**
 *  Camera capture mode
 */
typedef NS_ENUM(uint8_t, CameraCaptureMode){
    /**
     *  Single capture
     */
    CameraSingleCapture,
    /**
     *  Multiple capture
     */
    CameraMultiCapture,
    /**
     *  Continuous capture
     */
    CameraContinousCapture,
    /**
     *  BURST capture. Support in Inspire/Phantom3 professional
     */
    CameraBURSTCapture = CameraContinousCapture,
    /**
     *  AEB capture. Support in Inspire/Phantom3 professional
     */
    CameraAEBCapture,
};

/**
 *  Video quality
 */
typedef NS_ENUM(uint8_t, VideoQuality){
    /**
     *  Normal, Used in Inspire/Phantom3 professional
     */
    CameraVideoQualityNormal                = 0x00,
    /**
     *  Quality fine, Used in Inspire/Phantom3 professional
     */
    CameraVideoQualityFine                  = 0x01,
    /**
     *  Quality excellent, Used in Inspire/Phantom3 professional
     */
    CameraVideoQualityExcellent             = 0x02,
    /**
     *  Video resolution 320x240 15fps,  Used in Phantom 2 Vision
     */
    Video320x24015fps                       = 0x01,
    /**
     *  Video resolution 320x240 30fps,  Used in Phantom 2 Vision
     */
    Video320x24030fps                       = 0x02,
    /**
     *  Video resolution 640x480 15fps,  Used in Phantom 2 Vision
     */
    Video640x48015fps                       = 0x03,
    /**
     *  Video resolution 640x480 30fps,  Used in Phantom 2 Vision
     */
    Video640x48030fps                       = 0x04,
    /**
     *  Unknown
     */
    CameraVideoQualityUnknown               = 0xFF
};

/**
 *  The video storage format
 */
typedef NS_ENUM(uint8_t, CameraVideoStorageFormat){
    /**
     *  MOV storage format
     */
    CameraVideoStorageFormatMOV,
    /**
     *  MP4 storage format
     */
    CameraVideoStorageFormatMP4,
    /**
     *  Unknown
     */
    CameraVideoStorageFormatUnknown = 0xFF
};

/**
 *  Camera mode used in Phantom 2 Vision
 */
typedef NS_ENUM(uint8_t, CameraMode){
    /**
     *  Camera mode, Under this mode, user can do capture, record, set/get camera parameters and video preview.
     */
    CameraCameraMode                        = 0x00,
    /**
     *  USB mode. Under this mode, user can download media files from camera, but the video stream will stop push
     */
    CameraUSBMode                           = 0x01,
    /**
     *  Unknown
     */
    CameraModeUnknown                       = 0xFF
};

/**
 *  Camera work mode. Used in Inspire/Phantom3 professional
 */
typedef NS_ENUM(uint8_t, CameraWorkMode){
    /**
     *  Capture mode. In this mode, user could do capture action only.
     */
    CameraWorkModeCapture                   = 0x00,
    /**
     *  Record mode. In this mode, user could do record action only.
     */
    CameraWorkModeRecord                    = 0x01,
    /**
     *  Playback mode. In this mode, user could preview photos or videos and delete the file.
     */
    CameraWorkModePlayback                  = 0x02,
    /**
     *  Download mode. In this mode, user could download the selected file from SD card
     */
    CameraWorkModeDownload                  = 0x03,
    /**
     *  New download mode for Inspire 1/Phantom3 Professional. In this mode, user could use the api 'fetchMediaList:' to download media files.
     */
    CameraWorkModeDownload2                 = 0x04,
    /**
     *  Unknown
     */
    CameraWorkModeUnknown                   = 0xFF
};

/**
 *  Camera exposure mode
 */
typedef NS_ENUM(uint8_t, CameraExposureMode){
    /**
     *  Program
     */
    CameraExposureModeProgram,
    /**
     *  Shutter
     */
    CameraExposureModeShutter,
    /**
     *  Manual
     */
    CameraExposureModeManual,
    /**
     *  Unknown
     */
    CameraExposureModeUnknown               = 0xFF
};

/**
 *  Camera storage photo size
 */
typedef NS_ENUM(uint8_t, CameraPhotoSizeType){
    /**
     *  Default
     */
    CameraPhotoSizeDefault                  = 0x00,
    /**
     *  4384x3288. Used for Phantom 2 Vision camera
     */
    CameraPhotoSize4384x3288                = 0x01,
    /**
     *  4384x2922. Used for Phantom 2 Vision camera
     */
    CameraPhotoSize4384x2922                = 0x02,
    /**
     *  4384x2466. Used for Phantom 2 Vision camera
     */
    CameraPhotoSize4384x2466                = 0x03,
    /**
     *  4608x3456. Used for Phantom 2 Vision camera
     */
    CameraPhotoSize4608x3456                = 0x04,
    /**
     *  Small size. Used for Inspire / Phantom3 professional
     */
    CameraPhotoSizeSmall                    = CameraPhotoSize4384x2922,
    /**
     *  Middle size. Used for Inspire / Phantom3 professional
     */
    CameraPhotoSizeMiddle                   = CameraPhotoSize4384x2466,
    /**
     *  Large size. Used for Inspire / Phantom3 professional
     */
    CameraPhotoSizeLarge                    = CameraPhotoSize4608x3456,
    /**
     *  Unknown
     */
    CameraPhotoSizeUnknown                  = 0xFF
};

/**
 *  Camera's photo ration = width / height
 */
typedef NS_ENUM(uint8_t, CameraPhotoRatioType){
    /**
     *  Photo 4 : 3
     */
    CameraPhotoRatio4_3,
    /**
     *  Photo 16 : 9
     */
    CameraPhotoRatio16_9,
    /**
     *  Unknown
     */
    CameraPhotoRatioUnknown = 0xFF
};

/**
 *  Photo quality
 */
typedef NS_ENUM(uint8_t, CameraPhotoQualityType){
    /**
     *  Photo quality normal
     */
    CameraPhotoQualityNormal,
    /**
     *  Photo quality fine
     */
    CameraPhotoQualityFine,
    /**
     *  Photo quality excellent
     */
    CameraPhotoQualityExcellent,
    /**
     *  Unknown
     */
    CameraPhotoQualityUnknown = 0xFF
};

/**
 *  Camera ISO
 */
typedef NS_ENUM(uint8_t, CameraISOType){
    /**
     *  ISO Auto
     */
    CameraISOAuto                           = 0x00,
    /**
     *  ISO 100
     */
    CameraISO100                            = 0x01,
    /**
     *  ISO 200
     */
    CameraISO200                            = 0x02,
    /**
     *  ISO 400
     */
    CameraISO400                            = 0x03,
    /**
     *  ISO 800
     */
    CameraISO800                            = 0x04,
    /**
     *  ISO 1600
     */
    CameraISO1600                           = 0x05,
    /**
     *  ISO 3200
     */
    CameraISO3200                           = 0x06,
    /**
     *  Unknown
     */
    CameraISOUnknown                        = 0xFF
};

/**
 *  Camera white balance
 */
typedef NS_ENUM(uint8_t, CameraWhiteBalanceType){
    /**
     *  White balance auto
     */
    CameraWhiteBalanceAuto                  = 0x00,
    /**
     *  White balance sunny
     */
    CameraWhiteBalanceSunny                 = 0x01,
    /**
     *  White balance cloudy
     */
    CameraWhiteBalanceCloudy                = 0x02,
    /**
     *  White balance indoor
     */
    CameraWhiteBalanceIndoor                = 0x03,
    /**
     *  White balance water suface. Support in Inspire/Phantom3 professional
     */
    CameraWhiteBalanceWaterSuface           = CameraWhiteBalanceIndoor,
    /**
     *  White balance indoor incandescent. Support in Inspire/Phantom3 professional
     */
    CameraWhiteBalanceIndoorIncandescent    = 0x04,
    /**
     *  White balance indoor fluorescent. Support in Inspire/Phantom3 professional
     */
    CameraWhiteBalanceIndoorFluorescent     = 0x05,
    /**
     *  White balance unknown
     */
    CameraWhiteBalanceUnknown               = 0xFF
};

/**
 *  Camera exposure metering
 */
typedef NS_ENUM(uint8_t, CameraExposureMeteringType){
    /**
     *  Exposure metering center
     */
    CameraExposureMeteringCenter            = 0x00,
    /**
     *  Exposure metering average
     */
    CameraExposureMeteringAverage           = 0x01,
    /**
     *  Exposure metering point
     */
    CameraExposureMeteringPoint             = 0x02,
    /**
     *  Unknown
     */
    CameraExposureMeteringUnknown           = 0xFF
};

/**
 *  Camera recording resolution
 */
typedef NS_ENUM(uint8_t, CameraRecordingResolutionType){
    /**
     *  Resolution default
     */
    CameraRecordingResolutionDefault        = 0x00,
    /**
     *  Resolution 640x480 30
     */
    CameraRecordingResolution640x48030p     = 0x01,
    /**
     *  Resolution 1280x720 30p
     */
    CameraRecordingResolution1280x72030p    = 0x02,
    /**
     *  Resolution 1280x720 60p
     */
    CameraRecordingResolution1280x72060p    = 0x03,
    /**
     *  Resolution 1280x960 30p
     */
    CameraRecordingResolution1280x96030p    = 0x04,
    /**
     *  Resolution 1920x1080 30p
     */
    CameraRecordingResolution1920x108030p   = 0x05,
    /**
     *  Resolution 1920x1080 60i
     */
    CameraRecordingResolution1920x108060i   = 0x06,
    /**
     *  Resolution 1920x1080 25p
     */
    CameraRecordingResolution1920x108025p   = 0x07,
    /**
     *  Resolution 1280x960 25p
     */
    CameraRecordingResolution1280x96025p    = 0x08,
    /**
     *  Resolution unknown
     */
    CameraRecordingResolutionUnknown        = 0xFF
};

/**
 *  Camera's video resolution. Used in Inspire/Phantom3 professional camera
 */
typedef NS_ENUM(uint8_t, CameraVideoResolution){
    /**
     *  1280x720P
     */
    CameraVideoResolution1280x720p,
    /**
     *  1920x1080P
     */
    CameraVideoResolution1920x1080p,
    /**
     *  3840x2160P
     */
    CameraVideoResolution3840x2160p,
    /**
     *  4096x2160
     */
    CameraVideoResolution4096x2160p,
    /**
     *  Unknown
     */
    CameraVideoResolutionUnknown,
};

/**
 *  Camera's video frame rate
 */
typedef NS_ENUM(uint8_t, CameraVideoFrameRate){
    /**
     *  24fps
     */
    CameraVideoFrameRate24fps,
    /**
     *  25fps
     */
    CameraVideoFrameRate25fps,
    /**
     *  30fps
     */
    CameraVideoFrameRate30fps,
    /**
     *  48fps
     */
    CameraVideoFrameRate48fps,
    /**
     *  50fps
     */
    CameraVideoFrameRate50fps,
    /**
     *  60fps
     */
    CameraVideoFrameRate60fps,
    /**
     *  Unknonwn
     */
    CameraVideoFrameRateUnknown = 0xFF
};

/**
 *  Camera FOV
 */
typedef NS_ENUM(uint8_t, CameraRecordingFovType){
    /**
     *  Wide FOV
     */
    CameraRecordingFOV0                     = 0x00,
    /**
     *  Middle FOV, Only support in Phantom 2 Vision
     */
    CameraRecordingFOV1                     = 0x01,
    /**
     *  Narrow FOV, Only support in Phantom 2 Vision
     */
     CameraRecordingFOV2                     = 0x02,
    /**
     *  Unknown
     */
    CameraRecordingFOVUnknown               = 0xFF
};

/**
 *  Camera's photo storage format
 */
typedef NS_ENUM(uint8_t, CameraPhotoFormatType){
    /**
     *  RAW format
     */
    CameraPhotoRAW                          = 0x00,
    /**
     *  JPEG format
     */
    CameraPhotoJPEG                         = 0x01,
    /**
     *  RAW and JPEG format
     */
    CameraPhotoRAWAndJPEG                   = 0x02,
    /**
     *  Unknown
     */
    CameraPhotoFormatUnknown                = 0xFF
};

/**
 *  Camera exposure compensation
 */
typedef NS_ENUM(uint8_t, CameraExposureCompensationType){
    /**
     *  Default
     */
    CameraExposureCompensationDefault       = 0x00,
    /**
     *  -2.0ev
     */
    CameraExposureCompensationN20           = 0x01,
    /**
     *  -1.7ev
     */
    CameraExposureCompensationN17           = 0x02,
    /**
     *  -1.3ev
     */
    CameraExposureCompensationN13           = 0x03,
    /**
     *  -1.0ev
     */
    CameraExposureCompensationN10           = 0x04,
    /**
     *  -0.7ev
     */
    CameraExposureCompensationN07           = 0x05,
    /**
     *  -0.3ev
     */
    CameraExposureCompensationN03           = 0x06,
    /**
     *  0.0ev
     */
    CameraExposureCompensationN00           = 0x07,
    /**
     *  +0.3ev
     */
    CameraExposureCompensationP03           = 0x08,
    /**
     *  +0.7ev
     */
    CameraExposureCompensationP07           = 0x09,
    /**
     *  +1.0ev
     */
    CameraExposureCompensationP10           = 0x0A,
    /**
     *  +1.3ev
     */
    CameraExposureCompensationP13           = 0x0B,
    /**
     *  +1.7ev
     */
    CameraExposureCompensationP17           = 0x0C,
    /**
     *  +2.0ev
     */
    CameraExposureCompensationP20           = 0x0D,
    /**
     *  +2.3ev Support in Inspire/Phantom3 professional
     */
    CameraExposureCompensationP23           = 0x0E,
    /**
     *  +2.7ev Support in Inspire/Phantom3 professional
     */
    CameraExposureCompensationP27           = 0x0F,
    /**
     *  +3.0ev Support in Inspire/Phantom3 professional
     */
    CameraExposureCompensationP30           = 0x10,
    /**
     *  -3.0ev Support in Inspire/Phantom3 professional
     */
    CameraExposureCompensationN30           = 0x11,
    /**
     *  -2.7ev Support in Inspire/Phantom3 professional
     */
    CameraExposureCompensationN27           = 0x12,
    /**
     *  -2.3ev Support in Inspire/Phantom3 professional
     */
    CameraExposureCompensationN23           = 0x13,
    /**
     *  Unknown
     */
    CameraExposureCompensationUnknown       = 0xFF
};

/**
 *  Camera anti-flicker
 */
typedef NS_ENUM(uint8_t, CameraAntiFlickerType)
{
    /**
     *  Auto
     */
    CameraAntiFlickerAuto                   = 0x00,
    /**
     *  60 Hz
     */
    CameraAntiFlicker60Hz                   = 0x01,
    /**
     *  50 Hz
     */
    CameraAntiFlicker50Hz                   = 0x02,
    /**
     *  Unknown
     */
    CameraAntiFlickerUnknown                = 0xFF
};

/**
 *  Camera sharpness
 */
typedef NS_ENUM(uint8_t, CameraSharpnessType)
{
    /**
     *  Standard
     */
    CameraSharpnessStandard                 = 0x00,
    /**
     *  Hard
     */
    CameraSharpnessHard                     = 0x01,
    /**
     *  Soft
     */
    CameraSharpnessSoft                     = 0x02,
    /**
     *  Unknown
     */
    CameraSharpnessUnknown                  = 0xFF
};

/**
 *  Camera contrast
 */
typedef NS_ENUM(uint8_t, CameraContrastType)
{
    /**
     *  Standard
     */
    CameraContrastStandard                  = 0x00,
    /**
     *  Hard
     */
    CameraContrastHard                      = 0x01,
    /**
     *  Soft
     */
    CameraContrastSoft                      = 0x02,
    /**
     *  Unknown
     */
    CameraContrastUnknown                   = 0xFF
};

/**
 *  Camera will perform action when connection is broken
 */
typedef NS_ENUM(uint8_t, CameraActionWhenBreak)
{
    /**
     *  Keep current state
     */
    CameraKeepCurrentState                  = 0x00,
    /**
     *  Start continue shooting
     */
    CameraEnterContiuousShooting            = 0x01,
    /**
     *  Start recording
     */
    CameraEnterRecording                    = 0x02,
    /**
     *  Unknown
     */
    CameraActionUnknown                     = 0xFF
};

/**
 *  Camera multiple capture count
 */
typedef NS_ENUM(uint8_t, CameraMultiCaptureCount)
{
    /**
     *  Capture 3 photo at one shot
     */
    CameraMultiCapture3                     = 0x03,
    /**
     *  Capture 5 photo at one shot
     */
    CameraMultiCapture5                     = 0x05,
    /**
     *  Capture 7 photo at one shot. Support in inspire/Phantom3 professionla
     */
    CameraMultiCapture7                     = 0x07,
    /**
     *  Unknown
     */
    CameraMultiCaptureUnknown               = 0xFF
};

typedef struct
{
    /**
     *  Value(1 ~ 254) indicate continuous capture photo count, when the camera complete take the specified photo count, it will stop automatically
     *  Value(255) indicate the camera will constantly take photo unless user stop take photo manually
     */
    uint8_t contiCaptureCount;
    
    /**
     *  time interval between two capture action. value should be in range [5, 30]
     */
    uint16_t timeInterval;
} CameraContinuousCapturePara;

typedef struct
{
    /**
     *  Quick view duration in range [0, 127] (second)
     */
    uint8_t duration;
    /**
     *  Quick view enable
     */
    bool enable;
} CameraQuickViewParam;

/**
 *  File inde mode
 */
typedef NS_ENUM(uint8_t, CameraFileIndexMode){
    /**
     *  Camera will reset storage file's index while change new SD card
     */
    CameraFileIndexReset,
    /**
     *  Camera will use the sequence index whle change new SD caard
     */
    CameraFileIndexSequence,
};

/**
 *  AEB continue capture parameter
 */
typedef struct
{
    /**
     *  Exposure offset value in range [1, 10] : 1 = 0ev, 2 = 0.3ev, 3 = 0.7ev, 4 = 1.0ev .... 10 = 3.0ev
     */
    uint8_t exposureOffset;
    /**
     *  Continue capture count
     */
    uint8_t continueCaptureCount;
} CameraAEBParam;

/**
 *  Video standard
 */
typedef NS_ENUM(uint8_t, CameraVideoStandard){
    /**
     *  PAL
     */
    CameraVideoStandardPAL,
    /**
     *  NTSC
     */
    CameraVideoStandardNTSC,
    /**
     *  Unknown
     */
    CameraVideoStandardUnknown = 0xFF
};

/**
 *  Camera user settings. user can save or load settings from specific position
 */
typedef NS_ENUM(uint8_t, CameraUserSettings){
    /**
     *  Default
     */
    CameraSettingsDefault,
    /**
     *  USER1
     */
    CameraSettingsUSER1,
    /**
     *  USER2
     */
    CameraSettingsUSER2,
    /**
     *  USER3
     */
    CameraSettingsUSER3,
    /**
     *  USER4
     */
    CameraSettingsUSER4,
    /**
     *  Unknown
     */
    CameraSettingsUnknown = 0xFF
};

/**
 *  Camera's digital filter
 */
typedef NS_ENUM(uint8_t, CameraDigitalFilter){
    /**
     *  None
     */
    CameraDigitalFilterNone,
    /**
     *  Art
     */
    CameraDigitalFilterArt,
    /**
     *  Reminiscence
     */
    CameraDigitalFilterReminiscence,
    /**
     *  Inverse
     */
    CameraDigitalFilterInverse,
    /**
     *  Black and white
     */
    CameraDigitalFilterBlackAndWhite,
    /**
     *  Bright
     */
    CameraDigitalFilterBright,
    /**
     *  Movie
     */
    CameraDigitalFilterMovie,
    /**
     *  Not Support Now
     */
    CameraDigitalFilterPunk,
    /**
     *  Not Support Now
     */
    CameraDigitalFilterPopArt,
    /**
     *  Not Support Now
     */
    CameraDigitalFilterWedding,
    /**
     *  Not Support Now
     */
    CameraDigitalFilterTinyHole,
    /**
     *  Not Support Now
     */
    CameraDigitalFilterMiniature,
    /**
     *  Not Support Now
     */
    CameraDigitalFilterOilPainting,
    /**
     *  Not Support Now
     */
    CameraDigitalFilterWaterColor,
    /**
     *  M31
     */
    CameraDigitalFilterM31,
    /**
     *  Delta
     */
    CameraDigitalFilterDelta,
    /**
     *  kDX
     */
    CameraDigitalFilterkDX,
    /**
     *  DK79
     */
    CameraDigitalFilterDK79,
    /**
     *  Prismo
     */
    CameraDigitalFilterPrismo,
    /**
     *  Jugo
     */
    CameraDigitalFilterJugo,
    /**
     *  Vision4
     */
    CameraDigitalFilterVision4,
    /**
     *  Vision6
     */
    CameraDigitalFilterVision6,
    /**
     *  VisionX
     */
    CameraDigitalFilterVisionX,
    /**
     *  Neutral
     */
    CameraDigitalFilterNeutral,
    /**
     *  Unknown
     */
    CameraDigitalFilterUnknown = 0xFF
};

/**
 Download file type for Inspire/Phantom3Profession.
 */
typedef enum
{
    /**
     *  The download file is a photo
     */
    DJIDownloadFilePhoto,
    /**
     *  The download file is a DNG file
     */
    DJIDownloadFileDNG,
    /**
     *  The download file is a video 720P
     */
    DJIDownloadFileVideo720P,
    /**
     *  The download file is a video 1080P
     */
    DJIDownloadFileVideo1080P,
    /**
     *  The download file is a video 4K
     */
    DJIDownloadFileVideo4K,
    /**
     *  The download file unknown
     */
    DJIDownloadFileUnknown
} DJIDownloadFileType;

