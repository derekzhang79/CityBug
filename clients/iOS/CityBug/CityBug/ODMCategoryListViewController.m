//
//  ODMCategoryListViewController.m
//  CityBug
//
//  Created by InICe on 14/9/2555.
//  Copyright (c) พ.ศ. 2555 opendream. All rights reserved.
//

#import "ODMCategoryListViewController.h"
#import "ODMCategory.h"
#import "ODMDataManager.h"

@interface ODMCategoryListViewController(Accessor)
@property (nonatomic, readwrite, strong) NSArray *datasource;
@end

@implementation ODMCategoryListViewController {
    NSString *catString;
}

#pragma mark - SAVE

- (IBAction)save:(id)sender
{
    if ([self.delegate respondsToSelector:@selector(updateCategoryList:withCategory:)]) {
        if (catString.length < 1) {
            catString = @"Category 1";
        }
        [self.delegate updateCategoryList:self withCategory:catString];
    }
    
    [self.navigationController popViewControllerAnimated:YES];
}

#pragma mark - TABLEVIEW

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [self.datasource count];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"CategoryCellIdentifier";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
        cell.imageView.image = [UIImage imageNamed:@"cat1.png"];
        cell.textLabel.text = NSLocalizedString(@"Unknown String", @"Unknown String");
    }

    if (self.datasource.count > indexPath.row) {
        
        ODMCategory *cat = [self.datasource objectAtIndex:indexPath.row];
        
        cell.textLabel.text = [cat title];
    }
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = (UITableViewCell *)[tableView cellForRowAtIndexPath:indexPath];
    catString = cell.textLabel.text;
    
    if ([self.delegate respondsToSelector:@selector(updateCategoryList:withCategory:)]) {
        [self.delegate updateCategoryList:self withCategory:catString];
    }
    
    [self.navigationController popViewControllerAnimated:YES];
}


#pragma mark - VIEW

- (void)reloadData
{
    _datasource = [[ODMDataManager sharedInstance] categories];
    
    [self.tableView reloadData];
}

- (void)viewDidAppear:(BOOL)animated
{
    [self reloadData];
}

@end
