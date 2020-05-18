//
//  DemoUtilityMacro.h
//  DJISdkDemo
//
//  Copyright © 2015 DJI. All rights reserved.
//

#ifndef DemoUtilityMacro_h
#define DemoUtilityMacro_h

#import "metamacros.h"

#define WeakRef(__obj) __weak typeof(self) __obj = self
#define WeakReturn(__obj) if(__obj ==nil)return;

#define DeviceSystemVersion ([[[UIDevice currentDevice] systemVersion] floatValue])
#define iOS8System (DeviceSystemVersion >= 8.0)

#define SCREEN_WIDTH  (iOS8System ? [UIScreen mainScreen].bounds.size.width : [UIScreen mainScreen].bounds.size.height)
#define SCREEN_HEIGHT (iOS8System ? [UIScreen mainScreen].bounds.size.height : [UIScreen mainScreen].bounds.size.width)

#define DEGREE(x) ((x)*180.0/M_PI)
#define RADIAN(x) ((x)*M_PI/180.0)

#define DJI_ENUM_PAIR(__index__, __enumValue__) case __enumValue__: outputStr = @#__enumValue__; break;

#define DESCRIPTION_FOR_ENUM_WITH_PREFIX(enumType, shortName, prefix, ...) \
+(NSString *)descriptionFor##shortName:(enumType)enumValue { \
NSString *outputStr = nil; \
switch (enumValue) { \
metamacro_foreach(DJI_ENUM_PAIR, ;, __VA_ARGS__) \
default: break; \
}\
if (outputStr) {\
return [outputStr substringFromIndex:@#prefix.length]; \
}\
return nil; \
}

#define DESCRIPTION_FOR_ENUM(enumType, shortName, ...) DESCRIPTION_FOR_ENUM_WITH_PREFIX(enumType, shortName, enumType, __VA_ARGS__)

#endif /* DemoUtilityMacro_h */
