//
//  DJIH264PocQueue.h
//
//  Copyright (c) 2017 DJI. All rights reserved.
//
#import <UIKit/UIKit.h>
#import "DJIStreamCommon.h"

NS_ASSUME_NONNULL_BEGIN


/**
   A fixed-length priority queue, sorted by poc
   Encounter IDR then split the poc
   Optional lockless, need to operate in the same thread
 */
@interface DJIH264PocQueue : NSObject

/**
  * Initialize a static pointer loop queue of a given size
  *
  * @param size less than or equal to 0 the queue capacity is empty
  *
  */
- (id)initWithSize:(int)size
        threadSafe:(BOOL)threadSafe;

/**
 *  Clear the queue, in which case the queue will be locked
 */
- (void)clear;

/**
 *
 *  @return number of frames currently in queue
 */
- (int)count;

/**
 *
 *  @return current queue size
 */
- (int)size;

/**
 *  Put the data into the queue (the queue and subsequent queues remove the data.)
 *
 *  @param data object
 *
 *  @return When the return value is No, the queue is full (NO is returned if the queue length is 0)
 */
- (BOOL)push:(VideoFrameYUV*)object;

/**
 *  Remove data from the queue
 *
 *  @return When NULL, the queue is empty.
 */
- ( VideoFrameYUV* _Nullable )pull;

/**
 *  Checks if queue is full
 *
 */
- (bool)isFull;

/**
 * Special usage, for some read thread that is immediately wakeup waiting, the pull method will return null
 */
- (void)wakeupReader;


@end

NS_ASSUME_NONNULL_END
