//
//  DJIMedia.h
//  DJISDK
//
//  Copyright © 2015, DJI. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "DJIBaseProduct.h"

NS_ASSUME_NONNULL_BEGIN

/*********************************************************************************/
#pragma mark - DJIMediaType
/*********************************************************************************/

@class UIImage;
/**
 *  Media types.
 */
typedef NS_ENUM (NSUInteger, DJIMediaType){
    /**
     *  Unknown.
     */
    DJIMediaTypeUnknown,
    /**
     *  JPEG.
     */
    DJIMediaTypeJPEG,
    /**
     *  MP4.
     */
    DJIMediaTypeMP4,
    /**
     *  MOV.
     */
    DJIMediaTypeMOV,
    /**
     *  M4V.
     */
    DJIMediaTypeM4V,
    /**
     *  DNG.
     */
    DJIMediaTypeRAWDNG,
    /**
     *  Panorama
     */
    DJIMediaTypePanorama,

};

/*********************************************************************************/
#pragma mark - DJIMedia
/*********************************************************************************/

/**
 *  This class contains the information about a multi-media file on the SD card. It also provides methods to fetch the data of the file.
 */
@interface DJIMedia : NSObject

/**
 *  Returns the name of the media file.
 */
@property(nonatomic, readonly) NSString *fileName;

/**
 *  Returns the size, in bytes, of the media file.
 */
@property(nonatomic, readonly) long long fileSizeInBytes;

/**
 *  Returns the time when the media file was created as a string in
 *  the format "YYYY-MM-DD hh:mm:ss".
 */
@property(nonatomic, readonly) NSString *timeCreated;

/**
 *  If the media file is a video, this property returns the duration
 *  of the video in seconds. Will be 0s if media file is a photo.
 */
@property(nonatomic, readonly) float durationInSeconds;

/**
 *  Returns the type of media file.
 */
@property(nonatomic, readonly) DJIMediaType mediaType;

/**
 *  Returns the thumbnail for this media. If this property returns nil,
 *  the user should call fetchThumbnailWithCompletion
 */
@property(nonatomic, readonly) UIImage *_Nullable thumbnail;

/**
 *  Fetches this media's thumbnail from the SD card. This method can be used
 *  to fetch either a photo or a video, where the first frame of the video is
 *  the thumbnail that is fetched.
 *  It is not available if the media type is DJIMediaTypePanorama.
 *
 *  @param block Completion block.
 */
- (void)fetchThumbnailWithCompletion:(DJICompletionBlock)block;

/**
 *  Fetches this media's data from the SD card. The difference with fetching
 *  the media data and fetching the thumbnil is that fetching the thumbnail will
 *  return a low-resolution image of the actual picture while fetching the media
 *  data will return all data of a video or an image.
 *
 *  @param block Data callback will be called when media data has been received
 *  from the SD card or an error has occurred.
 */
- (void)fetchMediaDataWithCompletion:(void (^)(NSData *_Nullable data, BOOL *_Nullable stop, NSError *_Nullable error))block;

/**
 *  Fetch media's preview image. The preview image is a lower resolution (960 x 540) version of a still picture or
 *  the first frame of a video. The mediaType of this media object should be 'DJIMediaTypeJPG'.
 *  It is not available if the media type is DJIMediaTypePanorama.
 *
 *  @param block Remote execute result callback.
 */
- (void)fetchPreviewImageWithCompletion:(void (^)(UIImage *image, NSError *_Nullable error))block;


/**
 *  Fetch sub media files.
 *  It is available only when the media type is DJIMediaTypePanorama. User should use this method to fetch the set
 *  of photos shot in a panorama mission.
 *
 *  @param block Remote execute result callback.
 */
- (void)fetchSubMediaFileListWithCompletion:(void (^)(NSArray<DJIMedia *> *_Nullable mediaList, NSError *_Nullable error))block;

@end

NS_ASSUME_NONNULL_END
