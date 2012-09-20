//
//  ODMPlaceFormViewController.m
//  CityBug
//
//  Created by InICe on 20/9/2555.
//  Copyright (c) พ.ศ. 2555 opendream. All rights reserved.
//

#import "ODMPlaceFormViewController.h"
#import "ODMDataManager.h"
#import "ODMPlace.h"

@implementation ODMPlaceFormViewController {
    NSIndexPath *selectedIndexPath;
}

- (NSString *)keyForSection:(NSUInteger)section
{
    switch (section) {
        case 0:
            return @"suggestion_place";
            break;
        default:
            return @"additional_place";
            break;
    }
    return nil;
}

- (ODMPlace *)placeFromIndexPath:(NSIndexPath *)indexPath
{
    NSDictionary *sectionObject = [self.datasource objectAtIndex:indexPath.section];
    NSArray *itemsInSection = [sectionObject objectForKey:[self keyForSection:indexPath.section]];
    return [itemsInSection objectAtIndex:indexPath.row];
}

#pragma mark - TABLEVIEW

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return [self.datasource count];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    NSDictionary *sectionObject = [self.datasource objectAtIndex:section];
    NSArray *itemsInSection = [sectionObject objectForKey:[self keyForSection:section]];
    
    return [itemsInSection count];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{    
    if ([self.delegate respondsToSelector:@selector(didSelectPlace:)]) {
        [self.delegate didSelectPlace:[self placeFromIndexPath:indexPath]];
    }
    
    [self.navigationController popViewControllerAnimated:YES];
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    // get title string from section key path
    NSString *titleHeader = [self keyForSection:section];
    
    // replace underscore (_) with white space
    titleHeader = [titleHeader stringByReplacingOccurrencesOfString:@"_" withString:@" "];
    
    // capitalize string
    return [titleHeader capitalizedString];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"PlaceCellIdentifier";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    }
    
    cell.textLabel.text = [(ODMPlace *)[self placeFromIndexPath:indexPath] title];
    
    return cell;
}

#pragma mark - SEARCH

- (void)searchBarTextDidEndEditing:(UISearchBar *)searchBar
{
    [self resignFirstResponder];
}

- (void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText
{
    // handle search event
}

#pragma mark - VIEW

- (BOOL)resignFirstResponder
{
    [self.searchDisplayController.searchBar resignFirstResponder];
    
    return YES;
}

- (void)reloadData
{
    _datasource = [[ODMDataManager sharedInstance] places];
    
    [self.tableView reloadData];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [self reloadData];
}

@end
