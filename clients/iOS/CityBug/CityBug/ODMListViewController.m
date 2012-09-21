//
//  ODMListViewController.m
//  CityBug
//
//  Created by Pirapa on 9/10/12.
//  Copyright (c) 2012 opendream. All rights reserved.
//

#import "ODMListViewController.h"
#import "ODMDescriptionFormViewController.h"
#import "ODMDescriptionViewController.h"
#import "ODMDataManager.h"
#import "ODMEntry.h"
#import "UIImageView+AFNetworking.h"

#import <ImageIO/ImageIO.h>
#import <ImageIO/CGImageSource.h>
#import <ImageIO/CGImageProperties.h>
#import <AssetsLibrary/AssetsLibrary.h>

#define kSceenSize self.parentViewController.view.frame.size
#define CAMERA_SCALAR 1.32

static NSString *gotoFormSegue = @"presentFormSegue";
static NSString *gotoViewSegue = @"showDescriptionSegue";

@interface ODMListViewController () {
    CLLocationManager *locationManager;
}

@end

@implementation ODMListViewController {
    UIImage *imageToSave;
    UIImagePickerController *picker;
    NSArray *entries;
    
    ALAssetsLibraryAssetForURLResultBlock resultblock;
    ALAssetsLibraryAccessFailureBlock failureblock;
    ALAssetsLibrary *assetsLib;
    CLLocation *location;


}



#pragma mark - View's Life Cycle

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    ODMDataManager *dataManager = [ODMDataManager sharedInstance];
    
    entries = [dataManager getEntryList];
    if (!entries) {
        entries = [NSArray new];
    }
    [self.tableView reloadData];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self setTitle:@"CityBug"];
    
    locationManager = [[CLLocationManager alloc] init];
    locationManager.delegate = self;
    locationManager.distanceFilter = kCLDistanceFilterNone;
    locationManager.desiredAccuracy = kCLLocationAccuracyThreeKilometers;
    [locationManager startUpdatingLocation];
    self.location = locationManager.location;

    resultblock = ^(ALAsset *myasset) {
        CLLocation *locationAsset = [myasset valueForProperty:ALAssetPropertyLocation];
        self.location = locationAsset; 
    };
    failureblock = ^(NSError *myerror) {
        NSLog(@"error while get Location from picture : %d - message: %s", errno, strerror(errno));
        self.location = nil;
    };

}

-(void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
}

- (void)viewDidUnload
{
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

- (IBAction)refreshButtonTapped:(id)sender {
    ODMDataManager *dataManager = [ODMDataManager sharedInstance];
    entries = [dataManager getEntryList];
    [self.tableView reloadData];

}

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
    NSLog(@"clickedButtonAtIndex");
    picker =  [[UIImagePickerController alloc] init];
    picker.delegate = self;
    picker.allowsEditing = YES;
    if (buttonIndex == 0 && [UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera]){
        picker.sourceType = UIImagePickerControllerSourceTypeCamera;
        picker.wantsFullScreenLayout = YES;
        picker.cameraViewTransform = CGAffineTransformScale(picker.cameraViewTransform, CAMERA_SCALAR, CAMERA_SCALAR);
        
        [self presentModalViewController:picker animated:YES];
        
    } else if (buttonIndex == 1 && [UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypePhotoLibrary]){
        picker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
        [self presentModalViewController:picker animated:YES];

    }
}


- (void)imagePickerController:(UIImagePickerController *)aPicker didFinishPickingMediaWithInfo:(NSDictionary *)info
{   
    imageToSave = (UIImage *)[info objectForKey:UIImagePickerControllerEditedImage];
 
    if (aPicker.sourceType == UIImagePickerControllerSourceTypeCamera) {
        
        // Save the new image (original or edited) to the Camera Roll.
        UIImageWriteToSavedPhotosAlbum (imageToSave, nil, nil , nil);
        self.location = locationManager.location;
    } else if (picker.sourceType == UIImagePickerControllerSourceTypePhotoLibrary) {
        
        // Get the asset url
        NSURL *pictureURL = [info objectForKey:UIImagePickerControllerReferenceURL];
        assetsLib = [[ALAssetsLibrary alloc] init];
        [assetsLib assetForURL:pictureURL resultBlock:resultblock failureBlock:failureblock];
    
        
    }
    
    [self performSelector:@selector(performSegueWithIdentifier:sender:) withObject:gotoFormSegue afterDelay:1.f];
    [self dismissModalViewControllerAnimated: YES];
    
}



#pragma mark - segue

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.identifier isEqualToString:gotoFormSegue]) {
        ODMDescriptionFormViewController *formViewController = (ODMDescriptionFormViewController *) segue.destinationViewController;
        formViewController.bugImage = imageToSave;
        formViewController.location = self.location;
        
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
   
    dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH,  0ul);
    dispatch_async(queue, ^{
        if ([[imagePath substringToIndex:1] isEqualToString:@"."]) {
            imagePath = [imagePath substringFromIndex:1];
        }
        imagePath = [BASE_URL stringByAppendingString:imagePath];
        UIImageView *thumbnailImageView = (UIImageView *)[cell viewWithTag:1];
        
        NSLog(@"image %@", imagePath);
        [thumbnailImageView setImageWithURL:[NSURL URLWithString:imagePath] placeholderImage:[UIImage imageNamed:@"process"]];


    });
    
    UILabel *titleLabel = (UILabel *)[cell viewWithTag:3];
    titleLabel.text = [aEntry objectForKey:@"title"];
    
    UILabel *noteLabel = (UILabel *)[cell viewWithTag:2];
    noteLabel.text = [aEntry objectForKey:@"note"];

 
}


@end
