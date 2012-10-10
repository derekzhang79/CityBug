//
//  ODMExploreFormViewController.h
//  CityBug
//
//  Created by tua~* on 10/4/55 BE.
//  Copyright (c) 2555 opendream. All rights reserved.
//

//
//  ODMPlaceFormViewController.h
//  CityBug
//
//  Created by InICe on 20/9/2555.
//  Copyright (c) พ.ศ. 2555 opendream. All rights reserved.
//

#import "ODMFormFiedViewController.h"

@protocol ODMExploreFormViewControllerDelegate;

@class ODMPlace;

@interface ODMExploreFormViewController : UIViewController <UITableViewDataSource, UITableViewDelegate,UISearchBarDelegate> {
    __unsafe_unretained id <ODMExploreFormViewControllerDelegate> _delegate;
    
    BOOL _isActive;
    NSArray *_datasource;
    
    __weak UITableView *_tableView;
    __weak UISearchBar *_searchBar;
}
@property (unsafe_unretained) id <ODMExploreFormViewControllerDelegate> delegate;

@property (nonatomic, readonly, strong) NSArray *datasource;

@property (nonatomic, weak) IBOutlet UITableView *tableView;
@property (nonatomic, weak) IBOutlet UISearchBar *searchBar;
@property (nonatomic, weak) IBOutlet UIView *actView, *guideView, *noResultView;

@property (nonatomic, assign, setter = setActive:) BOOL isActive;

@end


@protocol ODMPlaceFormDelegate <NSObject>

- (void)didSelectPlace:(ODMPlace *)place;

@end


@protocol ODMExploreFormViewControllerDelegate <NSObject>

- (void)updatePlace:(ODMExploreFormViewController *)delegate withPlace:(ODMPlace *)place;

@end