//
//  DJIMedia.h
//  DJISDK
//
//  Copyright (c) 2015 DJI. All rights reserved.
//

#import <Foundation/Foundation.h>

@class UIImage;

/**
 *  Media type
 */
typedef NS_ENUM(NSUInteger, MediaType){
    /**
     *  Unknown
     */
    MediaTypeUnknown,
    /**
     *  JPG
     */
    MediaTypeJPG,
    /**
     *  MP4
     */
    MediaTypeMP4,
    /**
     *  MOV
     */
    MediaTypeMOV,
    /**
     *  M4V
     */
    MediaTypeM4V,
    /**
     *  DNG
     */
    MediaTypeDNG,
};

typedef void (^AsyncOperationHandler)(NSError* error);
typedef void (^AsyncFetchHandler)(NSData* data, BOOL* stop, NSError* error);

@interface DJIMedia : NSObject

/**
 *  The media file name
 */
@property(nonatomic, readonly) NSString* fileName;

/**
 *  The media file size
 */
@property(nonatomic, readonly) long long fileSize;

/**
 *  The media's create time
 */
@property(nonatomic, readonly) NSString* createTime;

/**
 *  If media is video. this property is show the duration of the video
 */
@property(nonatomic, readonly) float durationSeconds;

/**
 *  The media type
 */
@property(nonatomic, readonly) MediaType mediaType;

/**
 *  The media url
 */
@property(nonatomic, readonly) NSString* mediaURL;

/**
 *  Thumbnail of this media. if nil user should call once - fetchThumbnail: to fetch the thumbnail data
 */
@property(nonatomic, readonly) UIImage* thumbnail;

-(id) initWithMediaURL:(NSString*)url;

/**
 *  Fetch this media's thumbnail from remote album.
 *
 *  @param completion if there is no error, property "thumbnail" will be set
 */
-(void) fetchThumbnail:(AsyncOperationHandler)completion;

/**
 *  Fetch media data from remote album.
 *
 *  @param handler Data callback will call when received data frome remote or some error occured
 */
-(void) fetchMediaData:(AsyncFetchHandler)handler;

/**
 *  Fetch media's preview image(960 x 540). the mediaType of this media object should be 'MediaTypeJPG'
 *
 *  @param result Remote execute result callback.
 */
-(void) fetchPreviewImageWithResult:(void(^)(UIImage* image, NSError* error))result;

@end

