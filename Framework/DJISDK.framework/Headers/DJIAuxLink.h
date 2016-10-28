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
 *  This protocol provides a delegate method to receive updated signal information for the remote controller link for aircraft products that have a WiFi video link, such as the Phantom 3 Standard and 4K products.
 */
@protocol DJIAuxLinkDelegate <NSObject>

@optional

/**
 *  Signal quality and strength information for the current control link on each Remote Controller antenna.
 *
 *  @param link     `DJIControlLink` remote controller link instance.
 *  @param antennas  `DJISignalInformation` object containing updated signal information for the remote controller link. The `power` property of `DJISignalInformation` is not used for `DJIAuxLink` and should be ignored.
 */
- (void)auxLink:(DJIAuxLink *_Nonnull)link didUpdateRemoteControllerSignalInformation:(NSArray *_Nonnull)signalInfo;

@end
/**
 *  The Phantom 3 Standard and 4K products have two wireless links between the remote controller and aircraft. These include a WiFi link for video and app data, and a control link for telemetry and remote controller button/stick commands. This control link is called the auxiliary control link, which distinguishes it from other products having only a WiFi link (such as Osmo).
 */
@interface DJIAuxLink : NSObject

/**
 *  Returns the DJIAuxLink delegate.
 */
@property(nonatomic, weak) id<DJIAuxLinkDelegate> delegate;

@end

NS_ASSUME_NONNULL_END