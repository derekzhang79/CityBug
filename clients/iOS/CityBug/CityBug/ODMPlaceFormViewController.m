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
    NSUInteger cooldownSearchCount;
    NSArray *_filteredDatasoruce;
    UIView *_loadingView;
}

- (NSArray *)arrayForTableView:(UITableView *)tableView
{
    if (self.isActive) {
        return _filteredDatasoruce;
    }
    return self.datasource;
}

- (NSString *)keyForSection:(NSUInteger)section
{
    switch (section) {
        case 0:
            return @"suggested";
            break;
        default:
            return @"additional";
            break;
    }
    return nil;
}

- (ODMPlace *)placeFromIndexPath:(NSIndexPath *)indexPath forTableView:(UITableView *)tableView
{
    NSArray *sections = [[self arrayForTableView:tableView] objectAtIndex:indexPath.section];
    return [sections objectAtIndex:indexPath.row];
}

#pragma mark - TABLEVIEW

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return [[self arrayForTableView:tableView] count];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if ([[self arrayForTableView:tableView] count] == 0) return 0;
    
    NSArray *sectionItems = [[self arrayForTableView:tableView] objectAtIndex:section];
    return [sectionItems count];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{    
    if ([self.delegate respondsToSelector:@selector(didSelectPlace:)]) {
        [self.delegate didSelectPlace:[self placeFromIndexPath:indexPath forTableView:tableView]];
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
    
    cell.textLabel.text = [(ODMPlace *)[self placeFromIndexPath:indexPath forTableView:tableView] title];
    
    return cell;
}

#pragma mark - SEARCH

- (void)cooldownSearch:(NSTimer *)timer
{
    if (--cooldownSearchCount == 0) {
        [timer invalidate];
    }
}

- (void)searchBarTextDidBeginEditing:(UISearchBar *)searchBar
{
    [self setActive:YES];
    
    [self.actView setHidden:NO];
    [self.guideView setHidden:NO];
}

- (void)searchBarTextDidEndEditing:(UISearchBar *)searchBar
{
    [self.guideView setHidden:YES];
}

- (void)searchBarCancelButtonClicked:(UISearchBar *)searchBar
{
    [self resignFirstResponder];
    [self.actView setHidden:YES];
    [self.guideView setHidden:YES];
    [self.noResultView setHidden:YES];
}

- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar
{
    [searchBar resignFirstResponder];
    [self.actView setHidden:NO];
    [self.guideView setHidden:YES];
    
    NSDictionary *params = [NSDictionary dictionaryWithObject:searchBar.text forKey:@"text"];
    
    [[ODMDataManager sharedInstance] placesWithQueryParams:params];
}

/*
 * Actve flag
 * Use to determine state of a search view
 */
- (void)setActive:(BOOL)active
{
    // show Cancel button with animation
    [self.searchBar setShowsCancelButton:active animated:YES];
    
    // hide navigation bar
    [self.navigationController setNavigationBarHidden:active animated:YES];
    // show guide view
    [self.guideView setHidden:!active];
    
    _isActive = active;
    
    [self.tableView reloadData];
}

#pragma mark - VIEW

- (void)updatePlacesNotification:(NSNotification *)notification
{
    if ([[notification object] isKindOfClass:[NSArray class]]) {
        
        _datasource = [NSArray arrayWithArray:[notification object]];
        
        if (!self.isActive) {
            [self.noResultView setHidden:_datasource.count > 0 ? YES : NO];
            [self.actView setHidden:YES];
            [self.guideView setHidden:YES];
            
            [self.tableView reloadData];
        }
    }
}

- (void)updatePlacesSearchingNotification:(NSNotification *)notification
{
    if ([[notification object] isKindOfClass:[NSArray class]]) {
        
        _filteredDatasoruce = [NSArray arrayWithArray:[notification object]];
        
        if (self.isActive) {
            if (_filteredDatasoruce.count > 0) {
                [self.noResultView setHidden:YES];
                [self.searchBar resignFirstResponder];
            } else {
                [self.noResultView setHidden:NO];
                [self.searchBar becomeFirstResponder];
            }
            
            [self.actView setHidden:YES];
            [self.guideView setHidden:YES];
            
            [self.tableView reloadData];
        }
    }
}

- (BOOL)resignFirstResponder
{    
    [self setActive:NO];
    
    [self.searchBar resignFirstResponder];
    
    return [super resignFirstResponder];
}

- (void)reloadData
{
    _datasource = [[ODMDataManager sharedInstance] places];
    _filteredDatasoruce = [NSArray new];
    
    // show loading view and also make sure to guideView should be hidden
    [self.actView setHidden:NO];
    [self.guideView setHidden:YES];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(updatePlacesNotification:)
                                                 name:ODMDataManagerNotificationPlacesLoadingFinish
                                               object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(updatePlacesSearchingNotification:)
                                                 name:ODMDataManagerNotificationPlacesSearchingFinish
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(reloadData)
                                                 name:ODMDataManagerNotificationLocationDidUpdate
                                               object:nil];
    [self reloadData];
}

- (void)viewDidUnload
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    
    [super viewDidUnload];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    
    // hide navigation bar
    [self.navigationController setNavigationBarHidden:NO animated:YES];
}

@end
