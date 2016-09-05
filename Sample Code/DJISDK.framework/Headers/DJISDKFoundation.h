//
//  DJISDKFoundation.h
//  DJISDK
//
//  Copyright © 2015, DJI. All rights reserved.
//

#import <Foundation/Foundation.h>

#ifdef __cplusplus
#define DJI_API_EXTERN       extern "C" __attribute__((visibility("default")))
#else
#define DJI_API_EXTERN       extern __attribute__((visibility("default")))
#endif

#define DJI_API_DEPRECATED(_msg_) __attribute__((deprecated(_msg_)))

// These macros are to define SDKCache Keys in their .h and implement in their .m
#define CACHE_KEY_DECLARE(_key_name_)                       extern NSString *const _key_name_
#define CACHE_KEY_IMPLEMENT(_key_name_, _key_value_)        NSString *const _key_name_ = @"" #_key_value_

/**
 *  Completion block for asynchronous operations. This completion block is used for methods that return at an unknown future time.
 *
 *  @param error An error object if an error occured during async operation, or nil if no error occurred.
 */
typedef void(^_Nullable DJICompletionBlock)(NSError *_Nullable error);
