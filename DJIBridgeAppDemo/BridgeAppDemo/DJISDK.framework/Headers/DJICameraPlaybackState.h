//
//  DJICameraPlaybackState.h
//  DJISDK
//
//  Copyright © 2015, DJI. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreGraphics/CoreGraphics.h>

/**
 *  Media file type
 */
typedef NS_ENUM (uint8_t, DJICameraPlaybackFileFormat){
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
    DJICameraPlaybackFileFormatVIDEO = 0x02,
    /**
     *  The playback file format is unknown.
     */
    DJICameraPlaybackFileFormatUnknown = 0xFF
};

/**
 *  A playback mode represents a task that the Playback manager is executing.
 */
typedef NS_ENUM (uint8_t, DJICameraPlaybackMode){
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
 *  Status for a media file being deleted
 */
typedef NS_ENUM (uint8_t, DJICameraPlaybackDeletionStatus){
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

/**
 *  This class provides the current state of the Playback manager, like numbers of thumbnail and media files, video duration, video play progress, file download state, etc.
 */
@interface DJICameraPlaybackState : NSObject

/**
 *  The current mode of the Playback manager
 */
@property(nonatomic, readonly) DJICameraPlaybackMode playbackMode;

/**
 *  The type of the current file.
 *  The value of this property is valid only when the playbackMode is DJICameraPlaybackModeSingleFilePreview, DJICameraPlaybackModeSingleVideoPlaybackStart nor DJICameraPlaybackModeSingleVideoPlaybackPause.
 */
@property(nonatomic, readonly) DJICameraPlaybackFileFormat mediaFileType;

/**
 *  The total number of thumbnails for both the photos and videos being viewed on the page. The value of the property is valid when the playbackMode is DJICameraPlaybackModeMultipleFilesPreview or DJICameraPlaybackModeMultipleFilesEdit.
 */
@property(nonatomic, readonly) int numberOfThumbnails;

/**
 *  The total number of media files on the SD card, including photos and videos.
 *
 */
@property(nonatomic, readonly) int numberOfMediaFiles;

/**
 *  The index of the current selected file.
 *
 */
@property(nonatomic, readonly) int currentSelectedFileIndex;

/**
 *  The duration in second of the playing video. The value of the property is valid only when playbackMode is DJICameraPlaybackModeSingleVideoPlaybackStart or DJICameraPlaybackModeSingleVideoPlaybackPaused.
 */
@property(nonatomic, readonly) int videoDuration;

/**
 *  The progress in percentage of the playing video. The valid range is [0, 100].
 *  The value the property is valid only when playbackMode is DJICameraPlaybackModeSingleVideoPlaybackStart or DJICameraPlaybackModeSingleVideoPlaybackPaused.
 */
@property(nonatomic, readonly) int videoPlayProgress;

/**
 *  The played duration in second of the playing video.
 *
 *  The value the property is valid only when playbackMode is DJICameraPlaybackModeSingleVideoPlaybackStart or DJICameraPlaybackModeSingleVideoPlaybackPaused.
 */
@property(nonatomic, readonly) int videoPlayPosition;

/**
 *  The total number of the selected files.
 *
 *  The value is valid while playbackMode is in DJICameraPlaybackModeMultipleFilesEdit.
 */
@property(nonatomic, readonly) int numberOfSelectedFiles;

/**
 *  The total number of photos in the SD card.
 *
 */
@property(nonatomic, readonly) int numberOfPhotos;

/**
 *  The total number of videos in the SD card.
 *
 */
@property(nonatomic, readonly) int numberOfVideos;

/**
 *  The dimension of the previewing photo. The value of the property is valid only when playbackMode is DJICameraPlaybackModeSingleFilePreview and mediaFileType is DJICameraPlaybackFileFormatJPEG.
 *
 */
@property(nonatomic, readonly) CGSize photoSize;

/**
 *  The current status of a file when the user tries to delete it.
 *
 */
@property(nonatomic, readonly) DJICameraPlaybackDeletionStatus fileDeleteStatus;

/**
 *  YES if all the files on the current page are selected.
 *
 */
@property(nonatomic, readonly) BOOL isAllFilesInPageSelected;

/**
 *  YES if the previewing file is a valid photo or video. The value of the property is valid only when playbackMode is DJICameraPlaybackModeSingleFilePreview.
 *
 */
@property(nonatomic, readonly) BOOL isSelectedFileValid;

/**
 *  YES if the previewing file has been downloaded. The value of the property is valid only when playbackMode is DJICameraPlaybackModeSingleFilePreview.
 *
 */
@property(nonatomic, readonly) BOOL isFileDownloaded;

@end
