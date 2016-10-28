//
//  DJIGoHomeStep.h
//  DJISDK
//
//  Copyright © 2015, DJI. All rights reserved.
//

#import <DJISDK/DJIMissionStep.h>

NS_ASSUME_NONNULL_BEGIN

/**
 *  This class represents a go-home step for a custom mission. By creating an
 *  object of this class and adding it to a custom mission, a go-home action
 *  will be performed during the custom mission execution.
 */
@interface DJIGoHomeStep : DJIMissionStep

/**
 *  `YES` to enable automatic confirmation during landing.
 *  For flight controller firmware version 3.2.0.0 or above, when the clearance
 *  between the aircraft and the ground is less than 0.3m, the aircraft will
 *  pause landing and wait for the user's confirmation to continue. Enabling the
 *  auto confirmation, allows the aircraft to continue landing without the user's
 *  confirmation during the custom mission. For firmware that does not require
 *  landing confirmation, the value is ignored.
 *  The default value is `YES`.
 */
@property (nonatomic, readwrite) BOOL autoConfirmLandingEnabled;

@end

NS_ASSUME_NONNULL_END
