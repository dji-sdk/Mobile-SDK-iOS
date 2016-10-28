//
//  DemoScrollView.m
//  DJISdkDemo
//
//  Copyright © 2016 DJI. All rights reserved.
//

#import "DemoScrollView.h"

@interface DemoScrollView () <UIScrollViewDelegate>

@property(nonatomic, weak) IBOutlet UIView* view;
@property(nonatomic, weak) IBOutlet UILabel* statusLabel;
@property(nonatomic, weak) IBOutlet UIScrollView* scrollView;
@property(nonatomic, strong) IBOutlet UILabel* statusTextView;

@end

@implementation DemoScrollView

+(instancetype)viewWithViewController:(UIViewController *)viewController {
    DemoScrollView *scrollView = [[DemoScrollView alloc] init];
    [viewController.view addSubview:scrollView];
    scrollView.translatesAutoresizingMaskIntoConstraints = NO;  // disable for autolayout

    // center x
    [viewController.view addConstraint:[NSLayoutConstraint constraintWithItem:scrollView
                                                                    attribute:NSLayoutAttributeCenterX
                                                                    relatedBy:NSLayoutRelationEqual
                                                                       toItem:viewController.view
                                                                    attribute:NSLayoutAttributeCenterX
                                                                   multiplier:1.0
                                                                     constant:0]];

    // hug the bottom of the view
    [viewController.view addConstraint:[NSLayoutConstraint constraintWithItem:scrollView
                                                                    attribute:NSLayoutAttributeCenterY
                                                                    relatedBy:NSLayoutRelationEqual
                                                                       toItem:viewController.view
                                                                    attribute:NSLayoutAttributeCenterY
                                                                   multiplier:1.0
                                                                     constant:0]];

    [scrollView setHidden:YES];
    return scrollView; 
}

- (id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        [self setup];
        if (CGRectEqualToRect(frame, CGRectZero)) {
            [self setDefaultSize];
        }
    }
    return self;
}
- (void)setup {
    [[NSBundle mainBundle] loadNibNamed:NSStringFromClass([self class]) owner:self options:nil];
    [self addSubview:self.view];

    self.fontSize = 15;

    self.layer.cornerRadius = 5;
    self.layer.masksToBounds = YES;
    self.layer.borderWidth = 1.2;
    self.layer.borderColor = [UIColor grayColor].CGColor;

    self.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:0.4];

    self.statusTextView = [[UILabel alloc] initWithFrame:CGRectMake(10, 0, self.scrollView.frame.size.width - 15, 5 * self.scrollView.frame.size.height)];
    self.statusTextView.numberOfLines = 0;
    self.statusTextView.font = [UIFont systemFontOfSize:12];
    self.statusTextView.textAlignment = NSTextAlignmentLeft;
    self.statusTextView.font = [UIFont systemFontOfSize:self.fontSize];
    self.statusTextView.backgroundColor = [UIColor clearColor];
    self.statusTextView.textColor = [UIColor whiteColor];
    [self.scrollView setContentSize:self.statusTextView.bounds.size];
    [self.scrollView addSubview:self.statusTextView];
    self.scrollView.layer.borderColor = [UIColor blackColor].CGColor;
    self.scrollView.layer.borderWidth = 1.3;
    self.scrollView.layer.cornerRadius = 3.0;
    self.scrollView.layer.masksToBounds = YES;
    self.scrollView.pagingEnabled = NO;
    self.statusTextView.translatesAutoresizingMaskIntoConstraints = NO;
    [self addConstraint:[NSLayoutConstraint constraintWithItem:self.statusTextView
                                                     attribute:NSLayoutAttributeLeading
                                                     relatedBy:NSLayoutRelationEqual
                                                        toItem:self.scrollView
                                                     attribute:NSLayoutAttributeLeading
                                                    multiplier:1.0
                                                      constant:0]];
    [self addConstraint:[NSLayoutConstraint constraintWithItem:self.statusTextView
                                                     attribute:NSLayoutAttributeTop
                                                     relatedBy:NSLayoutRelationEqual
                                                        toItem:self.scrollView
                                                     attribute:NSLayoutAttributeTop
                                                    multiplier:1.0
                                                      constant:0]];
}

- (id)initWithCoder:(NSCoder *)aDecoder {
    self = [super initWithCoder:aDecoder];
    if(self) {
        [self setup];
    }
    return self;
}

-(void) awakeFromNib
{
    [super awakeFromNib];

    [self setup];
}

-(void) setTitle:(NSString *)title
{
    _title = title;
    self.statusLabel.text = title;
}

-(void) writeStatus:(NSString*)status
{
    self.statusTextView.text = status;
}

-(void) show
{
    [UIView animateWithDuration:0.25 animations:^{
        self.alpha = 1.0;
    }];
}

-(IBAction) onCloseButtonClicked:(id)sender
{
    [UIView animateWithDuration:0.25 animations:^{
        self.alpha = 0;
    }];
}

-(void)setDefaultSize {
    // The new self.view needs autolayout constraints for sizing
    self.view.translatesAutoresizingMaskIntoConstraints = NO;
    // Horizontal  200 in width
    [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|[_view(300)]|" options:NSLayoutFormatDirectionLeadingToTrailing metrics:nil views:NSDictionaryOfVariableBindings(_view, self)]];
    // Vertical   200 in height
    [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|[_view(300)]|" options:NSLayoutFormatDirectionLeadingToTrailing metrics:nil views:NSDictionaryOfVariableBindings(_view, self)]];
}

@end
