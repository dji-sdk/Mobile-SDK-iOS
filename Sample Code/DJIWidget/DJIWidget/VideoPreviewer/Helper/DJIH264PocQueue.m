//
//  DJIH264PocQueue.m
//
//  Copyright (c) 2017 DJI. All rights reserved.
//
#import "DJIH264PocQueue.h"
#import <pthread.h>
#import <sys/time.h>


typedef struct _DJIH264PocQueueNode{
    VideoFrameYUV* frame;
    struct _DJIH264PocQueueNode* prev;
    struct _DJIH264PocQueueNode* next;
}DJIH264PocQueueNode;

@interface DJIH264PocQueue()
{
    //total number of pointers
    int _size;
    //number of pointers
    int _count;
    //head node
    DJIH264PocQueueNode* _head;
    //tail node
    DJIH264PocQueueNode* _tail;
    
    //no for using in same thread
    BOOL _needThreadSafe;
    
    //mutex lock
    pthread_mutex_t _mutex;
    pthread_cond_t _cond;
}
@end

@implementation DJIH264PocQueue

#define NEED_THREAD_SAFE(x) if(_needThreadSafe){x;}

- (id)initWithSize:(int)size threadSafe:(BOOL)threadSafe{
    self = [super init];
    
    _needThreadSafe = threadSafe;
    
    if (_needThreadSafe)
    {
        pthread_mutex_init(&_mutex, NULL);
        pthread_cond_init(&_cond, NULL);
    }

    _head = 0;
    _tail = 0;
    _count = 0;
    _size = size;
    return self;
}

//Empty the queue, during which the queue is locked
- (void)clear{
    
    NEED_THREAD_SAFE(pthread_mutex_lock(&_mutex));
    
    DJIH264PocQueueNode* next = _head;
    
    while (next) {
        if(next->frame){
            free(next->frame);
        }
        DJIH264PocQueueNode* current = next;
        next = next->next;
        
        free(current);
    }
    
    _head = 0;
    _tail = 0;
    _count = 0;
    
    NEED_THREAD_SAFE(pthread_mutex_unlock(&_mutex));
}

// into the queue (when the return value is No, the queue is full, and the length is 0 or buf is NULL also returns NO)
- (BOOL)push:(VideoFrameYUV*)frame{
    
    NEED_THREAD_SAFE(pthread_mutex_lock(&_mutex));

    if(frame == nil || [self isFull]){
        NEED_THREAD_SAFE(pthread_mutex_unlock(&_mutex));
        return NO;
    }
    
    //create a node
    DJIH264PocQueueNode* node = malloc(sizeof(DJIH264PocQueueNode));
    node->frame = frame;
    node->next = nil;
    node->prev = nil;
    
    //find a place to insert the node
    if (_head == nil) {
        _head = node;
        _tail = node;
    }
    else if (frame->frame_info.frame_flag.has_idr) {
        //append
        _tail->next = node;
        node->prev = _tail;
        _tail = node;
    }
    else{
        //insert by poc
        DJIH264PocQueueNode* insertBehind = _tail;
        
        while (insertBehind != nil) {
            
            if (insertBehind->frame->frame_info.frame_flag.has_idr)
            {
                //insert behind idr
                break;
            }
            
            if (insertBehind->frame->frame_info.frame_poc
                <= node->frame->frame_info.frame_poc)
            {
                //inset by poc
                break;
            }
            
            //prev
            insertBehind = insertBehind->prev;
        }
        
        if (insertBehind == nil) {
            //inset to head
            node->next = _head;
            _head->prev = node;
            _head = node;
        }
        else{
            //inset behind
            node->next = insertBehind->next;
            node->prev = insertBehind;
            
            insertBehind->next = node;
            if (node->next) {
                node->next->prev = node;
            }else{
                _tail = node;
            }
        }
    }

    _count++;
    
    NEED_THREAD_SAFE(pthread_cond_signal(&_cond));
    NEED_THREAD_SAFE(pthread_mutex_unlock(&_mutex));
    return YES;
}

// Out of the queue (the queue is empty when the return value is NULL)
- (VideoFrameYUV*)pull{
    NEED_THREAD_SAFE(pthread_mutex_lock(&_mutex));
    if(_count == 0)
    {
        if (_needThreadSafe == NO) {
            return NULL;
        }
        
        struct timeval tv;
        gettimeofday(&tv, NULL);
        
        struct timespec ts;
        ts.tv_sec = tv.tv_sec + 2;
        ts.tv_nsec = tv.tv_usec*1000;
        pthread_cond_timedwait(&_cond, &_mutex, &ts);
        if(_count == 0)
        {
            pthread_mutex_unlock(&_mutex);
            return NULL;
        }
    }
    
    //pop head
    DJIH264PocQueueNode *node = _head;
    
    if (node) {
        _head = node->next;
        if (_head) {
            _head->prev = nil;
        }else{
            _tail = nil;
        }
    }
    _count--;
    
    NEED_THREAD_SAFE(pthread_mutex_unlock(&_mutex));
    if(node){
        VideoFrameYUV* frame = node->frame;
        free(node);
        return frame;
    }
    
    return nil;
}

// Immediately awaiting the waiting read thread
- (void)wakeupReader{
    if (_needThreadSafe) {
        pthread_mutex_lock(&_mutex);
        pthread_cond_signal(&_cond);
        pthread_mutex_unlock(&_mutex);
    }
}

- (int)count{
    return _count;
}

- (int)size{
    return _size;
}

- (bool)isFull{
    if(_count==_size){
        return YES;
    }
    else{
        return NO;
    }
}

@end
