//
//  RCHardwareStateViewController.m
//  DJISdkDemo
//
//  Copyright © 2015 DJI. All rights reserved.
//
/**
 *  This file demonstrates how to use the push data from DJIRemoteController. DJIRCHardwareState class contains the status of the buttons， 
 *  joysticks and wheels on the physical remote controller. For different types of remote controllers, the hareware may be different. 
 *  Then user can use isPresent property to check if the hardware component is on the connected remote controller or not. 
 */

#import "RCHardwareStateViewController.h"
#import "DemoComponentHelper.h"
#import <DJISDK/DJISDK.h>

@interface RCHardwareStateViewController () <DJIRemoteControllerDelegate>

@property (weak, nonatomic) IBOutlet UISlider *leftWheel;
@property (weak, nonatomic) IBOutlet UISlider *rightWheel;
@property (weak, nonatomic) IBOutlet UISegmentedControl *modeSwitch;
@property (weak, nonatomic) IBOutlet UILabel *leftVertical;
@property (weak, nonatomic) IBOutlet UILabel *rightVertical;
@property (weak, nonatomic) IBOutlet UILabel *rightHorizontal;
@property (weak, nonatomic) IBOutlet UILabel *leftHorizontal;
@property (weak, nonatomic) IBOutlet UILabel *cameraRecord;
@property (weak, nonatomic) IBOutlet UILabel *cameraShutter;
@property (weak, nonatomic) IBOutlet UILabel *cameraPlayback;
@property (weak, nonatomic) IBOutlet UILabel *goHomeButton;
@property (weak, nonatomic) IBOutlet UILabel *customButton1;
@property (weak, nonatomic) IBOutlet UILabel *customButton2;
@property (weak, nonatomic) IBOutlet UISwitch *transformSwitch;

@property (assign, nonatomic) int wheelOffset;

@end

@implementation RCHardwareStateViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    [self initUI];
    
    DJIRemoteController* rc = [DemoComponentHelper fetchRemoteController];
    if (rc) {
        rc.delegate = self;
    }
}

-(void) initUI
{
    self.leftVertical.layer.cornerRadius = 4.0;
    self.leftVertical.layer.borderColor = [UIColor blackColor].CGColor;
    self.leftVertical.layer.borderWidth = 1.2;
    self.leftVertical.layer.masksToBounds = YES;
    
    self.rightVertical.layer.cornerRadius = 4.0;
    self.rightVertical.layer.borderColor = [UIColor blackColor].CGColor;
    self.rightVertical.layer.borderWidth = 1.2;
    self.rightVertical.layer.masksToBounds = YES;
    
    self.rightHorizontal.layer.cornerRadius = 4.0;
    self.rightHorizontal.layer.borderColor = [UIColor blackColor].CGColor;
    self.rightHorizontal.layer.borderWidth = 1.2;
    self.rightHorizontal.layer.masksToBounds = YES;
    
    self.leftHorizontal.layer.cornerRadius = 4.0;
    self.leftHorizontal.layer.borderColor = [UIColor blackColor].CGColor;
    self.leftHorizontal.layer.borderWidth = 1.2;
    self.leftHorizontal.layer.masksToBounds = YES;
    
    self.cameraRecord.layer.cornerRadius = self.cameraRecord.frame.size.width * 0.5;
    self.cameraRecord.layer.borderColor = [UIColor blackColor].CGColor;
    self.cameraRecord.layer.borderWidth = 1.2;
    self.cameraRecord.layer.masksToBounds = YES;
    
    self.cameraShutter.layer.cornerRadius = self.cameraShutter.frame.size.width * 0.5;
    self.cameraShutter.layer.borderColor = [UIColor blackColor].CGColor;
    self.cameraShutter.layer.borderWidth = 1.2;
    self.cameraShutter.layer.masksToBounds = YES;
    
    self.cameraPlayback.layer.cornerRadius = self.cameraPlayback.frame.size.width * 0.5;
    self.cameraPlayback.layer.borderColor = [UIColor blackColor].CGColor;
    self.cameraPlayback.layer.borderWidth = 1.2;
    self.cameraPlayback.layer.masksToBounds = YES;
    
    self.goHomeButton.layer.cornerRadius = self.goHomeButton.frame.size.width * 0.5;
    self.goHomeButton.layer.borderColor = [UIColor blackColor].CGColor;
    self.goHomeButton.layer.borderWidth = 1.2;
    self.goHomeButton.layer.masksToBounds = YES;
    
    self.customButton1.layer.cornerRadius = self.customButton1.frame.size.width * 0.5;
    self.customButton1.layer.borderColor = [UIColor blackColor].CGColor;
    self.customButton1.layer.borderWidth = 1.2;
    self.customButton1.layer.masksToBounds = YES;
    
    self.customButton2.layer.cornerRadius = self.customButton2.frame.size.width * 0.5;
    self.customButton2.layer.borderColor = [UIColor blackColor].CGColor;
    self.customButton2.layer.borderWidth = 1.2;
    self.customButton2.layer.masksToBounds = YES;
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)remoteController:(DJIRemoteController *)rc didUpdateHardwareState:(DJIRCHardwareState)state
{
    self.rightHorizontal.text = [NSString stringWithFormat:@"%d", state.rightStick.horizontalPosition];
    self.rightVertical.text = [NSString stringWithFormat:@"%d", state.rightStick.verticalPosition];
    self.leftVertical.text = [NSString stringWithFormat:@"%d", state.leftStick.verticalPosition];
    self.leftHorizontal.text = [NSString stringWithFormat:@"%d", state.leftStick.horizontalPosition];
    
    [self.leftWheel setValue:state.leftWheel animated:YES];
    
    self.wheelOffset += (int)state.rightWheel.value;
    if (self.wheelOffset > 20) {
        self.wheelOffset = 20;
    }
    if (self.wheelOffset < -20) {
        self.wheelOffset = -20;
    }
    [self.rightWheel setValue:self.wheelOffset animated:YES];
    
    [self.modeSwitch setSelectedSegmentIndex:state.flightModeSwitch];
    
    UIColor* pressedColor = [[UIColor redColor] colorWithAlphaComponent:0.5];
    UIColor* normalColor = [UIColor whiteColor];
    
    [self.cameraRecord setBackgroundColor:(state.recordButton.isClicked ? pressedColor : normalColor)];
    [self.cameraRecord setHidden:!state.recordButton.isPresent];
    
    [self.cameraShutter setBackgroundColor:(state.shutterButton.isClicked ? pressedColor : normalColor)];
    [self.cameraShutter setHidden:!state.shutterButton.isPresent];
    
    [self.cameraPlayback setBackgroundColor:(state.playbackButton.isClicked ? pressedColor : normalColor)];
    [self.cameraPlayback setHidden:!state.shutterButton.isPresent];
    
    [self.goHomeButton setBackgroundColor:(state.goHomeButton.isClicked ? pressedColor : normalColor)];
    [self.goHomeButton setHidden:!state.shutterButton.isPresent];
    
    [self.customButton1 setBackgroundColor:(state.c1Button.isClicked ? pressedColor : normalColor)];
    [self.customButton1 setHidden:!state.shutterButton.isPresent];
    
    [self.customButton2 setBackgroundColor:(state.c2Button.isClicked ? pressedColor : normalColor)];
    [self.customButton2 setHidden:!state.shutterButton.isPresent];
    
    BOOL isTranforam = state.transformationSwitch.state == DJIRCTransformationSwitchStateRetract;
    [self.transformSwitch setOn:isTranforam animated:YES];
}


@end
