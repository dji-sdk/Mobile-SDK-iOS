//
//  DJICustomMission.h
//  DJISDK
//
//  Created by dji on 11/17/15.
//  Copyright © 2015 DJI. All rights reserved.
//

#import <DJISDK/DJISDK.h>

/*
 *  The DJICustomMission class is a kind of DJIMission you use to create a custom mission that is made up of a sequence of mission steps.
 *  After the custom mission is uploaded and started, the sequence of misson steps is executed.
 *  For more detail about the currently supported DJIMissionStep, please refer to DJIMissionStep.h. 
 */
@interface DJICustomMission : DJIMission

/*
 *  Create a custom mission with an array of DJIMissionStep objects.
 */
-(id) initWithSteps:(NSArray<DJIMissionStep*>*) steps;

@end
