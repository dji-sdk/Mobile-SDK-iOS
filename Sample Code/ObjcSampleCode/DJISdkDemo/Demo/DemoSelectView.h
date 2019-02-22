//
//  DemoUtilityMethod.h
//  DJISdkDemo
//
//  Copyright © 2015 DJI. All rights reserved.
//

#import <UIKit/UIKit.h>
@class DemoSelectView;

@protocol DemoSelectViewDelegate <NSObject>
- (void) selectView:(DemoSelectView *)selectView selectIndex:(NSInteger)index;
@property(nonatomic, readonly) NSArray* selectTableList;
@end
@interface DemoSelectView : UIView
@property(nonatomic, weak) id<DemoSelectViewDelegate> delegate;

- (void)refresh;

- (void)show;
@end
