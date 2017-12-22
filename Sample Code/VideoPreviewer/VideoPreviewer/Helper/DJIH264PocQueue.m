//
//  DJIH264PocQueue.m
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
    //指针总数
    int _size;
    //指针数量
    int _count;
    //指针头
    DJIH264PocQueueNode* _head;
    DJIH264PocQueueNode* _tail;
    
    //no for using in same thread
    BOOL _needThreadSafe;
    
    //队列锁
    pthread_mutex_t _mutex;
    //互斥锁
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

//清空队列，在此期间队列加锁
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

//进队列(返回值为No时队列满,长度为0或buf为NULL也返回NO)
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

//出队列(返回值为NULL时队列为空)
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

//立即唤醒等待的读取线程
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

//是否已满
- (bool)isFull{
    if(_count==_size){
        return YES;
    }
    else{
        return NO;
    }
}

@end
