//
//  DemoUtilityMethods.m
//  DJISdkDemo
//
//  Copyright © 2015 DJI. All rights reserved.
//

#import "DemoUtilityMethod.h"

NSString *splitCamelCase(NSString *input) {
    NSMutableString *output = [NSMutableString string];
    NSCharacterSet *uppercase = [NSCharacterSet uppercaseLetterCharacterSet];
    for (NSInteger idx = 0; idx < [input length]; idx += 1) {
        unichar c = [input characterAtIndex:idx];
        if ([uppercase characterIsMember:c]) {
            [output appendFormat:@" %@", [[NSString stringWithCharacters:&c length:1] lowercaseString]];
        } else {
            [output appendFormat:@"%C", c];
        }
    }
    return output;
}
