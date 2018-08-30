//
//  NSError+DJIVTH264CompressSession.h
//
//  Copyright (c) 2017 DJI. All rights reserved.
//
#import <Foundation/Foundation.h>


extern NSString * const DJIVTH264CompressSessionErrorDomain;


@interface NSError (DJIVTH264CompressSession)

+ (NSError *)videoToolboxErrorWithStatus:(OSStatus)status;

@end
