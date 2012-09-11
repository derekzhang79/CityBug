//
//  ODMListViewController.m
//  OpendreamBug
//
//  Created by Pirapa on 9/10/12.
//  Copyright (c) 2012 opendream. All rights reserved.
//

#import "ODMListViewController.h"
#import "ODMDescriptionFormViewController.h"

#define kSceenSize self.parentViewController.view.frame.size
#define kToolBarSize toolBar.frame.size
#define CAMERA_SCALAR 1.32

@interface ODMListViewController ()

@end

@implementation ODMListViewController {
    UIImage *imageToSave;
}
@synthesize toolBar;
@synthesize bugImageView;
@synthesize descLabel;
@synthesize amountLikeLable;


- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
    }
    return self;
}

#pragma mark - View's Life Cycle

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self.parentViewController.view addSubview:toolBar];
    toolBar.frame = CGRectMake(0, kSceenSize.height - kToolBarSize.height, kToolBarSize.width, kToolBarSize.height);
}
- (void)viewDidLoad
{
    [super viewDidLoad];
    
}

-(void)viewWillDisappear:(BOOL)animated
{
    [toolBar removeFromSuperview];
    [super viewWillDisappear:animated];
}

- (void)viewDidUnload
{
    [self setToolBar:nil];
    [self setBugImageView:nil];
    [self setDescLabel:nil];
    [self setAmountLikeLable:nil];
    [super viewDidUnload];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 2;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"BugCell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    
    // Configure the cell...
    
    return cell;
}

#pragma mark -

- (IBAction)addButtonTapped:(id)sender
{
    NSLog(@"addButtonTapped");
    UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:@"Choose Source"
                                                      delegate:self
                                             cancelButtonTitle:@"Cancel"
                                        destructiveButtonTitle:nil
                                             otherButtonTitles:@"Camera", @"Existing Photo", nil];
    actionSheet.actionSheetStyle = UIActionSheetStyleBlackTranslucent;
    [actionSheet showInView:self.view];


}

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
    NSLog(@"clickedButtonAtIndex");
     UIImagePickerController *picker =  [[UIImagePickerController alloc] init];
    if (buttonIndex == 0 && [UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera]){
        picker.sourceType = UIImagePickerControllerSourceTypeCamera;
        picker.delegate = self;
        picker.allowsEditing = NO;
        picker.wantsFullScreenLayout = YES;
        picker.cameraViewTransform = CGAffineTransformScale(picker.cameraViewTransform, CAMERA_SCALAR, CAMERA_SCALAR);
        [self presentModalViewController:picker animated:YES];
    } else if (buttonIndex == 1 && [UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypePhotoLibrary]){
        
        picker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
        picker.allowsEditing = NO;
        [self presentModalViewController:picker animated:YES];

    }
}

//static NSString *segueIdent = @"presentFormSegue";

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info
{      
    // Save the new image (original or edited) to the Camera Roll.
    imageToSave = (UIImage *)[info objectForKey:UIImagePickerControllerOriginalImage];
    UIImageWriteToSavedPhotosAlbum (imageToSave, nil, nil , nil);

    [self dismissModalViewControllerAnimated: YES];
    
    [self performSelector:@selector(performSegueWithIdentifier:sender:) withObject:@"presentFormSegue" afterDelay:1.f];
    
    
}

#pragma mark - segue

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.identifier isEqualToString:@"presentFormSegue"]) {
        ODMDescriptionFormViewController *formViewController = (ODMDescriptionFormViewController *) segue.destinationViewController;
        formViewController.bugImage = imageToSave;
    }
}


@end
