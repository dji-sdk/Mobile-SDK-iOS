//
//  FCIntelligentAssistantViewController.m
//  DJISdkDemo
//
//  Copyright © 2016 DJI. All rights reserved.
//

#import "FCIntelligentAssistantViewController.h"
#import <DJISDK/DJISDK.h>
#import "DemoUtility.h"


@interface FCIntelligentAssistantViewController () <DJIIntelligentFlightAssistantDelegate>

@property (weak, nonatomic) IBOutlet UISwitch *collisionAvoidanceEnable;
@property (weak, nonatomic) IBOutlet UISwitch *visionPositioningEnable;
@property (weak, nonatomic) IBOutlet UILabel *isSensorWorking;
@property (weak, nonatomic) IBOutlet UILabel *isBraking;
@property (weak, nonatomic) IBOutlet UILabel *systemWarning;

@property (weak, nonatomic) IBOutlet UILabel *l2Distance;
@property (weak, nonatomic) IBOutlet UILabel *l2WarningLevel;

@property (weak, nonatomic) IBOutlet UILabel *l1Distance;
@property (weak, nonatomic) IBOutlet UILabel *l1WarningLevel;

@property (weak, nonatomic) IBOutlet UILabel *r1Distance;
@property (weak, nonatomic) IBOutlet UILabel *r1WarningLevel;

@property (weak, nonatomic) IBOutlet UILabel *r2Distance;
@property (weak, nonatomic) IBOutlet UILabel *r2WarningLevel;

@end

@implementation FCIntelligentAssistantViewController

-(void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    DJIFlightController* fc = [DemoComponentHelper fetchFlightController];
    if (!fc || !fc.intelligentFlightAssistant) {
        ShowResult(@"Flight controller or intelligent flight assistant is not detected. ");
        return;
    }
    
    [fc.intelligentFlightAssistant setDelegate:self];
    [self updateIntelligentFlightAssistantSwitches];
}

-(void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    
    DJIFlightController* fc = [DemoComponentHelper fetchFlightController];
    if (fc && fc.intelligentFlightAssistant) {
        [fc.intelligentFlightAssistant setDelegate:nil];
    }
}


- (IBAction)onCollisionAvoidanceSwitchValueChanged:(id)sender {
    DJIFlightController* fc = [DemoComponentHelper fetchFlightController];
    if (fc && fc.intelligentFlightAssistant) {
        [fc.intelligentFlightAssistant setCollisionAvoidanceEnabled:((UISwitch*)sender).on withCompletion:^(NSError * _Nullable error) {
            if (error) {
                ShowResult(@"Set collision avoidance enabled failed: %@", error.description);
            }
        }];
    }
}

- (IBAction)onVisionPositioningSwitchValueChanged:(id)sender {
    DJIFlightController* fc = [DemoComponentHelper fetchFlightController];
    if (fc && fc.intelligentFlightAssistant) {
        [fc.intelligentFlightAssistant setVisionPositioningEnabled:((UISwitch*)sender).on withCompletion:^(NSError * _Nullable error) {
            if (error) {
                ShowResult(@"Set vision positioning enabled failed: @%", error.description);
            }
        }];
    }
}

- (void)updateIntelligentFlightAssistantSwitches {
    DJIFlightController* fc = [DemoComponentHelper fetchFlightController];
    DJIIntelligentFlightAssistant* assistant = fc.intelligentFlightAssistant;
    WeakRef(target);
    [assistant getCollisionAvoidanceEnabledWithCompletion:^(BOOL enable, NSError * _Nullable error) {
        WeakReturn(target);
        target.collisionAvoidanceEnable.on = enable;
    }];
    
    [assistant getVisionPositioningEnabledWithCompletion:^(BOOL enable, NSError * _Nullable error) {
        WeakReturn(target);
        target.visionPositioningEnable.on = enable;
    }];
}


-(void)intelligentFlightAssistant:(DJIIntelligentFlightAssistant *)assistant didUpdateVisionDetectionState:(DJIVisionDetectionState *)state {
    self.isSensorWorking.text = state.isSensorWorking ? @"YES" : @"NO";
    self.systemWarning.text = [self stringWithSystemWarning:state.systemWarning];
    
    self.l2Distance.text = [NSString stringWithFormat:@"%f", ((DJIVisionDetectionSector*)(state.detectionSectors[0])).obstacleDistanceInMeters];
    self.l2WarningLevel.text = [self stringWithSector:((DJIVisionDetectionSector*)(state.detectionSectors[0])).warningLevel];
    
    self.l1Distance.text = [NSString stringWithFormat:@"%f", ((DJIVisionDetectionSector*)(state.detectionSectors[1])).obstacleDistanceInMeters];
    self.l1WarningLevel.text = [self stringWithSector:((DJIVisionDetectionSector*)(state.detectionSectors[1])).warningLevel];
    
    self.r1Distance.text = [NSString stringWithFormat:@"%f", ((DJIVisionDetectionSector*)(state.detectionSectors[2])).obstacleDistanceInMeters];
    self.r1WarningLevel.text = [self stringWithSector:((DJIVisionDetectionSector*)(state.detectionSectors[2])).warningLevel];
    
    self.r2Distance.text = [NSString stringWithFormat:@"%f", ((DJIVisionDetectionSector*)(state.detectionSectors[3])).obstacleDistanceInMeters];
    self.r2WarningLevel.text = [self stringWithSector:((DJIVisionDetectionSector*)(state.detectionSectors[3])).warningLevel];
}

-(NSString*) stringWithSystemWarning:(DJIVisionSystemWarning) warning {
    switch (warning) {
        case DJIVisionSystemWarningInvalid:
            return @"Invalid";
            
        case DJIVisionSystemWarningSafe:
            return @"Safe";
        
        case DJIVisionSystemWarningDangerous:
            return @"Dangerous";
            
        case DJIVisionSystemWarningUnknown:
            return @"Unknown";
            
        default:
            break;
    }
    return @"";
}

-(NSString*) stringWithSector:(DJIVisionSectorWarning) warning {
    switch (warning) {
        case DJIVisionSectorWarningInvalid:
            return @"NA";
            
        case DJIVisionSectorWarningLevel1:
            return @"1";
            
        case DJIVisionSectorWarningLevel2:
            return @"2";
            
        case DJIVisionSectorWarningLevel3:
            return @"3";
        case DJIVisionSectorWarningLevel4:
            return @"4";
            
        default:
            return @"XX";
    }
}

@end
