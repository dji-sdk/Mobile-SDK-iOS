//
//  NSString+VersionCompare.m
//  DJISdkDemo
//
//  Created by Ares on 15/9/14.
//  Copyright (c) 2015年 DJI. All rights reserved.
//

#import "NSString+VersionCompare.h"

@implementation NSString (VersionCompare)

-(NSComparisonResult) compareToVersion:(NSString*)otherVersion
{
    if (otherVersion == nil || otherVersion.length == 0) {
        return NSOrderedAscending;
    }
    
    NSArray* obj1 = [self componentsSeparatedByString:@"."];
    NSArray* obj2 = [otherVersion componentsSeparatedByString:@"."];
    
    int nCount = (int)MIN(obj1.count, obj2.count);
    for (int i = 0; i < nCount; i++) {
        int n1 = [obj1[i] intValue];
        int n2 = [obj2[i] intValue];
        
        if (n1 < n2) {
            return NSOrderedDescending;
        }
        if (n1 > n2) {
            return NSOrderedAscending;
        }
    }
    
    if (obj1.count > obj2.count) {
        return NSOrderedAscending;
    }
    else if(obj1.count < obj2.count)
    {
        return NSOrderedDescending;
    }
    else
        return NSOrderedSame;
}

@end
