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
    /**
     *  TIFF
     */
    DJIMediaTypeTIFF
};

/*********************************************************************************/
#pragma mark - DJIMedia
/*********************************************************************************/

/**
 *  This class contains information about a multi-media file on the SD card. It also provides methods to retrieve the data in the file.
 */
@interface DJIMedia : NSObject

/**
 *  Returns the name of the media file.
 */
@property(nonatomic, readonly) NSString *_Nonnull fileName;

/**
 *  Returns the size, in bytes, of the media file.
 */
@property(nonatomic, readonly) long long fileSizeInBytes;

/**
 *  Returns the time when the media file was created as a string in
 *  the format "yyyy-MM-dd HH:mm:ss".
 */
@property(nonatomic, readonly) NSString *_Nonnull timeCreated;

/**
 *  If the media file is a video, this property returns the duration
 *  of the video in seconds. Will be 0s if the media file is a photo.
 */
@property(nonatomic, readonly) float durationInSeconds;

/**
 *  Returns the type of media file.
 */
@property(nonatomic, readonly) DJIMediaType mediaType;

/**
 *  Returns the thumbnail for this media. If this property returns nil,
 *  call `fetchThumbnailWithCompletion`.
 */
@property(nonatomic, readonly) UIImage *_Nullable thumbnail;

/**
 *  Fetches this media's thumbnail from the SD card. This method can be used
 *  to fetch either a photo or a video, where the first frame of the video is
 *  the thumbnail that is fetched.
 *  It is not available if the media type is `DJIMediaTypePanorama`.
 *
 *  @param block Completion block.
 */
- (void)fetchThumbnailWithCompletion:(DJICompletionBlock)block;

/**
 *  Fetches this media's data from the SD card. The difference between fetching
 *  the media data and fetching the thumbnail is that fetching the thumbnail will
 *  return a low-resolution image of the actual picture, while fetching the media
 *  data will return all data for a video or image.
 *
 *  @param block Data callback will be invoked when media data has been received
 *  from the SD card or an error has occurred.
 */
- (void)fetchMediaDataWithCompletion:(void (^_Nonnull)(NSData *_Nullable data, BOOL *_Nullable stop, NSError *_Nullable error))block;

/**
 *  Fetch media's preview image. The preview image is a lower resolution (960 x 540) version of a still picture or
 *  the first frame of a video. The `mediaType` of this media object should be 'DJIMediaTypeJPG'.
 *  It is not available if the media type is `DJIMediaTypePanorama`.
 *
 *  @param block Remote execute result callback.
 */
- (void)fetchPreviewImageWithCompletion:(void (^_Nonnull)(UIImage *image, NSError *_Nullable error))block;


/**
 *  Fetch sub media files.
 *  This is available only when the media type is `DJIMediaTypePanorama`. Call this method to fetch the set
 *  of photos shot in a panorama mission.
 *
 *  @param block Remote execute result callback.
 */
- (void)fetchSubMediaFileListWithCompletion:(void (^_Nonnull)(NSArray<DJIMedia *> *_Nullable mediaList, NSError *_Nullable error))block;

@end

NS_ASSUME_NONNULL_END
