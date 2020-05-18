//
//  DJIFlyZoneColorProvider.h
//  DJIGeoSample
//
//  Copyright © 2018 DJI. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface UIColor (DJIFlyZoneRGBA)

+ (UIColor *)colorWithR:(CGFloat)r G:(CGFloat)g B:(CGFloat)b A:(CGFloat)a;

@end


@interface DJIFlyZoneColorProvider : NSObject

+ (UIColor*)getFlyZoneOverlayColorWithCategory:(uint8_t)category isHeightLimit:(BOOL)isHeightLimit isFill:(BOOL)isFill;

@end
