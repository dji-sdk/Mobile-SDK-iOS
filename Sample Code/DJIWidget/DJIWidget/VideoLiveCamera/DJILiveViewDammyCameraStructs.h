//
//  DJILiveViewDammyCameraStructs.h
//
//  Copyright (c) 2017 DJI. All rights reserved.
//

#ifndef DJILiveViewDammyCameraStructs_h
#define DJILiveViewDammyCameraStructs_h

typedef enum : NSUInteger {
    DJILiveViewDammyCameraWorkModeOff, //user disabled
    DJILiveViewDammyCameraWorkModeCapture, //ready to take photo
    DJILiveViewDammyCameraWorkModeRecording, //ready to record video
    DJILiveViewDammyCameraWorkModeQuickmovie, //ready to record quickmovie
} DJILiveViewDammyCameraWorkMode;

typedef enum : NSUInteger {
    DJILiveViewDammyCameraCaptureStatusNone,
    DJILiveViewDammyCameraCaptureStatusCapturing,
    DJILiveViewDammyCameraCaptureStatusEnded, //ended, internal use
} DJILiveViewDammyCameraCaptureStatus;

typedef enum : NSUInteger {
    DJILiveViewDammyCameraRecordingStatusNone,
    DJILiveViewDammyCameraRecordingStatusPrepear,
    DJILiveViewDammyCameraRecordingStatusRecording,
    DJILiveViewDammyCameraRecordingStatusEnded, //ended, internal use
} DJILiveViewDammyCameraRecordingStatus;


#endif /* DJILiveViewDammyCameraStructs_h */
