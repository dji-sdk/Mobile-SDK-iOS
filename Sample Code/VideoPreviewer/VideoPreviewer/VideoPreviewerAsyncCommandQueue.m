//
//  VideoPreviewerAsyncCommandQueue.m
//

#import "VideoPreviewerAsyncCommandQueue.h"
#import <pthread.h>
#import <sys/time.h>

// SDK
#import "VideoPreviewerMacros.h"

@interface VideoPreviewerAsyncCommandObject ()
//用于在命令队列里面标记已经被清除的对象
@property (nonatomic, assign) BOOL cancelMark;
@property (nonatomic, strong) NSObject* _Nullable tag;
@property (nonatomic, strong) NSDate* _Nullable runAfterDate;
@end

@implementation VideoPreviewerAsyncCommandObject

+(instancetype) commandWithTag:(NSObject*)tag block:(VideoPreviewerAsyncCommandQueueOperation)work{
    return [self commandWithTag:tag afterDate:nil block:work];
}

+(instancetype) commandWithTag:(NSObject*)tag afterDate:(NSDate * _Nullable)date block:(VideoPreviewerAsyncCommandQueueOperation)work{
    VideoPreviewerAsyncCommandObject* object = [[VideoPreviewerAsyncCommandObject alloc] init];
    object.tag = tag;
    object.workBlock = work;
    object.runAfterDate = date;
    return object;
}

@end

@interface VideoPreviewerAsyncCommandQueue (){
    pthread_mutex_t _wait_mutex;
    pthread_cond_t _cond;
}

/**
 *  待执行的命令队列, 为了方便先用nsarray，如果效率不够以后再改
 */
@property (nonatomic, strong) NSMutableArray* commandArray;

/**
 *  是否需要线程安全
 */
@property (nonatomic, assign) BOOL needThreadSafe;
@end

@implementation VideoPreviewerAsyncCommandQueue

-(id) init{
    return [self initWithThreadSafe:YES];
}

-(id) initWithThreadSafe:(BOOL)threadSafe{
    if (self = [super init]) {
        self.needThreadSafe = threadSafe;
        pthread_mutex_init(&_wait_mutex, nil);
        pthread_cond_init(&_cond, nil);
        
        self.commandArray = [NSMutableArray array];
    }
    
    return self;
}

-(void) dealloc{
    pthread_mutex_destroy(&_wait_mutex);
    pthread_cond_destroy(&_cond);
}

-(void) pushCommand:(VideoPreviewerAsyncCommandObject *)command withOption:(VideoPreviewerAsyncCommandOption)optionFlag{
    if (!command) {
        return;
    }
    
    if(_needThreadSafe){
        pthread_mutex_lock(&_wait_mutex);
    }
    
    if (optionFlag & VideoPreviewerAsyncCommandOption_RemoveSameTag) {
        //先移除之前的命令
        for (VideoPreviewerAsyncCommandObject* object in self.commandArray) {
            if ([object.tag isEqual:command.tag]) {
                object.cancelMark = YES;
            }
        }
    }
    
    if (optionFlag & VideoPreviewerAsyncCommandOption_LIFO) {
        //插入队列前面
        [self.commandArray insertObject:command atIndex:0];
    } else{
        [self.commandArray addObject:command];
    }
    
    pthread_cond_signal(&_cond);
    if (_needThreadSafe) {
        pthread_mutex_unlock(&_wait_mutex);
    }
}

-(void) runloop{
    [self runloopWithTimeOutMS:0];
}

-(void) cancelCommandWithTag:(NSObject *)tag{
    NSArray* tags = nil;
    if (tag) {
        tags = @[tag];
    }
    
    [self cancelCommandWithTags:tags];
}

-(void) cancelCommandWithTags:(NSArray*)tags;{
    if(_needThreadSafe){
        pthread_mutex_lock(&_wait_mutex);
    }
    
    if (!tags) {
        for (VideoPreviewerAsyncCommandObject* object in self.commandArray) {
            object.cancelMark = YES;
        }
    }
    else{
        //留着在runloop的时候再清理也行
        for (VideoPreviewerAsyncCommandObject* object in self.commandArray) {
            for (NSObject* tag in tags) {
                if ([object.tag isEqual:tag]) {
                    object.cancelMark = YES;
                    break;
                }
            }
        }
    }
    
    if (_needThreadSafe) {
        pthread_mutex_unlock(&_wait_mutex);
    }
}

-(void) runloopWithTimeOutMS:(int)timeoutMs{
    NSDate* current = [NSDate date];
    
    if (_needThreadSafe) {
        pthread_mutex_lock(&_wait_mutex);
    }
    
    if (timeoutMs == 0 || self.commandArray.count || !_needThreadSafe) {
        //不用等待
    }else{
        //需要等待
        struct timeval tv;
        gettimeofday(&tv, NULL);
        
        struct timespec ts;
        long nanoSec = ((long)tv.tv_usec + (long)timeoutMs*1000)*(long)1000;
        ts.tv_sec = tv.tv_sec + nanoSec/(1000000000);
        ts.tv_nsec = nanoSec%(1000000000);
        pthread_cond_timedwait(&_cond, &_wait_mutex, &ts);
        if(_commandArray.count == 0)
        {
            //timeout
            pthread_mutex_unlock(&_wait_mutex);
            return;
        }
    }
    
    //commands for work
    NSMutableArray* commands = nil;
    
    if (self.commandArray.count) {
        //取出需要执行的command
        commands = [NSMutableArray arrayWithCapacity:self.commandArray.count];
        for (VideoPreviewerAsyncCommandObject* command in self.commandArray) {
            if (command.runAfterDate == nil
                || [command.runAfterDate timeIntervalSinceDate:current] <= 0) {
                [commands addObject:command];
            }
        }
        //移除将要执行的
        [self.commandArray removeObjectsInArray:commands];
    }
    
    if (_needThreadSafe) {
        pthread_mutex_unlock(&_wait_mutex);
    }
    
    for (VideoPreviewerAsyncCommandObject* object in commands) {
        if (object.cancelMark) {
            if (object.alwaysNeedCallback) {
                //一定需要回调
                SAFE_BLOCK(object.workBlock, VideoPreviewerAsyncCommandObjectWork_NeedCancel);
            }
        }else{
            SAFE_BLOCK(object.workBlock, VideoPreviewerAsyncCommandObjectWork_Normal);
        }
    }
}

@end
