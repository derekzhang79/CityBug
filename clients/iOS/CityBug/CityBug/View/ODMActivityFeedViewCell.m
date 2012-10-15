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
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(iminButtonConfig) name:ODMDataManagerNotificationAuthenDidFinish object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(hideIminButton:) name:ODMDataManagerNotificationIminDidLoading object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(iminButtonConfig) name:ODMDataManagerNotificationReportsLoadingFinish object:nil];
        
        [self.iminButton addTarget:self action:@selector(imin:) forControlEvents:UIControlEventTouchUpInside];
        
        self.iminCountLabel = (UILabel *)[self viewWithTag:IMIN_VIEW_TAG];
        UITapGestureRecognizer *iminCountTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleTapGesture:)];
        [self.iminCountLabel addGestureRecognizer:iminCountTap];
        
    }
    return self;
}


- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];
}

- (void)setReport:(ODMReport *)report
{    
    titleLabel.text = [report title];
    userLabel.text = [[report user] username];
    placeLabel.text = [[report place] title];
    self.iminCountLabel.text = [report iminString];
    createdAtLabel.text = [report.createdAt stringWithHumanizedTimeDifference];
    commentLabel.text = [NSString stringWithFormat:@"%d", report.comments.count];

    _report = report;
    
}

#pragma mark - imin action

- (IBAction)imin:(id)sender
{
    if ([self isImin]) {
        [[ODMDataManager sharedInstance] deleteIminAtReport:self.report];
    } else {
        [[ODMDataManager sharedInstance] postIminAtReport:self.report];
    }
    
    [self.iminButton setEnabled:NO];
}

- (void)handleTapGesture:(UITapGestureRecognizer *)gesture
{
    if ([self.delegate respondsToSelector:@selector(didClickIminLabelWithReport:)]) {
        [self.delegate didClickIminLabelWithReport:self.report];
    }
}

#pragma mark - imin config

- (void)iminButtonConfig
{
    if (![[ODMDataManager sharedInstance] isAuthenticated]) {
        [self.iminButton setEnabled:NO];
        return;
    }
    [self.iminButton setEnabled:YES];
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
        if ([imin.user.username isEqualToString:[[[ODMDataManager sharedInstance] currentUser] username]]) {
            return YES;
        }
    }
    return NO;
}

- (BOOL)isCommentExisted
{
    for (ODMComment *comment in self.report.comments) {
        if ([comment.user.username isEqualToString:[[[ODMDataManager sharedInstance] currentUser] username]]) {
            return YES;
        }
    }
    return NO;
}

#pragma mark - imin notification

- (void)showIminButton:(NSNotification *)notification
{
    [self.iminButton setEnabled:YES];
}

- (void)hideIminButton:(NSNotification *)notification
{
    ODMReport *report = [notification object];
    if ([self.report.uid isEqualToString:[report uid]]) {
        [self.iminButton setEnabled:NO];
    }
}


#pragma mark - layout subview

- (void)layoutSubviews
{
    [self iminButtonConfig];
}


 
@end
