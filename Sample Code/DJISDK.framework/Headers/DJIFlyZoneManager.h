//
//  DJIFlyZoneManager.h
//  DJISDK
//
//  Copyright © 2016, DJI. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <MapKit/MKCircle.h>
#import <DJISDK/DJIFlyZoneInformation.h>
#import <DJISDK/DJIBaseProduct.h>

NS_ASSUME_NONNULL_BEGIN


@class DJIFlyZoneManager;


/**
 *  User account status. Users need to be logged
 */
typedef NS_ENUM(uint8_t, DJIUserAccountStatus) {
    /**
     *  User is not logged in. User needs to be logged in to retrieve currently unlocked, and unlock authorization zones.
     */
    DJIUserAccountStatusNotLoggedIn,
    
    /**
     * User is logged in but has not been authorized to unlock authorization zones.
     */
    DJIUserAccountStatusNotAuthorized,
    
    /**
     * User is logged in and has been authorized to unlock authoization zones.
     */
    DJIUserAccountStatusAuthorized,
    
    /**
     * The token of the user account is out of date.
     */
    DJIUserAccountStatusTokenOutOfDate,

    /**
     * Unknown.
     */
    DJIUserAccountStatusUnknown = 0xFF
};

/**
 *  This protocol provides the delegate method to receive updated fly zone information.
 *
 */
@protocol DJIFlyZoneDelegate <NSObject>

/**
 *  A delegate method to receive the latest fly zone status.
 */
 -(void)flyZoneManager:(DJIFlyZoneManager *)manager didUpdateFlyZoneStatus:(DJIFlyZoneStatus)status;

@end

/**
 *  This class manages the Geospatial Environment Online (GEO) system which provides warning, enhanced
 *  warning, authorization and restricted fly zone information.
 *  Warning zones have no flight restrictions.
 *  Enhanced warning, authorization and restricted fly zones do not allow flight by default.
 *  Enhanced warning zones can be unlocked once the user is logged into their DJI account.
 *  Authorization zones can be unlocked once the user is logged into their DJI account, and that account has
 *  been authorized to unlock authorization zones.
 *  Restricted zones cannot be unlocked using the GEO system.
 *
 *  Use of the geographic information provided DJIFlyZoneManager is restricted.
 *  Refer to the DJI Developer Policy sent when signing up for Mobile SDK v3.3 Beta.
 */
@interface DJIFlyZoneManager : NSObject

/**
 *  The `DJIFlyZoneManager` singleton.
 */
+(instancetype)sharedInstance;

/**
 *  Delegate to receive the updated status.
 */
@property(nonatomic, weak) id<DJIFlyZoneDelegate> delegate;

/**
 *  Gets all the fly zones within 20km of the aircraft. During simulation, this method is
 *  available only when the aircraft location is within 50km of (37.460484, -122.115312).
 *
 *  Use of the geographic information provided by DJIFlyZoneManager is restricted.
 *  Refer to the DJI Developer Policy sent when signing up for Mobile SDK v3.3 Beta.
 *
 *  @param block The execution block with the returned execution result.
 */
-(void)getFlyZonesInSurroundingAreaWithCompletion:(void (^_Nullable)(NSArray<DJIFlyZoneInformation*> *_Nullable infos, NSError* _Nullable error))block;

/**
 *  After invoking this method, a dialog redirecting users to log into their DJI account will be
 *  shown. After the login process, if the account has not been authorized to unlock authorization zones,
 *  the dialog will then redirect users to authorize their account.
 *
 *  @param block The execution block with the returned execution result.
 */
-(void)logIntoDJIUserAccountWithCompletion:(DJICompletionBlock)block;

/**
 *  Logs out the logged in DJI user.
 *
 *  @param block The execution block with the returned execution result.
 */
-(void)logOutOfDJIUserAccountWithCompletion:(DJICompletionBlock)block;

/**
 *  `YES` to enable GEO system. By default, if the GEO system is available at the aircraft location, GEO system will be enabled.
 *  The setting is NOT settable when the aircraft is in the air. The setting will take effect only when the aircraft lands.
 *  When GEO system is disabled, the aircraft reverts back to the previous NFZ (No Fly Zone) system.
 *  This interface may be deprecated in the future.
 *
 *  @param enabled  `YES` to enable GEO system.
 *  @param block    The execution block with the returned execution result.
 */
-(void)setGEOSystemEnabled:(BOOL)enabled withCompletion:(DJICompletionBlock)block;

/**
 *  Gets if the GEO system is enabled or not.
 *
 *  @param block Completion block that receives the getter execution result.
 */
-(void)getGEOSystemEnabled:(void (^_Nonnull)(BOOL enabled, NSError *_Nullable error))block;

/**
 *  Gets the account status.
 *
 *  @return current account status.
 */
-(DJIUserAccountStatus)getUserAccountStatus;

/**
 *  Gets a list of unlocked fly zones of the authorized account. The list contains
 *  the fly zones unlocked by the Flight Planner http://www.dji.com/flysafe/geo-system#planner
 *  and fly zones unlocked during flight using DJI GO or any DJI Mobile SDK based application.
 *
 *  @param block The execution block with the returned execution result.
 */
-(void)getUnlockedFlyZonesWithCompletion:(void (^_Nullable)(NSArray<DJIFlyZoneInformation*> *_Nullable infos, NSError* _Nullable error))block;

/**
 *  Unlocks the selected fly zones. This method can be used to unlock enhanced warning and authorization zones.
 *  After unlocking the zones flight will be unrestricted in those zones until the unlock expires.
 *  The unlocking record will be linked to the user's account and will be accessible to DJI GO and other DJI Mobile SDK
 *  based applications.
 *
 *  @param flyZoneIDs The IDs of EnhancedWarningZones or AuthorizedWarningZones.
 *  @param block The execution block with the returned execution result.
 */
-(void)unlockFlyZones:(NSArray<NSNumber *> *_Nullable)flyZoneIDs withCompletion:(DJICompletionBlock)block;


@end
NS_ASSUME_NONNULL_END
