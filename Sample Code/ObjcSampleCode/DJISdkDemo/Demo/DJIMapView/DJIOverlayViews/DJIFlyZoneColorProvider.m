//
//  DJIFlyZoneColorProvider.m
//  DJIGeoSample
//
//  Copyright © 2018 DJI. All rights reserved.
//

#import "DJIFlyZoneColorProvider.h"
#import <DJISDK/DJIFlyZoneInformation.h>

@implementation UIColor (DJIFlyZoneRGBA)

+ (UIColor *)colorWithR:(CGFloat)r G:(CGFloat)g B:(CGFloat)b A:(CGFloat)a {
	return [UIColor colorWithRed:r/255.0 green:g/255.0 blue:b/255.0 alpha:a];
}

@end

//0x979797
#define DJI_FS_HEIGHT_LIMIT_GRAY_03 [UIColor colorWithR:151 G:151 B:151 A:0.3]
#define DJI_FS_HEIGHT_LIMIT_GRAY_1 [UIColor colorWithR:151 G:151 B:151 A:1]
//0xDE4329
#define DJI_FS_LIMIT_RED_03 [UIColor colorWithR:222 G:67 B:41 A:0.3]
#define DJI_FS_LIMIT_RED_1 [UIColor colorWithR:222 G:67 B:41 A:1]
//0x1088F2
#define DJI_FS_AUTH_BLUE_03 [UIColor colorWithR:16 G:136 B:242 A:0.3]
#define DJI_FS_AUTH_BLUE_1 [UIColor colorWithR:16 G:136 B:242 A:1]
//0xFFCC00
#define DJI_FS_WARNING_YELLOW_03 [UIColor colorWithR:255 G:204 B:0 A:0.3]
#define DJI_FS_WARNING_YELLOW_1 [UIColor colorWithR:255 G:204 B:0 A:1]
//0xEE8815
#define DJI_FS_SPECIAL_WARNING_ORANGE_03 [UIColor colorWithR:238 G:136 B:21 A:0.3]
#define DJI_FS_SPECIAL_WARNING_ORANGE_1 [UIColor colorWithR:238 G:136 B:21 A:1]

@implementation DJIFlyZoneColorProvider

+ (UIColor*)getFlyZoneOverlayColorWithCategory:(uint8_t)category isHeightLimit:(BOOL)isHeightLimit isFill:(BOOL)isFill {
	
	if (isHeightLimit) {
		return isFill ? DJI_FS_HEIGHT_LIMIT_GRAY_03 : DJI_FS_HEIGHT_LIMIT_GRAY_1;
	}
	
	if (category == DJIFlyZoneCategoryAuthorization) {
		return (isFill ? DJI_FS_AUTH_BLUE_03 : DJI_FS_AUTH_BLUE_1);
	} else if (category == DJIFlyZoneCategoryRestricted) {
		return (isFill ? DJI_FS_LIMIT_RED_03 : DJI_FS_LIMIT_RED_1);
	} else if (category == DJIFlyZoneCategoryWarning) {
		return (isFill ? DJI_FS_WARNING_YELLOW_03 : DJI_FS_WARNING_YELLOW_1);
	} else if (category == DJIFlyZoneCategoryEnhancedWarning) {
		return (isFill ? DJI_FS_SPECIAL_WARNING_ORANGE_03 : DJI_FS_SPECIAL_WARNING_ORANGE_1);
	}
	return [UIColor colorWithR:0 G:0 B:0 A:0];
}

@end
