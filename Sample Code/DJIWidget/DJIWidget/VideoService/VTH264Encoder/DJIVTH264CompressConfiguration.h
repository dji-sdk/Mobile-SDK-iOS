//
//  DJIVTH264CompressConfiguration.h
//
//  Copyright (c) 2017 DJI. All rights reserved.
//

#import <Foundation/Foundation.h>

extern const NSUInteger kDefaultFrameRate;

//Usage type
typedef NS_ENUM(NSUInteger, DJIVTH264CompressConfigurationUsageType) {
    DJIVTH264CompressConfigurationUsageTypeLocalRecord,
    DJIVTH264CompressConfigurationUsageTypeLiveStream,
    DJIVTH264CompressConfigurationUsageTypeQuickMovie,
};



@interface DJIVTH264CompressConfiguration : NSObject

- (instancetype)initWithUsageType:(DJIVTH264CompressConfigurationUsageType)usageType;

- (void)setStreamFrameRate:(NSUInteger)frameRate;

- (NSDictionary *)configDict;

- (NSUInteger)configFrameRate;

@end
