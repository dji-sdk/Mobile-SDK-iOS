//
//  DJIAlbumHandler.m
//
//  Copyright (c) 2017 DJI. All rights reserved.
//

#import "DJIAlbumHandler.h"
#import "DJIWidgetMacros.h"

#define NO_SAPCE_ERROR_CODE (-1)
#define ADD_ASSET_ERROR (-2)
#define UNKNOWN_ERROR_CODE (-11)


@implementation DJIAlbumHandler

#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wdeprecated-declarations"

+ (void)savePhotoToAssetLibrary:(NSURL *)url completionBlock:(DJIAlbumCompletionBlock)completion{
    [self savePhotoToAssetLibrary2:url completionBlock:^(NSURL *assetURL, ALAsset *asset, NSError *error) {
        if (completion) {
            completion(assetURL, error);
        }
    }];
}

+ (void)savePhotoToAssetLibrary2:(NSURL *)url completionBlock:(DJIAlbumCompletionBlock2)completion
{
    NSLog(@"save asset library: %@", url);
    ALAssetsLibrary *library = [[ALAssetsLibrary alloc] init];
    NSLog(@"save url: %@", url);
    NSError *tmpError = nil;
    NSData *data = [NSData dataWithContentsOfURL:url options:0 error:&tmpError];
    NSLog(@"save data length: %tu", [data length]);
    NSLog(@"save data error: %@", tmpError);
    [library writeImageDataToSavedPhotosAlbum:[NSData dataWithContentsOfURL:url] metadata:nil
                              completionBlock:^(NSURL *assetURL, NSError *error) {
                                  if (error) {
                                      NSLog(@"writeImageDataToSavedPhotosAlbum error: %@", error);
                                      if (completion) {
                                          completion(nil, nil, error);
                                      }
                                      return;
                                  }
                                  
                                  if (assetURL == NULL) {
                                      NSLog(@"writeImageDataToSavedPhotosAlbum failed, maybe no space.");
                                      NSString *description = @"No space left on device";
                                      NSDictionary *errorDict = @{NSLocalizedDescriptionKey : description, NSLocalizedFailureReasonErrorKey : description, NSURLErrorKey: url};
                                      NSError *customError = [[NSError alloc] initWithDomain:@"drone.dji.com" code:NO_SAPCE_ERROR_CODE userInfo:errorDict];
                                      if (completion) {
                                          completion(nil, nil, customError);
                                      }
                                      return;
                                  }
                                  
                                  NSLog(@"assetURL: %@", assetURL);
                                  
                                  [library assetForURL: assetURL
                                           resultBlock:^(ALAsset *asset) {
                                               [self addAssetToDJEyeAlbum:asset assetsLibrary:library withCompletionBlock:completion assetURL:assetURL];
                                           }
                                          failureBlock:^(NSError * error){
                                              if (completion) {
                                                  completion(nil, nil, error);
                                              }
                                          }];
                              }];
}

+ (void)saveVideoToAssetLibrary:(NSURL *)url withCompletionBlock:(DJIAlbumCompletionBlock2)completion
{
    ALAssetsLibrary *library = [[ALAssetsLibrary alloc] init];
    
    [library writeVideoAtPathToSavedPhotosAlbum:url
                                completionBlock:^(NSURL *assetURL, NSError *error) {
                                    if (error) {
                                        NSLog(@"writeVideoAtPathToSavedPhotosAlbum error: %@", error);
                                        if (completion) {
                                            completion(nil, nil, error);
                                        }
                                        return;
                                    }
                                    
                                    if (assetURL == NULL) {
                                        NSLog(@"writeVideoAtPathToSavedPhotosAlbum failed, maybe no space.");
                                        NSString *description = @"No space left on device";
                                        NSDictionary *errorDict = @{NSLocalizedDescriptionKey : description, NSLocalizedFailureReasonErrorKey : description, NSURLErrorKey: url};
                                        NSError *customError = [[NSError alloc] initWithDomain:@"drone.dji.com" code:NO_SAPCE_ERROR_CODE userInfo:errorDict];
                                        if (completion) {
                                            completion(nil, nil, customError);
                                        }
                                        return;
                                    }
                                    
                                    NSLog(@"assetURL: %@", assetURL);
                                    
                                    [library assetForURL: assetURL
                                             resultBlock:^(ALAsset *asset) {
                                                 [self addAssetToDJEyeAlbum:asset  assetsLibrary:library withCompletionBlock:^(NSURL *assetURL, ALAsset *asset, NSError *error) {
                                                     if (completion) {
                                                         completion(assetURL, asset, error);
                                                     }
                                                 } assetURL:assetURL];
                                             }
                                            failureBlock:^(NSError * error){
                                                if (completion) {
                                                    completion(nil, nil, error);
                                                }
                                                
                                            }];
                                }];
}

+ (void)addAssetToDJEyeAlbum:(ALAsset *)asset assetsLibrary:(ALAssetsLibrary *)library withCompletionBlock:(DJIAlbumCompletionBlock2)completion assetURL:(NSURL *)assetURL
{
    NSLog(@"save asset to album");
    
    [self findOrCreateAssetsGroup:NSLocalizedString(@"import_album_name", @"")
                       completion:^(ALAssetsGroup *group, NSError *error){
                           NSLog(@"assets group: %@", group);
                           if (error) {
                               if (completion) {
                                   completion(nil, nil, error);
                               }
                           } else {
                               @try {
                                   BOOL ret = [group addAsset:asset];
                                   NSLog(@"add addasset to grou %@ , ret code : %d", group, ret);
                                   if (completion) {
                                       completion(assetURL, asset, nil);
                                   }
                               }
                               @catch (NSException *exception) {
                                   NSLog(@"exception: %@", exception);
                                   NSString *description = @"add asset error!";
                                   NSDictionary *errorDict = @{NSLocalizedDescriptionKey : description, NSLocalizedFailureReasonErrorKey : description};
                                   NSError *customError = [[NSError alloc] initWithDomain:@"drone.dji.com" code:ADD_ASSET_ERROR userInfo:errorDict];
                                   if (completion) {
                                       completion(nil, nil, customError);
                                   }
                                   return;
                               }
                               @finally {
                                   
                               }

                           }
                           
                       }assetsLibrary:library];
}

+ (void)findOrCreateAssetsGroup:(NSString *)groupName completion:(void (^)(ALAssetsGroup *group, NSError *error))completion assetsLibrary:(ALAssetsLibrary *)library {
    //ALAssetsLibrary *library = [[ALAssetsLibrary alloc] init];
    
    // replacement of the buggy *stop
    __block BOOL albumWasFound = NO;
    
    weakSelf(target);
    
    [library enumerateGroupsWithTypes:ALAssetsGroupAlbum
                           usingBlock:^(ALAssetsGroup *group, BOOL *stop) {
                               if (albumWasFound) {
                                   return;
                               }
                               
                               if ([groupName compare: [group valueForProperty:ALAssetsGroupPropertyName]] == NSOrderedSame) {
                                   
                                   //target album is found
                                   *stop = YES; // not work for iOS 6.0.1
                                   albumWasFound = YES;
                                   if (completion) {
                                        completion(group, nil);
                                   }
                                   
                                   //album was found, bail out of the method
                                   return;
                               }
                               
                               if (group == nil) {
                                   
                                   [target createAlbumWithCompletion:completion assetsLibrary:library groupName:groupName];
                               }
                               
                               
                           } failureBlock:^(NSError *error) {
                               if (completion) {
                                   completion(nil, error);
                               }
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
            //            SEL creationRequestForAssetCollectionWithTitle = NSSelectorFromString(@"creationRequestForAssetCollectionWithTitle:");
            NSLog(@"PHAssetCollectionChangeRequest_class %@ ", PHAssetCollectionChangeRequest_class);
            
            
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
                                               if (completion) {
                                                   completion(group, nil);
                                               }
                                               
                                               return;
                                           }
                                           
                                           if (group == nil) {
                                               
                                               *stop = YES;
                                               NSError *error = [NSError errorWithDomain:@"com.dji.drone" code:-11 userInfo:nil];
                                               if (completion) {
                                                   completion(nil, error);
                                               }
                                           }
                                           
                                           
                                       } failureBlock:^(NSError *error) {
                                           if (completion) {
                                               completion(nil, error);
                                           }
                                       }];
            } else {
                if (completion) {
                    completion(nil, error);
                }
            }
        };
        
        [inv setArgument:&firstBlock atIndex:2];
        [inv setArgument:&secondBlock atIndex:3];
        
        [inv invoke];
        
    } else {
        
        NSLog(@"iOS7");
        [library addAssetsGroupAlbumWithName:groupName
                                 resultBlock:^(ALAssetsGroup *group) {
                                     if (completion) {
                                         completion(group, nil);
                                     }

                                 } failureBlock:^(NSError *error) {
                                     if (completion) {
                                         completion(nil, error);
                                     }
                                 }];
    }
}

#pragma clang diagnostic pop

@end
