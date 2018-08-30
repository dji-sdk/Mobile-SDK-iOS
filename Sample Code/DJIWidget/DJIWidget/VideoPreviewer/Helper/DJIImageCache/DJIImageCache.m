//
//  DJIImageCache.m
//  DJIWidget
//
//  Copyright © 2018 DJI. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "DJIImageCache.h"

@interface DJIImageCache(){
    NSArray* _sizes;
    void* _baseAddr;
}
@end

@implementation DJIImageCache

-(void)dealloc{
    if (_baseAddr != NULL){
        free(_baseAddr);
        _baseAddr = NULL;
    }
}

-(instancetype)initWithCacheSizeArray:(NSArray*)sizes{
    if (self = [super init]){
        if ([sizes isKindOfClass:[NSArray class]]){
            _sizes = sizes.copy;
        }
        else{
            _sizes = nil;
        }
        _baseAddr = NULL;
        [self initMem];
    }
    return self;
}

-(void)initMem{
    NSUInteger sizeNeeded = 0;
    for (NSNumber* size in _sizes){
        if (![size isKindOfClass:[NSNumber class]]){
            continue;
        }
        sizeNeeded += size.unsignedIntegerValue;
    }
    if (_baseAddr != NULL){
        free(_baseAddr);
        _baseAddr = NULL;
    }
    if (sizeNeeded > 0){
        _baseAddr = malloc(sizeNeeded);
        if (_baseAddr != NULL){
            memset(_baseAddr, 0, sizeNeeded);
        }
    }
}

-(void*)baseAddrForIndex:(NSUInteger)index{
    if (index >= _sizes.count
        || _baseAddr == NULL){
        return NULL;
    }
    NSNumber* size = [_sizes objectAtIndex:index];
    if (![size isKindOfClass:[NSNumber class]]){
        return NULL;
    }
    NSUInteger offset = 0;
    for (NSUInteger startIndex = 0; startIndex < index; startIndex++){
        NSNumber* size = [_sizes objectAtIndex:startIndex];
        if (![size isKindOfClass:[NSNumber class]]){
            continue;
        }
        offset += size.unsignedIntegerValue;
    }
    return (void*)((uint8_t*)_baseAddr + offset);
}

-(BOOL)checkFitsSizeArray:(NSArray*)sizes{
    if (_sizes == nil){
        return NO;
    }
    if (![sizes isKindOfClass:[NSArray class]]){
        return NO;
    }
    return [_sizes isEqualToArray:sizes];
}

@end
