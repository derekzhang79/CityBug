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
            return @"suggested_place";
            break;
        default:
            return @"additional_place";
            break;
    }
    return nil;
}

- (ODMPlace *)placeFromIndexPath:(NSIndexPath *)indexPath
{
    NSArray *sections = [self.datasource objectAtIndex:indexPath.section];
    return [sections objectAtIndex:indexPath.row];
}

#pragma mark - TABLEVIEW

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return [self.datasource count];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    NSArray *sectionItems = [self.datasource objectAtIndex:section];
    return [sectionItems count];
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
    if (searchText.length >= LOCATION_SEARCH_THRESHOLD) {
        NSDictionary *params = [NSDictionary dictionaryWithObject:searchText forKey:@"title"];
    
        [[ODMDataManager sharedInstance] placesWithQueryParams:params];
    }
}

- (void)searchBarCancelButtonClicked:(UISearchBar *)searchBar
{
    [self reloadData];
}

#pragma mark - VIEW

- (void)updatePlacesNotification:(NSNotification *)notification
{
    if ([[notification object] isKindOfClass:[NSArray class]]) {
        _datasource = [NSArray arrayWithArray:[notification object]];
    }
    
    [self.searchDisplayController.searchResultsTableView reloadData];
    [self.tableView reloadData];
}

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
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(updatePlacesNotification:)
                                                 name:ODMDataManagerNotificationPlacesLoadingFinish
                                               object:nil];
    [self reloadData];
}

@end
