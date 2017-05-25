//
//  KeyedInterfaceViewController.m
//  DJISdkDemo
//
//  Created by Arnaud Thiercelin on 2/6/17.
//  Copyright © 2017 DJI. All rights reserved.
//

#import "KeyedInterfaceViewController.h"
#import <DJISDK/DJISDK.h>

@interface KeyedInterfaceViewController ()

@property (weak, nonatomic) IBOutlet UIButton *getBatteryLevelButton;
@property (weak, nonatomic) IBOutlet UILabel *batteryLevelLabel;

@property (weak, nonatomic) IBOutlet UIButton *setCameraModeButton;
@property (weak, nonatomic) IBOutlet UILabel *setCameraModeLabel;

@property (weak, nonatomic) IBOutlet UIButton *listeningOnCoordinatesButton;
@property (weak, nonatomic) IBOutlet UILabel *listeningCoordinatesLabel;

@property (weak, nonatomic) IBOutlet UIButton *exposureSettingsButton;
@property (weak, nonatomic) IBOutlet UILabel *exposureSettingsLabel;

@end

@implementation KeyedInterfaceViewController

-(instancetype)init {
    self = [super initWithNibName:@"KeyedInterfaceViewController"  bundle:[NSBundle mainBundle]];
    if (self) {
    }
    
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewWillAppear:(BOOL)animated {
    self.batteryLevelLabel.text = @"N/A %";
    self.setCameraModeLabel.text = @"N/A";
    self.listeningCoordinatesLabel.text = @"Lat: N/A - Long: N/A";
    self.exposureSettingsLabel.text = @"N/A";
}


- (IBAction)getBatteryLevel:(id)sender {
    DJIKeyManager *keyManager = [DJISDKManager keyManager];
    DJIBatteryKey *batteryLevelKey = [DJIBatteryKey keyWithParam:DJIBatteryParamChargeRemainingInPercent];
    
    [keyManager getValueForKey:batteryLevelKey
                withCompletion:^(DJIKeyedValue * _Nullable value, NSError * _Nullable error)
     {
         if (error || value == nil) {
             // insert graceful error handling here.

             self.batteryLevelLabel.text = @"Error";
         } else {
             // DJIBatteryParamChargeRemainingInPercent is associated with a uint8_t value
             NSUInteger batteryLevel = value.unsignedIntegerValue;
             
             self.batteryLevelLabel.text = [NSString stringWithFormat:@"%tu%%", batteryLevel];
         }
     }];
}

- (IBAction)setCameraMode:(id)sender {
    DJIKeyManager *keyManager = [DJISDKManager keyManager];
    DJICameraKey *cameraModeKey = [DJICameraKey keyWithParam:DJICameraParamMode];

    DJICameraMode currentMode = DJICameraModeShootPhoto; // Default value.

    // Sometimes you want to get the value that is cached inside the keyed interface rather
    // than fetching it from the connected product. To do so, you may call getValueForKey:
    DJIKeyedValue *currentCameraMode = [keyManager getValueForKey:cameraModeKey];

    if (currentCameraMode) {
        // DJICameraParamMode is associated with DJICameraMode enum values
        currentMode = currentCameraMode.integerValue;
    }
    
    DJICameraMode newMode = currentMode == DJICameraModeShootPhoto ? DJICameraModeRecordVideo : DJICameraModeShootPhoto;
    
    [keyManager setValue:@(newMode)
                  forKey:cameraModeKey
          withCompletion:^(NSError * _Nullable error) {
              if (error) {
                  // insert graceful error handling here.
                  
                  self.setCameraModeLabel.text = @"Error";
              } else {
                  self.setCameraModeLabel.text = newMode == DJICameraModeShootPhoto ? @"DJICameraModeShootPhoto" : @"DJICameraModeRecordVideo";
              }
          }];
}

- (IBAction)startStopListeningOnCoodinates:(id)sender {
    static BOOL isListening = NO;
    DJIKeyManager *keyManager = [DJISDKManager keyManager];
    DJIFlightControllerKey *locationKey = [DJIFlightControllerKey keyWithParam:DJIFlightControllerParamAircraftLocation];
    
    if (isListening) {

        // At anytime, you may stop listening to a key or to all key for a given listener
        [keyManager stopListeningOnKey:locationKey ofListener:self];
        self.listeningCoordinatesLabel.text = @"Stopped";
    } else {
        
        // Start listening is as easy as passing a block with a key.
        // Note that start listening won't do a get. Your block will be executed
        // the next time the associated data is being pulled.
        [keyManager startListeningForChangesOnKey:locationKey
                                     withListener:self
                                   andUpdateBlock:^(DJIKeyedValue * _Nullable oldValue, DJIKeyedValue * _Nullable newValue)
        {
            if (newValue) {
               // DJIFlightControllerParamAircraftLocation is associated with a DJISDKLocation object
                CLLocation *aircraftCoordinates = (CLLocation *)newValue.value;
                
                self.listeningCoordinatesLabel.text = [NSString stringWithFormat:@"Lat: %.6f - Long: %.6f", aircraftCoordinates.coordinate.latitude, aircraftCoordinates.coordinate.longitude];
            }
        }];
        self.listeningCoordinatesLabel.text = @"Started...";
    }
    
    isListening = !isListening;
}

- (IBAction)getExposureSettings:(id)sender {

    DJIKeyManager *keyManager = [DJISDKManager keyManager];
    DJICameraKey *exposureKey = [DJICameraKey keyWithParam:DJICameraParamExposureSettings];


    [keyManager getValueForKey:exposureKey
                withCompletion:^(DJIKeyedValue * _Nullable value, NSError * _Nullable error)
    {
        if (error || value == nil) {
            // insert graceful error handling here.
            
            self.exposureSettingsLabel.text = @"error";
        } else {
            // DJICameraParamExposureSettings is associated with DJICameraExposureSettings struct.
            // Structs are stored inside an NSValue when carried by a DJIKeyedValue object.
            DJICameraExposureSettings exposureSettings = {0};
            
            [value.value getValue:&exposureSettings];
            
            self.exposureSettingsLabel.text = [NSString stringWithFormat:@"ISO: %tu\nAperture: %tu\nEV: %tu\nShutter:%tu",
                                          exposureSettings.ISO,
                                          exposureSettings.aperture,
                                          exposureSettings.exposureCompensation,
                                          exposureSettings.shutterSpeed];
        }
    }];
    
}


@end
