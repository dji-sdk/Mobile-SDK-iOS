//
//  PayloadViewController.m
//  DJISdkDemo
//
//  Copyright © 2017 DJI. All rights reserved.
//

#import "PayloadViewController.h"
#import <DJISDK/DJISDK.h>
#import "PayloadTestChannelViewController.h"
#import "DemoComponentHelper.h"
#import "DemoUtilityMacro.h"
#import "DemoAlertView.h"

@interface PayloadViewController ()
<
    DJIPayloadDelegate
>
{
    NSInteger _payloadIndex;
}

@property (weak, nonatomic) IBOutlet UILabel *payloadName;
@property (weak, nonatomic) IBOutlet UITextView *sendContent;
@property (weak, nonatomic) IBOutlet UITextView *receiveContent;

@property (weak, nonatomic) IBOutlet UITextView *floatHintMsg;

@end

@implementation PayloadViewController

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    [[DemoComponentHelper fetchPayload] setDelegate:self];
    
    [self printAllWidgets:[[DemoComponentHelper fetchPayload] getWidgets]];
}

- (void)viewDidAppear:(BOOL)animated {
    DJIPayload *payload = [DemoComponentHelper fetchPayload];
    self.payloadName.text = [payload getPayloadProductName];
}

#pragma mark - Button

- (IBAction)toggleDismissKeyboard:(id)sender {
    if (self.sendContent) {
        [self.sendContent resignFirstResponder];
    }
}

- (IBAction)toggleBackEvent:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (IBAction)togglesSendData:(id)sender {
    if (!self.sendContent.text) {
        return;
    }
    
    NSData *data = [self.sendContent.text dataUsingEncoding:NSUTF8StringEncoding];
    
    if (!data) {
        ShowResult(@"String Convert To Data using UTF8 error");
        return;
    }
    
    [[DemoComponentHelper fetchPayload] sendDataToPayload:data withCompletion:^(NSError * _Nullable error) {
        if (!error) {
            ShowResult(@"sendDataToPayload Success");
        } else {
            ShowResult(@"sendDataToPayload error: %@", error);
        }
    }];
}

- (IBAction)togglesChannelPage:(id)sender {
    DJIPayload *payload = [DemoComponentHelper fetchPayload];
    if (payload) {
        PayloadTestChannelViewController* vc = [[PayloadTestChannelViewController alloc] init];
        vc.payload                           = payload;
        [self presentViewController:vc animated:YES completion:nil];
    } else {
        ShowResult(@"The payload is not connected. ");
    }
}

#pragma mark - DJIPayloadDelegate

- (void)payload:(DJIPayload *)payload didReceiveCommandData:(NSData *)data {
    NSString *content = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
    
    if (!content) {
        NSLog(@"❌ data convert to string using utf8 error");
        
        return;
    }
    
    self.receiveContent.text = content;
}

- (void)payload:(DJIPayload *)payload didReceiveMessage:(NSString *)message {
    if (!message) {
        return;
    }
    
    self.floatHintMsg.text = message;
}

- (void)payload:(DJIPayload *)payload didUpdateWidgets:(NSArray<DJIPayloadWidget *> *)allWidgetStatus {
    [self printAllWidgets:allWidgetStatus];
}

- (void)printAllWidgets:(NSArray<DJIPayloadWidget *> *)allWidgetStatus {
    NSLog(@"======= begin widgets ===========");
    
    [allWidgetStatus enumerateObjectsUsingBlock:^(DJIPayloadWidget * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        NSLog(@"type: %@ index: %@, name: %@", @(obj.type), @(obj.index), obj.name);
        
        switch (obj.type) {
            case DJIPayloadWidgetTypeList:
                NSLog(@"list: %@ selected: %@", obj.list, @(obj.selectedListItem));
                break;
            case DJIPayloadWidgetTypeInput:
                NSLog(@"inputValue: %@, tips: %@", @(obj.inputValue), obj.inputHint ? obj.inputHint : @"");
                break;
            case DJIPayloadWidgetTypeRange:
                NSLog(@"range: %@", obj.percentage);
                break;
            case DJIPayloadWidgetTypeButton:
                NSLog(@"buttonStatue: %@", @(obj.buttonState));
                break;
            case DJIPayloadWidgetTypeSwitch:
                NSLog(@"switchState: %@", @(obj.switchState));
                break;
                
            default:
                break;
        }
    }];
    
    NSLog(@"======= end widgets ===========");
}

@end
