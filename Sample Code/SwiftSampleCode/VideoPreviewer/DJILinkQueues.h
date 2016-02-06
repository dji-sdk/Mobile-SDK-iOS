//
//  DJILinkQueues.h
//  DJI
//
//  Copyright (c) 2013. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <pthread.h>

/**
 *  Static Link Queue (Thread safe)
 */
@interface DJILinkQueues : NSObject

/**
 *  Initial a static link queue with given size
 *
 *  @param size, if size <= 0, returns nil.
 *
 */
- (DJILinkQueues *)initWithSize:(int)size;

/**
 *  clean the queue.  The lock is used while doing so.
 */
- (void)clear;

/**
 *  Elements number in the queue
 *
 */
- (int)count;

/**
 *  Size of the queue
 *
 */
- (int)size;

/**
 *  Put the data into the queue
 *
 *  @param buf: pointer of the data
 *  @param len: size of the data.
 *
 *  @returns NO if the queue is full or queue is nil.
 */
- (bool)push:(uint8_t *)buf length:(int)len;

/**
 *  Take the data out of the queue.
 *
 *  @param len, out reference value which is the lenght of the returned data.
 *
 *  @returns the data.  If the queue is nil, the returned data is NULL.
 */
- (uint8_t *)pull:(int *)len;

/**
 *  The queue is full or not.
 *
 */
- (bool)isFull;

@end
