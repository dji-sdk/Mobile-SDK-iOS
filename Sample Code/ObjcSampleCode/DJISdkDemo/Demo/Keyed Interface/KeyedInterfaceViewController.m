//
//  KeyedInterfaceViewController.m
//  DJISdkDemo
//
//  Created by Arnaud Thiercelin on 2/6/17.
//  Copyright © 2017 DJI. All rights reserved.
//

#import "KeyedInterfaceViewController.h"
#import <DJISDK/DJISDK.h>
#import "DemoUtility.h"
#import <objc/runtime.h>
#import <objc/message.h>
typedef NS_ENUM(NSInteger, SelectType){
    SelectTypeNone = 0,
    SelectTypeComponent,
    SelectTypeSubComponent,
    SelectTypeComponentIndex,
    SelectTypeSubComponentIndex,
    SelectTypeKeyParam,
};
static const NSString *NAString = @"N/A";
@interface KeyedInterfaceViewController ()<DemoSelectViewDelegate>
@property (weak, nonatomic) IBOutlet UILabel *componentLabel;
@property (weak, nonatomic) IBOutlet UILabel *subComponentLabel;
@property (weak, nonatomic) IBOutlet UILabel *componenetIndexLabel;
@property (weak, nonatomic) IBOutlet UILabel *subComponentIndexLabel;
@property (weak, nonatomic) IBOutlet UILabel *keyParamLabel;
@property (weak, nonatomic) IBOutlet UITextView *keyTextView;
@property (weak, nonatomic) IBOutlet UITextView *logTextView;

@property (weak, nonatomic) IBOutlet DemoSelectView *selectView;
@property (strong, nonatomic) NSArray *currentSelectList;
@property (assign, nonatomic) SelectType currentSelectType;

@property (nonatomic, strong) NSString *currentCompont;
@property (nonatomic, strong) NSString *currentSubCompont;
@property (nonatomic, strong) NSString *currentCompontIndex;
@property (nonatomic, strong) NSString *currentSubCompontIndex;
@property (nonatomic, strong) NSString *currentKeyParam;
@property (nonatomic, strong) NSDictionary *keys;
@property (nonatomic, strong) DJIKey *currentKey;
@end

@implementation KeyedInterfaceViewController

- (UIInterfaceOrientation)preferredInterfaceOrientationForPresentation{
    return UIInterfaceOrientationPortrait;
}

- (BOOL)shouldAutorotate{
    return NO;
}
-(instancetype)init {
    self = [super initWithNibName:@"KeyedInterfaceViewController"  bundle:[NSBundle mainBundle]];
    if (self) {
    }
    
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.selectView.delegate = self;
    self.logTextView.editable = NO;
    self.keyTextView.editable = NO;
    _keys = [NSDictionary dictionaryWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"keys" ofType:@"plist"]];
    // Do any additional setup after loading the view from its nib.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self updateLabels];
    self.keyTextView.text = @"How to Create a Key Will Show Here:";
    self.logTextView.text = @"Log will Show Here:";
}

#pragma mark Build Key

- (IBAction)onSelectComponentButtonClicked:(id)sender {
    NSMutableArray* components = [[NSMutableArray alloc] init];
    if ([DemoComponentHelper fetchBattery]) {
        [components addObject:DJIBatteryComponent];
    }
    if ([DemoComponentHelper fetchGimbal]) {
        [components addObject:DJIGimbalComponent];
    }
    if ([DemoComponentHelper fetchCamera]) {
        [components addObject:DJICameraComponent];
    }
    if ([DemoComponentHelper fetchAirLink]) {
        [components addObject:DJIAirLinkComponent];
    }
    if ([DemoComponentHelper fetchFlightController]) {
        [components addObject:DJIFlightControllerComponent];
    }
    if ([DemoComponentHelper fetchRemoteController]) {
        [components addObject:DJIRemoteControllerComponent];
    }
    if ([DemoComponentHelper fetchHandheldController]) {
        [components addObject:DJIHandheldControllerComponent];
    }
    if ([DemoComponentHelper fetchPayload]) {
        [components addObject:DJIPayloadComponent];
    }
    if ([DemoComponentHelper fetchAccessoryAggregation]) {
        [components addObject:DJIAccessoryAggregationComponent];
    }
    self.currentSelectList = [NSArray arrayWithArray:components];
    
    [self showSelectView];
    self.currentSelectType = SelectTypeComponent;
}

- (IBAction)onSelectSubComponentButtonClicked:(id)sender {
    if (!self.currentCompont) {
        ShowResult(@"You Must Select a Componet First!");
        return;
    }
    bool hasSubComponent = NO;
    if ([self.currentCompont isEqualToString: DJIAirLinkComponent]) {
        self.currentSelectList = @[
                                   DJIAirLinkWiFiLinkSubComponent,
                                   DJIAirLinkLightbridgeLinkSubComponent,
                                   DJIAirLinkOcuSyncLinkSubComponent];
        hasSubComponent = YES;
    }else if ([self.currentCompont isEqualToString:DJIFlightControllerComponent]){
        self.currentSelectList = @[
                                   DJIFlightControllerAccessLockerSubComponent,
                                   DJIFlightControllerFlightAssistantSubComponent];
        hasSubComponent = YES;
    }else if ([self.currentCompont isEqualToString:DJIAccessoryAggregationComponent]){
        self.currentSelectList = @[
                                   DJIAccessoryParamBeaconSubComponent,
                                   DJIAccessoryParamSpeakerSubComponent,
                                   DJIAccessoryParamSpotlightSubComponent];
    }
    if (hasSubComponent) {
        [self showSelectView];
        self.currentSelectType = SelectTypeSubComponent;
    }else{
        ShowResult(@"Current component does not have subComponent!");
    }
}

- (IBAction)onSelectComponentIndexButtonClicked:(id)sender {
    NSMutableArray *indexs = [NSMutableArray array];
    if([[DemoComponentHelper fetchProduct] isKindOfClass:[DJIAircraft class]]){
        DJIAircraft *aircraft = (DJIAircraft *)[DemoComponentHelper fetchProduct];
        if ([self.currentCompont isEqualToString:DJICameraComponent]) {
            for (DJICamera *camera in aircraft.cameras) {
                [indexs addObject:[NSString stringWithFormat:@"%ld", camera.index]];
            }
        }else if ([self.currentCompont isEqualToString:DJIGimbalComponent]){
            for (DJIGimbal *gimbal in aircraft.gimbals) {
                [indexs addObject:[NSString stringWithFormat:@"%ld", gimbal.index]];
            }
        }else if ([self.currentCompont isEqualToString:DJIBatteryComponent]){
            for (DJIBattery *battery in aircraft.batteries) {
                [indexs addObject:[NSString stringWithFormat:@"%ld", battery.index]];
            }
        }else if ([self.currentCompont isEqualToString:DJIPayloadComponent]){
            for (DJIPayload *payload in aircraft.payloads) {
                [indexs addObject:[NSString stringWithFormat:@"%ld", payload.index]];
            }
        }
    }
    if (indexs.count > 0) {
        self.currentSelectList = indexs;
        [self showSelectView];
        self.currentSelectType = SelectTypeComponentIndex;
    }else{
        ShowResult(@"Current component index must be 0!");
        self.componenetIndexLabel.text = @"0";
    }
}

- (IBAction)onSelectSubComponentIndexButtonClicked:(id)sender {
    ShowResult(@"Current  subComponent index must be 0!");
    self.subComponentIndexLabel.text = @"0";
}

- (IBAction)onSelectKeyParamButtonClicked:(id)sender {
    if (!_keys) {
        ShowResult(@"Please check Keys.plist");
        return;
    }
    if (!self.currentCompont) {
        ShowResult(@"You must select a component first!");
        return;
    }
    NSArray *currentKeys = _keys[self.currentCompont];
    self.currentSelectList = currentKeys;
    self.currentSelectType = SelectTypeKeyParam;
    [self showSelectView];
}

- (void)showSelectView{
    [self.selectView refresh];
    [self.selectView show];
}

#pragma mark Functions

- (IBAction)onStartListenButtonClicked:(id)sender {
    if (!self.currentKey) {
        ShowResult(@"You must create a DJIKey first!");
        return;
    }
    WeakRef(target);
    [[DJISDKManager keyManager] startListeningForChangesOnKey:self.currentKey withListener:self andUpdateBlock:^(DJIKeyedValue * _Nullable oldValue, DJIKeyedValue * _Nullable newValue) {
        WeakReturn(target);
        NSString *str = [target.logTextView.text stringByAppendingString:[NSString stringWithFormat:@"received value from Key: %@", target.currentKeyParam]];
        if (newValue) {
            //only consider the common type
            if ([newValue.value isKindOfClass:[NSString class]]) {
                str = [NSString stringWithFormat:@"%@, value: %@ \n", str, newValue.stringValue];
            }else{
                str = [NSString stringWithFormat:@"%@, value: %ld\n", str, newValue.integerValue];
            }
        }
        target.logTextView.text = [target.logTextView.text stringByAppendingString:str];
    }];
    ShowResult(@"Start listen to key : %@ successful!", self.currentKeyParam);
    
    self.logTextView.text = @"Key use will Show Here:\n";
    NSString *keyStr = [NSString stringWithFormat:@"[[DJISDKManager keyManager] startListeningForChangesOnKey:key withListener:self andUpdateBlock:^(DJIKeyedValue * _Nullable oldValue, DJIKeyedValue * _Nullable newValue) {\n     do something here\n}];\n"];
    self.logTextView.text = [self.logTextView.text stringByAppendingString:keyStr];
    
}
- (IBAction)onStopListenButtonClicked:(id)sender {
    if (!self.currentKey) {
        ShowResult(@"You must create a DJIKey first!");
        return;
    }
    [[DJISDKManager keyManager] stopListeningOnKey:self.currentKey ofListener:self];
    ShowResult(@"Stop listen to key : %@ successful!", self.currentKeyParam);
    
    self.logTextView.text = @"Key use will Show Here:\n";
    NSString *keyStr = [NSString stringWithFormat:@"[[DJISDKManager keyManager] stopListeningOnKey:key ofListener:self];\n"];
    self.logTextView.text = [self.logTextView.text stringByAppendingString:keyStr];
}

- (IBAction)onGetButtonClicked:(id)sender {
    if (!self.currentKey) {
        ShowResult(@"You must create a DJIKey first!");
        return;
    }
    DJIKeyedValue *value = [[DJISDKManager keyManager] getValueForKey:self.currentKey];
    
    //for sample, we just consider the common type
    if ([value.value isKindOfClass:[NSString class]]) {
        ShowResult([NSString stringWithFormat:@"Get value for key: %@, value:%@", self.currentKeyParam, value.stringValue]);
    }else{
        ShowResult([NSString stringWithFormat:@"Get value for key: %@, value:%ld", self.currentKeyParam, value.integerValue]);
    }
    self.logTextView.text = @"Key use will Show Here:\n";
    NSString *keyStr = [NSString stringWithFormat:@"DJIKeyedValue *value = [[DJISDKManager keyManager] getValueForKey:key];\n"];
    self.logTextView.text = [self.logTextView.text stringByAppendingString:keyStr];
}

- (IBAction)onSetButtonClicked:(id)sender {
    if (!self.currentKey) {
        ShowResult(@"You must create a DJIKey first!");
        return;
    }
    WeakRef(target);
    [DemoAlertView showAlertViewWithMessage:@"" titles:@[@"input"] textFields:@[@"input"] action:^(NSArray<UITextField *> * _Nullable textFields, NSUInteger buttonIndex) {
        WeakReturn(target);
        NSLog(@"Set value: %@", textFields[0].text);
        NSString *input = textFields[0].text;
        id value;
        NSRegularExpression *tNumRegularExpression = [NSRegularExpression regularExpressionWithPattern:@"[0-9]" options:NSRegularExpressionCaseInsensitive error:nil];
        NSUInteger numCount = [tNumRegularExpression numberOfMatchesInString:input
                                                                           options:NSMatchingReportProgress
                                                                             range:NSMakeRange(0, input.length)];
        //for sample, we just consider the common type
        if (numCount == input.length) {
            value = @(textFields[0].text.integerValue);
        }else{
            value = input;
        }
        DJIKey *key = [DJICameraKey keyWithIndex:self.currentCompontIndex.integerValue andParam: DJICameraParamShootPhotoMode];
        if ([self.currentKey isEqual:key]) {
            NSLog(@"equal");
        }
        [[DJISDKManager keyManager] setValue:value forKey:key withCompletion:^(NSError * _Nullable error) {
            if (error) {
                ShowResult(@"Set value for key: %@ failed, error: %@", target.currentKeyParam, error.localizedDescription);
                return;
            }
            ShowResult(@"Set value for key: %@ successful!", self.currentKeyParam);
        }];
    }];
    self.logTextView.text = @"Key use will Show Here:\n";
    NSString *keyStr = [NSString stringWithFormat:@"[[DJISDKManager keyManager] setValue:value forKey:key withCompletion:^(NSError * _Nullable error) {\n          do something here\n}];"];
    self.logTextView.text = [self.logTextView.text stringByAppendingString:keyStr];
}
- (IBAction)onActionButtonClicked:(id)sender {
    if (!self.currentKey) {
        ShowResult(@"You must create a DJIKey first!");
        return;
    }
    WeakRef(target);
    [[DJISDKManager keyManager] performActionForKey:self.currentKey withArguments:nil andCompletion:^(BOOL finished, DJIKeyedValue * _Nullable response, NSError * _Nullable error) {
        WeakReturn(target);
        if (error) {
            ShowResult(@"Perform action for key: %@ failed, error: %@", target.currentKeyParam, error.localizedDescription);
            return;
        }
        ShowResult(@"Perform action for key: %@ successful!");
    }];
    self.logTextView.text = @"Key use will Show Here:\n";
    NSString *keyStr = [NSString stringWithFormat:@"[[DJISDKManager keyManager] performActionForKey:key withArguments:params andCompletion:^(BOOL finished, DJIKeyedValue * _Nullable response, NSError * _Nullable error) {\n        do something here\n}];"];
    self.logTextView.text = [self.logTextView.text stringByAppendingString:keyStr];
}

#pragma mark DemoSelectViewDelegate
- (NSArray *)selectTableList{
    return self.currentSelectList;
}

- (void)selectView:(DemoSelectView *)selectView selectIndex:(NSInteger)index{
    switch (_currentSelectType) {
        case SelectTypeComponent:{
            if (self.currentCompont == self.currentSelectList[index]) {
                break;
            }
            self.currentCompont = self.currentSelectList[index];
            self.currentSubCompont = nil;
            self.currentCompontIndex = nil;
            self.currentCompontIndex = nil;
            self.currentSubCompontIndex = nil;
            self.currentKeyParam = nil;
            self.currentKey = nil;
        }
            break;
        case SelectTypeSubComponent:{
            if (self.currentSubCompont == self.currentSelectList[index]) {
                break;
            }
            self.currentSubCompont = self.currentSelectList[index];
            self.currentCompontIndex = nil;
            self.currentCompontIndex = nil;
            self.currentKeyParam = nil;
            self.currentKey = nil;
        }
            break;
        case SelectTypeComponentIndex:{
            self.currentCompontIndex = self.currentSelectList[index];
        }
            break;
        case SelectTypeSubComponentIndex:{
            self.currentSubCompontIndex = self.currentSelectList[index];
        }
            break;
        case SelectTypeKeyParam:{
            NSString *keyParam = self.currentSelectList[index];
            if (self.currentSubCompont) {
                //lowercase the strings to check if contain subComponent
                if(![keyParam.lowercaseString containsString:self.currentSubCompont.lowercaseString]){
                    ShowResult(@"Current key param is invalid for current subComponet!");
                    break;
                }
            }
            self.currentKeyParam = keyParam;
        }
            break;
        default:
            break;
    }
    [self updateLabels];
    [self updateKeyTextView];
}

- (void)updateLabels{
    self.componentLabel.text = self.currentCompont ?: NAString;
    self.subComponentLabel.text = self.currentSubCompont ?: NAString;
    self.componenetIndexLabel.text = self.currentCompontIndex ?: NAString;
    self.subComponentIndexLabel.text = self.currentSubCompontIndex ?: NAString;
    self.keyParamLabel.text = self.currentKeyParam ?: NAString;
}
#pragma mark Create Key
- (void)updateKeyTextView{
    if (!self.currentCompont || !self.currentKeyParam ) {
        self.keyTextView.text = @"Key create will show here:";
        return;
    }
    if (!self.currentCompontIndex) {
        self.currentCompontIndex = @"0";
    }
    if (self.currentSubCompont) {
        self.currentSubCompontIndex = @"0";
    }
    self.currentKey = [self createKey];
    if (!self.currentKey) {
        return;
    }
    NSString *keyStr = @"Key create will show here:\n";
    if (!self.currentSubCompont) {
        keyStr = [keyStr stringByAppendingString:[NSString stringWithFormat:@"DJIKey *key = [%@ keyWithIndex:%ld andParam:%@];",
                  NSStringFromClass(self.currentKey.class),
                  self.currentKey.index,
                  self.currentKeyParam]];
    }else{
        keyStr = [keyStr stringByAppendingString:[NSString stringWithFormat:@"DJIKey *key = [%@ keyWithIndex:%ld subComponent:%@ subComponentIndex:%ld andParam:%@];",
                  NSStringFromClass([self.currentKey class]),
                  self.currentKey.index,
                  self.currentKey.subComponent,
                  self.currentKey.subComponentIndex,
                  self.currentKeyParam]];
    }
    self.keyTextView.text = keyStr;
}

- (DJIKey *)createKey{
    NSString *clsName = [NSString stringWithFormat:@"DJI%@Key", [self upperFirstCharForString:self.currentCompont]];
    Class cls = NSClassFromString(clsName);
    SEL sel = NSSelectorFromString(@"keyWithIndex:andParam:");
    NSString *innerKeyParam = [self innerKeyParam:self.currentKeyParam];
    if (self.currentSubCompont) {
        sel = NSSelectorFromString(@"keyWithIndex:subComponent:subComponentIndex:andParam:");
    }
    if (![cls respondsToSelector:sel]) {
        ShowResult(@"current Key is Invaild!");
        self.currentKeyParam = nil;
        [self updateLabels];
        return nil;
    }
    DJIKey *key = ((id (*)(id, SEL, NSInteger, NSString *))objc_msgSend)(cls, sel, self.currentCompontIndex.integerValue, innerKeyParam);
    if (self.currentSubCompont) {
        key = ((id (*)(id, SEL, NSInteger, NSString *, NSInteger, NSString *))objc_msgSend)(cls, sel, self.currentCompontIndex.integerValue, self.currentSubCompont, self.currentSubCompontIndex.integerValue, innerKeyParam);
    }
    return key;

}

- (NSString *)innerKeyParam:(NSString *)key{
    NSRange range = [key rangeOfString:@"Param"];
    NSString *innerKeyParam = [key substringFromIndex:(range.location + range.length)];
    return innerKeyParam;
}

- (NSString *)upperFirstCharForString:(NSString *)from{
    NSString *firstChar = [from substringToIndex:1].uppercaseString;
    NSString *upperFirstString = [firstChar stringByAppendingString:[from substringFromIndex:1]];
    return upperFirstString;
}
@end
