//
//  PipelineStatistical.h
//  DJISdkDemo
//
//  Copyright © 2020 DJI. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface PipelineStatistical : NSObject

/// Number of cases successfully received or sent within the time frame
@property (nonatomic) NSInteger numberOfPacketsSuccessfully;

/// Number of bytes successfully received or sent in a given period of time
@property (nonatomic) NSInteger numberOfBytesSuccessfully;

/// Start transmission time
@property (nonatomic) CFAbsoluteTime startTime;

/// End transmission time
@property (nonatomic) CFAbsoluteTime endTime;

/// Total successful receptions
@property (nonatomic) NSInteger totalSuccessful;

- (void)clearRegularData;

@end

NS_ASSUME_NONNULL_END
