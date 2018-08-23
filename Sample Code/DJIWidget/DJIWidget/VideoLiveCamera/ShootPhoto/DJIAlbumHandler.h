//
//  DJIAlbumHandler.h
//
//  Copyright (c) 2017 DJI. All rights reserved.
//
#import <AssetsLibrary/AssetsLibrary.h>
#import <Foundation/Foundation.h>
#import <Photos/Photos.h>

#pragma GCC diagnostic push
#pragma GCC diagnostic ignored "-Wdeprecated-declarations"
typedef void (^DJIAlbumCompletionBlock)(NSURL *assetURL , NSError *error);
typedef void (^DJIAlbumCompletionBlock2)(NSURL *assetURL , ALAsset* asset, NSError *error);
#pragma GCC diagnostic pop

@interface DJIAlbumHandler : NSObject

+ (void) __attribute__((deprecated)) savePhotoToAssetLibrary:(NSURL *)url completionBlock:(DJIAlbumCompletionBlock)completion;
+ (void) __attribute__((deprecated)) savePhotoToAssetLibrary2:(NSURL *)url completionBlock:(DJIAlbumCompletionBlock2)completion;
+ (void) __attribute__((deprecated)) saveVideoToAssetLibrary:(NSURL *)url withCompletionBlock:(DJIAlbumCompletionBlock2)completion;
+ (void) __attribute__((deprecated)) findOrCreateAssetsGroup:(NSString *)groupName completion:(void (^)(ALAssetsGroup *group, NSError *error))completion assetsLibrary:(ALAssetsLibrary *)library;
@end
