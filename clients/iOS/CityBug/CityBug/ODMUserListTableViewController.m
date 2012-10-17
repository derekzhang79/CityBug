//
//  ODMUserListTableViewController.m
//  CityBug
//
//  Created by tua~* on 10/10/55 BE.
//  Copyright (c) 2555 opendream. All rights reserved.
//

#import "ODMUserListTableViewController.h"
#import "ODMDataManager.h"
#import "ODMUser.h"
#import "UIImageView+WebCache.h"
#import <QuartzCore/QuartzCore.h>

@interface ODMUserListTableViewController ()
@property (nonatomic, readwrite, strong) NSArray *datasource;
@end

@implementation ODMUserListTableViewController

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
    }
    return self;
}


- (void)reloadData
{
    _datasource = [[ODMDataManager sharedInstance] iminUsersWithReport:self.report];
    
    [self.tableView reloadData];
}

- (void)updateUsersNotification:(NSNotification *)notification
{
    if ([[notification object] isKindOfClass:[NSArray class]]) {
        _datasource = [notification object];
        
        [self.tableView reloadData];
    }
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self reloadData];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(updateUsersNotification:)
                                                 name:ODMDataManagerNotificationIminUsersLoadingFinish
                                               object:nil];
}

- (void)viewDidUnload
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    
    [super viewDidUnload];
}


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [self.datasource count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"UserCellIdentifier";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
        cell.imageView.image = [UIImage imageNamed:@"1.jpeg"];
        cell.textLabel.text = NSLocalizedString(@"Unknown String", @"Unknown String");
    }
    
    if (self.datasource.count > indexPath.row) {
        
        ODMUser *user = [self.datasource objectAtIndex:indexPath.row];
        
        cell.textLabel.text = [user username];
        if (user.thumbnailImage != nil) {
            NSURL *avatarURL = [NSURL URLWithString:[NSString stringWithFormat:@"%@%@", BASE_URL, user.thumbnailImage]];
            [cell.imageView setImageWithURL:avatarURL placeholderImage:[UIImage imageNamed:@"1.jpeg"] options:SDWebImageCacheMemoryOnly];
        } else {
            [cell.imageView setImage:[UIImage imageNamed:@"1.jpeg"]];
        }
    }
    
    return cell;
}



@end
