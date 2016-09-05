//
//  BluetoothConnectorViewController.m
//  DJISdkDemo
//
//  Copyright © 2016 DJI. All rights reserved.
//

#import "BluetoothConnectorViewController.h"
#import <Corebluetooth/CoreBluetooth.h>
#import "DemoUtility.h"
#import <DJISDK/DJISDK.h>

static NSString* const BluetoothCellReuseKey = @"BluetoothCellReuseKey";

@interface BluetoothConnectorViewController ()<UITableViewDelegate, UITableViewDataSource, DJIBluetoothProductConnectorDelegate>

@property (weak, nonatomic) IBOutlet UIButton *searchButton;
@property (weak, nonatomic) IBOutlet UIButton *connectionButton;
@property (weak, nonatomic) IBOutlet UITableView *tableView;

@property(nonatomic, strong) NSMutableArray<CBPeripheral *> *bluetoothProducts;
@property(nonatomic, assign) NSUInteger selectedIndex;
@property(nonatomic, weak, readonly) DJIBluetoothProductConnector* bluetoothConnector;

@end

@implementation BluetoothConnectorViewController

-(DJIBluetoothProductConnector *)bluetoothConnector {
    return [DJISDKManager bluetoothConnector];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    _tableView.delegate = self;
    _tableView.dataSource = self;

    self.bluetoothProducts = [NSMutableArray new];
    self.selectedIndex = 0;
    self.bluetoothConnector.delegate = self;
    [self updateConnectionButtonUI];
}

- (IBAction)onSearchBluetoothButtonClicked:(id)sender
{
    [self.bluetoothConnector searchBluetoothProductsWithCompletion:^(NSError * _Nullable error) {
        if (error)
            ShowResult(@"Search Bluetooth product failed:%@", error.description);
    }];
}

-(void)updateConnectionButtonUI {
    if ([self isBluetoothProductConnected]) {
        [self.connectionButton setTitle:@"Disconnect" forState:UIControlStateNormal];
    }
    else {
        [self.connectionButton setTitle:@"Connect" forState:UIControlStateNormal];
    }
}

- (IBAction)onConnectionButtonClicked:(id)sender
{
    if ([self isBluetoothProductConnected]) {
        [self disconnectBluetooth];
    }
    else {
        [self connectBluetooth];
    }
}

-(void)connectBluetooth {
    WeakRef(target);
    if (!self.bluetoothProducts || self.bluetoothProducts.count == 0) {
        ShowResult(@"No Bluetooth products found. ");
        return;
    }

    [self.bluetoothConnector connectProduct:[self.bluetoothProducts objectAtIndex:self.selectedIndex] withCompletion:^(NSError * _Nullable error) {
        if (error) {
            NSLog(@"connect error:%@", error.description);
        } else {
            [target.bluetoothProducts removeAllObjects];
            [target.tableView reloadData];
            [target.connectionButton setTitle:@"Disconnect" forState:UIControlStateNormal];
        }
    }];
}

- (void)disconnectBluetooth
{
    WeakRef(target);
    [self.bluetoothConnector disconnectProductWithCompletion:^(NSError * _Nullable error) {
        if (error) {
            NSLog(@"disconnect error:%@", error.description);
        } else {
            [target.connectionButton setTitle:@"Connect" forState:UIControlStateNormal];
        }
    }];
}

-(BOOL)isBluetoothProductConnected {
    DJIBaseProduct *product = [DJISDKManager product];
    if (product) {
        if ([product.model isEqual:DJIHandheldModelNameOsmoMobile]) {
            return YES;
        }
    }
    return NO;
}

#pragma mark DJIBluetoothProductConnectorDelegate

- (void)connectorDidFindProducts:(NSArray<CBPeripheral *> *)peripherals
{
    self.bluetoothProducts = [NSMutableArray arrayWithArray:peripherals];
    [self.tableView reloadData];
}


#pragma mark UITableViewDelegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    self.selectedIndex = indexPath.row;
}

#pragma mark UITableViewDataSource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.bluetoothProducts.count;
}

- (UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell* cell = [tableView dequeueReusableCellWithIdentifier:BluetoothCellReuseKey];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:BluetoothCellReuseKey];
    }
    
    CBPeripheral* peripheral = [self.bluetoothProducts objectAtIndex:indexPath.row];
    if (peripheral) {
        cell.textLabel.text = peripheral.name ? peripheral.name : @"null";
        if (peripheral.state == CBPeripheralStateConnected) {
            cell.textLabel.backgroundColor = [UIColor colorWithRed:0 green:0 blue:1 alpha:0.2];
        } else {
            cell.textLabel.backgroundColor = [UIColor whiteColor];
        }
    }
    return cell;
}

@end
