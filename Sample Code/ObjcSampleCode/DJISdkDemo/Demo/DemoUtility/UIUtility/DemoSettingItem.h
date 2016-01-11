//
//  DemoSettingItem.h
//  DJISdkDemo
//
//  Copyright © 2015 DJI. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface DemoSettingItem : NSObject

@property(nonatomic, retain) NSString* itemName;
@property(nonatomic) Class viewControllerClass;

-(id) initWithName:(NSString *)name andClass:(Class)viewControllerClass;
+(id) itemWithName:(NSString *)name andClass:(Class)viewControllerClass;
@end