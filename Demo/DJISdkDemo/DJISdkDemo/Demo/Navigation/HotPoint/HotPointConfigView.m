//
//  InspireHotPointConfigView.m
//  DJISdkDemo
//
//  Created by Ares on 15/6/3.
//  Copyright (c) 2015年 DJI. All rights reserved.
//

#import "HotPointConfigView.h"

@interface HotPointConfigView ()
@property (weak, nonatomic) IBOutlet UITextField *altitudeInputBox;
@property (weak, nonatomic) IBOutlet UITextField *radiusInputBox;
@property (weak, nonatomic) IBOutlet UITextField *speedInputBox;
@property (weak, nonatomic) IBOutlet UISegmentedControl *headingControl;
@property (weak, nonatomic) IBOutlet UISegmentedControl *entryControl;
@property (weak, nonatomic) IBOutlet UISwitch *clockwiseSwitch;

- (IBAction)onOkButtonClicked:(id)sender;

@end

@implementation HotPointConfigView

-(id) initWithNib
{
    UIView* mainView = [[[NSBundle mainBundle] loadNibNamed:@"HotPointConfigView" owner:self options:nil] objectAtIndex:0];
    self = [super initWithFrame:[mainView bounds]];
    if (self) {
        [self addSubview:mainView];
        
        _altitude = 50.0;
        _radius = 20.0;
        _speed = 20;
        _headingMode = DJIHotPointHeadingAlongTheCircleLookingForwards;
        _entryPoint = DJIHotPointEntryFromNorth;
        _clockwise = YES;
        
        self.altitudeInputBox.text = [NSString stringWithFormat:@"%0.1f", _altitude];
        self.radiusInputBox.text = [NSString stringWithFormat:@"%0.1f", _radius];
        self.speedInputBox.text = [NSString stringWithFormat:@"%d", _speed];
        [self.headingControl setSelectedSegmentIndex:(int)_headingMode];
        [self.entryControl setSelectedSegmentIndex:(int)_entryPoint];
        [self.clockwiseSwitch setOn:_clockwise];
    }
    
    return self;
}

-(void) setAltitude:(float)altitude
{
    self.altitudeInputBox.text = [NSString stringWithFormat:@"%0.1f", altitude];
}

- (IBAction)onOkButtonClicked:(id)sender {
    _altitude = [self.altitudeInputBox.text floatValue];
    _radius = [self.radiusInputBox.text floatValue];
    _speed = [self.speedInputBox.text intValue];
    _headingMode = (DJIHotPointHeadingMode)self.headingControl.selectedSegmentIndex;
    _entryPoint = (DJIHotPointEntryPoint)self.entryControl.selectedSegmentIndex;
    _clockwise = self.clockwiseSwitch.isOn;
    if (self.delegate && [self.delegate respondsToSelector:@selector(configViewWillDisappear)]) {
        [self.delegate configViewWillDisappear];
    }
    [UIView animateWithDuration:0.2 animations:^{
        self.alpha = 0.0;
    }];
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    if ([self.altitudeInputBox isFirstResponder]) {
        [self.altitudeInputBox resignFirstResponder];
    }
    if ([self.radiusInputBox isFirstResponder]) {
        [self.radiusInputBox resignFirstResponder];
    }
    if ([self.speedInputBox isFirstResponder]) {
        [self.speedInputBox resignFirstResponder];
    }
    return YES;
}
@end
