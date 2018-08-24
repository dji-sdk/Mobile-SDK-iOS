//
//  DemoTableViewController.m
//  DJISdkDemo
//
//  Copyright © 2015 DJI. All rights reserved.
//

#import "DemoTableViewController.h"
#import "DemoSettingItem.h"

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
    UIViewController * vc = [[item.viewControllerClass alloc] init];
    vc.title = item.itemName;
    [self.navigationController pushViewController:vc animated:YES];
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 30;
}

@end
