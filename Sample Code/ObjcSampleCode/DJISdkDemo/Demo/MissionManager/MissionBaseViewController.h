//
//  MissionBaseViewController.h
//  DJISdkDemo
//
//  Copyright © 2015 DJI. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <DJISDK/DJISDK.h>

@interface MissionBaseViewController : UIViewController <DJIMissionManagerDelegate, DJIFlightControllerDelegate>

@property (nonatomic, strong) DJIMission* mission;
@property(nonatomic, assign) CLLocationCoordinate2D homeLocation;
@property(nonatomic, assign) CLLocationCoordinate2D aircraftLocation; 

@property (weak, nonatomic) IBOutlet UIButton *prepareButton;
@property (weak, nonatomic) IBOutlet UIButton *startButton;
@property (weak, nonatomic) IBOutlet UIButton *stopButton;
@property (weak, nonatomic) IBOutlet UIButton *downloadButton;
@property (weak, nonatomic) IBOutlet UIButton *pauseButton;
@property (weak, nonatomic) IBOutlet UIButton *resumeButton;
@property (weak, nonatomic) IBOutlet UIProgressView *progressBar;
@property (weak, nonatomic) IBOutlet UILabel *statusLabel;


// methods to override by sub-classes
-(DJIMission*) initializeMission;

-(void) missionDidStart:(NSError*)error;
-(void) missionWillPause;
-(void) missionDidResume:(NSError*)error;
-(void) missionDidStop:(NSError*)error;
-(void) mission:(DJIMission*)mission didDownload:(NSError*)error; 
@end
