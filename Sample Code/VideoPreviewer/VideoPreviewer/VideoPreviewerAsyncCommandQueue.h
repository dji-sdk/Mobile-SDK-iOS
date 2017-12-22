//
//  VideoPreviewerAsyncCommandQueue.h
//

/**
 *  实现一个用于异步命令队列，相当于runloop的行为，可以同步或异步的插入，读取，可以定义不同的命令插入规则
 */
#import <Foundation/Foundation.h>

/**
 命令执行前的上下文环境提示
 */
typedef enum : NSUInteger {
    VideoPreviewerAsyncCommandObjectWork_Initial, //还未执行
    VideoPreviewerAsyncCommandObjectWork_Normal, //正常执行
    VideoPreviewerAsyncCommandObjectWork_NeedCancel, //被取消
} VideoPreviewerAsyncCommandObjectWorkHint;

/**
 异步指令执行时，可以指定的option
 */
typedef enum : NSUInteger {
    VideoPreviewerAsyncCommandOption_FIFO = 0, //正常队列
    VideoPreviewerAsyncCommandOption_LIFO = 1<<0, //优先出队
    VideoPreviewerAsyncCommandOption_RemoveSameTag = 1<<1, //清除相同tag
} VideoPreviewerAsyncCommandOption;

typedef void(^VideoPreviewerAsyncCommandQueueOperation)(VideoPreviewerAsyncCommandObjectWorkHint hint);

/**
 *  异步命令对象
 */
@interface VideoPreviewerAsyncCommandObject : NSObject

/**
 *  是否一定需要回调，如果YES则即使被cancel了，也会回调，只是回调中的hint会变成 VideoPreviewerAsyncCommandObjectWork_NeedCancel
 */
@property (nonatomic, assign) BOOL alwaysNeedCallback;

/**
 *  将被调用的block
 */
@property (nonatomic, copy) VideoPreviewerAsyncCommandQueueOperation _Nullable workBlock;

/**
 *  命令的tag
 */
@property (nonatomic, readonly) NSObject* _Nullable tag;

/**
 *  延迟
 */
@property (nonatomic, readonly) NSDate* _Nullable runAfterDate;

/**
 *  构造命令
 *
 *  @param tag  tag description
 *  @param work work description
 *
 *  @return return value description
 */
+(instancetype _Nonnull) commandWithTag:(NSObject* _Nullable)tag block:(VideoPreviewerAsyncCommandQueueOperation _Nullable)work;
+(instancetype _Nonnull) commandWithTag:(NSObject* _Nullable)tag afterDate:(NSDate* _Nullable)date block:(VideoPreviewerAsyncCommandQueueOperation _Nullable)work;
@end

/**
 *  用于异步命令队列，相当于runloop的行为，可以同步或异步的插入，读取，可以定义不同的命令插入规则
 */
@interface VideoPreviewerAsyncCommandQueue : NSObject

/**
 *  是否需要线程安全
 *
 *  @param threadSafe threadSafe description
 *
 *  @return return value description
 */
-(id _Nonnull) initWithThreadSafe:(BOOL)threadSafe;

/**
 *  加入命令
 *
 *  @param command    command description
 *  @param optionFlag optionFlag description
 */
-(void) pushCommand:(VideoPreviewerAsyncCommandObject* _Nonnull)command withOption:(VideoPreviewerAsyncCommandOption)optionFlag;

/**
 *  取消指令，发送nil可以全部取消
 *
 */
-(void) cancelCommandWithTag:(NSObject* _Nullable)tag;

/**
 *  取消某些指令
 *
 *  @param tags array of NSString*
 */
-(void) cancelCommandWithTags:(NSArray* _Nullable)tags;

/**
 *  执行全部命令，完成后退出函数
 */
-(void) runloop;

/**
 *  执行全部命令, 带超时，完成后退出函数
 */
-(void) runloopWithTimeOutMS:(int)timeoutMs;

@end
