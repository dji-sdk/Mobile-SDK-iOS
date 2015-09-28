//
//  DJILogerView.m
//  DJISdkDemo
//
//  Created by Ares on 15/2/15.
//  Copyright (c) 2015年 DJI. All rights reserved.
//

#import "DJILogerView.h"

@implementation DJILogerView

+(id) sharedView
{
    static DJILogerView* s_sharedLogerView = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        s_sharedLogerView = [[DJILogerView alloc] initWithNib];
    });
    
    return s_sharedLogerView;
}

-(id) initWithNib
{
    NSArray* objs = [[NSBundle mainBundle] loadNibNamed:@"DJILogerView" owner:self options:nil];
    UIView* mainView = [objs objectAtIndex:0];
    self = [super initWithFrame:mainView.bounds];
    if (self) {
        [self addSubview:mainView];
        
        self.layer.cornerRadius = 5.0;
        self.layer.masksToBounds = YES;
        
        mMutableLogs = [[NSMutableString alloc] init];
        mPause = NO;
        mAutoScroll = YES;
        
        UILabel* testLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, self.scrollView.frame.size.width, 100)];
        testLabel.font = [UIFont systemFontOfSize:14];
        testLabel.text = @"Test Text";
        CGSize size = [testLabel sizeThatFits:testLabel.frame.size];
        mItemHeight = size.height;
        
        self.logContentLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, self.scrollView.frame.size.width, mItemHeight)];
        self.logContentLabel.font = [UIFont systemFontOfSize:14];
        self.logContentLabel.numberOfLines = 0;
        [self.scrollView addSubview:self.logContentLabel];
    }
    
    return self;
}

-(IBAction) onCloseButtonClicked:(id)sender
{
    [self removeFromSuperview];
}

-(IBAction) onAutoScrollButtonClicked:(id)sender
{
    mAutoScroll = YES;
}

-(IBAction) onClearButtonClicked:(id)sender
{
    mMutableLogs = [[NSMutableString alloc] init];
    self.logContentLabel.text = nil;
    mLogItemCount = 0;
}

-(void) logItem:(NSString*)logItem;
{
    mLogItemCount++;
    NSDateFormatter* dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
    NSString* currentDate = [dateFormatter stringFromDate:[NSDate date]];
    [mMutableLogs appendFormat:@"%@: %@\n", currentDate, logItem];

    [self.logContentLabel setFrame:CGRectMake(0, 0, self.scrollView.frame.size.width, mLogItemCount * mItemHeight + 20)];
    [self.scrollView setContentSize:self.logContentLabel.bounds.size];
    self.logContentLabel.text = mMutableLogs;
    
    if (mAutoScroll) {
        [self.scrollView scrollRectToVisible:self.logContentLabel.bounds animated:YES];
    }
}

- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView
{
    mAutoScroll = NO;
}

void outputDebugString(NSString *format, ...)
{
    va_list argumentList;
    va_start(argumentList, format);
    
    NSString *string = [[NSString alloc] initWithFormat:format arguments:argumentList];
    va_end(argumentList);
    
    fprintf(stderr, "%s\n", [string UTF8String]);
    [[DJILogerView sharedView] logItem:string];
}

@end

