//
//  NSError+DJIVTH264CompressSession.m
//
//  Copyright (c) 2017 DJI. All rights reserved.
//



#import <VideoToolbox/VTErrors.h>
#import "NSError+DJIVTH264CompressSession.h"


NSString * const DJIVTH264CompressSessionErrorDomain = @"DJIVTH264CompressSessionErrorDomain";


static NSString * DescriptionWithStatus(OSStatus status){
    switch(status) {
        case kVTPropertyNotSupportedErr:
            return @"Property Not Supported";
        default:
            return [NSString stringWithFormat:@"Video Toolbox Error: %d", (int)status];
    }
}


@implementation NSError (DJIVTH264CompressSession)

+ (NSError *)videoToolboxErrorWithStatus:(OSStatus)status {
    NSDictionary* userInfo = @{NSLocalizedDescriptionKey:DescriptionWithStatus(status)};
    return [NSError errorWithDomain:DJIVTH264CompressSessionErrorDomain code:(NSInteger)status userInfo:userInfo];
}

@end
