//
//  PipelineStatistical.m
//  DJISdkDemo
//
//  Copyright © 2020 DJI. All rights reserved.
//

#import "PipelineStatistical.h"

@implementation PipelineStatistical

- (void)clearRegularData {
    self.numberOfPacketsFailure = 0;
    self.numberOfBytesSuccessfully = 0;
    self.numberOfPacketsSuccessfully = 0;
}

@end
