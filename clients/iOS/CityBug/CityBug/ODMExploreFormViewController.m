//
//  ODMPlaceFormViewController.m
//  CityBug
//
//  Created by InICe on 20/9/2555.
//  Copyright (c) พ.ศ. 2555 opendream. All rights reserved.
//

#import "ODMExploreFormViewController.h"
#import "ODMExplorePlaceDetailViewController.h"
#import "ODMDataManager.h"
#import "ODMPlace.h"
#import "ODMPlaceViewCell.h"

#define goToPlaceViewSegue @"goToPlaceViewSegue"

@implementation ODMExploreFormViewController {
    NSIndexPath *selectedIndexPath;
    NSUInteger cooldownSearchCount;
    NSArray *_filteredDatasource;
    UIView *_loadingView;
    
    ODMPlace *selectedPlace;
}

- (NSArray *)arrayForTableView:(UITableView *)tableView
{
    if (self.isActive) {
        return _filteredDatasource;
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
    ODMPlaceViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    
    if (!cell) {
        cell = [[ODMPlaceViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    }
    ODMPlace *place = (ODMPlace *)[self placeFromIndexPath:indexPath forTableView:tableView];
    cell.place = place;
    
    if (place.isSubscribed == YES) {
        cell.subscribeStatusImageView.image = [UIImage imageNamed:@"star_active"];
    } else {
        cell.subscribeStatusImageView.image = [UIImage imageNamed:@"star_inactive"];
    }
    
    return cell;
}

#pragma mark - segue

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.identifier isEqualToString:goToPlaceViewSegue]) {
        
        ODMExplorePlaceDetailViewController *detailViewController = (ODMExplorePlaceDetailViewController *)segue.destinationViewController;
        self.delegate = detailViewController;
        NSIndexPath *selectedIndexPath = [self.tableView indexPathForCell:(UITableViewCell *)sender];
        selectedPlace = [self placeFromIndexPath:selectedIndexPath forTableView:self.tableView];
        detailViewController.place = selectedPlace;
    }
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
    [self setActive:NO];
    [self.searchBar resignFirstResponder];
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

// Update tp explore place detail view
- (void)checkUpdatePlaceFromDatasource:(NSArray *)datasource
{
    if (selectedPlace == nil)
        return;
    
    for (int i=0; i<datasource.count; i++) {
        NSArray *placeArray = [datasource objectAtIndex:i];
        for (int j=0; j<placeArray.count; j++) {
            //NSLog([NSString stringWithFormat:@"[placeArray objectAtIndex:j] %@", [[placeArray objectAtIndex:j] class]]);
            ODMPlace *datasourcePlace = [placeArray objectAtIndex:j];
            if ([datasourcePlace.uid isEqualToString:selectedPlace.uid]) {
                if ([self.delegate respondsToSelector:@selector(updatePlace:withPlace:)]) {
                    [self.delegate updatePlace:self withPlace:datasourcePlace];
                }
                return;
            }
        }
    }
}

- (void)updatePlacesNotification:(NSNotification *)notification
{
    if ([[notification object] isKindOfClass:[NSArray class]]) {
        
        _datasource = [NSArray arrayWithArray:[notification object]];
        [self checkUpdatePlaceFromDatasource:_datasource];
        
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
        
        _filteredDatasource = [NSArray arrayWithArray:[notification object]];
        [self checkUpdatePlaceFromDatasource:_filteredDatasource];
        
        if (self.isActive) {
            if (_filteredDatasource.count > 0) {
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
    if (self.searchBar.text.length == 0) {
        [self setActive:NO];
    }
    
    [self.searchBar resignFirstResponder];
    
    return [super resignFirstResponder];
}

- (void)reloadData
{
    _datasource = [[ODMDataManager sharedInstance] places];
    
    NSString *searchText = @"";
    if (self.searchBar.text != nil) {
        searchText = self.searchBar.text;
    }
    NSDictionary *params = [NSDictionary dictionaryWithObject:searchText forKey:@"text"];
    _filteredDatasource = [[ODMDataManager sharedInstance] placesWithQueryParams:params];;
    
    // show loading view and also make sure to guideView should be hidden
    [self.actView setHidden:NO];
    [self.guideView setHidden:YES];
    
    [self.tableView reloadData];
}

- (void)reloadTableView
{
    [self.tableView reloadData];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self setTitle:TAB_EXPLORE_TITLE];
    
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
                                                 name:ODMDataManagerNotificationAuthenDidFinish
                                               object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(reloadTableView)
                                                 name:ODMDataManagerNotificationPlaceSubscribeDidFinish
                                               object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(reloadTableView)
                                                 name:ODMDataManagerNotificationPlaceUnsubscribeDidFinish
                                               object:nil];
    
    [self reloadData];
}

- (void)viewDidUnload
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    selectedPlace = nil;
    
    [super viewDidUnload];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    selectedPlace = nil;
    
    [[NSUserDefaults standardUserDefaults] setObject:@"1" forKey:NOW_TABBAR];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    
    // hide navigation bar
    [self.navigationController setNavigationBarHidden:NO animated:YES];
}

@end
