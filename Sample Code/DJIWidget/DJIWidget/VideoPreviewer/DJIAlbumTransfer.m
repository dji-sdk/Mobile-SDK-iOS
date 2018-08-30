//
//  DJIAlbumTransfer.h
//
//  Copyright (c) 2015 DJI. All rights reserved.
//


#import <DJIWidgetMacros.h>
#import "DJIAlbumTransfer.h"
#import <AssetsLibrary/AssetsLibrary.h>
#import <Photos/Photos.h>

#ifndef SAFE_BLOCK
#define SAFE_BLOCK(block, ...) if(block){block(__VA_ARGS__);};
#endif

#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wdeprecated-declarations"

@implementation DJIAlbumTransfer
+(void) writeVideo:(NSString*)file toAlbum:(NSString*)album completionBlock:(void(^)(NSURL *assetURL, NSError *error))block{
    
    NSFileManager* fm = [NSFileManager defaultManager];
    if (![fm fileExistsAtPath:file]) {
        NSError *customError = [[NSError alloc] initWithDomain:@"drone.dji.com" code:DJIAlbumTransferErrorCode_FileNotFound userInfo:nil];
        SAFE_BLOCK(block, nil, customError);
    }
    
    if(!UIVideoAtPathIsCompatibleWithSavedPhotosAlbum(file)){
        NSError *customError = [[NSError alloc] initWithDomain:@"drone.dji.com" code:DJIAlbumTransferErrorCode_FileCannotPlay userInfo:nil];
        SAFE_BLOCK(block, nil, customError);
        return;
    }
    
    weakSelf(target);
    NSURL* fileURL = [NSURL fileURLWithPath:file];
    [self saveVideoToAssetLibrary:fileURL completionBlock:^(NSURL *assetURL, NSError *error) {//Write library continue writing the album
        weakReturn(target);
        
        if (!assetURL || error) {
            SAFE_BLOCK(block, nil, error);
            return;
        }
        
        __block ALAssetsLibrary *library = [[ALAssetsLibrary alloc] init];
        [library assetForURL:assetURL resultBlock:^(ALAsset *asset) {
             [target addAsset:asset toAlbum:album withAssetsLibrary:library completionBlock:^(ALAssetsGroup *group, NSError *error) {
                 
                 if (!group || error) {
                     SAFE_BLOCK(block, nil, error);
                     return;
                 }
                 
                 SAFE_BLOCK(block, assetURL, nil);
             }];
         }
        failureBlock:^(NSError * error){
            SAFE_BLOCK(block, nil, error);
            return;
        }];
    }];
}

+(void) writeVidoToAssetLibrary:(NSString*)file completionBlock:(void(^)(NSURL *assetURL, NSError *error))block{
    
    NSFileManager* fm = [NSFileManager defaultManager];
    if (![fm fileExistsAtPath:file]) {
        NSError *customError = [[NSError alloc] initWithDomain:@"drone.dji.com" code:DJIAlbumTransferErrorCode_FileNotFound userInfo:nil];
        SAFE_BLOCK(block, nil, customError);
    }
    
    if(!UIVideoAtPathIsCompatibleWithSavedPhotosAlbum(file)){
        NSError *customError = [[NSError alloc] initWithDomain:@"drone.dji.com" code:DJIAlbumTransferErrorCode_FileCannotPlay userInfo:nil];
        SAFE_BLOCK(block, nil, customError);
        return;
    }
    
    NSURL* fileURL = [NSURL fileURLWithPath:file];
    [DJIAlbumTransfer saveVideoToAssetLibrary:fileURL completionBlock:block];
}


//The file will be transferred to assetslibrary
+ (void)saveVideoToAssetLibrary:(NSURL *)url completionBlock:(void(^)(NSURL *assetURL, NSError *error))block;
{
    ALAssetsLibrary *library = [[ALAssetsLibrary alloc] init];
    
    weakSelf(target);
    [library writeVideoAtPathToSavedPhotosAlbum:url completionBlock:^(NSURL *assetURL, NSError *error) {
        weakReturn(target);
        if (error) {
            NSLog(@"writeVideoAtPathToSavedPhotosAlbum error: %@", error);
            SAFE_BLOCK(block, nil, error);
            return;
        }
        
        if (assetURL == NULL) {
            NSLog(@"writeVideoAtPathToSavedPhotosAlbum failed, maybe no space.");
            NSError *customError = [[NSError alloc] initWithDomain:@"drone.dji.com" code:DJIAlbumTransferErrorCode_NoDiskSpace userInfo:nil];
            SAFE_BLOCK(block, nil, customError);
            return;
        }
        
        NSLog(@"assetURL: %@", assetURL);
        SAFE_BLOCK(block, assetURL, nil);
    }];
}

+ (void)addAsset:(ALAsset *)asset toAlbum:(NSString*)album withAssetsLibrary:(ALAssetsLibrary *)library completionBlock:(void(^)(ALAssetsGroup *group, NSError *error))block;
{
    [self findOrCreateAssetsGroup:album withAssetsLibrary:library
                       completion:^(ALAssetsGroup *group, NSError *error){
                           if (error) {
                               SAFE_BLOCK(block, nil, error);
                               return;
                           } else {
                               [group addAsset:asset];
                               SAFE_BLOCK(block, group, nil);
                           }
                       }];
}

+ (void)findOrCreateAssetsGroup:(NSString *)groupName withAssetsLibrary:(ALAssetsLibrary *)library completion:(void (^)(ALAssetsGroup *group, NSError *error))completion{

    // replacement of the buggy *stop
    __block BOOL albumWasFound = NO;
    
    //search all photo albums in the library
    weakSelf(target);
    [library enumerateGroupsWithTypes:ALAssetsGroupAlbum
                           usingBlock:^(ALAssetsGroup *group, BOOL *stop) {
           if (albumWasFound) {
               return;
           }
           
           //compare the names of the albums
           if ([groupName compare: [group valueForProperty:ALAssetsGroupPropertyName]] == NSOrderedSame) {
               
               //target album is found
               *stop = YES; // not work for iOS 6.0.1
               albumWasFound = YES;
               SAFE_BLOCK(completion, group, nil);
               return;
           }
           
           if (group == nil) {
               //photo albums are over, target album does not exist, thus create it
               //create new assets album
               [target createAlbumWithCompletion:completion assetsLibrary:library groupName:groupName];
               
               //should be the last iteration anyway, but just in case
               return;
           }
       }
     failureBlock:^(NSError *error) {
         SAFE_BLOCK(completion, nil, error);
     }];
}

+ (void)createAlbumWithCompletion:(void (^)(ALAssetsGroup *group, NSError *error))completion assetsLibrary:(ALAssetsLibrary *)library groupName:(NSString *)groupName
{
    //search all photo albums in the library
    
    id PHPhotoLibrary_class = NSClassFromString(@"PHPhotoLibrary");
    
    //just ios8 have PHPhotoLibrary library
    
    if (PHPhotoLibrary_class)
    {
        NSLog(@"iOS8");
        
        // ---------  dynamic runtime code  -----------
        
        id sharedPhotoLibrary = [PHPhotoLibrary_class performSelector:@selector(sharedPhotoLibrary) withObject:nil];//[PHPhotoLibrary_class performSelector:NSSelectorFromString(@"sharedPhotoLibrary")];
        NSLog(@"sharedPhotoLibrary %@ ", sharedPhotoLibrary);
        
        SEL performChanges = NSSelectorFromString(@"performChanges:completionHandler:");
        
        NSMethodSignature *methodSig = [sharedPhotoLibrary methodSignatureForSelector:performChanges];
        
        NSInvocation* inv = [NSInvocation invocationWithMethodSignature:methodSig];
        [inv setTarget:sharedPhotoLibrary];
        [inv setSelector:performChanges];
        
        void(^firstBlock)(void) = ^void()
        {
            NSLog(@"firstBlock");
            Class PHAssetCollectionChangeRequest_class = NSClassFromString(@"PHAssetCollectionChangeRequest");
            //SEL creationRequestForAssetCollectionWithTitle = NSSelectorFromString(@"creationRequestForAssetCollectionWithTitle:");
//            NSLog(@"PHAssetCollectionChangeRequest_class %@ ", PHAssetCollectionChangeRequest_class);
            [PHAssetCollectionChangeRequest_class performSelector:@selector(creationRequestForAssetCollectionWithTitle:) withObject:groupName];
            
        };
        
        __block BOOL albumWasFound = NO;
        
        void (^secondBlock)(BOOL success, NSError *error) = ^void(BOOL success, NSError *error)
        {
            if (success) {
                [library enumerateGroupsWithTypes:ALAssetsGroupAlbum
                                       usingBlock:^(ALAssetsGroup *group, BOOL *stop) {
                                           
                                           if (albumWasFound) {
                                               return ;
                                           }
                                           
                                           if ([groupName compare: [group valueForProperty:ALAssetsGroupPropertyName]] == NSOrderedSame) {
                                               
                                               *stop = YES;
                                               albumWasFound = YES;
                                               SAFE_BLOCK(completion, group, nil);
                                               return;
                                           }
                                           
                                           if (group == nil) {
                                               
                                               *stop = YES;
                                               NSError *error = [NSError errorWithDomain:@"com.dji.drone" code:DJIAlbumTransferErrorCode_AlbumCanNotCreate userInfo:nil];
                                               SAFE_BLOCK(completion, nil, error);
                                           }
                                           
                                           
                                       } failureBlock:^(NSError *error) {
                                          SAFE_BLOCK(completion, nil, error);
                                       }];
            } else {
                SAFE_BLOCK(completion, nil, error);
            }
        };
        
        [inv setArgument:&firstBlock atIndex:2];
        [inv setArgument:&secondBlock atIndex:3];
        [inv invoke];
        
    } else {
        
        NSLog(@"iOS7");
        [library addAssetsGroupAlbumWithName:groupName
                                 resultBlock:^(ALAssetsGroup *group) {
                                     SAFE_BLOCK(completion, group, nil);
                                 } failureBlock:^(NSError *error) {
                                     SAFE_BLOCK(completion, nil, error);
                                 }];
    }
}

+(void) createAlbumIfNotExist:(NSString *)album{
    ALAssetsLibrary* library = [[ALAssetsLibrary alloc] init];
    [self findOrCreateAssetsGroup:album withAssetsLibrary:library
                       completion:^(ALAssetsGroup *group, NSError *error){
                       }];

}

@end

#pragma clang diagnostic pop

