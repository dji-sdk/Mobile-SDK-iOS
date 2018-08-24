//
//  DJIPixelCache.m
//  DJIWidget
//
//  Copyright © 2018 DJI. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "DJIPixelCache.h"

@interface DJIPixelCache(){
    CVPixelBufferRef _pixel;
    CGSize _frameSize;
    OSType _frameType;
}
@end

@implementation DJIPixelCache

-(void)dealloc{
    if (_pixel != NULL){
        CVBufferRelease(_pixel);
        _pixel = NULL;
    }
}

-(instancetype)initWithFrameWidth:(NSUInteger)width
                           height:(NSUInteger)height
                     andFrameType:(OSType)type{
    if (self = [self init]){
        _frameType = type;
        _frameSize = CGSizeMake(width, height);
        [self initPixel];
    }
    return self;
}

-(instancetype)init{
    if (self = [super init]){
        _pixel = NULL;
        _frameSize = CGSizeZero;
        _frameType = kCVPixelFormatType_420YpCbCr8Planar;
    }
    return self;
}

-(BOOL)checkFitsFrameWidth:(NSUInteger)width
                    height:(NSUInteger)height
              andFrameType:(OSType)type{
    if (!CGSizeEqualToSize(_frameSize, CGSizeMake(width, height))){
        return NO;
    }
    if (_frameType != type){
        NSArray* compitableTypes = [[[self class] osTypeMap] objectForKey:@(type)];
        if (![compitableTypes isKindOfClass:[NSArray class]]
            || ![compitableTypes containsObject:@(_frameType)]){
            return NO;
        }
    }
    if (_pixel == NULL){
        return NO;
    }
    return YES;
}

-(CVPixelBufferRef)pixelBuffer{
    return _pixel;
}

-(void)initPixel{
    if (_frameSize.width <= 0
        || _frameSize.height <= 0){
        _pixel = NULL;
        return;
    }
    if (_pixel != NULL){
        CVPixelBufferRelease(_pixel);
        _pixel = NULL;
    }
    NSDictionary *options = [NSDictionary dictionaryWithObjectsAndKeys:
                             @(YES), kCVPixelBufferCGImageCompatibilityKey,
                             @(YES), kCVPixelBufferCGBitmapContextCompatibilityKey,
                             nil];
    CVReturn create_status = CVPixelBufferCreate(kCFAllocatorDefault,
                                                 _frameSize.width,
                                                 _frameSize.height,
                                                 _frameType,
                                                 (__bridge CFDictionaryRef)options,
                                                 &_pixel);
    
    if (kCVReturnSuccess != create_status
        || _pixel == NULL) {
        CVPixelBufferRelease(_pixel);
        _pixel = NULL;
    }
}
            
+(NSDictionary*)osTypeMap{
    static NSDictionary* map = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        map = @{
                @(kCVPixelFormatType_420YpCbCr8BiPlanarFullRange):@[
                        @(kCVPixelFormatType_420YpCbCr8BiPlanarVideoRange),
                        @(kCVPixelFormatType_420YpCbCr8BiPlanarFullRange),
                        ],
                @(kCVPixelFormatType_420YpCbCr8BiPlanarVideoRange):@[
                        @(kCVPixelFormatType_420YpCbCr8BiPlanarVideoRange),
                        @(kCVPixelFormatType_420YpCbCr8BiPlanarFullRange),
                        ],
                @(kCVPixelFormatType_420YpCbCr8PlanarFullRange):@[
                        @(kCVPixelFormatType_420YpCbCr8Planar),
                        @(kCVPixelFormatType_420YpCbCr8PlanarFullRange),
                        ],
                @(kCVPixelFormatType_420YpCbCr8Planar):@[
                        @(kCVPixelFormatType_420YpCbCr8Planar),
                        @(kCVPixelFormatType_420YpCbCr8PlanarFullRange),
                        ],
                };
    });
    return map;
}

@end
