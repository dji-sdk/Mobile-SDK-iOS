//
//  DemoTableViewController.m
//  DJISdkDemo
//
//  Copyright © 2015 DJI. All rights reserved.
//

#import "DemoTableViewController.h"
#import "DemoSettingItem.h"
#import "WaypointV2ViewController.h"
#import "CameraActionsTableViewController.h"

@interface DemoTableViewController ()

@end

@implementation DemoTableViewController

-(instancetype)init {
    self = [super initWithStyle:UITableViewStyleGrouped];
    if (self) {
        _sectionNames = [[NSMutableArray alloc] init];
        _items = [[NSMutableArray alloc] init];
        self.tableView.rowHeight = 50;
    }
    
    return self;
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    if (self.sectionNames.count == 0) {
        return 1;
    }
    else
        return self.sectionNames.count;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (self.sectionNames.count == 0) {
        return self.items.count;
    }
    else {
        return ((NSMutableArray*)self.items[section]).count;
    }
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    if (self.sectionNames.count == 0) {
        return nil;
    }
    return [self.sectionNames objectAtIndex:section];
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    static NSString *CellIdentifier = @"Cell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
    }
    
    NSInteger section = [indexPath section];
    NSInteger row = [indexPath row];
    DemoSettingItem* item = nil;
    if (self.sectionNames.count == 0) {
        item = [self.items objectAtIndex:row];
    }
    else {
        item = [[self.items objectAtIndex:section] objectAtIndex:row];
    }
    
    [cell.textLabel setText:item.itemName];
    [cell setAccessoryType:UITableViewCellAccessoryDisclosureIndicator];
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    // Navigation logic may go here. Create and push another view controller.

    NSInteger section = [indexPath section];
    NSInteger row = [indexPath row];
    
    DemoSettingItem* item = nil;
    if (self.sectionNames.count == 0) {
        item = [self.items objectAtIndex:row];
    }
    else {
        item = [[self.items objectAtIndex:section] objectAtIndex:row];
    }
    
    if ([item.viewControllerClass isEqual:[WaypointV2ViewController class]]) {
        UIStoryboard *waypointV2Board = [UIStoryboard storyboardWithName:@"WaypointV2" bundle:[NSBundle mainBundle]];
        WaypointV2ViewController *wp2vc = [waypointV2Board instantiateViewControllerWithIdentifier:@"WaypointV2VC"];
        [self.navigationController pushViewController:wp2vc animated:YES];
        return;
    }
    
    if ([item.viewControllerClass isEqual:[CameraActionsTableViewController class]]) {
        [[NSUserDefaults standardUserDefaults] setObject:item.itemName forKey:@"currentCameraName"];
        CameraActionsTableViewController *vc = [[CameraActionsTableViewController alloc] init];
        [self.navigationController pushViewController:vc animated:YES];
        return;
    }

    UIViewController * vc = [[item.viewControllerClass alloc] init];
    vc.title = item.itemName;
    [self.navigationController pushViewController:vc animated:YES];
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 30;
}

@end
