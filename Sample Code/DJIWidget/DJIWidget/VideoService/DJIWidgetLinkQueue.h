//
//  DJIWidgetLinkQueue.h
//
//  Copyright (c) 2017 DJI. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <pthread.h>

NS_ASSUME_NONNULL_BEGIN

/**
 *  Threadsafe circular queue
 */
@interface DJIWidgetLinkQueue : NSObject

- (id)initWithSize:(int)size;

- (void)clear;

- (int)count;

- (int)size;

- (BOOL)push:(uint8_t *)buf length:(int)len;

- (uint8_t *)pull:(int *)len;

- (bool)isFull;

- (void)wakeupReader;

- (uint8_t *)getHeaderOfQueue;

@end

@interface DJIObjectLinkQueue : NSObject

- (id)initWithSize:(int)size;

- (void)clear;

- (int)count;

- (int)size;

- (BOOL)push:(id)object;

- (_Nullable id)pull;

- (bool)isFull;

- (void)wakeupReader;

- (_Nullable id)getHeaderOfQueue;

@end

NS_ASSUME_NONNULL_END
