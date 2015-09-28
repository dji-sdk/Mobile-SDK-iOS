//
//  NSString+VersionCompare.h
//  DJISdkDemo
//
//  Created by Ares on 15/9/14.
//  Copyright (c) 2015年 DJI. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSString (VersionCompare)

-(NSComparisonResult) compareToVersion:(NSString*)otherVersion;

@end
