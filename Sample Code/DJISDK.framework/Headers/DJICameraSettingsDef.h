//
//  DJICameraSettingsDef.h
//  DJISDK
//
//  Copyright © 2015, DJI. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreGraphics/CoreGraphics.h>
#import "DJISDKFoundation.h"

NS_ASSUME_NONNULL_BEGIN

/**
 *  Camera Focus Area Row.
 */
DJI_API_EXTERN const int DJICameraFocusAreaRow;           // 8
/**
 *  Camera Focus Area Column.
 */
DJI_API_EXTERN const int DJICameraFocusAreaColumn;        // 12
/**
 *  Camera Spot Metering Area Row.
 */
DJI_API_EXTERN const int DJICameraSpotMeteringAreaRow;    // 8
/**
 *  Camera Spot Metering Area Column.
 */
DJI_API_EXTERN const int DJICameraSpotMeteringAreaColumn; // 12

/*********************************************************************************/
#pragma mark - Camera Modes
/*********************************************************************************/

/*********************************************************************************/
#pragma mark DJICameraMode
/*********************************************************************************/

/**
 *  Camera work modes.
 */
typedef NS_ENUM (NSUInteger, DJICameraMode){
    /**
     *  Capture mode. In this mode, the user can capture pictures.
     */
    DJICameraModeShootPhoto = 0x00,
    /**
     *  Record mode. In this mode, the user can record videos.
     */
    DJICameraModeRecordVideo = 0x01,
    /**
     *  Playback mode. In this mode, the user can preview photos and videos, and
     *  can delete files.
     *  Not supported by Osmo, Phantom 3 Standard or Phantom 3 4K.
     */
    DJICameraModePlayback = 0x02,
    /**
     *  In this mode, the user can download media to the Mobile Device.
     *  Not supported by Inspire 1 Pro (X5 camera) nor Inspire 1 RAW (X5R camera).
     */
    DJICameraModeMediaDownload = 0x03,
    
    /**
     *  The camera work mode is unknown.
     */
    DJICameraModeUnknown = 0xFF
};

/*********************************************************************************/
#pragma mark DJICameraShootPhotoMode
/*********************************************************************************/

/**
 *  The ShootPhoto mode itself can have several modes. The default value is `DJICameraShootPhotoModeSingle`.
 */
typedef NS_ENUM (NSUInteger, DJICameraShootPhotoMode){
    /**
     *  Sets the camera to take a single photo.
     */
    DJICameraShootPhotoModeSingle,
    /**
     *  Sets the camera to take an HDR photo.
     *  X5 camera, X5R camera and XT camera do not support HDR mode.
     */
    DJICameraShootPhotoModeHDR,
    /**
     *  Set the camera to take multiple photos at once.
     *  XT camera does not support Burst mode.
     */
    DJICameraShootPhotoModeBurst,
    /**
     *  Automatic Exposure Bracketing (AEB) capture. In this mode you can
     *  quickly take multiple shots (the default is 3) at different exposures
     *  without having to manually change any settings between frames.
     *  XT camera does not support AEB mode.
     */
    DJICameraShootPhotoModeAEB,
    /**
     *  Sets the camera to take a picture (or multiple pictures) continuously at
     *  a set time interval.
     *  The minimum interval for JPEG format of any quality is 2s.
     *  The minimum interval for Raw or Raw+JPEG format is 10s.
     */
    DJICameraShootPhotoModeInterval,
    /**
     *  Sets the camera to take a picture (or multiple pictures) continuously at
     *  a set time interval.
     *  The camera will merge the photo sequence and the output is a video.
     *  The minimum interval for Video only format is 1 s.
     *  The minimum interval for Video+Photo format is 2 s.
     *  Supported only by Osmo camera.
     *
     *  For the new Osmo firmware version, no video feed will be received if the
     *  camera is shooting photos with Time-lapse mode. Instead, user can 
     *  receive a sequence of preview images using the delegate method
     *  `camera:didGenerateTimeLapsePreview:`.
     */
    DJICameraShootPhotoModeTimeLapse,
    
    /**
     *  The shoot photo mode is unknown.
     */
    DJICameraShootPhotoModeUnknown = 0xFF,
};

/*********************************************************************************/
#pragma mark DJICameraExposureMode
/*********************************************************************************/

/**
 *  Camera exposure modes. The default value is `DJICameraExposureModeProgram`.
 *
 *  The different exposure modes define whether Aperture, Shutter Speed, ISO can
 *  be set automatically or manually. Exposure compensation can be changed in all modes
 *  except Manual mode where it is not settable.
 *
 *  <b>X5 camera and X5R camera:</b><br/>
 *       Program Mode:       Shutter: Auto     Aperture: Auto     ISO: Manual or Auto<br/>
 *       Shutter Priority:   Shutter: Manual   Aperture: Auto     ISO: Manual or Auto<br/>
 *       Aperture Priority:  Shutter: Auto     Aperture: Manual   ISO: Manual or Auto<br/>
 *       Manual Mode:        Shutter: Manual   Aperture: Manual   ISO: Manual<br/><br/><br/>
 *
 *
 *   <b>All other cameras:</b><br/>
 *       Program Mode:       Shutter: Auto     Aperture: Fixed    ISO: Auto<br/>
 *       Shutter Priority:   Shutter: Manual   Aperture: Fixed    ISO: Auto<br/>
 *       Aperture Priority:  N/A<br/>
 *       Manual Mode:        Shutter: Manual   Aperture: Manual   ISO: Manual
 */
typedef NS_ENUM (NSUInteger, DJICameraExposureMode){
    /**
     *  Program mode.
     */
    DJICameraExposureModeProgram,
    /**
     *  Shutter priority mode.
     */
    DJICameraExposureModeShutter,
    /**
     *  Aperture priority mode.
     */
    DJICameraExposureModeAperture,
    /**
     *  Manual mode.
     */
    DJICameraExposureModeManual,
    /**
     *  The camera exposure mode is unknown.
     */
    DJICameraExposureModeUnknown = 0xFF
};

/*********************************************************************************/
#pragma mark - Video Related
/*********************************************************************************/

/*********************************************************************************/
#pragma mark DJICameraVideoFileFormat
/*********************************************************************************/

/**
 *  Video storage formats.
 */
typedef NS_ENUM (NSUInteger, DJICameraVideoFileFormat){
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

/*********************************************************************************/
#pragma mark DJICameraVideoResolution
/*********************************************************************************/

/**
 *  Camera video resolution values. The resolutions available for a product are in `supportedCameraVideoResolutionAndFrameRateRange`.
 */
typedef NS_ENUM (NSUInteger, DJICameraVideoResolution){
    /**
     *  The camera's video resolution is 640x480.
     */
    DJICameraVideoResolution640x480,
    /**
     *  The camera's video resolution is 640x512.
     */
    DJICameraVideoResolution640x512,
    /**
     *  The camera's video resolution is 1280x720.
     */
    DJICameraVideoResolution1280x720,
    /**
     *  The camera's video resolution is 1920x1080.
     */
    DJICameraVideoResolution1920x1080,
    /**
     *  The camera's video resolution is 2704x1520.
     */
    DJICameraVideoResolution2704x1520,
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
    DJICameraVideoResolutionUnknown = 0xFF,
};

/*********************************************************************************/
#pragma mark DJICameraVideoFrameRate
/*********************************************************************************/

/**
 *  Camera video frame rate values. The frame rates available for a product are in `supportedCameraVideoResolutionAndFrameRateRange`.
 */
typedef NS_ENUM (NSUInteger, DJICameraVideoFrameRate){
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
     *  The camera's video frame rate is 120fps (frames per second). This frame
     *  rate can only be used when `isSlowMotionSupported` returns YES.
     */
    DJICameraVideoFrameRate120fps,
    
    /**
     *  The camera's video frame rate is unknown.
     */
    DJICameraVideoFrameRateUnknown = 0xFF
};

/*********************************************************************************/
#pragma mark DJICameraVideoStandard
/*********************************************************************************/

/**
 *  Video standard values. The default value is NTSC.
 */
typedef NS_ENUM (NSUInteger, DJICameraVideoStandard){
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

/*********************************************************************************/
#pragma mark DJICameraPhotoFileFormat
/*********************************************************************************/

/**
 *  Camera photo file formats. The default value is `CameraPhotoJPEG`.
 */
typedef NS_ENUM (NSUInteger, DJICameraPhotoFileFormat){
    /**
     *  The camera's photo storage format is RAW.
     */
    DJICameraPhotoFileFormatRAW,
    /**
     *  The camera's photo storage format is JPEG.
     */
    DJICameraPhotoFileFormatJPEG,
    /**
     *  The camera stores both the RAW and JPEG formats of the photo.
     */
    DJICameraPhotoFileFormatRAWAndJPEG,
    /**
     *  The camera's photo storage format is TIFF (14bit).
     *  Only supported by XT camera.
     */
    DJICameraPhotoFileFormatTIFF14Bit,
    /**
     *  The camera's photo storage format is Radiometric JPEG (a special JPEG
     *  format with temperature information). A radiometric JPEG has the .jpg
     *  suffix and can be viewed as a normal JPEG file would. At the same time,
     *  the temperature data is also stored in the file as meta data. PC
     *  software is required to analyze the file and it is accessible at FLIR's
     *  website http://www.flir.com/instruments/display/?id=54865 .
     *  Only supported by XT camera with firmware version 1.16.1.70 or above.
     */
    DJICameraPhotoFileFormatRadiometricJPEG,
    /**
     *  The camera's photo storage format is TIFF Linear Low. In this mode each
     *  pixel is 14 bits and linearly proportional with temperature, covering a
        high dynamic range of temperture which results in a lower temperature
     *  resolution.
     *  Supported only by Zenmuse XT containing Advanced Radiometry capabilities
     *  with firmware version 1.17.1.80 or lower. For newer firmwares, the
     *  temperature resolution preference is coupled with the thermal gain mode.
     */
    DJICameraPhotoFileFormatTIFF14BitLinearLowTempResolution,
    /**
     *  The camera's photo storage format is TIFF Linear High. In this mode each
     *  pixel is 14 bits and linearly proportional with temperature, covering a
     *  low dynamic range of temperture which results in a higher temperature
     *  resolution.
     *  Supported only by Zenmuse XT containing Advanced Radiometry capabilities
     *  with firmware version 1.17.1.80 or lower. For newer firmwares, the
     *  temperature resolution preference is coupled with the thermal gain mode.
     */
    DJICameraPhotoFileFormatTIFF14BitLinearHighTempResolution,
    /**
     *  The camera's photo storage format is unknown.
     */
    DJICameraPhotoFileFormatUnknown = 0xFF
};

/*********************************************************************************/
#pragma mark DJICameraPhotoTimeLapseFileFormat
/*********************************************************************************/

/**
 *  File format for camera when it is in time-lapse mode. The default file
 *  format is video. If video+JPEG is selected the minimum interval will be 2
 *  seconds.
 */
typedef NS_ENUM (NSUInteger, DJICameraPhotoTimeLapseFileFormat) {
    /**
     *  The camera in time-lapse mode will generate video
     */
    DJICameraPhotoTimeLapseFileFormatVideo = 0x00,
    /**
     *  The camera in time-lapse mode will generate video and JPEG
     */
    DJICameraPhotoTimeLapseFileFormatVideoAndJPEG,
    /**
     *  The file format is unknown
     */
    DJICameraPhotoTimeLapseFileFormatUnknown = 0xFF
};

/*********************************************************************************/
#pragma mark DJICameraPhotoQuality
/*********************************************************************************/

/**
 *  Photo quality of the JPEG image. Higher photo quality results in larger file
 *  size. The default value is `CameraPhotoQualityExcellent`.
 */
typedef NS_ENUM (NSUInteger, DJICameraPhotoQuality){
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

/*********************************************************************************/
#pragma mark DJICameraPhotoAspectRatio
/*********************************************************************************/

/**
 *  Photo aspect ratio, where the first value is the width and the
 *  second value is the height. The default value is `CameraPhotoRatio4_3`.
 */
typedef NS_ENUM (NSUInteger, DJICameraPhotoAspectRatio){
    /**
     *  The camera's photo ratio is 4 : 3.
     */
    DJICameraPhotoAspectRatio4_3 = 0x00,
    /**
     *  The camera's photo ratio is 16 : 9.
     */
    DJICameraPhotoAspectRatio16_9 = 0x01,
    /**
     *  the camera's photo ratio is 3:2
     */
    DJICameraPhotoAspectRatio3_2 = 0x02,
    /**
     *  The camera's photo ratio is unknown.
     */
    DJICameraPhotoAspectRatioUnknown = 0xFF
};


/*********************************************************************************/
#pragma mark DJICameraPhotoBurstCount
/*********************************************************************************/

/**
 *  The number of photos taken in one burst shot (shooting photo in burst mode).
 */
typedef NS_ENUM (NSUInteger, DJICameraPhotoBurstCount){
    /**
     *  The camera burst shoot count is set to capture 3 pictures at once when
     *  the camera shoots a photo.
     */
    DJICameraPhotoBurstCount3 = 0x03,
    /**
     *  The camera burst shoot count is set to capture 5 pictures at once when
     *  the camera takes a photo.
     */
    DJICameraPhotoBurstCount5 = 0x05,
    /**
     *  The camera burst shoot count is set to capture 7 pictures at once when
     *  the camera takes a photo.
     */
    DJICameraPhotoBurstCount7 = 0x07,
    /**
     *  The camera burst shoot count value is unknown.
     */
    DJICameraPhotoBurstCountUnknown = 0xFF
};

/*********************************************************************************/
#pragma mark DJICameraPhotoAEBParam
/*********************************************************************************/

/**
 *  AEB continuous capture parameter values.
 */
typedef struct
{
    /**
     *  Exposure offset value (EV). A value is mapped to an exposure offset.
     *  2 = 0.3EV, 3 = 0.7EV, 4 = 1.0EV, 5 = 1.3EV, 6 = 1.7EV, 7 = 2.0EV,
     *  8 = 2.3EV, 9 = 2.7EV, 10 = 3.0ev.
     *  The default value is 2.3ev.
     *  When captureCount is 3, the valid range for exposureOffset is [2, 10].
     *  When captureCount is 5, the valid range for exposureOffset is [2, 5].
     */
    uint8_t exposureOffset;
    /**
     *  The number of pictures to continuously take at one time.
     *  If the exposureOffest is larger than 5, the captureCount can only be 3.
     *  Otherwise, the value can only be 3 or 5.
     *  The default value is 3.
     */
    uint8_t captureCount;
} DJICameraPhotoAEBParam;

/*********************************************************************************/
#pragma mark DJICameraPhotoIntervalParam
/*********************************************************************************/

/**
 *  Sets the number of pictures, and sets the time interval between pictures for
 *  the Interval shoot photo mode.
 */
typedef struct
{
    /**
     *  The number of photos to capture. The value range is [2, 255].
     *  If 255 is selected, then the camera will continue to take pictures until
     *  stopShootPhotoWithCompletion is called.
     *  For thermal imaging camera, it can only be set to 255.
     */
    uint8_t captureCount;
    
    /**
     *  The time interval between when two photos are taken. The range for this
     *  parameter depends the photo file format(DJICameraPhotoFileFormat).
     *  For XT camera, the range is [1, 60] seconds.
     *  For all other products, when the file format is JPEG, the range is
     *  [2, 2^16 - 1] seconds; when the file format is RAW or RAW+JPEG, the
     *  range is [10, 2^16 - 1] seconds.
     */
    uint16_t timeIntervalInSeconds;
} DJICameraPhotoIntervalParam;

/*********************************************************************************/
#pragma mark - Camera advanced settings
/*********************************************************************************/

/*********************************************************************************/
#pragma mark DJICameraShutterSpeed
/*********************************************************************************/

/**
 *  Camera's shutter speed options.
 */
typedef NS_ENUM (NSUInteger, DJICameraShutterSpeed) {
    /**
     *  Camera's shutter speed 1/8000 s.
     */
    DJICameraShutterSpeed1_8000 = 0x00,
    /**
     *  Camera's shutter speed 1/6400 s.
     */
    DJICameraShutterSpeed1_6400 = 0x01,
    /**
     *  Camera's shutter speed 1/5000 s.
     */
    DJICameraShutterSpeed1_5000 = 0x02,
    /**
     *  Camera's shutter speed 1/4000 s.
     */
    DJICameraShutterSpeed1_4000 = 0x03,
    /**
     *  Camera's shutter speed 1/3200 s.
     */
    DJICameraShutterSpeed1_3200 = 0x04,
    /**
     *  Camera's shutter speed 1/2500 s.
     */
    DJICameraShutterSpeed1_2500 = 0x05,
    /**
     *  Camera's shutter speed 1/2000 s.
     */
    DJICameraShutterSpeed1_2000 = 0x06,
    /**
     *  Camera's shutter speed 1/1600 s.
     */
    DJICameraShutterSpeed1_1600 = 0x07,
    /**
     *  Camera's shutter speed 1/1250 s.
     */
    DJICameraShutterSpeed1_1250 = 0x08,
    /**
     *  Camera's shutter speed 1/1000 s.
     */
    DJICameraShutterSpeed1_1000 = 0x09,
    /**
     *  Camera's shutter speed 1/800 s.
     */
    DJICameraShutterSpeed1_800 = 0x0A,
    /**
     *  Camera's shutter speed 1/640 s.
     */
    DJICameraShutterSpeed1_640 = 0x0B,
    /**
     *  Camera's shutter speed 1/500 s.
     */
    DJICameraShutterSpeed1_500 = 0x0C,
    /**
     *  Camera's shutter speed 1/400 s.
     */
    DJICameraShutterSpeed1_400 = 0x0D,
    /**
     *  Camera's shutter speed 1/320 s.
     */
    DJICameraShutterSpeed1_320 = 0x0E,
    /**
     *  Camera's shutter speed 1/240 s.
     */
    DJICameraShutterSpeed1_240 = 0x0F,
    /**
     *  Camera's shutter speed 1/200 s.
     */
    DJICameraShutterSpeed1_200 = 0x10,
    /**
     *  Camera's shutter speed 1/160 s.
     */
    DJICameraShutterSpeed1_160 = 0x11,
    /**
     *  Camera's shutter speed 1/120 s.
     */
    DJICameraShutterSpeed1_120 = 0x12,
    /**
     *  Camera's shutter speed 1/100 s.
     */
    DJICameraShutterSpeed1_100 = 0x13,
    /**
     *  Camera's shutter speed 1/80 s.
     */
    DJICameraShutterSpeed1_80 = 0x14,
    /**
     *  Camera's shutter speed 1/60 s.
     */
    DJICameraShutterSpeed1_60 = 0x15,
    /**
     *  Camera's shutter speed 1/50 s.
     */
    DJICameraShutterSpeed1_50 = 0x16,
    /**
     *  Camera's shutter speed 1/40 s.
     */
    DJICameraShutterSpeed1_40 = 0x17,
    /**
     *  Camera's shutter speed 1/30 s.
     */
    DJICameraShutterSpeed1_30 = 0x18,
    /**
     *  Camera's shutter speed 1/25 s.
     */
    DJICameraShutterSpeed1_25 = 0x19,
    /**
     *  Camera's shutter speed 1/20 s.
     */
    DJICameraShutterSpeed1_20 = 0x1A,
    /**
     *  Camera's shutter speed 1/15 s.
     */
    DJICameraShutterSpeed1_15 = 0x1B,
    /**
     *  Camera's shutter speed 1/12.5 s.
     */
    DJICameraShutterSpeed1_12p5 = 0x1C,
    /**
     *  Camera's shutter speed 1/10 s.
     */
    DJICameraShutterSpeed1_10 = 0x1D,
    /**
     *  Camera's shutter speed 1/8 s.
     */
    DJICameraShutterSpeed1_8 = 0x1E,
    /**
     *  Camera's shutter speed 1/6.25 s.
     */
    DJICameraShutterSpeed1_6p25 = 0x1F,
    /**
     *  Camera's shutter speed 1/5 s.
     */
    DJICameraShutterSpeed1_5 = 0x20,
    /**
     *  Camera's shutter speed 1/4 s.
     */
    DJICameraShutterSpeed1_4 = 0x21,
    /**
     *  Camera's shutter speed 1/3 s.
     */
    DJICameraShutterSpeed1_3 = 0x22,
    /**
     *  Camera's shutter speed 1/2.5 s.
     */
    DJICameraShutterSpeed1_2p5 = 0x23,
    /**
     *  Camera's shutter speed 1/2 s.
     */
    DJICameraShutterSpeed1_2 = 0x24,
    /**
     *  Camera's shutter speed 1/1.67 s.
     */
    DJICameraShutterSpeed1_1p67 = 0x25,
    /**
     *  Camera's shutter speed 1/1.25 s.
     */
    DJICameraShutterSpeed1_1p25 = 0x26,
    /**
     *  Camera's shutter speed 1.0 s.
     */
    DJICameraShutterSpeed1p0 = 0x27,
    /**
     *  Camera's shutter speed 1.3 s.
     */
    DJICameraShutterSpeed1p3 = 0x28,
    /**
     *  Camera's shutter speed 1.6 s.
     */
    DJICameraShutterSpeed1p6 = 0x29,
    /**
     *  Camera's shutter speed 2.0 s.
     */
    DJICameraShutterSpeed2p0 = 0x2A,
    /**
     *  Camera's shutter speed 2.5 s.
     */
    DJICameraShutterSpeed2p5 = 0x2B,
    /**
     *  Camera's shutter speed 3.0 s.
     */
    DJICameraShutterSpeed3p0 = 0x2C,
    /**
     *  Camera's shutter speed 3.2 s.
     */
    DJICameraShutterSpeed3p2 = 0x2D,
    /**
     *  Camera's shutter speed 4.0 s.
     */
    DJICameraShutterSpeed4p0 = 0x2E,
    /**
     *  Camera's shutter speed 5.0 s.
     */
    DJICameraShutterSpeed5p0 = 0x2F,
    /**
     *  Camera's shutter speed 6.0 s.
     */
    DJICameraShutterSpeed6p0 = 0x30,
    /**
     *  Camera's shutter speed 7.0 s.
     */
    DJICameraShutterSpeed7p0 = 0x31,
    /**
     *  Camera's shutter speed 8.0 s.
     */
    DJICameraShutterSpeed8p0 = 0x32,
    /**
     *  Camera's shutter speed 9.0 s.
     */
    DJICameraShutterSpeed9p0 = 0x33,
    /**
     *  Camera's shutter speed 10.0 s.
     */
    DJICameraShutterSpeed10p0 = 0x34,
    /**
     *  Camera's shutter speed 13.0 s.
     */
    DJICameraShutterSpeed13p0 = 0x35,
    /**
     *  Camera's shutter speed 15.0 s.
     */
    DJICameraShutterSpeed15p0 = 0x36,
    /**
     *  Camera's shutter speed 20.0 s.
     */
    DJICameraShutterSpeed20p0 = 0x37,
    /**
     *  Camera's shutter speed 25.0 s.
     */
    DJICameraShutterSpeed25p0 = 0x38,
    /**
     *  Camera's shutter speed 30.0 s.
     */
    DJICameraShutterSpeed30p0 = 0x39,
    /**
     *  Camera's shutter speed unknown.
     */
    DJICameraShutterSpeedUnknown = 0xFF
};


/*********************************************************************************/
#pragma mark DJICameraISO
/*********************************************************************************/

/**
 *  Camera ISO values.
 */
typedef NS_ENUM (NSUInteger, DJICameraISO){
    /**
     *  The ISO value is automatically set. This cannot be used for all cameras
     *  when in Manual mode.
     */
    DJICameraISOAuto = 0x00,
    /**
     *  The ISO value is set to 100.
     */
    DJICameraISO100 = 0x01,
    /**
     *  The ISO value is set to 200.
     */
    DJICameraISO200 = 0x02,
    /**
     *  The ISO value is set to 400.
     */
    DJICameraISO400 = 0x03,
    /**
     *  The ISO value is set to 800.
     */
    DJICameraISO800 = 0x04,
    /**
     *  The ISO value is set to 1600.
     */
    DJICameraISO1600 = 0x05,
    /**
     *  The ISO value is set to 3200.
     */
    DJICameraISO3200 = 0x06,
    /**
     *  The ISO value is set to 6400.
     */
    DJICameraISO6400 = 0x07,
    /**
     *  The ISO value is set to 12800.
     */
    DJICameraISO12800 = 0x08,
    /**
     *  The ISO value is set to 25600.
     */
    DJICameraISO25600 = 0x09,
    /**
     *  The ISO value is set to an unknown value.
     */
    DJICameraISOUnknown = 0xFF
};

/*********************************************************************************/
#pragma mark DJICameraAperture
/*********************************************************************************/

/**
 *  Camera aperture values. Currently only the X5 and X5R cameras support
 *  this setting.
 */
typedef NS_ENUM (NSUInteger, DJICameraAperture) {
    /**
     *  The Aperture value is f/1.7.
     */
    DJICameraApertureF1p7,
    /**
     *  The Aperture value is f/1.8.
     */
    DJICameraApertureF1p8,
    /**
     *  The Aperture value is f/2.
     */
    DJICameraApertureF2,
    /**
     *  The Aperture value is f/2.2.
     */
    DJICameraApertureF2p2,
    /**
     *  The Aperture value is f/2.5.
     */
    DJICameraApertureF2p5,
    /**
     *  The Aperture value is f/2.8.
     */
    DJICameraApertureF2p8,
    /**
     *  The Aperture value is f/3.2.
     */
    DJICameraApertureF3p2,
    /**
     *  The Aperture value is f/3.5.
     */
    DJICameraApertureF3p5,
    /**
     *  The Aperture value is f/4.
     */
    DJICameraApertureF4,
    /**
     *  The Aperture value is f/4.5.
     */
    DJICameraApertureF4p5,
    /**
     *  The Aperture value is f/5.
     */
    DJICameraApertureF5,
    /**
     *  The Aperture value is f/5.6.
     */
    DJICameraApertureF5p6,
    /**
     *  The Aperture value is f/6.3.
     */
    DJICameraApertureF6p3,
    /**
     *  The Aperture value is f/7.1.
     */
    DJICameraApertureF7p1,
    /**
     *  The Aperture value is f/8.
     */
    DJICameraApertureF8,
    /**
     *  The Aperture value is f/9.
     */
    DJICameraApertureF9,
    /**
     *  The Aperture value is f/10.
     */
    DJICameraApertureF10,
    /**
     *  The Aperture value is f/11.
     */
    DJICameraApertureF11,
    /**
     *  The Aperture value is f/13.
     */
    DJICameraApertureF13,
    /**
     *  The Aperture value is f/14.
     */
    DJICameraApertureF14,
    /**
     *  The Aperture value is f/16.
     */
    DJICameraApertureF16,
    /**
     *  The Aperture value is f/18.
     */
    DJICameraApertureF18,
    /**
     *  The Aperture value is f/20.
     */
    DJICameraApertureF20,
    /**
     *  The Aperture value is f/22.
     */
    DJICameraApertureF22,
    /**
     *  The Aperture value is Unknown.
     */
    DJICameraApertureUnknown = 0xFF
};

/*********************************************************************************/
#pragma mark DJICameraWhiteBalance
/*********************************************************************************/

/**
 *  Camera white balance. The default value is `CameraWhiteBalanceAuto`.
 */
typedef NS_ENUM (NSUInteger, DJICameraWhiteBalance){
    /**
     *  The camera's white balance is automatically set.
     */
    DJICameraWhiteBalanceAuto = 0x00,
    /**
     *  The camera's white balance is set to sunny.
     */
    DJICameraWhiteBalanceSunny = 0x01,
    /**
     *  The camera's white balance is set to cloudy.
     */
    DJICameraWhiteBalanceCloudy = 0x02,
    /**
     *  The camera's white balance is set to water surface.
     */
    DJICameraWhiteBalanceWaterSuface = 0x03,
    /**
     *  The camera's white balance is set to indoors and incandescent light.
     */
    DJICameraWhiteBalanceIndoorsIncandescent = 0x04,
    /**
     *  The camera's white balance is set to indoors and fluorescent light.
     */
    DJICameraWhiteBalanceIndoorsFluorescent = 0x05,
    /**
     *  The camera's white balance is set to custom color temperature.
     *  By using this white balance value, user can set a specific value for the
     *  color temperature.
     */
    DJICameraWhiteBalanceCustomColorTemperature = 0x06,
    /**
     *  The camera's white balance is unknown.
     */
    DJICameraWhiteBalanceUnknown = 0xFF
};

/*********************************************************************************/
#pragma mark DJICameraMeteringMode
/*********************************************************************************/

/**
 *  Camera exposure metering. The default value is `CameraExposureMeteringCenter`.
 */
typedef NS_ENUM (NSUInteger, DJICameraMeteringMode){
    /**
     *  The camera's exposure metering is set to the center.
     */
    DJICameraMeteringModeCenter = 0x00,
    /**
     *  The camera's exposure metering is set to average.
     */
    DJICameraMeteringModeAverage = 0x01,
    /**
     *  The camera's exposure metering is set to a single spot.
     */
    DJICameraMeteringModeSpot = 0x02,
    /**
     *  The camera's exposure metering is unknown.
     */
    DJICameraMeteringModeUnknown = 0xFF
};

/*********************************************************************************/
#pragma mark DJICameraExposureCompensation
/*********************************************************************************/

/**
 *  Camera exposure compensation.
 */
typedef NS_ENUM (NSUInteger, DJICameraExposureCompensation){
    /**
     *  The camera's exposure compensation is -5.0ev.
     */
    DJICameraExposureCompensationN50 = 0x01,
    /**
     *  The camera's exposure compensation is -4.7ev.
     */
    DJICameraExposureCompensationN47,
    /**
     *  The camera's exposure compensation is -4.3ev.
     */
    DJICameraExposureCompensationN43,
    /**
     *  The camera's exposure compensation is -4.0ev.
     */
    DJICameraExposureCompensationN40,
    /**
     *  The camera's exposure compensation is -3.7ev.
     */
    DJICameraExposureCompensationN37,
    /**
     *  The camera's exposure compensation is -3.3ev.
     */
    DJICameraExposureCompensationN33,
    /**
     *  The camera's exposure compensation is -3.0ev.
     */
    DJICameraExposureCompensationN30,
    /**
     *  The camera's exposure compensation is -2.7ev.
     */
    DJICameraExposureCompensationN27,
    /**
     *  The camera's exposure compensation is -2.3ev.
     */
    DJICameraExposureCompensationN23,
    /**
     *  The camera's exposure compensation is -2.0ev.
     */
    DJICameraExposureCompensationN20,
    /**
     *  The camera's exposure compensation is -1.7ev.
     */
    DJICameraExposureCompensationN17,
    /**
     *  The camera's exposure compensation is -1.3ev.
     */
    DJICameraExposureCompensationN13,
    /**
     *  The camera's exposure compensation is -1.0ev.
     */
    DJICameraExposureCompensationN10,
    /**
     *  The camera's exposure compensation is -0.7ev.
     */
    DJICameraExposureCompensationN07,
    /**
     *  The camera's exposure compensation is -0.3ev.
     */
    DJICameraExposureCompensationN03,
    /**
     *  The camera's exposure compensation is 0.0ev.
     */
    DJICameraExposureCompensationN00,
    /**
     *  The camera's exposure compensation is +0.3ev.
     */
    DJICameraExposureCompensationP03,
    /**
     *  The camera's exposure compensation is +0.7ev.
     */
    DJICameraExposureCompensationP07,
    /**
     *  The camera's exposure compensation is +1.0ev.
     */
    DJICameraExposureCompensationP10,
    /**
     *  The camera's exposure compensation is +1.3ev.
     */
    DJICameraExposureCompensationP13,
    /**
     *  The camera's exposure compensation is +1.7ev.
     */
    DJICameraExposureCompensationP17,
    /**
     *  The camera's exposure compensation is +2.0ev.
     */
    DJICameraExposureCompensationP20,
    /**
     *  The camera's exposure compensation is +2.3ev.
     */
    DJICameraExposureCompensationP23,
    /**
     *  The camera's exposure compensation is +2.7ev.
     */
    DJICameraExposureCompensationP27,
    /**
     *  The camera's exposure compensation is +3.0ev.
     */
    DJICameraExposureCompensationP30,
    /**
     *  The camera's exposure compensation is +3.3ev.
     */
    DJICameraExposureCompensationP33,
    /**
     *  The camera's exposure compensation is +3.7ev.
     */
    DJICameraExposureCompensationP37,
    /**
     *  The camera's exposure compensation is +4.0ev.
     */
    DJICameraExposureCompensationP40,
    /**
     *  The camera's exposure compensation is +4.3ev.
     */
    DJICameraExposureCompensationP43,
    /**
     *  The camera's exposure compensation is +4.7ev.
     */
    DJICameraExposureCompensationP47,
    /**
     *  The camera's exposure compensation is +5.0ev.
     */
    DJICameraExposureCompensationP50,
    /**
     *  The camera's exposure compensation is unknown.
     */
    DJICameraExposureCompensationUnknown = 0xFF
};

/*********************************************************************************/
#pragma mark DJICameraAntiFlicker
/*********************************************************************************/

/**
 *  Camera anti-flickers. The default value is `CameraAntiFlicker50Hz`.
 */
typedef NS_ENUM (NSUInteger, DJICameraAntiFlicker){
    /**
     *  The camera's anti-flicker is automatically set.
     */
    DJICameraAntiFlickerAuto = 0x00,
    /**
     *  The camera's anti-flicker is 60 Hz.
     */
    DJICameraAntiFlicker60Hz = 0x01,
    /**
     *  The camera's anti-flicker is 50 Hz.
     */
    DJICameraAntiFlicker50Hz = 0x02,
    /**
     *  The camera's anti-flicker is unknown.
     */
    DJICameraAntiFlickerUnknown = 0xFF
};

/*********************************************************************************/
#pragma mark DJICameraSharpness
/*********************************************************************************/

/**
 *  Camera sharpnesss. The default value is `CameraSharpnessStandard`.
 */
typedef NS_ENUM (NSUInteger, DJICameraSharpness){
    /**
     *  The camera's sharpness is set to standard.
     */
    DJICameraSharpnessStandard = 0x00,
    /**
     *  The camera's sharpness is set to hard.
     */
    DJICameraSharpnessHard = 0x01,
    /**
     *  The camera's sharpness is set to soft.
     */
    DJICameraSharpnessSoft = 0x02,
    /**
     *  The camera's sharpness is set to unknown.
     */
    DJICameraSharpnessUnknown = 0xFF
};

/*********************************************************************************/
#pragma mark DJICameraContrast
/*********************************************************************************/

/**
 *  Camera contrast. The default value is `CameraContrastStandard`.
 */
typedef NS_ENUM (NSUInteger, DJICameraContrast){
    /**
     *  The camera's contrast is set to standard.
     */
    DJICameraContrastStandard = 0x00,
    /**
     *  The camera's contrast is set to hard.
     */
    DJICameraContrastHard = 0x01,
    /**
     *  The camera's contrast is set to soft.
     */
    DJICameraContrastSoft = 0x02,
    /**
     *  The camera's contrast is unknown.
     */
    DJICameraContrastUnknown = 0xFF
};

/*********************************************************************************/
#pragma mark - DJICameraExposureParameters
/*********************************************************************************/

/**
 *  This class contains current values for some camera parameters related to
 *  exposure, which determines how sensitive the picture is to light and depends
 *  on the balance of the ISO value, the shutter speed, and the aperture value.
 *  When the camera is in different exposure modes, different parameters are
 *  automatically changed by the camera to either get the correct exposure (in 
 *  Program, Shutter Priority and Aperture Priority modes), or report back the 
 *  current exposure (in Manual mode). The current values of these parameters
 *  used by the camera are contained in this class.
 */

typedef struct{
    /**
     *  Camera aperture value. A larger aperture results in a higher exposure
     *  and shallower depth of field.
     */
    DJICameraAperture aperture;
    
    /**
     *  Camera shutter speed. A slower shutter speed results in a higher
     *  exposure, but more blurring in areas of the scene that are moving.
     */
    DJICameraShutterSpeed shutterSpeed;
    
    /**
     *  Camera ISO. A higher ISO results in a higher exposure, and more noise in
     *  the resulting image.
     */
    NSUInteger iso;
    
    /**
     *  Returns the camera's current exposure compensation. In Program, Aperture
     *  Priority and Shutter Priority modes, the exposure compensation value 
     *  changes the exposure target the camera is using to calculate correct
     *  exposure and is set by the user. For example, Aperture Priority mode
     *  indicates that the priority is to maintain the aperture setting and
     *  adjusting the exposure by varying the ISO and shutter speed. In Manual
     *  mode, this value is reported from the camera and reports how much the 
     *  exposure needs to be compensated for to get to what the camera thinks is
     *  the correct exposure.
     *  In Manual mode, the range of exposure compensation reported by the
     *  camera is -2.0 EV to 2.0 EV. In Program, Aperture Priority and Shutter
     *  Priority modes, the range of exposure compensation is -3.0 EV to + 3.0
     *  EV.
     */
    DJICameraExposureCompensation exposureCompensation;
}DJICameraExposureParameters;

/*********************************************************************************/
#pragma mark - Lens related
/*********************************************************************************/

/*********************************************************************************/
#pragma mark DJICameraLensFocusMode
/*********************************************************************************/

/**
 *  Camera focus mode.
 *  It is settable only when `IsAdjustableFocalPointSupported` returns YES and
 *  the physical AF switch on the camera is set to auto.
 */
typedef NS_ENUM (NSUInteger, DJICameraLensFocusMode){
    /**
     *  The camera's focus mode is set to manual.
     *  In this mode, user sets the focus ring value to adjust the focal distance.
     */
    DJICameraLensFocusModeManual,
    /**
     *  The camera's focus mode is set to auto.
     *  In this mode, user sets the lens focus target to adjust the focal point.
     */
    DJICameraLensFocusModeAuto,
    /**
     *  The camera's focus mode is unknown.
     */
    DJICameraLensFocusModeUnknown = 0xFF
};

/*********************************************************************************/
#pragma mark DJILensType
/*********************************************************************************/

/**
 *  The type of the installed lens.
 */
typedef NS_ENUM (NSUInteger, DJILensType) {
    /**
     *  The lens supports Auto Focus (AF).
     *  For this type, the DJI SDK can control the focus point.
     */
    DJILensTypeAF,
    /**
     *  The lens supports only Manual Focus.
     *  For this type, the DJI SDK cannot control the focus point.
     */
    DJILensTypeMF,
    /**
     *  The lens type is unknown.
     */
    DJILensTypeUnknown
};

/*********************************************************************************/
#pragma mark DJICameraLensFocusStatus
/*********************************************************************************/

/**
 *  The focusing status of the camera's lens.
 */
typedef NS_ENUM (NSUInteger, DJICameraLensFocusStatus) {
    /**
     *  The lens is idle. No focus target has been set.
     */
    DJICameraLensFocusStatusIdle = 0x00,
    /**
     *  The lens is focusing on the target.
     */
    DJICameraLensFocusStatusFocusing,
    /**
     *  The lens succeeded to focus on the target.
     */
    DJICameraLensFocusStatusSuccess,
    /**
     *  The lens failed to focus on the target.
     *  This happens when the target is too close, or the camera cannot
     *  distinguish the object to focus (e.g. a white wall).
     */
    DJICameraLensFocusStatusFailure
};

/*********************************************************************************/
#pragma mark - SSD related
/*********************************************************************************/

/*********************************************************************************/
#pragma mark DJICameraSSDOperationState
/*********************************************************************************/

/**
 *  Solid State Drive (SSD) State
 */
typedef NS_ENUM (NSUInteger, DJICameraSSDOperationState) {
    
    /**
     *  SSD is not found.
     */
    DJICameraSSDOperationStateNotFound,
    /**
     *  SSD is idle.
     */
    DJICameraSSDOperationStateIdle,
    /**
     *  SSD is Saving.
     */
    DJICameraSSDOperationStateSaving,
    /**
     *  SSD is formatting.
     */
    DJICameraSSDOperationStateFormatting,
    /**
     *  SSD is Initializing.
     */
    DJICameraSSDOperationStateInitializing,
    /**
     *  SSD validation error.
     */
    DJICameraSSDOperationStateError,
    /**
     *  SSD is full.
     */
    DJICameraSSDOperationStateFull,
    /**
     *  SSD state is unknown. This happens in the first 2 seconds after turning
     *  the camera power on as during this time the camera cannot check the
     *  state of the SSD.
     */
    DJICameraSSDOperationStateUnknown = 0xFF,
};

/*********************************************************************************/
#pragma mark DJICameraSSDCapacity
/*********************************************************************************/

/**
 *  Solid State Drive (SSD) Capacity
 */
typedef NS_ENUM (NSUInteger, DJICameraSSDCapacity) {
    /**
     *  SSD capacity is 256G.
     */
    DJICameraSSDCapacity256G,
    /**
     *  SSD capacity is 512G.
     */
    DJICameraSSDCapacity512G,
    /**
     *  SSD capacity is 1T.
     */
    DJICameraSSDCapacity1T,
    /**
     *  SSD capacity is unknown.
     */
    DJICameraSSDCapacityUnknown = 0xFF,
};


/*********************************************************************************/
#pragma mark - Thermal Imaging Camera Related
/*********************************************************************************/

/*********************************************************************************/
#pragma mark DJICameraThermalROI (Region Of Interest)
/*********************************************************************************/

/**
 *  Region of interest. Use this feature to manage color range distribution
 *  across the screen to maximize contrast for regions of highest interest.
 *  Supported only by thermal imaging cameras.
 */
typedef NS_ENUM(NSUInteger, DJICameraThermalROI) {
    /**
     *  Causes the color spectrum to be evenly distributed across the entire
     *  image depending the default settings.
     */
    DJICameraThermalROIFull,
    /**
     *  Ignores areas of the sky 33% so that most of the spectrum can be
     *  allocated to remaining areas, providing higher contrast and utility for
     *  analysis.
     */
    DJICameraThermalROISkyExcluded33,
    /**
     *  Ignores areas of the sky 50% so that most of the spectrum can be
     *  allocated to remaining areas, providing higher contrast and utility for
     *  analysis.
     */
    DJICameraThermalROISkyExcluded50,
    /**
     *  The ROI type is unknown.
     */
    DJICameraThermalROIUnknown = 0xFF
};

/*********************************************************************************/
#pragma mark DJICameraThermalPalette
/*********************************************************************************/

/**
 *  The different colors are used to show various temperatures in the thermal
 *  imagery image. The colors are not actually related to wavelengths of light,
 *  but rather the grayscale intensity.
 *  Supported only by thermal imaging cameras.
 */
typedef NS_ENUM(NSUInteger, DJICameraThermalPalette) {
    /**
     *  Without Isotherm enabled, the Palette type is WhiteHot. With Isotherm
     *  enabled, the Palette type is WhiteHotIso.
     */
    DJICameraThermalPaletteWhiteHot,
    /**
     *  Without Isotherm enabled, the Palette type is BlackHot. With Isotherm
     *  enabled, the Palette type is BlackHotIso.
     */
    DJICameraThermalPaletteBlackHot,
    /**
     *  Without Isotherm enabled, the Palette type is RedHot. With Isotherm
     *  enabled, the Palette type is RedHotIso.
     */
    DJICameraThermalPaletteRedHot,
    /**
     *  Without Isotherm enabled, the Palette type is GreenHot. With Isotherm
     *  enabled, the Palette type is GreenHotIso.
     */
    DJICameraThermalPaletteGreenHot,
    /**
     *  Without Isotherm enabled, the Palette type is Fusion. With Isotherm
     *  enabled, the Palette type is FusionIso.
     */
    DJICameraThermalPaletteFusion,
    /**
     *  Without Isotherm enabled, the Palette type is Rainbow. With Isotherm
     *  enabled, the Palette type is RainbowIso.
     */
    DJICameraThermalPaletteRainbow,
    /**
     *  Without Isotherm enabled, the Palette type is Ironbow1. With Isotherm
     *  enabled, the Palette type is IronbowWHIso.
     */
    DJICameraThermalPaletteIronbow1,
    /**
     *  Without Isotherm enabled, the Palette type is Ironbow2. With Isotherm
     *  enabled, the Palette type is IronbowBHIso.
     */
    DJICameraThermalPaletteIronbow2,
    /**
     *  Without Isotherm enabled, the Palette type is IceFire. With Isotherm
     *  enabled, the Palette type is IceFireIso.
     */
    DJICameraThermalPaletteIceFire,
    /**
     *  Without Isotherm enabled, the Palette type is Sepia. With Isotherm
     *  enabled, the Palette type is SepiaIso.
     */
    DJICameraThermalPaletteSepia,
    /**
     *  Without Isotherm enabled, the Palette type is Glowbow. With Isotherm
     *  enabled, the Palette type is GlowbowIso.
     */
    DJICameraThermalPaletteGlowbow,
    /**
     *  Without Isotherm enabled, the Palette type is Color1. With Isotherm
     *  enabled, the Palette type is MidRangeWHIso.
     */
    DJICameraThermalPaletteColor1,
    /**
     *  Without Isotherm enabled, the Palette type is Color2. With Isotherm
     *  enabled, the Palette type is MidRangeBHIso.
     */
    DJICameraThermalPaletteColor2,
    /**
     *  Without Isotherm enabled, the Palette type is Rain. With Isotherm
     *  enabled, the Palette type is RainbowHCIso.
     */
    DJICameraThermalPaletteRain,
    /**
     *  The palette type is unknown.
     */
    DJICameraThermalPaletteUnknown = 0xFF
};

/*********************************************************************************/
#pragma mark DJICameraThermalScene
/*********************************************************************************/

/**
 *  Uses the Scene option to instantly enhance your image.
 *  Supported only by thermal imaging cameras.
 */
typedef NS_ENUM(NSUInteger, DJICameraThermalScene) {
    /**
     *  Lienarly transforms the 14-bit sensor pixel data to 8-bit JPEG/MP4 pixel
     *  data.
     */
    DJICameraThermalSceneLinear,
    /**
     *  Automatically adjusts DDE, ACE, SSO, brightness and contrast.
     */
    DJICameraThermalSceneDefault,
    /**
     *  Automatically adjusts DDE, ACE, SSO, brightness and contrast with presets
     *  optimized for scenes composed of the sea and the sky scenes.
     */
    DJICameraThermalSceneSeaSky,
    /**
     *  Automatically adjusts DDE, ACE, SSO, brightness and contrast with presets
     *  optimized for outdoor scenes.
     */
    DJICameraThermalSceneOutdoor,
    /**
     *  Automatically adjusts DDE, ACE, SSO, brightness and contrast with presets
     *  optimized for indoor scenes.
     */
    DJICameraThermalSceneIndoor,
    /**
     *  Allows manual setting of DDE, ACE, SSO, brightness and contrast.
     */
    DJICameraThermalSceneManual,
    /**
     *  First saved settings of DDE, ACE, SSO, brightness and contrast.
     */
    DJICameraThermalSceneUser1,
    /**
     *  Second saved settings of DDE, ACE, SSO, brightness and contrast.
     */
    DJICameraThermalSceneUser2,
    /**
     *  Third saved settings of DDE, ACE, SSO, brightness and contrast.
     */
    DJICameraThermalSceneUser3,
    /**
     *  The Scene type is unknown.
     */
    DJICameraThermalSceneUnknown = 0xFF
};

/*********************************************************************************/
#pragma mark DJICameraThermalIsothermUnit
/*********************************************************************************/

/**
 *  The unit for Isotherm.
 *  Supported only by thermal imaging cameras.
 */
typedef NS_ENUM(NSUInteger, DJICameraThermalIsothermUnit) {
    /**
     *  The unit type is percentage. The allowed range is [0, 100].
     */
    DJICameraThermalIsothermUnitPercentage,
    /**
     *  The unit type is degrees Celsius. The allowed range is [-40, 1000].
     */
    DJICameraThermalIsothermUnitCelsius,
    /**
     *  The unit type is unknown.
     */
    DJICameraThermalIsothermUnitUnknown = 0xFF
};

/*********************************************************************************/
#pragma mark DJICameraThermalGainMode
/*********************************************************************************/

/**
 *  The gain mode.
 *  Supported only by thermal imaging cameras.
 */
typedef NS_ENUM(NSUInteger, DJICameraThermalGainMode) {
    /**
     *  The camera will automatically select the optimal gain mode according to
     *  the temperature range of the image.
     */
    DJICameraThermalGainModeAuto,
    /**
     *  The camera covers a wider temperature range but is less sensitive to
     *  temperature differences.
     */
    DJICameraThermalGainModeLow,
    /**
     *  The camera covers a smaller temperature range but is more sensitive to
     *  temperature differences.
     */
    DJICameraThermalGainModeHigh,
    /**
     *  The gain mode is unknown.
     */
    DJICameraThermalGainModeUnknown = 0xFF
};

/*********************************************************************************/
#pragma mark DJICameraThermalResolution
/*********************************************************************************/

/**
 *  The resolution of thermal imaging camera.
 *  Supported only by thermal imaging cameras.
 */
typedef NS_ENUM(NSUInteger, DJICameraThermalResolution) {
    /**
     *  The thermal imaging camera resolution is 336x256.
     */
    DJICameraThermalResolution336x256,
    /**
     *  The thermal imaging camera resolution is 640x512.
     */
    DJICameraThermalResolution640x512,
    /**
     *  The thermal imaging camera resolution is unknown.
     */
    DJICameraThermalResolutionUnknown = 0xFF
};

/*********************************************************************************/
#pragma mark DJICameraThermalFrameRateUpperBound
/*********************************************************************************/

/**
 *  The frame rate upper bound supported by the thermal camera.
 *  Supported only by thermal imaging cameras.
 */
typedef NS_ENUM(NSUInteger, DJICameraThermalFrameRateUpperBound) {
    /**
     *  The thermal imaging camera frame rate upper bound is 8.3Hz.
     */
    DJICameraThermalFrameRateUpperBound8p3Hz,
    /**
     *  The thermal imaging camera frame rate upper bound is 30Hz.
     */
    DJICameraThermalFrameRateUpperBound30Hz,
    /**
     *  The thermal imaging camera frame rate upper bound is unknown.
     */
    DJICameraThermalFrameRateUpperBoundUnknown = 0xFF
};

/*********************************************************************************/
#pragma mark DJICameraThermalLens
/*********************************************************************************/

/**
 *  The lens model of the thermal imaging camera.
 *  Supported only by thermal imaging cameras.
 */
typedef NS_ENUM(NSUInteger, DJICameraThermalLensModel) {
    /**
     *  The thermal imaging camera's lens focal length is 6.8 mm.
     */
    DJICameraThermalLensModel6p8mm,
    /**
     *  The thermal imaging camera's lens focal length is 7.5 mm.
     */
    DJICameraThermalLensModel7p5mm,
    /**
     *  The thermal imaging camera's lens focal length is 9 mm.
     */
    DJICameraThermalLensModel9mm,
    /**
     *  The thermal imaging camera's lens focal length is 13 mm.
     */
    DJICameraThermalLensModel13mm,
    /**
     *  The thermal imaging camera's lens focal length is 19 mm.
     */
    DJICameraThermalLensModel19mm,
    /**
     *  The thermal imaging camera's lens focal length is unknown.
     */
    DJICameraThermalLensModelUnknown = 0xFF
};

/*********************************************************************************/
#pragma mark DJICameraThermalVersion
/*********************************************************************************/

/**
 *  There is a standard version and version with Advanced Radiometry capabilities
 *  of the Zenmuse XT thermal camera. This enum defines the versions.
 *  Supported only by thermal imaging cameras.
 */
typedef NS_ENUM(NSUInteger, DJICameraThermalVersion) {
    /**
     *  The thermal camera is Zenmuse XT Standard version.
     */
    DJICameraThermalVersionXTStandard,
    /**
     *  The thermal camera is Zenmuse XT Advanced Radiometry version.
     */
    DJICameraThermalVersionXTAdvancedRadiometry,
};

/*********************************************************************************/
#pragma mark DJICameraThermalCustomSettings
/*********************************************************************************/

/**
 *  User defined parameters. Supported only by the thermal imaging camera.
 */
typedef NS_ENUM(NSUInteger, DJICameraThermalCustomExternalSceneSettings) {
    /**
     *  Custom thermal external scene settings for user 1
     */
    DJICameraThermalCustomExternalSceneSettingsProfile1,
    /**
     *  Custom thermal external scene settings for user 2
     */
    DJICameraThermalCustomExternalSceneSettingsProfile2,
    /**
     *  Custom thermal external scene settings for user 3
     */
    DJICameraThermalCustomExternalSceneSettingsProfile3,
    /**
     *  The user is unknown.
     */
    DJICameraThermalCustomExternalSceneSettingsProfileUnknown = 0xFF
};

/*********************************************************************************/
#pragma mark DJICameraThermalFFCMode
/*********************************************************************************/
/**
 *  Flat-field correciton mods.
 */
typedef NS_ENUM(NSUInteger, DJICameraThermalFFCMode) {
    /**
     *  Automatic flat-field correction mode.
     */
    DJICameraThermalFFCModeAuto,
    /**
     *  Manual flat-field correction mode.
     */
    DJICameraThermalFFCModeManual,
    /**
     *  Unknown flat-field correction mode.
     */
    DJICameraThermalFFCModeUnknown = 0xFF
};

/*********************************************************************************/
#pragma mark DJICameraThermalProfile
/*********************************************************************************/

/**
 *  The profile of the thermal imaging camera, which includes information about
 *  resolution, frame rate and focal length.
 *  Supported only by thermal imaging cameras.
 */
typedef struct {
    /**
     *  The supported resolution of the thermal imaging camera.
     */
    DJICameraThermalResolution resolution;
    /**
     *  The supported frame rate upper bound of the thermal imaging camera.
     */
    DJICameraThermalFrameRateUpperBound frameRateUpperBound;
    /**
     *  The lens model of the thermal imaging camera.
     */
    DJICameraThermalLensModel lensModel;
    /**
     *  The version of the thermal imaging camera.
     */
    DJICameraThermalVersion version;
} DJICameraThermalProfile;

/*********************************************************************************/
#pragma mark DJICameraThermalDigitalZoomScale
/*********************************************************************************/

/**
 *  Thermal camera digital zoom scale. The default value is
 *  `DJICameraThermalDigitalZoomScalex1`.
 */
typedef NS_ENUM(NSUInteger, DJICameraThermalDigitalZoomScale) {
    /**
     *  Digital Zoom Scale x1.
     */
    DJICameraThermalDigitalZoomScalex1,
    /**
     *  Digital Zoom Scale x2.
     */
    DJICameraThermalDigitalZoomScalex2,
    /**
     *  Digital Zoom Scale x4.
     */
    DJICameraThermalDigitalZoomScalex4,
    /**
     *  Digital Zoom Scale x8.
     */
    DJICameraThermalDigitalZoomScalex8,
    /**
     *  Digital Zoom Scale unknown.
     */
    DJICameraThermalDigitalZoomScaleUnknown = 0xFF
};

/*********************************************************************************/
#pragma mark DJICameraThermalMeasurementMode
/*********************************************************************************/
/**
 *  Thermal camera temperature measurement mode. The default value is 
 *  `DJICameraThermalMeasurementModeDisabled`.
 */
typedef NS_ENUM(NSUInteger, DJICameraThermalMeasurementMode) {
    /**
     *  Disable temperature measuring.
     */
    DJICameraThermalMeasurementModeDisabled,
    /**
     *  Enable temperature measurement and set mode to spot metering. 
     *  Use `[camera:didUpdateTemperatureData:]` in `DJICameraDelegate` to
     *  receive the updated temperature data.
     *  In this mode, the advanced radiometry version XT camera can change the
     *  metering point using `setThermalSpotMeteringTargetPoint:withCompletion`.
     */
    DJICameraThermalMeasurementModeSpotMetering,
    /**
     *  Enable temperature measurement and set mode to area metering. 
     *  Use `camera:didUpdateAreaTemperatureAggregations:` in `DJICameraDelegate`
     *  to receive the updated temperature data.
     *  Only supported by the advanced radiometry version XT camera.
     */
    DJICameraThermalMeasurementModeAreaMetering,
    /**
     *  Thermal camera's temperature measurement mode is unknown.
     */
    DJICameraThermalMeasurementModeUnknown = 0xFF
};

/*********************************************************************************/
#pragma mark DJICameraThermalAreaTemperatureAggregations
/*********************************************************************************/
 /**
  *  The aggregate temperature measurements for a selected metering area.
  */
typedef struct {
    /**
     *  The average temperature of the selected metering area.
     */
    float averageAreaTemperature;
    /**
     *  The minimum temperature of the selected metering area.
     */
    float minAreaTemperature;
    /**
     *  The minimum temperature coordinate of the selected metering area.
     */
    CGPoint minTemperaturePoint;
    /**
     *  The maximum temperature of the selected metering area.
     */
    float maxAreaTemperature;
    /**
     *  The maximum temperature coordinate of the selected metering area.
     */
    CGPoint maxTemperaturePoint;
} DJICameraThermalAreaTemperatureAggregations;

/*********************************************************************************/
#pragma mark DJICameraThermalExternalSceneSettings
/*********************************************************************************/

 /**
  *
  *  Thermal cameras measure the apparent surface temperature of a given object. 
  *  This is done by taking the amount of infrared radiation an object emits
  *  and calculating the surface temperature by applying a formula that adjusts for external factors.
  * 
  *  This struct includes all of the external scene parameters that the thermal camera firmware allows 
  *  to be customized. There are two types of parameters, optical parameters which specify how much infrared 
  *  radiation is transmitted from the surface to the thermal sensor, as well as parameters
  *  that specify sources of thermal radiance other than the object. 
  *
  *  For a more in-depth overview of the physics behind thermal imaging, see https://en.wikipedia.org/wiki/Thermography.
  *
  */
typedef struct {
    /**
     *  Atmospheric temperature, can be between -50 and 327.67 degrees Celsius.
     */
    float atmosphericTemperature;
    /**
     *  Transmission coefficient of the atmosphere between the scene and the camera, can be between 50 and 100.
     */
    float atmosphericTransmissionCoefficient;
    /**
     *  Background temperature (reflected by the scene), can be between -50 and 327.67 degrees Celsius.
     */
    float backgroundTemperature;
    /**
     *  Emissivity of the scene, can be between 50 and 100.
     */
    float sceneEmissivity;
    /**
     *  Window reflection, can be between 50 and 100-X where X is the window transmission coefficient parameter
     */
    float windowReflection;
    /**
     *  Temperature reflected in the window, can be between -50 and 327.67 degrees Celsius.
     */
    float windowReflectedTemperature;
    /**
     *  Window temperature, can be between -50 and 327.67 degrees Celsius.
     */
    float windowTemperature;
    /**
     *  Transmission coefficient of the window, can be between 50 and 100-X where X is the window reflection
     */
    float windowTransmissionCoefficient;
} DJICameraThermalExternalSceneSettings;

/*********************************************************************************/
#pragma mark - Optical Zoom
/*********************************************************************************/

/*********************************************************************************/
#pragma mark DJICameraOpticalZoomSpec
/*********************************************************************************/

/**
 *  Zoom lens profile. Includes focal length range and minimum focal length step.
 *  Supported only by X5 and X5R camera with zoom lens.
 */
typedef struct {
    /**
     *  The maximum focal length of the lens in units of 0.1mm.
     */
    NSUInteger maxFocalLength;
    /**
     *  The minimum focal length of the lens in units of 0.1mm.
     */
    NSUInteger minFocalLength;
    /**
     *  The minimum interval of focal length change in units of 0.1mm.
     */
    NSUInteger focalLengthStep;
}DJICameraOpticalZoomSpec;

/*********************************************************************************/
#pragma mark DJICameraOpticalZoomDirection
/*********************************************************************************/

/**
 * The direction to adjust the camera zoom (camera focal length).
 *  Supported only by X5 and X5R camera with zoom lens.
 */
typedef NS_ENUM(uint8_t, DJICameraOpticalZoomDirection) {
    /**
     *  Lens will zoom in. The focal length increases, field of view becomes
     *  narrower and magnification is higher.
     */
    DJICameraOpticalZoomDirectionZoomIn,
    /**
     *  Lens will zoom out. The focal length decreases, field of view becomes
     *  wider and magnification is lower.
     */
    DJICameraOpticalZoomDirectionZoomOut
};

/*********************************************************************************/
#pragma mark DJICameraOpticalZoomSpeed
/*********************************************************************************/

/**
 *  The speed of lens to zoom.
 *  Supported only by X5 and X5R camera with zoom lens.
 */
typedef NS_ENUM(uint8_t, DJICameraOpticalZoomSpeed) {
    /**
     *  Lens zooms very in slowest speed.
     */
    DJICameraOpticalZoomSpeedSlowest,
    /**
     *  Lens zooms in slow speed.
     */
    DJICameraOpticalZoomSpeedSlow,
    /**
     *  Lens zooms in speed slightly slower than normal speed.
     */
    DJICameraOpticalZoomSpeedModeratelySlow,
    /**
     *  Lens zooms in normal speed.
     */
    DJICameraOpticalZoomSpeedNormal,
    /**
     *  Lens zooms very in speed slightly faster than normal speed.
     */
    DJICameraOpticalZoomSpeedModeratelyFast,
    /**
     *  Lens zooms very in fast speed.
     */
    DJICameraOpticalZoomSpeedFast,
    /**
     *  Lens zooms very in fastest speed.
     */
    DJICameraOpticalZoomSpeedFastest
};

/*********************************************************************************/
#pragma mark - Others
/*********************************************************************************/

/*********************************************************************************/
#pragma mark DJICameraFileIndexMode
/*********************************************************************************/

/**
 *  File index modes.
 */
typedef NS_ENUM (NSUInteger, DJICameraFileIndexMode){
    /**
     *  Camera will reset the newest file's index to be one larger than the
     *  largest number of photos taken on the SD card.
     */
    DJICameraFileIndexModeReset,
    /**
     *  Camera will set the newest file's index to the larger of either the
     *  maximum number of photos taken on the SD card or the camera.
     */
    DJICameraFileIndexModeSequence,
    /**
     *  The mode is unknown.
     */
    DJICameraFileIndexModeUnknown = 0xFF
};

/*********************************************************************************/
#pragma mark DJICameraCustomSettings
/*********************************************************************************/

/**
 *  Camera user settings. A user can save or load camera settings to or from the
 *  specified user.
 */
typedef NS_ENUM (NSUInteger, DJICameraCustomSettings){
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

/*********************************************************************************/
#pragma mark DJICameraDigitalFilter
/*********************************************************************************/

/**
 *  Camera digital filters. The default value is `DJICameraDigitalFilterNone`.
 */
typedef NS_ENUM (NSUInteger, DJICameraDigitalFilter){
    /**
     *  The digital filter is set to none or no filter.
     */
    DJICameraDigitalFilterNone,
    /**
     *  The digital filter is set to art.
     */
    DJICameraDigitalFilterArt,
    /**
     *  The digital filter is set to black and white.
     */
    DJICameraDigitalFilterBlackAndWhite,
    /**
     *  The digital filter is set to bright.
     */
    DJICameraDigitalFilterBright,
    /**
     *  The digital filter is set to movie, also known as D-Cinelike.
     */
    DJICameraDigitalFilterCinelike,
    /**
     *  The digital filter is set to portrait. Only supported by OSMO with X3
     *  camera.
     */
    DJICameraDigitalFilterPortrait,
    /**
     *  The digital filter is set to M31.
     */
    DJICameraDigitalFilterM31,
    /**
     *  The digital filter is set to kDX.
     */
    DJICameraDigitalFilterkDX,
    /**
     *  The digital filter is set to prismo.
     */
    DJICameraDigitalFilterPrismo,
    /**
     *  The digital filter is set to jugo.
     */
    DJICameraDigitalFilterJugo,
    /**
     *  The digital filter is set to neutral, also known as D-Log.
     */
    DJICameraDigitalFilterDLog,
    /**
     *  The digital filter is set to true color. support since xxx firmware of P4
     */
    DJICameraDigitalFilterTrueColor,
    
    /**
     *  reserved
     */
    DJICameraDigitalFilterReminiscence,
    /**
     *  reserved
     */
    DJICameraDigitalFilterInverse,
    /**
     *  reserved
     */
    DJICameraDigitalFilterSolarize,
    /**
     *  reserved
     */
    DJICameraDigitalFilterPostrize,
    /**
     *  reserved
     */
    DJICameraDigitalFilterWhiteboard,
    /**
     *  reserved
     */
    DJICameraDigitalFilterBlackboard,
    /**
     *  reserved
     */
    DJICameraDigitalFilterAqua,
    
    /**
     *  The digital filter is unknown.
     */
    DJICameraDigitalFilterUnknown = 0xFF
};

/*********************************************************************************/
#pragma mark DJIDownloadFileType
/*********************************************************************************/

/**
 *  Download file types. This typedef is only supported by the Phantom 3
 *  Professional and the Inspire 1.
 */
typedef NS_ENUM (NSUInteger, DJIDownloadFileType){
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
