//
//  JoystickTestViewController.m
//  DJISdkDemo
//
//  Copyright © 2015 DJI. All rights reserved.
//
/**
 *  This file demonstrates how to use the advanced set of methods in DJIFlightController to control the aircraft. Through DJIFlightController,
 *  user can make the aircraft enter the virtual stick mode. In this mode, SDK gives the flexibility for user to control the aircraft just 
 *  like controlling it using the joystick. There are different combinations to control the aircraft in the virtual stick mode. In this 
 *  sample, we will control the horizontal movement by velocity. 
 *
 *  For more information about the virtual stick, please refer to the Get Started page on http://developer.dji.com.
 */
#import "FCVirtualStickViewController.h"
#import "FCVirtualStickView.h"
#import "DemoUtility.h"

@interface FCVirtualStickViewController ()

@property(nonatomic, weak) IBOutlet FCVirtualStickView* joystickLeft;
@property(nonatomic, weak) IBOutlet FCVirtualStickView* joystickRight;
@property(nonatomic, weak) IBOutlet UIButton* coordinateSys;

@property (weak, nonatomic) IBOutlet UIButton *enableVirtualStickButton;

-(IBAction) onEnterVirtualStickControlButtonClicked:(id)sender;
-(IBAction) onExitVirtualStickControlButtonClicked:(id)sender;
-(IBAction) onTakeoffButtonClicked:(id)sender;
-(IBAction) onCoordinateSysButtonClicked:(id)sender;

@end

@implementation FCVirtualStickViewController
{
    float mXVelocity;
    float mYVelocity;
    float mYaw;
    float mThrottle;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
    
    NSNotificationCenter *notificationCenter = [NSNotificationCenter defaultCenter];
    [notificationCenter addObserver: self
                           selector: @selector (onStickChanged:)
                               name: @"StickChanged"
                             object: nil];
    
    
    DJIFlightController* fc = [DemoComponentHelper fetchFlightController];
    if (fc) {
        fc.delegate = self;
        fc.rollPitchControlMode = DJIVirtualStickFlightCoordinateSystemGround;
    }
}

-(IBAction) onExitVirtualStickControlButtonClicked:(id)sender
{
    DJIFlightController* fc = [DemoComponentHelper fetchFlightController];
    if (fc) {
        [fc disableVirtualStickControlModeWithCompletion:^(NSError * _Nullable error) {
            if (error){
                ShowResult(@"Exit Virtual Stick Mode: %@", error.debugDescription);
            } else{
                ShowResult(@"Success. ");
            }
        }];
    }
    else
    {
        ShowResult(@"Component not exist.");
    }
}
    
-(IBAction) onEnterVirtualStickControlButtonClicked:(id)sender
{
    DJIFlightController* fc = [DemoComponentHelper fetchFlightController];
    if (fc) {
        fc.yawControlMode = DJIVirtualStickYawControlModeAngularVelocity;
        fc.rollPitchControlMode = DJIVirtualStickRollPitchControlModeVelocity;
        
        [fc enableVirtualStickControlModeWithCompletion:^(NSError *error) {
            if (error) {
                ShowResult(@"Enter Virtual Stick Mode:%@", error.description);
            }
            else
            {
                ShowResult(@"Enter Virtual Stick Mode:Succeeded");
            }
        }];
    }
    else
    {
        ShowResult(@"Component not exist.");
    }
}

-(IBAction) onTakeoffButtonClicked:(id)sender
{
    DJIFlightController* fc = [DemoComponentHelper fetchFlightController];
    if (fc) {
        [fc takeoffWithCompletion:^(NSError *error) {
            if (error) {
                ShowResult(@"Takeoff:%@", error.description);
            } else {
                ShowResult(@"Success. ");
            }
        }];
    }
    else
    {
        ShowResult(@"Component not exist.");
    }
}

-(IBAction) onCoordinateSysButtonClicked:(id)sender
{
    DJIFlightController* fc = [DemoComponentHelper fetchFlightController];
    if (fc) {
        if (fc.rollPitchCoordinateSystem == DJIVirtualStickFlightCoordinateSystemGround) {
            fc.rollPitchCoordinateSystem = DJIVirtualStickFlightCoordinateSystemBody;
            [_coordinateSys setTitle:NSLocalizedString(@"CoordinateSys:Body", @"") forState:UIControlStateNormal ];
        }
        else
        {
            fc.rollPitchCoordinateSystem = DJIVirtualStickFlightCoordinateSystemGround;
            [_coordinateSys setTitle:NSLocalizedString(@"CoordinateSys:Ground", @"") forState:UIControlStateNormal];
        }
    }
    else
    {
        ShowResult(@"Component not exist.");
    }
}

- (void)onStickChanged:(NSNotification*)notification
{
    NSDictionary *dict = [notification userInfo];
    NSValue *vdir = [dict valueForKey:@"dir"];
    CGPoint dir = [vdir CGPointValue];
    
    FCVirtualStickView* joystick = (FCVirtualStickView*)notification.object;
    if (joystick) {
        if (joystick == self.joystickLeft) {
            [self setThrottle:dir.y andYaw:dir.x];
        }
        else
        {
            // To consist with the physical remote controller, the negative Y axis (push up) of the virtual stick is mapped to
            // the X direction of the coordinate (body or ground). The X axis (push right) is mapped to the Y direction of the
            // coordinate (body or ground).
            // If the developer wants to use the angle mode to control the horizontal movement, the mapping between the virtual
            // stick and the aircraft coordinate will be different. 
            [self setXVelocity:-dir.y andYVelocity:dir.x];
        }
    }
}

-(void) setThrottle:(float)y andYaw:(float)x
{
    mThrottle = y * -2;
    mYaw = x * 30;
    
    [self updateJoystick];
}

-(void) setXVelocity:(float)x andYVelocity:(float)y {
    mXVelocity = x * DJIVirtualStickRollPitchControlMaxVelocity;
    mYVelocity = y * DJIVirtualStickRollPitchControlMaxVelocity;
    [self updateJoystick];
}

-(void) updateJoystick
{
    // In rollPitchVelocity mode, the pitch property in DJIVirtualStickFlightControlData represents the Y direction velocity.
    // The roll property represents the X direction velocity.
    DJIVirtualStickFlightControlData ctrlData = {0};
    ctrlData.pitch = mYVelocity;
    ctrlData.roll = mXVelocity;
    ctrlData.yaw = mYaw;
    ctrlData.verticalThrottle = mThrottle;
    DJIFlightController* fc = [DemoComponentHelper fetchFlightController];
    if (fc && fc.isVirtualStickControlModeAvailable) {
        [fc sendVirtualStickFlightControlData:ctrlData withCompletion:nil];
    }
}

#pragma mark - Delegate

-(void) flightController:(DJIFlightController*)fc didUpdateSystemState:(DJIFlightControllerCurrentState*)state
{

}
@end
