//
//  PayloadWidgetViewController.m
//  DJISdkDemo
//
//  Created by neo.xu on 2021/11/25.
//  Copyright © 2021 DJI. All rights reserved.
//

#import "PayloadWidgetViewController.h"
#import "DemoSelectView.h"
#import "DemoAlertView.h"
#import <DJISDK/DJISDK.h>
#import "DemoComponentHelper.h"
#import "DemoUtilityMacro.h"

@interface PayloadWidgetViewController ()
<
DJIPayloadDelegate
>

@property (weak, nonatomic) IBOutlet UITextView *statusView;

@property (nonatomic, strong) NSMutableString *mainWidgetStatusString;
@property (nonatomic, strong) NSMutableString *configwidgetStatusString;

@property (nonatomic, strong) NSString *fetchStateString;
@property (nonatomic, strong) NSString *fetchProgressString;

@end

@implementation PayloadWidgetViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [[DemoComponentHelper fetchPayload] setDelegate:self];
    self.mainWidgetStatusString = [NSMutableString stringWithString:[PayloadWidgetViewController convertAllWidgetsToString:[[DemoComponentHelper fetchPayload] getMainInterfaceWidgets]]];
    self.configwidgetStatusString = [NSMutableString stringWithString:[PayloadWidgetViewController convertAllWidgetsToString:[[DemoComponentHelper fetchPayload] getConfigInterfaceWidgets]]];
    [self updatePanel];
}

- (void)updatePanel {
    NSMutableString *panelStr = [NSMutableString string];
    [panelStr appendFormat:@"--------Main Interface Widgets--------\n"];
    [panelStr appendFormat:@"%@\n", self.mainWidgetStatusString];
    [panelStr appendFormat:@"--------Config Interface Widgets--------\n"];
    [panelStr appendFormat:@"%@\n", self.configwidgetStatusString];
    [panelStr appendFormat:@"--------Widget Fetch--------\n"];
    [panelStr appendFormat:@"%@\n", self.fetchStateString];
    [panelStr appendFormat:@"%@\n", self.fetchProgressString];

    self.statusView.text = panelStr;
}

#pragma mark - DJIPayloadDelegate

- (void)payload:(DJIPayload *)payload didUpdateMainInterfaceWidgets:(NSArray<DJIPayloadWidget *> *)widgets {
    self.mainWidgetStatusString = [NSMutableString string];
    [self.mainWidgetStatusString appendFormat:@"--------Main Widget Status--------\n"];
    [self.mainWidgetStatusString appendFormat:@"Status: %@\n", [PayloadWidgetViewController convertAllWidgetsToString:widgets]];
    [self updatePanel];

}

- (void)payload:(DJIPayload *)payload didUpdateConfigInterfaceWidgets:(NSArray<DJIPayloadWidget *> *)widgets {
    self.configwidgetStatusString = [NSMutableString string];
    [self.configwidgetStatusString appendFormat:@"--------Config Widget Status--------\n"];
    [self.configwidgetStatusString appendFormat:@"Status: %@\n", [PayloadWidgetViewController convertAllWidgetsToString:widgets]];
    [self updatePanel];
}

#pragma mark - Select Event

- (IBAction)onFetchWidgetButtonClicked:(id)sender {
    WeakRef(target);
    [[DemoComponentHelper fetchPayload] fetchWidgetConfigurationWithProgress:^(NSProgress * progress) {
        target.fetchStateString = @"State: Fetching";
        target.fetchProgressString = [NSString stringWithFormat:@"Progress: %@/%@", @(progress.completedUnitCount), @(progress.totalUnitCount)];
        [target updatePanel];
        DJILogDebug(@"[PSDK], fetch Progress:%@", self.fetchProgressString);
    } success:^{
        target.fetchStateString = @"State: Success";
        [target updatePanel];
        DJILogDebug(@"[PSDK], fetch Success");
    } failure:^(NSError * _Nonnull error) {
        target.fetchStateString = [NSString stringWithFormat:@"State: Failed, %@", error.localizedDescription];
        [target updatePanel];
        DJILogDebug(@"[PSDK], fetch Failed: %@", error.description);

    }];
}

- (IBAction)onGetUpstreamBandwidthButtonClicked:(id)sender {
    [[DemoComponentHelper fetchPayload] getUpstreamBandwidthWithCompletion:^(NSUInteger upstreamBandwidth, NSError * _Nullable error) {
        if (error) {
            ShowResult(@"getUpstreamBandwidth error: %@", error);
        } else {
            ShowResult(@"getUpstreamBandwidth : %@", @(upstreamBandwidth));
        }
    }];
}

- (IBAction)onSetSwitchStateButtonClicked:(id)sender {
    [DemoAlertView showAlertViewWithMessage:@"SwitchState" titles:@[@"Cancel", @"OK"] textFields:@[@"input 0(Off) 1(On)", @"input index"] action:^(NSArray<UITextField *> * _Nullable textFields, NSUInteger buttonIndex) {
        if (buttonIndex == 1 && textFields.count > 1) {
            DJIPayloadSwitchState state = (DJIPayloadSwitchState)[textFields[0].text integerValue];
            NSUInteger index = [textFields[1].text integerValue];
            [[DemoComponentHelper fetchPayload] setSwitchState:state index:index withCompletion:^(NSError * _Nullable error) {
                if (error) {
                    ShowResult(@"SwitchState :%@", error.description);
                } else {
                    ShowResult(@"Success");
                }
            }];
        }
    }];
}

- (IBAction)onSetRangeValueButtonClicked:(id)sender {
    [DemoAlertView showAlertViewWithMessage:@"SetRangeValue" titles:@[@"Cancel", @"OK"] textFields:@[@"input range [0, 100]", @"input index"] action:^(NSArray<UITextField *> * _Nullable textFields, NSUInteger buttonIndex) {
        if (buttonIndex == 1 && textFields.count > 1) {
            NSUInteger value = [textFields[0].text integerValue];
            NSUInteger index = [textFields[1].text integerValue];
            [[DemoComponentHelper fetchPayload] setRangeValue:value index:index withCompletion:^(NSError * _Nullable error) {
                if (error) {
                    ShowResult(@"setRangeValue :%@", error.description);
                } else {
                    ShowResult(@"Success");
                }
            }];
        }
    }];
}

- (IBAction)onSetSelectItemButtonClicked:(id)sender {
    [DemoAlertView showAlertViewWithMessage:@"setSelectedItem" titles:@[@"Cancel", @"OK"] textFields:@[@"setSelectedItem value", @"input index"] action:^(NSArray<UITextField *> * _Nullable textFields, NSUInteger buttonIndex) {
        if (buttonIndex == 1 && textFields.count > 1) {
            NSUInteger value = [textFields[0].text integerValue];
            NSUInteger index = [textFields[1].text integerValue];
            [[DemoComponentHelper fetchPayload] setSelectedItem:value index:index withCompletion:^(NSError * _Nullable error) {
                if (error) {
                    ShowResult(@"setRangeValue :%@", error.description);
                } else {
                    ShowResult(@"Success");
                }
            }];
        }
    }];
}

- (IBAction)onSetInputValueButtonClicked:(id)sender {
    [DemoAlertView showAlertViewWithMessage:@"setInputValue" titles:@[@"Cancel", @"OK"] textFields:@[@"setInputValue value", @"input index"] action:^(NSArray<UITextField *> * _Nullable textFields, NSUInteger buttonIndex) {
        if (buttonIndex == 1 && textFields.count > 1) {
            NSInteger value = [textFields[0].text integerValue];
            NSUInteger index = [textFields[1].text integerValue];
            
            if (value < 0) {
                ShowResult(@"Invalid Parameter");
                return;
            }
            
            [[DemoComponentHelper fetchPayload] setInputValue:value index:index withCompletion:^(NSError * _Nullable error) {
                if (error) {
                    ShowResult(@"setInputValue :%@", error.description);
                } else {
                    ShowResult(@"Success");
                }
            }];
        }
    }];
}

#pragma mark - Convert

+ (NSString *)convertAllWidgetsToString:(NSArray<DJIPayloadWidget *> *)allWidgetStatus {
    NSMutableString *content = [NSMutableString string];
    [allWidgetStatus enumerateObjectsUsingBlock:^(DJIPayloadWidget * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        [content appendFormat:@"%@\n\n", [self convertWidgetToString:obj]];
    }];
    
    return content;
}

+ (NSString *)convertWidgetToString:(DJIPayloadWidget *)obj {
    NSMutableString *content = [NSMutableString string];
    [content appendFormat:@"type: %@ index: %@, name: %@", [self convertWidgetTypeToString:obj.type], @(obj.index), obj.name];
    
    switch (obj.type) {
        case DJIPayloadWidgetTypeList:
            for (NSString *name in obj.list) {
                [content appendFormat:@"\nlist: {\n%@", name];
            }
            [content appendFormat:@"\n}selected: %@", @(obj.selectedListItem)];
            break;
        case DJIPayloadWidgetTypeInput:
            [content appendFormat:@"\ninputValue: %@, tips: %@", @(obj.inputValue), obj.inputHint ? obj.inputHint : @""];
            break;
        case DJIPayloadWidgetTypeRange:
            [content appendFormat:@"\nrange: %@ total: %@", @(obj.percentage.completedUnitCount), @(obj.percentage.totalUnitCount)];
            break;
        case DJIPayloadWidgetTypeButton:
            [content appendFormat:@"\nbuttonStatue: %@ [0(pull) 1(press)]", @(obj.buttonState)];
            break;
        case DJIPayloadWidgetTypeSwitch:
            [content appendFormat:@"\nswitchState: %@ [0(off) 1(on)]", @(obj.switchState)];
            break;
            
        default:
            break;
    }
    
    return content;
}

+ (NSString *)convertWidgetTypeToString:(DJIPayloadWidgetType)type {
    NSString *str = @"Unknown";
    switch (type) {
        case DJIPayloadWidgetTypeInput:
            str = @"Input";
            break;
        case DJIPayloadWidgetTypeList:
            str = @"List";
            break;
        case DJIPayloadWidgetTypeRange:
            str = @"Range";
            break;
        case DJIPayloadWidgetTypeButton:
            str = @"Button";
            break;
        case DJIPayloadWidgetTypeSwitch:
            str = @"Switch";
            break;
            
        default:
            break;
    }
    
    return str;
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
