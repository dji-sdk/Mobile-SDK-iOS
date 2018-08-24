//
//  DemoAlertView.h
//  DJISdkDemo
//
//  Copyright © 2015 DJI. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

extern void ShowResult(NSString * format, ...);

typedef void (^DemoAlertViewActionBlock)(NSUInteger buttonIndex);
typedef void (^DemoAlertInputViewActionBlock)(NSArray<UITextField*>* _Nullable textFields, NSUInteger buttonIndex);

@interface DemoAlertView : NSObject

+(instancetype _Nullable) showAlertViewWithMessage:(NSString* _Nullable)message titles:(NSArray<NSString*> * _Nullable)titles action:(DemoAlertViewActionBlock _Nullable)actionBlock;

+(instancetype _Nullable) showAlertViewWithMessage:(NSString* _Nullable)message titles:(NSArray<NSString*> * _Nullable)titles textFields:(NSArray<NSString*>* _Nullable)textFields action:(DemoAlertInputViewActionBlock _Nullable)actionBlock;

+(instancetype _Nullable) showAlertViewWithMessage:(NSString* _Nullable)message titles:(NSArray<NSString*> * _Nullable)titles action:(DemoAlertViewActionBlock _Nullable)actionBlock presentedViewController:(UIViewController *)viewController;

-(void) dismissAlertView;

-(void) unpdateMessage:(nullable NSString *)message;

@end

NS_ASSUME_NONNULL_END
