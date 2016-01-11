//
//  DJILinkQueues.h
//  DJI
//
//  Copyright (c) 2013年. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <pthread.h>

/**
 *  静态指针循环队列(线程安全)
 */
@interface DJILinkQueues : NSObject

/**
 *  初始化大小为size的静态指针循环队列
 *
 *  @param size 小于等于0则队列容量为空
 *
 *  @return 返回0
 */
- (DJILinkQueues *)initWithSize:(int)size;

/**
 *  清空队列，该情况下队列会加锁
 */
- (void)clear;

/**
 *  当前队列已使用的容量
 *
 *  @return 已使用的容量
 */
- (int)count;

/**
 *  当前的队列容量大小
 *
 *  @return 返回队列容量
 */
- (int)size;

/**
 *  将数据放入队列
 *
 *  @param buf 数据指针
 *  @param len 数据长度
 *
 *  @return 当返回值为No时队列满（若队列长度为0也返回NO）
 */
- (bool)push:(uint8_t *)buf length:(int)len;

/**
 *  将数据取出队列
 *
 *  @param len 返回数据的长度
 *
 *  @return 当返回值为NULL时，队列为空。
 */
- (uint8_t *)pull:(int *)len;

/**
 *  是否已满
 *
 *  @return 队列是否满
 */
- (bool)isFull;

@end
