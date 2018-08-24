//
//  DemoAlertView.m
//  DJISdkDemo
//
//  Copyright © 2015 DJI. All rights reserved.
//
/**
 *  A helper function to pop-up a simple alert view. 
 */
#import "DemoAlertView.h"

#define NavControllerObject(navController) UINavigationController* navController = (UINavigationController*)[[UIApplication sharedApplication] keyWindow].rootViewController;


void ShowResult(NSString *format, ...)
{
    va_list argumentList;
    va_start(argumentList, format);

    NSString* message = [[NSString alloc] initWithFormat:format arguments:argumentList];
    va_end(argumentList);
    NSString * newMessage = [message hasSuffix:@":(null)"] ? [message stringByReplacingOccurrencesOfString:@":(null)" withString:@" successful!"] : message;
    dispatch_async(dispatch_get_main_queue(), ^{
        UIAlertController* alertViewController = [UIAlertController alertControllerWithTitle:nil message:newMessage preferredStyle:UIAlertControllerStyleAlert];
        UIAlertAction* okAction = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:nil];
        [alertViewController addAction:okAction];
        UINavigationController* navController = (UINavigationController*)[[UIApplication sharedApplication] keyWindow].rootViewController;
        [navController dismissViewControllerAnimated:NO completion:nil];
        [navController presentViewController:alertViewController animated:YES completion:nil];
    });
}

@interface DemoAlertView()

@property(nonatomic, strong)UIAlertController* alertController;

@end

@implementation DemoAlertView

+(instancetype _Nullable) showAlertViewWithMessage:(NSString* _Nullable)message titles:(NSArray<NSString*> * _Nullable)titles action:(DemoAlertViewActionBlock _Nullable)actionBlock presentedViewController:(UIViewController *)viewController
{
    DemoAlertView* alertView = [[DemoAlertView alloc] init];
    
    alertView.alertController = [UIAlertController alertControllerWithTitle:@"" message:message preferredStyle:UIAlertControllerStyleAlert];
    for (NSUInteger index = 0; index < titles.count; ++index) {
        UIAlertActionStyle actionStyle = (index == 0) ? UIAlertActionStyleCancel : UIAlertActionStyleDefault;
        UIAlertAction* alertAction = [UIAlertAction actionWithTitle:titles[index] style:actionStyle handler:^(UIAlertAction * _Nonnull action) {
            if (actionBlock) {
                actionBlock(index);
            }
        }];
        [alertView.alertController addAction:alertAction];
    }
    
    [viewController presentViewController:alertView.alertController animated:YES completion:nil];
    return alertView;
}

+(instancetype _Nullable) showAlertViewWithMessage:(NSString* _Nullable)message titles:(NSArray<NSString*> * _Nullable)titles action:(DemoAlertViewActionBlock _Nullable)actionBlock
{
    DemoAlertView* alertView = [[DemoAlertView alloc] init];

    alertView.alertController = [UIAlertController alertControllerWithTitle:@"" message:message preferredStyle:UIAlertControllerStyleAlert];
    for (NSUInteger index = 0; index < titles.count; ++index) {
        UIAlertActionStyle actionStyle = (index == 0) ? UIAlertActionStyleCancel : UIAlertActionStyleDefault;
        UIAlertAction* alertAction = [UIAlertAction actionWithTitle:titles[index] style:actionStyle handler:^(UIAlertAction * _Nonnull action) {
            if (actionBlock) {
                actionBlock(index);
            }
        }];
        [alertView.alertController addAction:alertAction];
    }

    NavControllerObject(navController);
    [navController presentViewController:alertView.alertController animated:YES completion:nil];
    return alertView;
}

+(instancetype _Nullable) showAlertViewWithMessage:(NSString* _Nullable)message titles:(NSArray<NSString*> * _Nullable)titles textFields:(NSArray<NSString*>* _Nullable)textFields action:(DemoAlertInputViewActionBlock _Nullable)actionBlock
{
    DemoAlertView* alertView = [[DemoAlertView alloc] init];

    alertView.alertController = [UIAlertController alertControllerWithTitle:@"" message:message preferredStyle:UIAlertControllerStyleAlert];
    for (NSUInteger index = 0; index < textFields.count; ++index) {
        [alertView.alertController addTextFieldWithConfigurationHandler:^(UITextField * _Nonnull textField) {
            textField.placeholder = textFields[index];
        }];
    }

    NSArray* fieldViews = alertView.alertController.textFields;
    for (NSUInteger index = 0; index < titles.count; ++index) {
        UIAlertActionStyle actionStyle = (index == 0) ? UIAlertActionStyleCancel : UIAlertActionStyleDefault;
        UIAlertAction* alertAction = [UIAlertAction actionWithTitle:titles[index] style:actionStyle handler:^(UIAlertAction * _Nonnull action) {
            if (actionBlock) {
                actionBlock(fieldViews, index);
            }
        }];

        [alertView.alertController addAction:alertAction];
    }

    NavControllerObject(navController);
    [navController presentViewController:alertView.alertController animated:YES completion:nil];
    return alertView;
}

-(void) unpdateMessage:(nullable NSString *)message
{
    self.alertController.message = message;
}

-(void) dismissAlertView
{
    [self.alertController dismissViewControllerAnimated:YES completion:nil];
}

@end

