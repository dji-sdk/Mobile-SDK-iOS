//
//  DemoUtilityMethod.h
//  DJISdkDemo
//
//  Copyright © 2015 DJI. All rights reserved.
//

#import <Foundation/Foundation.h>

extern NSString *splitCamelCase(NSString *input);

@interface NSData (Conversion)

+ (NSData *)md5:(NSString *)filePath;

@end
