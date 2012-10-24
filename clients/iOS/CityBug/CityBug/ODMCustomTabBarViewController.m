//
//  ODMCustomTabBarViewController.m
//  CityBug
//
//  Created by nut hancharoernkit on 10/24/12.
//  Copyright (c) 2012 opendream. All rights reserved.
//

#import "ODMCustomTabBarViewController.h"


@interface ODMCustomTabBarViewController ()

@end

@implementation ODMCustomTabBarViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    UITabBarController *tabController = (UITabBarController *)[[[[UIApplication sharedApplication] delegate] window] rootViewController];
    tabController.delegate = self;
    
	// Do any additional setup after loading the view.
    [self customTabBar];
}

- (void)customTabBar
{

    
    UIButton *photoButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [photoButton setUserInteractionEnabled:YES];
    [photoButton setBackgroundImage:[UIImage imageNamed:@"star_active"] forState:UIControlStateNormal];
    [photoButton setBackgroundImage:[UIImage imageNamed:@"star_inactive"] forState:UIControlStateSelected];
    [photoButton setBackgroundImage:[UIImage imageNamed:@"cat1.png"] forState:UIControlStateDisabled];

    [photoButton addTarget:self action:@selector(photoButtonTap:) forControlEvents:UIControlEventTouchUpInside];
    
    [photoButton setFrame:CGRectMake(20, 410, 50, 50)];
    
    [self.view addSubview:photoButton];
    
}

- (void)photoButtonTap:(UIGestureRecognizer *)gesture
{
    [self setSelectedIndex:0];
    [[NSUserDefaults standardUserDefaults] setObject:@"0" forKey:NOW_TABBAR];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)tabBarController:(UITabBarController *)tabBarController didSelectViewController:(UIViewController *)viewController
{
    NSLog(@"TAB!!! %@", viewController.title);
    NSString *tabNumber = @"1";
    
    if ([viewController.title isEqualToString:TAB_PROFILE_TITLE]) {
        return;
    } else if ([viewController.title isEqualToString:TAB_FEED_TITLE]) {
        tabNumber = @"1";
    } else if ([viewController.title isEqualToString:TAB_EXPLORE_TITLE]) {
        tabNumber = @"2";
    }
    [[NSUserDefaults standardUserDefaults] setObject:tabNumber forKey:NOW_TABBAR];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

@end
