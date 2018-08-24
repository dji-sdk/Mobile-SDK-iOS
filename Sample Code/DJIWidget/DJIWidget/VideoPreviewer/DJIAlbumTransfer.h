//
//  DJIAlbumTransfer.h
//
//  Copyright (c) 2015 DJI. All rights reserved.
//


#import <UIKit/UIKit.h>

#define DJI_IMPORT_DEFAULT_ALBUM (@"DJI Import")
#define DJI_MOMENTS_ALBUM (@"DJI Moments")
#define DJI_FILM_ALBUM (@"DJI Works")

typedef enum{
    DJIAlbumTransferErrorCode_Unknown = 0,
    DJIAlbumTransferErrorCode_FileNotFound,
    DJIAlbumTransferErrorCode_FileCannotPlay,
    DJIAlbumTransferErrorCode_AlbumCanNotCreate,
    DJIAlbumTransferErrorCode_NoDiskSpace
} DJIAlbumTransferErrorCode;

//For existing video files into photo library
//Returned error code is possible only error，It may also be derived from the system having localized
@interface DJIAlbumTransfer : NSObject

+(void) writeVidoToAssetLibrary:(NSString*)file completionBlock:(void(^)(NSURL *assetURL, NSError *error))block;

+(void) writeVideo:(NSString*)file toAlbum:(NSString*)album completionBlock:(void(^)(NSURL *assetURL, NSError *error))block;
+(void) createAlbumIfNotExist:(NSString*)album;
@end
