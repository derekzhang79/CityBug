//
//  ODMMySubscribeViewController.m
//  CityBug
//
//  Created by Pirapa on 10/3/12.
//  Copyright (c) 2012 opendream. All rights reserved.
//

#import "ODMMySubscribeViewController.h"
#import "ODMDataManager.h"

@interface ODMMySubscribeViewController ()

@end

@implementation ODMMySubscribeViewController {
    NSArray *dataSource;
}

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(updateMySubscription:)
                                                 name:ODMDataManagerNotificationMySubscriptionLoadingFinish
                                               object:nil];
    dataSource = [NSArray new];
    dataSource = [[ODMDataManager sharedInstance] mySubscriptions];

}

- (void)viewDidUnload
{
    [super viewDidUnload];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [super viewWillDisappear:animated];
    
}

- (void)updateMySubscription:(NSNotification *)notification
{
    if ([[notification object] isKindOfClass:[NSArray class]]) {
        dataSource = [NSArray arrayWithArray:notification.object];
    }
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return dataSource.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"PlaceCellIdentifier";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    
    cell.detailTextLabel.text = [[dataSource objectAtIndex:indexPath.row] objectForKey:@"title"];
    
    return cell;
}


@end
