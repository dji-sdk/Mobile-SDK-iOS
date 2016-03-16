//
//  VideoPreviewerQueue.h
//
//  Copyright (c) 2013 DJI. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <pthread.h>

/**
 *  Thread-safe Queue
 */
@interface VideoPreviewerQueue : NSObject

/**
 *  Creates a queue object.
 *
 *  @param size the initial size
 *
 *  @return the created queue
 */
- (VideoPreviewerQueue *)initWithSize:(int)size;

/**
 *  Cleans objects in queue.
 */
- (void)clear;

/**
 *  Gets the number of objects in queue.
 *
 *  @return the number of objects in queue
 */
- (int)count;

/**
 *  Get the size of the queue.
 *
 *  @return size in queue
 */
- (int)size;

/**
 *  Push data into the queue. It is the consumer's responsibility to release the data.
 *
 *  @param buf pointer to data
 *  @param len data length in byte
 *
 *  @return `YES` if the push operation succeeds.
 */
- (BOOL)push:(uint8_t *)buf length:(int)len;

/**
 *  Pull data from the queue.
 *
 *  @param len length of data to pull
 *
 *  @return Data pulled.
 */
- (uint8_t *)pull:(int *)len;

/**
 *  Returns `YES` if the queue is already full.
 *
 *  @return `YES` if the queue is full.
 */
- (bool)isFull;

/**
 * Wakeup the blocking consumer. 
 */
- (void)wakeupReader;

@end
