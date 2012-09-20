//
//  ODMPlaceFormViewController.h
//  CityBug
//
//  Created by InICe on 20/9/2555.
//  Copyright (c) พ.ศ. 2555 opendream. All rights reserved.
//

#import "ODMFormFiedViewController.h"

@protocol ODMPlaceFormDelegate;

@class ODMPlace;

@interface ODMPlaceFormViewController : UITableViewController <UISearchBarDelegate> {

    __unsafe_unretained id <ODMPlaceFormDelegate> _delegate;
    
    NSArray *_datasource;
}

@property (unsafe_unretained) id <ODMPlaceFormDelegate> delegate;

@property (nonatomic, readonly, strong) NSArray *datasource;

@end


@protocol ODMPlaceFormDelegate <NSObject>

- (void)didSelectPlace:(ODMPlace *)place;

@end