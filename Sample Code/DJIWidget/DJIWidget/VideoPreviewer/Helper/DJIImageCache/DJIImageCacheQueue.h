//
//  DJIImageCacheQueue.h
//  DJIWidget
//
//  Copyright © 2018 DJI. All rights reserved.
//

#ifndef DJIImageCacheQueue_h
#define DJIImageCacheQueue_h

@interface DJIImageCacheQueue : NSObject

-(id)pull;

-(BOOL)push:(id)cache;

-(instancetype)initWithThreadSafe:(BOOL)threadSafe;

@end

#endif /* DJIImageCacheQueue_h */
