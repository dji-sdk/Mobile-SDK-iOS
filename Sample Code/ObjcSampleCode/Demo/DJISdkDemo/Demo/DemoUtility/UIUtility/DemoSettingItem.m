//
//  SettingItem.m
//  DJISdkDemo
//
//  Copyright © 2015 DJI. All rights reserved.
//

#import "DemoSettingItem.h"

@implementation DemoSettingItem

-(id) initWithName:(NSString *)name andClass:(Class)viewControllerClass {
    self = [super init];
    if (self) {
        _itemName = name;
        _viewControllerClass = viewControllerClass;
    }
    
    return self;
}

+(id)itemWithName:(NSString *)name andClass:(Class)viewControllerClass {
    return [[DemoSettingItem alloc] initWithName:name andClass:viewControllerClass];
}

@end