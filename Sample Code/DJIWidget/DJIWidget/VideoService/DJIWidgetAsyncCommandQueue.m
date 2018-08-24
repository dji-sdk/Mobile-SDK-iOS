//
//  DJIWidgetAsyncCommandQueue.m
//
//  Copyright (c) 2017 DJI. All rights reserved.
//
#import "DJIWidgetAsyncCommandQueue.h"
#import "DJIWidgetMacros.h"
#import <pthread.h>
#import <sys/time.h>

@interface DJIAsyncCommandObject ()

@property (nonatomic, assign) BOOL cancelMark;
@property (nonatomic, strong) NSObject* _Nullable tag;
@property (nonatomic, strong) NSDate* _Nullable runAfterDate;
@end

@implementation DJIAsyncCommandObject

+(instancetype) commandWithTag:(NSObject*)tag block:(DJIWidgetAsyncCommandQueueOperation)work{
    return [self commandWithTag:tag afterDate:nil block:work];
}

+(instancetype) commandWithTag:(NSObject*)tag afterDate:(NSDate * _Nullable)date block:(DJIWidgetAsyncCommandQueueOperation)work{
    DJIAsyncCommandObject* object = [[DJIAsyncCommandObject alloc] init];
    object.tag = tag;
    object.workBlock = work;
    object.runAfterDate = date;
    return object;
}

@end

@interface DJIWidgetAsyncCommandQueue (){
    pthread_mutex_t _wait_mutex;
    pthread_cond_t _cond;
}

@property (nonatomic, strong) NSMutableArray* commandArray;
@property (nonatomic, assign) BOOL needThreadSafe;

@end

@implementation DJIWidgetAsyncCommandQueue

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

-(void) pushCommand:(DJIAsyncCommandObject *)command withOption:(DJIAsyncCommandOption)optionFlag{
    if (!command) {
        return;
    }
    
    if(_needThreadSafe){
        pthread_mutex_lock(&_wait_mutex);
    }
    
    if (optionFlag & DJIAsyncCommandOption_RemoveSameTag) {
        for (DJIAsyncCommandObject* object in self.commandArray) {
            if ([object.tag isEqual:command.tag]) {
                object.cancelMark = YES;
            }
        }
    }
    
    if (optionFlag & DJIAsyncCommandOption_LIFO) {
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
        for (DJIAsyncCommandObject* object in self.commandArray) {
            object.cancelMark = YES;
        }
    }
    else{
        for (DJIAsyncCommandObject* object in self.commandArray) {
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
    }else{
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
    
    NSMutableArray* commands = nil;
    
    if (self.commandArray.count) {
        commands = [NSMutableArray arrayWithCapacity:self.commandArray.count];
        for (DJIAsyncCommandObject* command in self.commandArray) {
            if (command.runAfterDate == nil
                || [command.runAfterDate timeIntervalSinceDate:current] <= 0) {
                [commands addObject:command];
            }
        }
        [self.commandArray removeObjectsInArray:commands];
    }
    
    if (_needThreadSafe) {
        pthread_mutex_unlock(&_wait_mutex);
    }
    
    for (DJIAsyncCommandObject* object in commands) {
        if (object.cancelMark) {
            if (object.alwaysNeedCallback) {
                SAFE_BLOCK(object.workBlock, DJIAsyncCommandObjectWork_NeedCancel);
            }
        }else{
            SAFE_BLOCK(object.workBlock, DJIAsyncCommandObjectWork_Normal);
        }
    }
}

@end
