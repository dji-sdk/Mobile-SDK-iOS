//
//  DJIImageCache.h
//  DJIWidget
//
//  Copyright © 2018 DJI. All rights reserved.
//

#ifndef DJIImageCache_h
#define DJIImageCache_h

@interface DJIImageCache : NSObject
//size array for each image channel
-(instancetype)initWithCacheSizeArray:(NSArray*)sizes;

-(void*)baseAddrForIndex:(NSUInteger)index;

-(BOOL)checkFitsSizeArray:(NSArray*)sizes;

@end

#endif /* DJIImageCache_h */
