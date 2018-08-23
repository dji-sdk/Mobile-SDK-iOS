//
//  DJIWidgetAsyncCommandQueue.h
//
//  Copyright (c) 2017 DJI. All rights reserved.
//

/**
 *  Asynchronous command queue whose behavior is similar to NSRunLoop.
 */
#import <Foundation/Foundation.h>

typedef enum : NSUInteger {
    DJIAsyncCommandObjectWork_Initial, //Not yet executed
    DJIAsyncCommandObjectWork_Normal, //Normal Execution
    DJIAsyncCommandObjectWork_NeedCancel, //Canceled
} DJIAsyncCommandObjectWorkHint;

/**
 Command execution ordering options.
 */
typedef enum : NSUInteger {
    DJIAsyncCommandOption_FIFO = 0,
    DJIAsyncCommandOption_LIFO = 1<<0,
    DJIAsyncCommandOption_RemoveSameTag = 1<<1,
} DJIAsyncCommandOption;

typedef void(^DJIWidgetAsyncCommandQueueOperation)(DJIAsyncCommandObjectWorkHint hint);

@interface DJIAsyncCommandObject : NSObject

@property (nonatomic, assign) BOOL alwaysNeedCallback;

@property (nonatomic, copy) DJIWidgetAsyncCommandQueueOperation _Nullable workBlock;

@property (nonatomic, readonly) NSObject* _Nullable tag;

@property (nonatomic, readonly) NSDate* _Nullable runAfterDate;

+(instancetype _Nonnull) commandWithTag:(NSObject* _Nullable)tag
                                  block:(DJIWidgetAsyncCommandQueueOperation _Nullable)work;

+(instancetype _Nonnull) commandWithTag:(NSObject* _Nullable)tag
                              afterDate:(NSDate* _Nullable)date
                                  block:(DJIWidgetAsyncCommandQueueOperation _Nullable)work;
@end

@interface DJIWidgetAsyncCommandQueue : NSObject


-(id _Nonnull) initWithThreadSafe:(BOOL)threadSafe;

-(void) pushCommand:(DJIAsyncCommandObject* _Nonnull)command withOption:(DJIAsyncCommandOption)optionFlag;

-(void) cancelCommandWithTag:(NSObject* _Nullable)tag;

-(void) cancelCommandWithTags:(NSArray* _Nullable)tags;

-(void) runloop;

-(void) runloopWithTimeOutMS:(int)timeoutMs;

@end
