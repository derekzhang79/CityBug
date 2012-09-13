//
//  ODMListViewController.m
//  OpendreamBug
//
//  Created by Pirapa on 9/10/12.
//  Copyright (c) 2012 opendream. All rights reserved.
//

#import "ODMListViewController.h"
#import "ODMDescriptionFormViewController.h"
#import "ODMDescriptionViewController.h"
#import "ODMDataManager.h"
#import "ODMEntry.h"

#define kSceenSize self.parentViewController.view.frame.size
#define kToolBarSize toolBar.frame.size
#define CAMERA_SCALAR 1.32

static NSString *gotoFormSegue = @"presentFormSegue";
static NSString *gotoViewSegue = @"showDescriptionSegue";

@interface ODMListViewController ()

@end

@implementation ODMListViewController {
    UIImage *imageToSave;
    UIImagePickerController *picker;
    NSArray *entries;

}
@synthesize toolBar;


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
    ODMDataManager *dataManager = [ODMDataManager sharedInstance];
    entries = [dataManager getEntryList];
}

-(void)viewWillDisappear:(BOOL)animated
{
    [toolBar removeFromSuperview];
    [super viewWillDisappear:animated];
}

- (void)viewDidUnload
{
    [self setToolBar:nil];
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
    NSLog(@"%i", entries.count);
    return [entries count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"BugCell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];

        [self configureCell:cell withEntry:[entries objectAtIndex:indexPath.row]];

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
    picker =  [[UIImagePickerController alloc] init];
    picker.delegate = self;
    if (buttonIndex == 0 && [UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera]){
        picker.sourceType = UIImagePickerControllerSourceTypeCamera;
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

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info
{      
    // Save the new image (original or edited) to the Camera Roll.
    imageToSave = (UIImage *)[info objectForKey:UIImagePickerControllerOriginalImage];
    UIImageWriteToSavedPhotosAlbum (imageToSave, nil, nil , nil);

    
    [self performSelector:@selector(performSegueWithIdentifier:sender:) withObject:gotoFormSegue afterDelay:1.f];
    [self dismissModalViewControllerAnimated: YES];
    
}

#pragma mark - segue

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.identifier isEqualToString:gotoFormSegue]) {
        ODMDescriptionFormViewController *formViewController = (ODMDescriptionFormViewController *) segue.destinationViewController;
        formViewController.bugImage = imageToSave;
    }
    else if ([segue.identifier isEqualToString:gotoViewSegue]) {
        ODMDescriptionViewController *DetailViewController = (ODMDescriptionViewController *) segue.destinationViewController;
        NSIndexPath *indexPath = [self.tableView indexPathForCell:(UITableViewCell *)sender];
        DetailViewController.entry = [entries objectAtIndex:indexPath.row];
    }
}


#pragma mark - Helper Function

- (void)configureCell:(UITableViewCell *)cell withEntry:(NSDictionary *)aEntry
{
    __block NSString *imagePath = [aEntry objectForKey:@"thumbnail_image"];
    __block NSData *imageData;
   

    
    dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH,  0ul);
    dispatch_async(queue, ^{
        
        NSArray *documentDir = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
        NSString *documentPath = [documentDir lastObject];
        
        NSString *imageName = [[NSURL URLWithString:imagePath] lastPathComponent];
        NSString *imagePathInCache = [documentPath stringByAppendingPathComponent:imageName];
        
        if ( [[NSFileManager defaultManager] fileExistsAtPath:imagePathInCache]) // if มีอยู่ใน cache
        {
            imageData = [NSData dataWithContentsOfFile:imagePathInCache];
        }
        
        UIImageView *thumbnailImageView = (UIImageView *)[cell viewWithTag:1];
        NSURLRequest *requestImage = [NSURLRequest requestWithURL:[NSURL URLWithString:imagePath]];
        
        imageData = [NSURLConnection  sendSynchronousRequest:requestImage returningResponse:nil error:NULL];
        thumbnailImageView.image = [UIImage imageWithData:imageData];
    });
    
    UILabel *descLabel = (UILabel *)[cell viewWithTag:2];
    descLabel.text = [aEntry objectForKey:@"title"];

 
}


@end
