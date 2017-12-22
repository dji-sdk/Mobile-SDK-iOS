//
//  DJIH264PocQueue.h
//

#import <UIKit/UIKit.h>
#import "DJIStreamCommon.h"

NS_ASSUME_NONNULL_BEGIN


/**
 一个固定长度的优先队列，根据poc来排序
 * 遇到IDR则对poc进行分割
 * 可选无锁，需要在同线程中操作
 */
@interface DJIH264PocQueue : NSObject

/**
 *  初始化大小为size的静态指针循环队列
 *
 *  @param size 小于等于0则队列容量为空
 *
 *  @return 返回0
 */
- (id)initWithSize:(int)size
        threadSafe:(BOOL)threadSafe;

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
 *  将数据放入队列(由队列和后续取出队列者去释放数据。 )
 *
 *  @param object 数据
 *
 *  @return 当返回值为No时队列满（若队列长度为0也返回NO）
 */
- (BOOL)push:(VideoFrameYUV*)object;

/**
 *  将数据取出队列
 *
 *  @return 当返回值为NULL时，队列为空。
 */
- ( VideoFrameYUV* _Nullable )pull;

/**
 *  是否已满
 *
 *  @return 队列是否满
 */
- (bool)isFull;

/**
 * 特殊用法，用于立即wakeup等待的某个read线程，pull方法将会返回null
 */
- (void)wakeupReader;


@end

NS_ASSUME_NONNULL_END
