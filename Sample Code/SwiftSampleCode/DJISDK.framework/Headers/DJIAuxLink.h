//
//  DJIControlLink.h
//  DJISDK
//
//  Copyright © 2015, DJI. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@class DJIAuxLink;


/**
 *  This protocol provides a delegate method to receive updated signal information of the remote controller link for the aircraft products that have WiFi video link. Eg. Phantom 3 Standard, 4K.
 */
@protocol DJIAuxLinkDelegate <NSObject>

@optional

/**
 *  Signal quality and strength information for current control link on each Remote Controller antenna.
 *
 *  @param link     DJIControlLink Instance.
 *  @param antennas DJISignalInformation object. The power property of DJISignalInformation is not used for DJIAuxLink,
 *                  so should be ignored.
 */
- (void)auxLink:(DJIAuxLink *_Nonnull)link didUpdateRemoteControllerSignalInformation:(NSArray *_Nonnull)signalInfo;

@end
/**
 *  Phantom 3 Standard and 4K products have two wireless links between the remote controller and aircraft. A WiFi link for video and app data, and a control link for telemetry and remote controller button/stick commands. This control link is called the auxiliary control link to distinguish it from other products with only a WiFi link (like Osmo).
 */
@interface DJIAuxLink : NSObject

@property(nonatomic, weak) id<DJIAuxLinkDelegate> delegate;

@end

NS_ASSUME_NONNULL_END