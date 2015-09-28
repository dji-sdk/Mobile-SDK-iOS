//
//  DJIBaseViewController.m
//  DJISdkDemo
//
//  Created by Ares on 15/9/9.
//  Copyright © 2015年 DJI. All rights reserved.
//

#import "DJIBaseViewController.h"

@interface DJIBaseViewController ()

@end

@implementation DJIBaseViewController

-(id) initWithDrone:(DJIDrone*)drone
{
    self = [super init];
    if (self) {
        _connectedDrone = drone;
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


-(int) dataSourceFromDroneType:(DJIDroneType)type
{
    if (type == DJIDrone_Inspire) {
        return kDJIDecoderDataSoureInspire;
    }
    else if (type == DJIDrone_Phantom3Professional)
    {
        return kDJIDecoderDataSourePhantom3Professional;
    }
    else if (type == DJIDrone_Phantom3Advanced)
    {
        return kDJIDecoderDataSourePhantom3Advanced;
    }
    
    return kDJIDecoderDataSoureNone;
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
