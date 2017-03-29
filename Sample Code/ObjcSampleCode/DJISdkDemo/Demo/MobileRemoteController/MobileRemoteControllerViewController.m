//
//  JoystickTestViewController.m
//  DJISdkDemo
//
//  Copyright © 2016 DJI. All rights reserved.
//
/**
 *  This file demonstrates how to use the mobile remote controller to control
 *  the aircraft and how to start the simulator.
 *  Mobile remote controller can be used only the mobile device is connecting
 *  to the aircraft directly without a remote controller. User can use the 
 *  mobile remote controller to control the aircraft just like a physical 
 *  remote controller.
 */
#import "MobileRemoteControllerViewController.h"
#import "DemoVirtualStickView.h"
#import "DemoUtility.h"

@interface MobileRemoteControllerViewController ()

@property(nonatomic, weak) IBOutlet DemoVirtualStickView* joystickLeft;
@property(nonatomic, weak) IBOutlet DemoVirtualStickView* joystickRight;

@property (weak, nonatomic) IBOutlet UIButton *simulatorButton;
@property (weak, nonatomic) IBOutlet UILabel *simulatorStateLabel;
@property (assign, nonatomic) BOOL isSimulatorOn;

-(IBAction) onTakeoffButtonClicked:(id)sender;
- (IBAction)onSimulatorButtonClicked:(id)sender;

@end

@implementation MobileRemoteControllerViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
    
    NSNotificationCenter *notificationCenter = [NSNotificationCenter defaultCenter];
    [notificationCenter addObserver: self
                           selector: @selector (onStickChanged:)
                               name: @"StickChanged"
                             object: nil];
}

-(void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    DJIFlightController* fc = [DemoComponentHelper fetchFlightController];
    if (fc && fc.simulator) {
        self.isSimulatorOn = fc.simulator.isSimulatorActive;
        [self updateSimulatorUI];
        
        [fc.simulator addObserver:self forKeyPath:@"isSimulatorStarted" options:NSKeyValueObservingOptionNew context:nil];
        [fc.simulator setDelegate:self];
    }
}

-(void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    DJIFlightController* fc = [DemoComponentHelper fetchFlightController];
    if (fc && fc.simulator) {
        [fc.simulator removeObserver:self forKeyPath:@"isSimulatorStarted"];
        [fc.simulator setDelegate:nil];
    }
}

-(IBAction) onTakeoffButtonClicked:(id)sender
{
    DJIFlightController* fc = [DemoComponentHelper fetchFlightController];
    if (fc) {
        [fc startTakeoffWithCompletion:^(NSError *error) {
            if (error) {
                ShowResult(@"Takeoff:%@", error.description);
            } else {
                ShowResult(@"Takeoff Success. ");
            }
        }];
    }
    else
    {
        ShowResult(@"Component not exist.");
    }
}

- (IBAction)onSimulatorButtonClicked:(id)sender {
    DJIFlightController* fc = [DemoComponentHelper fetchFlightController];
    if (fc && fc.simulator) {
        if (!self.isSimulatorOn) {
            // The initial aircraft's position in the simulator.
            CLLocationCoordinate2D location = CLLocationCoordinate2DMake(22, 113);
            [fc.simulator startWithLocation:location updateFrequency:20 GPSSatellitesNumber:10 withCompletion:^(NSError * _Nullable error) {
                if (error) {
                    ShowResult(@"Start simulator error:%@", error.description);
                } else {
                    ShowResult(@"Start simulator succeeded.");
                }
            }];
        }
        else {
            [fc.simulator stopWithCompletion:^(NSError * _Nullable error) {
                if (error) {
                    ShowResult(@"Stop simulator error:%@", error.description);
                } else {
                    ShowResult(@"Stop simulator succeeded.");
                }
            }];
        }
    }
}

- (void)onStickChanged:(NSNotification*)notification
{
    NSDictionary *dict = [notification userInfo];
    NSValue *vdir = [dict valueForKey:@"dir"];
    CGPoint dir = [vdir CGPointValue];

    DJIMobileRemoteController *mobileRC = [DemoComponentHelper fetchMobileRemoteController];
    DemoVirtualStickView* joystick = (DemoVirtualStickView*)notification.object;
    if (joystick) {
        if (joystick == self.joystickLeft) {
            if (-dir.y != mobileRC.leftStickVertical) {
                mobileRC.leftStickVertical = -dir.y;
            }
            if (dir.x != mobileRC.leftStickHorizontal) {
                mobileRC.leftStickHorizontal = dir.x;
            }
        }
        else
        {
            if (-dir.y != mobileRC.rightStickVertical) {
                mobileRC.rightStickVertical = -dir.y;
            }
            if (dir.x != mobileRC.rightStickHorizontal) {
                mobileRC.rightStickHorizontal = dir.x;
            }
        }
    }
}

-(void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSString *,id> *)change context:(void *)context {
    if ([keyPath isEqualToString:@"isSimulatorStarted"]) {
        self.isSimulatorOn = [[change objectForKey:NSKeyValueChangeNewKey] boolValue];
        [self updateSimulatorUI];
    }
}

-(void) updateSimulatorUI {
    if (!self.isSimulatorOn) {
        [self.simulatorButton setTitle:@"Start Simulator" forState:UIControlStateNormal];
        [self.simulatorStateLabel setHidden:YES];
    }
    else {
        [self.simulatorButton setTitle:@"Stop Simulator" forState:UIControlStateNormal];
    }
}

#pragma mark - Delegate

-(void)simulator:(DJISimulator *)simulator didUpdateState:(DJISimulatorState *)state {
    [self.simulatorStateLabel setHidden:NO];
    self.simulatorStateLabel.text = [NSString stringWithFormat:@"Yaw: %f\nX: %f Y: %f Z: %f", state.yaw, state.positionX, state.positionY, state.positionZ];
}

@end
