//
//  ODMCategoryListViewController.m
//  CityBug
//
//  Created by InICe on 14/9/2555.
//  Copyright (c) พ.ศ. 2555 opendream. All rights reserved.
//

#import "ODMCategoryListViewController.h"
#import "ODMCategory.h"
#import "ODMDataManager.h"
#import "UIImageView+WebCache.h"
#import "ODMCategoryView.h"

#import <ImageIO/ImageIO.h>
#import <ImageIO/CGImageSource.h>
#import <ImageIO/CGImageProperties.h>

#define CELL_HEIGHT 106

@interface ODMCategoryListViewController(Accessor)
@property (nonatomic, readwrite, strong) NSArray *datasource;
@end

@implementation ODMCategoryListViewController {
    NSString *catString;
}

#pragma mark - SAVE

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

#pragma mark - VIEW

- (void)reloadData
{
    _datasource = [[ODMDataManager sharedInstance] categories];
    
//    [self.tableView reloadData];
}

- (void)updateCategoriesNotification:(NSNotification *)notification
{
    if ([[notification object] isKindOfClass:[NSArray class]]) {
        _datasource = [notification object];
        
        for (int i = 0; i < _datasource.count; i++) {
            int x=0, y=0;
            x = i%3;
            y = i/3;
            ODMCategoryView *view = [[ODMCategoryView alloc] initWithFrame:CGRectMake(CELL_HEIGHT*x, CELL_HEIGHT*y, CELL_HEIGHT, CELL_HEIGHT)];
            ODMCategory *cat = [_datasource objectAtIndex:i];
            view.text = cat.title;
            
            if (cat.thumbnailImage != nil) {
                NSURL *avatarURL = [NSURL URLWithString:[NSString stringWithFormat:@"%@%@", BASE_URL, cat.thumbnailImage]];
                [view.imageView setImageWithURL:avatarURL placeholderImage:[UIImage imageNamed:@"cat1.png"] options:SDWebImageCacheMemoryOnly];
            } else {
                view.imageView.image = [UIImage imageNamed:@"cat1.png"];
            }
            UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self  action:@selector(tapAction:)];
            [view addGestureRecognizer:tap];
            
            [self.view addSubview:view];
        }
//        [self.tableView reloadData];
    }
}

- (void)tapAction:(UITapGestureRecognizer *)sender
{
    if ([sender.view isKindOfClass:[ODMCategoryView class]]) {
        ODMCategoryView *view = (ODMCategoryView *)sender.view;
        catString = view.text;
        
        if ([self.delegate respondsToSelector:@selector(updateCategoryList:withCategory:)]) {
            [self.delegate updateCategoryList:self withCategory:catString];
        }
        
        [self.navigationController popViewControllerAnimated:YES];
    }
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self reloadData];
    
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(updateCategoriesNotification:)
                                                 name:ODMDataManagerNotificationCategoriesLoadingFinish
                                               object:nil];
}

- (void)viewDidUnload
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    
    [super viewDidUnload];
}

@end
