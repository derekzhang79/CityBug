//
//  ODMActivityFeedViewCell.m
//  CityBug
//
//  Created by InICe on 24/9/2555.
//  Copyright (c) พ.ศ. 2555 opendream. All rights reserved.
//

#import "ODMDataManager.h"
#import "ODMUser.h"
#import "ODMPlace.h"
#import "ODMImin.h"

#import "ODMActivityFeedViewCell.h"

#import "NSDate+HumanizedTime.h"

#define CELL_VIEW_TAG 4400
#define AVATAR_VIEW_TAG CELL_VIEW_TAG
#define USER_VIEW_TAG CELL_VIEW_TAG+1
#define TITLE_VIEW_TAG CELL_VIEW_TAG+2
#define IMAGE_VIEW_TAG CELL_VIEW_TAG+3
#define PLACE_VIEW_TAG CELL_VIEW_TAG+4
#define IMIN_VIEW_TAG CELL_VIEW_TAG+5
#define CREATED_AT_TAG CELL_VIEW_TAG+6
#define AMOUNT_COMMENT_TAG CELL_VIEW_TAG+7
#define IMIN_BUTTON_TAG CELL_VIEW_TAG+8

@implementation ODMActivityFeedViewCell
{
    NSInteger cooldownSendImin;
}

- (id)initWithCoder:(NSCoder *)aDecoder
{
    if (self = [super initWithCoder:aDecoder]) {
        _avatarImageView = (UIImageView *)[self viewWithTag:AVATAR_VIEW_TAG];
        _avatarImageView.image = [UIImage imageNamed:@"1.jpeg"];
        _reportImageView = (UIImageView *)[self viewWithTag:IMAGE_VIEW_TAG];
        _reportImageView.image = [UIImage imageNamed:@"bugs.jpeg"];
        _iminButton = (UIButton *)[self viewWithTag:IMIN_BUTTON_TAG];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(updateCommentView:) name:ODMDataManagerNotificationAuthenDidFinish object:nil];
        [self.iminButton addTarget:self action:@selector(imin:) forControlEvents:UIControlEventTouchUpInside];
    }
    return self;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];
}

- (void)setReport:(ODMReport *)report
{    
    UILabel *titleLabel = (UILabel *)[self viewWithTag:TITLE_VIEW_TAG];
    titleLabel.text = [report title];
    
    UILabel *userLabel = (UILabel *)[self viewWithTag:USER_VIEW_TAG];
    userLabel.text = [[report user] username];

    UILabel *placeLabel = (UILabel *)[self viewWithTag:PLACE_VIEW_TAG];
    
    placeLabel.text = [[report place] title];
    
    UILabel *iminCountLabel = (UILabel *)[self viewWithTag:IMIN_VIEW_TAG];
    iminCountLabel.text = [report iminString];
    
    UILabel *createdAtLabel = (UILabel *)[self viewWithTag:CREATED_AT_TAG];
    createdAtLabel.text = [report.createdAt stringWithHumanizedTimeDifference];
    
    UILabel *commentLabel = (UILabel *)[self viewWithTag:AMOUNT_COMMENT_TAG];
    commentLabel.text = [NSString stringWithFormat:@"%d", report.comments.count];

    _report = report;
    
    
    [self updateCommentView:nil];
}

#pragma mark - imin

- (IBAction)imin:(id)sender
{
    if ([self isImin]) {
        [[ODMDataManager sharedInstance] deleteIminAtReport:self.report];
    } else {
        [[ODMDataManager sharedInstance] postIminAtReport:self.report];
    }
    
    [self.iminButton setEnabled:NO];
    cooldownSendImin = 3;
    [NSTimer scheduledTimerWithTimeInterval:1.f target:self selector:@selector(cooldownSendImin:) userInfo:nil repeats:YES];
}

- (void)iminButtonConfig
{
    if(![self isImin]) {
        [self.iminButton setTitle:@"Imin" forState:UIControlStateNormal];
    } else {
        [self.iminButton setTitle:@"Imout" forState:UIControlStateNormal];
        if ([self isCommentExisted]) {
            [self.iminButton setEnabled:NO];
        }
    }
}

- (BOOL)isImin
{
    for (ODMImin *imin in self.report.imins) {
        if ([imin.user.username isEqualToString:[[NSUserDefaults standardUserDefaults] stringForKey:@"username"]]) {
            return YES;
        }
    }
    return NO;
}

- (BOOL)isCommentExisted
{
    for (ODMComment *comment in self.report.comments) {
        if ([comment.user.username isEqualToString:[[NSUserDefaults standardUserDefaults] stringForKey:@"username"]]) {
            return YES;
        }
    }
    return NO;
}

- (void)updateCommentView:(NSNotificationCenter *)noti
{
    BOOL isAuthen = [[ODMDataManager sharedInstance] isAuthenticated];
    
    if (isAuthen) {
        [self.iminButton setEnabled:YES];
    } else {
        [self.iminButton setEnabled:NO];
    }
}


#pragma mark - cooldown

- (void)cooldownSendImin:(NSTimer *)timer
{
    if (--cooldownSendImin == 0) {
        [timer invalidate];
        [self.iminButton setEnabled:YES];
    }
}

- (void)layoutSubviews
{
    [self iminButtonConfig];
}

- (void)updateComment:(NSString *)comment
{
    // For beta version
    // We enforce user to reload all contents from server
    // Thus, we have to reload comments after
    // reports has completely parsed
    
    [self iminButtonConfig];
}

@end
