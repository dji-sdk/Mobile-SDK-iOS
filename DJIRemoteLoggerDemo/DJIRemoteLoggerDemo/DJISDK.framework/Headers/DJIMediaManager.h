//
//  DJIMediaManager.h
//  DJISDK
//
//  Copyright © 2015 DJI. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@class DJIMedia;

/*********************************************************************************/
#pragma mark - DJIMediaManager
/*********************************************************************************/
/**
 *  The media manager is used to interact with the file system in the SD card.
 *  By using the manager, user can get the meta data for all the multi-media
 *  files and access to each single multi-media file.
 */
@interface DJIMediaManager : NSObject

/**
 *  Fetch media list from remote album. The camera's work mode should be set as DJICameraModePlaybackPreview or DJICameraModePlaybackDownload before call this api.
 *
  *  @param block Remote execute result. Objects in mediaList is kind of class DJIMedia.
 */
-(void) fetchMediaListWithCompletion:(void (^)(NSArray<DJIMedia*> *_Nullable mediaList, NSError* _Nullable error))block;

/**
 *  Delete media from remote album. The camera's work mode should be set as DJICameraModePlaybackPreview or DJICameraModePlaybackDownload before call this api.
 *
 *  @param media  Media files to be deleted.
 *  @param block  Remote execute result, 'failureDeletes' will contain media which failured delete.
 */
-(void) deleteMedia:(NSArray<DJIMedia*> *)media withCompletion:(void(^)(NSArray<DJIMedia*>*  _Nonnull failureDeletes, NSError * _Nullable error))block;

@end

NS_ASSUME_NONNULL_END
