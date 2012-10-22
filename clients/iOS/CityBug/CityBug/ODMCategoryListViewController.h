//
//  ODMCategoryListViewController.h
//  CityBug
//
//  Created by InICe on 14/9/2555.
//  Copyright (c) พ.ศ. 2555 opendream. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol ODMCategoryListDelegate;

@interface ODMCategoryListViewController : UIViewController <UITableViewDataSource, UITableViewDelegate> {
    __unsafe_unretained id <ODMCategoryListDelegate> _delegate;
    
    NSArray *_datasource;
}

@property (unsafe_unretained) id <ODMCategoryListDelegate> delegate;

/*
 * Datasource
 */
@property (nonatomic, readonly, strong) NSArray *datasource;

/*
 * Save a category and Send this view back to the form
 */
- (IBAction)save:(id)sender;

@end


@protocol ODMCategoryListDelegate <NSObject>

- (void)updateCategoryList:(ODMCategoryListViewController *)delegate withCategory:(id)category;

@end