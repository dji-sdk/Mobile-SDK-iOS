//
//  DJIDemoHelper.m
//  DJISdkDemo
//
//  Created by Ares on 15/4/10.
//  Copyright (c) 2015年 DJI. All rights reserved.
//

#import "DJIDemoHelper.h"

void ShowResult(NSString *format, ...)
{
    va_list argumentList;
    va_start(argumentList, format);
    
    NSString* message = [[NSString alloc] initWithFormat:format arguments:argumentList];
    va_end(argumentList);
    
    UIAlertView* alertView = [[UIAlertView alloc] initWithTitle:nil message:message delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
    [alertView show];
}

@implementation DJIDemoHelper

+(NSString*) droneName:(DJIDroneType)type
{
    if (type == DJIDrone_Inspire) {
        return @"Inspire";
    }
    else if (type == DJIDrone_Phantom3Professional)
    {
        return @"Phantom 3 Professional";
    }
    else if (type == DJIDrone_Phantom3Advanced)
    {
        return @"Phantom 3 Advanced";
    }
    
    return nil;
}

@end
