//
//  DJIMediaManager.h
//  DJISDK
//
//  Copyright © 2015, DJI. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@class DJIMedia;

/*********************************************************************************/
#pragma mark - DJIMediaManager
/*********************************************************************************/

/**
 *  The media manager is used to interact with the file system in the SD card.
 *  By using the manager, user can get the meta data for all the multimedia
 *  files and access to each single multimedia file.
 */
@interface DJIMediaManager : NSObject

/**
 *  Fetch media list from remote album. The camera's work mode should be set as DJICameraModeMediaDownload.
 *
 *  @param block Remote execute result. Objects in mediaList are kind of class DJIMedia.
 */
- (void)fetchMediaListWithCompletion:(void (^)(NSArray<DJIMedia *> *_Nullable mediaList, NSError *_Nullable error))block;

/**
 *  Delete media from remote album. The camera's work mode should be set as DJICameraModeMediaDownload.
 *
 *  @param media  Media files to be deleted.
 *  @param block  Remote execute result, 'deleteFailures' will contain media which failed to delete.
 */
- (void)deleteMedia:(NSArray<DJIMedia *> *)media withCompletion:(void (^)(NSArray<DJIMedia *> *_Nonnull deleteFailures, NSError *_Nullable error))block;

@end

NS_ASSUME_NONNULL_END