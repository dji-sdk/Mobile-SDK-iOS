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

/**
 *  Block invoked when preparing a file for download.
 */
typedef void (^_Nullable DJIFileDownloadPreparingBlock)(NSString *_Nullable fileName, DJIDownloadFileType fileType, NSUInteger fileSize, BOOL *skip);

/**
 *  Block invoked when a file is downloading.
 */
typedef void (^_Nullable DJIFileDownloadingBlock)(NSData *_Nullable data, NSError *_Nullable error);

/**
 *  Block invoked after a file has been downloaded.
 */
typedef void (^_Nullable DJIFileDownloadCompletionBlock)();

/*********************************************************************************/
#pragma mark - DJIPlaybackDelegate
/*********************************************************************************/

/**
 *  The protocol provides a delegate method to receive the updated state of the playback manager.
 */
@protocol DJIPlaybackDelegate <NSObject>

@required
/**
 *  Updates the playback state of the camera. This update method will only be called when the camera's work
 *  mode is set to `DJICameraModePlayback`.
 *
 *  @param playbackState The camera's playback state.
 */
- (void)playbackManager:(DJIPlaybackManager *_Nonnull)playbackManager didUpdatePlaybackState:(DJICameraPlaybackState *_Nonnull)playbackState;

@end

/*********************************************************************************/
#pragma mark - DJIMediaManager
/*********************************************************************************/

/**
 *  The playback manager is used to interact with the playback system of the camera.
 *  By using the playback manager, the user can control the playback system.
 */
@interface DJIPlaybackManager : NSObject

/**
 *  Returns the delegate of DJIPlaybackManager
 */
@property(nonatomic, weak) id<DJIPlaybackDelegate> delegate;

/**
 *  This enables the user to select, download, or delete multiple media files when the camera is in Playback mode.
 */
- (void)enterMultipleEditMode;

/**
 *  Exits multiple edit mode.
 */
- (void)exitMultipleEditMode;

/**
 *  Selects or unselects a file at the specified index of the current page. This index is unrelated to the filename, and is used in multiple edit mode.
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
 *  Downloads the selected files. When this method is called, the `dataBlock` is
 *  called continuously until all the data is downloaded.
 *  The prepare and completion blocks are called once for each file being
 *  downloaded. In the `prepareBlock`, you can get the forthcoming file's
 *  information, including the file name, file size, etc. If an error occurs,
 *  the `overallCompletionBlock` will be called with an error returned. If the
 *  entire download process finishes successfully, `overallCompletionBlock` will
 *  be called without any errors.
 *
 *  @param prepareBlock         Callback to prepare each file for download.
 *  @param dataBlock            Callback while a file is downloading. The
 *                              dataBlock can be called multiple times for a file.
 *                              The error argument in `DJIFileDownloadingBlock` 
 *                              is not used and should be ignored.
 *  @param fileCompletionBlock  Callback after each file have been downloaded.
 *  @param finishBlock          Callback after the downloading is finished.
 */
- (void)downloadSelectedFilesWithPreparation:(nullable DJIFileDownloadPreparingBlock)prepareBlock
                                     process:(nullable DJIFileDownloadingBlock)dataBlock
                              fileCompletion:(nullable DJIFileDownloadCompletionBlock)fileCompletionBlock
                           overallCompletion:(nullable DJICompletionBlock)overallCompletionBlock;

/**
 * Cancel current file download.
 *
 * @param block Callback after the operation finished.
 */

- (void)stopDownloadingFilesWithCompletion:(nullable DJICompletionBlock)block;

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
 *  the camera work mode must be `DJICameraModePlayback`.
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