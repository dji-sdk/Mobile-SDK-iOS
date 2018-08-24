//
//  DemoComponentActionTableViewController.m
//  DJISdkDemo
//
//  Copyright © 2015 DJI. All rights reserved.
//
#import <DJISDK/DJISDK.h>
#import "DemoUtility.h"
#import "DemoComponentActionTableViewController.h"

@interface DemoComponentActionTableViewController ()

@property(nonatomic, strong) UIView* infoView;
@property(nonatomic, strong) UILabel* serialVersionLabel;
@property(nonatomic, strong) UILabel* snLabel;

@end

@implementation DemoComponentActionTableViewController

-(instancetype)init {
    self = [super init];
    if (self) {
        _infoView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.tableView.bounds.size.width, 40)];
        _serialVersionLabel = [[UILabel alloc] initWithFrame: self.infoView.bounds];
        _serialVersionLabel.textColor = [UIColor colorWithWhite:0.5 alpha:1.0];
        _serialVersionLabel.font = [UIFont italicSystemFontOfSize:10];
        _serialVersionLabel.numberOfLines = 0;
        _serialVersionLabel.textAlignment = NSTextAlignmentCenter;
        [self updateInfoView];
        [_infoView addSubview:self.serialVersionLabel];
    }
    
    return self;
}

-(void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    DJIBaseComponent* component = [self getComponent];
    if (component) {
        WeakRef(target);
        [component getFirmwareVersionWithCompletion:^(NSString * _Nullable version, NSError * _Nullable error) {
            WeakReturn(target);
            if (error == nil) {
                target.version = version;
            }
            else
            {
                target.version = nil;
            }
        }];
        [component getSerialNumberWithCompletion:^(NSString * _Nullable serialNumber, NSError * _Nullable error) {
            WeakReturn(target);
            if (error == nil) {
                target.serialNumber = serialNumber;
            }
            else
            {
                target.serialNumber = nil;
            }
        }];
    }
}

-(void) setVersion:(NSString *)version
{
    _version = version;
    [self updateInfoView];
}

-(void) setSerialNumber:(NSString *)serialNumber
{
    _serialNumber = serialNumber;
    [self updateInfoView];
}

- (void) updateInfoView
{
    if (!self.tableView.tableFooterView) {
        self.tableView.tableFooterView = self.infoView;
    }
    
    NSMutableArray * tempArray = [NSMutableArray array];
    if (self.version) {
        [tempArray addObject:[NSString stringWithFormat:@"Firmware Version: %@", self.version]];
    }
    if (self.serialNumber) {
        [tempArray addObject:[NSString stringWithFormat:@"Serial Number: %@", self.serialNumber]];
    }
    _serialVersionLabel.text = [tempArray componentsJoinedByString:@"   "];
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section
{
    return 1.0;
}

#pragma mark - Override Methods
-(DJIBaseComponent *)getComponent {
    return nil;
}


@end
