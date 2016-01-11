/*
 *  DJI iOS Mobile SDK Framework
 *  DJICameraPlaybackState.h
 *
 *  Copyright (c) 2015, DJI.
 *  All rights reserved.
 *
 */

//
#import <Foundation/Foundation.h>
#import <CoreGraphics/CoreGraphics.h>

/**
 *  Media file type
 */
typedef NS_ENUM(uint8_t, DJICameraPlaybackFileFormat){
    /**
     *  JPEG file
     */
    DJICameraPlaybackFileFormatJPEG = 0x00,
    /**
     *  DNG file
     */
    DJICameraPlaybackFileFormatRAWDNG = 0x01,
    /**
     *  Video file
     */
    DJICameraPlaybackFileFormatVIDEO =0x02,
};

/**
 *  Playback mode
 */
typedef NS_ENUM(uint8_t, DJICameraPlaybackMode){
    /**
     *  Single file preview
     */
    DJICameraPlaybackModeSingleFilePreview = 0x00,
    /**
     *  Single photo zoomed
     */
    DJICameraPlaybackModeSinglePhotoZoomMode = 0x01,
    /**
     *  Single video play start
     */
    DJICameraPlaybackModeSingleVideoPlaybackStart = 0x02,
    /**
     *  Single video play pause
     */
    DJICameraPlaybackModeSingleVideoPlaybackPause = 0x03,
    /**
     *  Multiple file edit
     */
    DJICameraPlaybackModeMultipleFilesEdit = 0x04,
    /**
     *  Multiple file preview
     */
    DJICameraPlaybackModeMultipleFilesPreview = 0x05,
    /**
     *  Download file
     */
    DJICameraPlaybackModeDownload = 0x06,
    /**
     *  Unknown mode
     */
    DJICameraPlaybackModeUnknown = 0xFF,
};

/**
 *  Status for delete a media file
 */
typedef NS_ENUM(uint8_t, DJICameraPlaybackDeletionStatus){
    /**
     *  Delete failed
     */
    DJICameraPlaybackDeletionStatusFailure = 1,
    /**
     *  Deleting
     */
    DJICameraPlaybackDeletionStatusDeleting,
    /**
     *  Delete Succeeded
     */
    DJICameraPlaybackDeletionStatusSuccess,
};

@interface DJICameraPlaybackState : NSObject

// the mode of playback.
@property(nonatomic, readonly) DJICameraPlaybackMode playbackMode;

// the media file type.
// attention:
//      value is type of DJICameraPlaybackFileFormat while playbackMode is in SinglePhotoPlayback/SinglePhotoZoomMode/SingleVideoPlaybackStart
//      value's bit will indicate file type of multiple media while playbackMode is in MultipleMediaFilesDelete/MultipleMediaFilesDisplay. bit[i] = 0 photo, bit[i] = 1 video. ex. value = 0x003A, then the file index of 1, 3, 4, 5 is video file.
@property(nonatomic, readonly) DJICameraPlaybackFileFormat mediaFileType;

// numbers of thumbnail.
// attention:
//      value is valid while playbackMode is in MultipleFilesPreview
@property(nonatomic, readonly) int numbersOfThumbnail;

// numbers of media files, include photos and videos.
@property(nonatomic, readonly) int numbersOfMediaFiles;

// current selected file index.
@property(nonatomic, readonly) int currentSelectedFileIndex;

// duration in second of video.
// attention:
//      value is valid while playbackMode is in SingleVideoPlaybackStart
@property(nonatomic, readonly) int videoDuration;

// progress in percentage of video playback. range in [0, 100]
// attention:
//      value is valid while playbackMode is in SingleVideoPlaybackStart
@property(nonatomic, readonly) int videoPlayProgress;

// current playing location of the videoplay
// attention:
//      value is valid while playbackMode is in SingleVideoPlaybackStart
@property(nonatomic, readonly) int videoPlayPosition;

// number of the selected file
// attention:
//      value is valid while playbackMode is in MultipleFilesEdit
@property(nonatomic, readonly) int numbersOfSelected;

// numbers of photos in the SD card
@property(nonatomic, readonly) int numbersOfPhotos;

// numbers of videos in the SD card
@property(nonatomic, readonly) int numbersOfVideos;

// zoom scale of photo.
@property(nonatomic, readonly) int zoomScale;

// photo size
@property(nonatomic, readonly) CGSize photoSize;

// center coordinate of photo in current zoom scale.
@property(nonatomic, readonly) CGPoint photoCenterCoordinate;

// file delete status.
@property(nonatomic, readonly) DJICameraPlaybackDeletionStatus fileDeleteStatus;

// is all files selected in current view.
@property(nonatomic, readonly) BOOL isAllFilesInPageSelected;

// is the selected file is a valid photo/video file.
@property(nonatomic, readonly) BOOL isSelectedFileValid;

// is the file ever been downloaded.
@property(nonatomic, readonly) BOOL isFileDownloaded;
@end
