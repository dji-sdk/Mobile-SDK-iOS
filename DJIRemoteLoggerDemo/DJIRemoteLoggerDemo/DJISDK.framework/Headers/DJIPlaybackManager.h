//
//  DJIPlaybackManager.h
//  DJISDK
//
//  Copyright © 2015 DJI. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "DJICameraSettingsDef.h"
#import <CoreGraphics/CoreGraphics.h>

NS_ASSUME_NONNULL_BEGIN

@class DJIPlaybackManager;
@class DJICameraPlaybackState;


typedef void (^DJIFileDownloadPreparingBlock)(NSString* _Nullable fileName, DJIDownloadFileType fileType, NSUInteger fileSize, BOOL* skip);
typedef void (^DJIFileDownloadingBlock)(NSData* _Nullable data, NSError* _Nullable error);
typedef void (^DJIFileDownloadCompletionBlock)();

/*********************************************************************************/
#pragma mark - DJIPlaybackDelegate
/*********************************************************************************/
/**
 *  Represent delegate who is interested on the state of playback manager.
 */
@protocol DJIPlaybackDelegate <NSObject>

@required
/**
 *  Updates playback state of the camera. This update method will only be called when the camera's work
 *  mode is set to DJICameraModePlaybackPreview.
 *
 *  @param playbackState Camera's playback state.
 */
-(void) playbackManager:(DJIPlaybackManager *)playbackManager didUpdatePlaybackState:(DJICameraPlaybackState*)playbackState;

@end

/*********************************************************************************/
#pragma mark - DJIMediaManager
/*********************************************************************************/
/**
 *  The playback manager is used to interact with the playback system of the camera.
 *  By using the manager, user can control the playback system.
 */
@interface DJIPlaybackManager : NSObject

@property(nonatomic, weak) id<DJIPlaybackDelegate> delegate;

/**
 *  This enables the user to select, download and/or delete multiple media files when the camera is in Playback mode.
 */
-(void) enterMultipleEditMode;

/**
 *  Exits multiple edit mode.
 */
-(void) exitMultipleEditMode;

/**
 *  Selects a file at the specified index of the current page. This index is unrelated to filename, and used in multiple edit mode.
 *
 *  @param index Index at which to select a file.
 */
-(void) selectFileAtIndex:(int)index;

/**
 *  Unselects a file at the specified index of the current page. This index is unrelated to filename, and used in multiple edit mode.
 *
 *  @param index Index at which to unselect a file.
 */
-(void) unselectFileAtIndex:(int)index;

/**
 *  Selects all the files on the SD card.
 */
-(void) selectAllFiles;

/**
 *  Unselects all the files on the SD card.
 */
-(void) unselectAllFiles;

/**
 *  Selects all the file(s) on the current page.
 */
-(void) selectAllFilesInPage;

/**
 *  Unselects all the file(s) on the current page.
 */
-(void) unselectAllFilesInPage;

/**
 *  Deletes all selected files from the SD card.
 */
-(void) deleteAllSelectedFiles;

/**
 *  Downloads the selected files. When this method is called, the camera's work mode will be automatically
 *  changed to DJICameraModePlaybackDownload. The dataBlock gets called continuously until all the data is downloaded.
 *  The prepare and completion blocks are called once for each file being downloaded. In the prepareBlock, you can get the forthcoming file's info, like file name, file size, etc.
 *
 *  @param prepareBlock Callback to prepare each file for download.
 *  @param dataBlock    Callback while a file is downloaded.
 *  @param completion   Callback after each file have been downloaded.
 */
-(void) downloadSelectedFilesWithPreparation:(DJIFileDownloadPreparingBlock)prepareBlock process:(DJIFileDownloadingBlock)dataBlock completion:(DJIFileDownloadCompletionBlock)completion;

/**
 *  Enables the user to preview multiple files when the camera is in Playback mode.
 */
-(void) enterMultiplePreviewMode;

/**
 *  Goes to the next page when there are multiple pages.
 */
-(void) goToNextMultiplePreviewPage;

/**
 *  Goes back to the previous page when there are multiple pages.
 */
-(void) goToPreviousMultiplePreviewPage;

/**
 *  Enters single file preview mode for a file at the specified index. In order for this method to be called,
 *  the camera work mode should be DJICameraModePlaybackPreview.
 *
 *  @param index File to be previewed at the specified index.
 */
-(void) enterSinglePreviewModeWithIndex:(uint8_t)index;

/**
 *  Goes to the next page.
 */
-(void) goToNextSinglePreviewPage;

/**
 *  Goes back to the previous page.
 */
-(void) goToPreviousSinglePreviewPage;

/**
 *  Deletes the current file being previewed.
 */
-(void) deleteCurrentPreviewFile;

/**
 *  Sets the photo's zoom scale.
 *
 *  @param scale Zoom scale value must be in the range [0, 1]. If the scale value is negative, the
 *  DJICameraModePlaybackPreview will be set to MultipleFilesPreview.
 */
-(void) setPhotoZoomScale:(float)scale;

/**
 *  Moves the center coordinate of the photo to the specified position. When the photo is zoomed in, you can use this method to move the photo to the specified coordinate to check different part of the big photo.
 *
 *  @param position Position to move center coordinate of the photo to.
 */
-(void) movePhotoCenterCoordinateTo:(CGPoint)position;

/**
 *  Starts video playback. The selected file must be a video file.
 */
-(void) startVideoPlayback;

/**
 *  Pause a video during playback.
 */
-(void) pauseVideoPlayback;

/**
 *  Stops a video during playback
 */
-(void) stopVideoPlayback;

/**
 *  Plays a video from the specified location.
 *
 *  @param location Location from which to play the video must be in the range of [0, 100]. This
 *  value represents at what percent of the entire video it should start playing.
 */
-(void) setVideoPlaybackFromLocation:(uint8_t)location;

@end

NS_ASSUME_NONNULL_END
