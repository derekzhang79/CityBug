//
//  ODMCategoryListViewController.m
//  CityBug
//
//  Created by InICe on 14/9/2555.
//  Copyright (c) พ.ศ. 2555 opendream. All rights reserved.
//

#import "ODMCategoryListViewController.h"

@implementation ODMCategoryListViewController {
    NSString *catString;
}

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

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = (UITableViewCell *)[tableView cellForRowAtIndexPath:indexPath];
    catString = cell.textLabel.text;
    
    if ([self.delegate respondsToSelector:@selector(updateCategoryList:withCategory:)]) {
        [self.delegate updateCategoryList:self withCategory:catString];
    }
    
    [self.navigationController popViewControllerAnimated:YES];
}

@end
