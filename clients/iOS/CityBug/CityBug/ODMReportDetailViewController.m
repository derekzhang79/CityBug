//
//  ODMReportDetailViewController.m
//  CityBug
//
//  Created by Pirapa on 9/23/12.
//  Copyright (c) 2012 opendream. All rights reserved.
//

#import "ODMReportDetailViewController.h"

#import "UIImageView+WebCache.h"

#import "NSDate+HumanizedTime.h"

#import "ODMDataManager.h"

@implementation ODMReportDetailViewController

- (void)reloadData
{
    
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
//    ODMReportCommentViewController *reportComment = [[ODMReportCommentViewController alloc] init];
//    reportComment.delegate = self;
}

- (BOOL)resignFirstResponder
{
    [self.commentTextField resignFirstResponder];
    
    return [super resignFirstResponder];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

#pragma mark - Datasource

- (void)setReport:(ODMReport *)report
{
    _report = report;
}

#pragma mark - FormField Delegate

- (void)updateComment:(NSString *)comment
{
    self.commentLabel.text = comment;
 
    ODMComment *commentObject = [[ODMComment alloc] init];
    
    [commentObject setText:comment];
    [commentObject setReportID:self.report.uid];
    
    [[ODMDataManager sharedInstance] postComment:commentObject];
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.identifier isEqualToString:@"commentSegue"]) {
        ODMReportCommentViewController *commentVC = segue.destinationViewController;
        commentVC.delegate = self;
    }
}

- (IBAction)addCommentButtonTapped:(id)sender
{
    
}

#pragma mark - UIScrollView

- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    [self resignFirstResponder];
}

#pragma mark - UITableView

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 5;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // [self.report.comments count]
    return 1;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *cellIdentifier = @"CommentCellIdentifier";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:cellIdentifier];
    }
    
//    ODMComment *comment = [self.report.comments objectAtIndex:indexPath.row];
//    cell.textLabel.text = [self.report.user username];
//    cell.detailTextLabel.text = [comment text];
    
    cell.textLabel.text = @"admin";
    cell.detailTextLabel.text = @"qqqqwwwweeeerrr";
    return cell;
}

@end
