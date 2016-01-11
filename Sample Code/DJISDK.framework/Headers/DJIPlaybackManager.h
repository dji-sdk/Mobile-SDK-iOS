//
//  DJIPlaybackManager.h
//  DJISDK
//
//  Copyright © 2015, DJI. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "DJICameraSettingsDef.h"
#import <CoreGraphics/CoreGraphics.h>

NS_ASSUME_NONNULL_BEGIN

@class DJIPlaybackManager;
@class DJICameraPlaybackState;

typedef void (^DJIFileDownloadPreparingBlock)(NSString *_Nullable fileName, DJIDownloadFileType fileType, NSUInteger fileSize, BOOL *skip);
typedef void (^DJIFileDownloadingBlock)(NSData *_Nullable data, NSError *_Nullable error);
typedef void (^DJIFileDownloadCompletionBlock)();

/*********************************************************************************/
#pragma mark - DJIPlaybackDelegate
/*********************************************************************************/

/**
 *  The protocol provides delegate method to receive the updated state of the playback manager.
 */
@protocol DJIPlaybackDelegate <NSObject>

@required
/**
 *  Updates playback state of the camera. This update method will only be called when the camera's work
 *  mode is set to DJICameraModePlayback.
 *
 *  @param playbackState Camera's playback state.
 */
- (void)playbackManager:(DJIPlaybackManager *)playbackManager didUpdatePlaybackState:(DJICameraPlaybackState *)playbackState;

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
- (void)enterMultipleEditMode;

/**
 *  Exits multiple edit mode.
 */
- (void)exitMultipleEditMode;

/**
 *  Selects or unselects a file at the specified index of the current page. This index is unrelated to filename, and used in multiple edit mode.
 *
 *  @param index Index at which to select a file.
 */
- (void)toggleFileSelectionAtIndex:(int)index;

/**
 *  Selects all the files on the SD card.
 */
- (void)selectAllFiles;

/**
 *  Unselects all the files on the SD card.
 */
- (void)unselectAllFiles;

/**
 *  Selects all the file(s) on the current page.
 */
- (void)selectAllFilesInPage;

/**
 *  Unselects all the file(s) on the current page.
 */
- (void)unselectAllFilesInPage;

/**
 *  Deletes all selected files from the SD card.
 */
- (void)deleteAllSelectedFiles;

/**
 *  Downloads the selected files. When this method is called. The dataBlock gets called continuously until all the data is downloaded.
 *  The prepare and completion blocks are called once for each file being downloaded. In the prepareBlock, you can get the forthcoming file's info, like file name, file size, etc.
 *
 *  If an error occurs before the downloading of any files, only the overallCompletionBlock will be called with an error returned.
 *  If an error occurs during the downloading of a file, both dataBlock and overallCompletionBlock will be called with an error returned.
 *
 *  @param prepareBlock         Callback to prepare each file for download.
 *  @param dataBlock            Callback while a file is downloading. The dataBlock can be called multiple times for a file.
 *  @param fileCompletionBlock  Callback after each file have been downloaded.
 *  @param finishBlock          Callback after the downloading is finished.
 */
- (void)downloadSelectedFilesWithPreparation:(DJIFileDownloadPreparingBlock)prepareBlock process:(DJIFileDownloadingBlock)dataBlock fileCompletion:(DJIFileDownloadCompletionBlock)fileCompletionBlock overallCompletion:(DJICompletionBlock)overallCompletionBlock;

/**
 *  Enables the user to preview multiple files when the camera is in Playback mode.
 */
- (void)enterMultiplePreviewMode;

/**
 *  Goes to the next page when there are multiple pages.
 */
- (void)goToNextMultiplePreviewPage;

/**
 *  Goes back to the previous page when there are multiple pages.
 */
- (void)goToPreviousMultiplePreviewPage;

/**
 *  Enters single file preview mode for a file at the specified index. In order for this method to be called,
 *  the camera work mode should be DJICameraModePlayback.
 *
 *  @param index File to be previewed at the specified index.
 */
- (void)enterSinglePreviewModeWithIndex:(uint8_t)index;

/**
 *  Goes to the next page.
 */
- (void)goToNextSinglePreviewPage;

/**
 *  Goes back to the previous page.
 */
- (void)goToPreviousSinglePreviewPage;

/**
 *  Deletes the current file being previewed.
 */
- (void)deleteCurrentPreviewFile;

/**
 *  Starts video playback. The selected file must be a video file.
 */
- (void)startVideoPlayback;

/**
 *  Pause a video during playback.
 */
- (void)pauseVideoPlayback;

/**
 *  Stops a video during playback
 */
- (void)stopVideoPlayback;

/**
 *  Plays a video from the specified location.
 *
 *  @param location Location from which to play the video must be in the range of [0, 100]. This
 *  value represents at what percent of the entire video it should start playing.
 */
- (void)setVideoPlaybackFromLocation:(uint8_t)location;

@end

NS_ASSUME_NONNULL_END