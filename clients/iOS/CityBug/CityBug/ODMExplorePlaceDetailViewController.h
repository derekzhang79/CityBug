//
//  ODMExplorePlaceDetailViewController.h
//  CityBug
//
//  Created by tua~* on 10/4/55 BE.
//  Copyright (c) 2555 opendream. All rights reserved.
//


#import "ODMPlace.h"
#import "ODMExploreFormViewController.h"
#import "ODMActivityFeedViewCell.h"

#import <MapKit/MapKit.h>

@interface ODMExplorePlaceDetailViewController : UIViewController <UITableViewDataSource, UITableViewDelegate, ODMExploreFormViewControllerDelegate, ODMActivityFeedViewCellDelegate>
{
    BOOL _isActive;
    NSArray *_datasource;
    
    __weak UITableView *_tableView;
    ODMPlace *_place;

    IBOutlet UILabel *titleLabel;
}
@property (strong, nonatomic) IBOutlet UIBarButtonItem *rightButton;

@property (nonatomic, strong) ODMPlace *place;

@property (nonatomic, readonly, strong) NSArray *datasource;

@property (nonatomic, weak) IBOutlet UITableView *tableView;
@property (nonatomic, weak) IBOutlet UISearchBar *searchBar;
@property (nonatomic, weak) IBOutlet UIView *actView, *noResultView, *mapView;
@property (strong, nonatomic) IBOutlet MKMapView *map;

@property (nonatomic, assign, setter = setActive:) BOOL isActive;

- (IBAction)refreshButtonTapped:(id)sender;

@end
