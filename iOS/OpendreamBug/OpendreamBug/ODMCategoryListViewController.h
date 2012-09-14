//
//  ODMCategoryListViewController.h
//  OpendreamBug
//
//  Created by InICe on 14/9/2555.
//  Copyright (c) พ.ศ. 2555 opendream. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol ODMCategoryListDelegate;

@interface ODMCategoryListViewController : UITableViewController {
    __unsafe_unretained id <ODMCategoryListDelegate> delegate;
}

@property (unsafe_unretained) id <ODMCategoryListDelegate> delegate;

- (IBAction)save:(id)sender;

@end


@protocol ODMCategoryListDelegate <NSObject>

- (void)updateCategoryList:(ODMCategoryListViewController *)delegate withCategory:(id)category;

@end