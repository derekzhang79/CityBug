//
//  ODMMySubscribeViewController.m
//  CityBug
//
//  Created by Pirapa on 10/3/12.
//  Copyright (c) 2012 opendream. All rights reserved.
//

#import "ODMMySubscribeViewController.h"
#import "ODMDataManager.h"
#import "ODMPlace.h"
#import "ODMExplorePlaceDetailViewController.h"

#define goToPlaceViewSegue @"goToPlaceViewSegue"

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
    

}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    dataSource = [NSArray new];
    if ([[ODMDataManager sharedInstance] isAuthenticated]) {
        dataSource = [[ODMDataManager sharedInstance] mySubscriptions];
    }
    [self.tableView reloadData];

}

- (void)viewDidUnload
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [self setTableView:nil];
    [super viewDidUnload];
}


- (void)updateMySubscription:(NSNotification *)notification
{
    if ([[notification object] isKindOfClass:[NSArray class]]) {
        dataSource = [NSArray arrayWithArray:notification.object];
        [self.tableView reloadData];

        NSLog(@"count %d", dataSource.count);
        
    }
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    NSLog(@"count %d", dataSource.count);
    return dataSource.count;
}

- (UITableViewCell *)tableView:(UITableView *)aTableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"subscriptionCellIdentifier";
    UITableViewCell *cell = [aTableView dequeueReusableCellWithIdentifier:CellIdentifier];
    
    cell.textLabel.text = ((ODMPlace *)[dataSource objectAtIndex:indexPath.row]).title;
    
    return cell;
}


#pragma mark - segue

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.identifier isEqualToString:goToPlaceViewSegue]) {
        
        ODMExplorePlaceDetailViewController *detailViewController = (ODMExplorePlaceDetailViewController *)segue.destinationViewController;
        NSIndexPath *selectedIndexPath = [self.tableView indexPathForCell:(UITableViewCell *)sender];
        ODMPlace *aPlace = [dataSource objectAtIndex:selectedIndexPath.row];
        detailViewController.place = aPlace;
    }
}

@end
