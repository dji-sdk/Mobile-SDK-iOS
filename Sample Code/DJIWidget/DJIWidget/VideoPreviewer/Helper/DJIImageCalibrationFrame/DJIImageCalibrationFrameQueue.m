//
//  DJIImageCalibrationFrameQueue.m
//  DJIWidget
//
//  Copyright © 2018 DJI. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <sys/time.h>
#import <pthread.h>
#import "DJIImageCalibrationFrameQueue.h"

@interface DJIImageCalibrationFrameQueue(){
    NSUInteger _capacity;
    pthread_mutex_t _queueMutex;
    DJIImageCalibrationFastFrame* _head;
    BOOL _threadSafe;
}
@end

@implementation DJIImageCalibrationFrameQueue

-(void)dealloc{
    DJIImageCalibrationFastFrame* frameObject = nil;
    do{
        frameObject = [self pull];
    } while(frameObject != nil);
}

-(instancetype)initWithQueueCapacity:(NSUInteger)capacity
                       andThreadSafe:(BOOL)threadSafe{
    if (self = [super init]){
        _threadSafe = threadSafe;
        _capacity = capacity;
        _head = nil;
        if (_threadSafe){
            pthread_mutex_init(&_queueMutex, NULL);
        }
    }
    return self;
}

-(instancetype)init{
    if (self = [super init]){
        _threadSafe = YES;
        _capacity = 0;
        _head = nil;
        if (_threadSafe){
            pthread_mutex_init(&_queueMutex, NULL);
        }
    }
    return self;
}

-(BOOL)push:(DJIImageCalibrationFastFrame*)frame{
    if (!frame
        || ![frame isKindOfClass:[DJIImageCalibrationFastFrame class]]){
        return NO;
    }
    if (_threadSafe){
        pthread_mutex_lock(&_queueMutex);
    }
    if (_capacity == 0){
        while (_head != nil){
            DJIImageCalibrationFastFrame* front = _head.nextFrame;
            _head.nextFrame = nil;
            _head = front;
        }
    }
    else{
        if (!_head){
            _head = frame;
        }
        else{
            DJIImageCalibrationFastFrame* front = _head;
            DJIImageCalibrationFastFrame* tail = nil;
            NSUInteger count = 1;
            while (front.nextFrame != nil){
                count++;
                if (count >= _capacity){
                    tail = front.nextFrame;
                    front.nextFrame = frame;
                    break;
                }
                front = front.nextFrame;
            }
            if (tail != nil){
                while (tail != nil){
                    DJIImageCalibrationFastFrame* head = tail.nextFrame;
                    tail.nextFrame = nil;
                    tail = head;
                }
            }
            else{
                front.nextFrame = frame;
            }
        }
        frame.nextFrame = nil;
    }
    if (_threadSafe){
        pthread_mutex_unlock(&_queueMutex);
    }
    return YES;
}

-(DJIImageCalibrationFastFrame*)pull{
    if (_threadSafe){
        pthread_mutex_lock(&_queueMutex);
    }
    DJIImageCalibrationFastFrame* front = _head;
    _head = front.nextFrame;
    front.nextFrame = nil;
    if (_threadSafe){
        pthread_mutex_unlock(&_queueMutex);
    }
    return front;
}

@end
