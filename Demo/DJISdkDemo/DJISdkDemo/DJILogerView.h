//
//  DJILogerView.h
//  DJISdkDemo
//
//  Created by Ares on 15/2/15.
//  Copyright (c) 2015年 DJI. All rights reserved.
//

#import <UIKit/UIKit.h>

#define NSLog(...) outputDebugString(__VA_ARGS__)

@interface DJILogerView : UIView<UIScrollViewDelegate>
{
    NSMutableString* mMutableLogs;
    BOOL mPause;
    BOOL mAutoScroll;
    int mLogItemCount;
    float mItemHeight;
}

@property(nonatomic, strong) IBOutlet UIScrollView* scrollView;
@property(nonatomic, strong) UILabel* logContentLabel;

+(id) sharedView;

-(void) logItem:(NSString*)logItem;

-(IBAction) onCloseButtonClicked:(id)sender;

-(IBAction) onAutoScrollButtonClicked:(id)sender;

-(IBAction) onClearButtonClicked:(id)sender;

void outputDebugString(NSString *format, ...);
@end

