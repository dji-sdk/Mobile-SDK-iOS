//
//  DemoUtilityMethods.m
//  DJISdkDemo
//
//  Copyright © 2015 DJI. All rights reserved.
//

#import "DemoUtilityMethod.h"
#import <CommonCrypto/CommonCrypto.h>

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

@implementation NSData (Conversion)

+ (NSData *)md5:(NSString *)filePath {
    CC_MD5_CTX md5Ctx;
    CC_MD5_Init(&md5Ctx);
    
    FILE *file = fopen(filePath.UTF8String, "rb");
    if (file == NULL) {
        return nil;
    }
    
    size_t buffer_len = 256;
    void *buffer = malloc(buffer_len);
    while (1) {
        size_t readLengh = fread(buffer, 1, buffer_len, file);
        if (readLengh > 0) {
            CC_MD5_Update(&md5Ctx, buffer, (CC_LONG)readLengh);
        } else {
            break;
        }
    }

    unsigned char digest[CC_MD5_DIGEST_LENGTH];
    CC_MD5_Final(digest, &md5Ctx);
    free(buffer);
    
    fclose(file);
    file = NULL;

    NSData *md5Data = [NSData dataWithBytes:digest length:CC_MD5_DIGEST_LENGTH];

    return md5Data;
}

@end
