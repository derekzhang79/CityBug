//
//  ODMDataManagerTest.m
//  CityBug
//
//  Created by InICe on 11/9/2555.
//  Copyright (c) พ.ศ. 2555 opendream. All rights reserved.
//

#import "ODMDataManagerTest.h"
#import <CoreData/CoreData.h>
#import "ODMEntry.h"
#import "ODMDataManager.h"
#import "ODMReport.h"

@implementation ODMDataManagerTest {
    NSManagedObjectContext *context;
    ODMDataManager *dataManager;
    RKObjectManager *objectManager;
}

- (void)setUp
{
    [super setUp];
    
    NSManagedObjectModel *mom = [NSManagedObjectModel mergedModelFromBundles:[NSBundle allBundles]];
    NSPersistentStoreCoordinator *psc = [[NSPersistentStoreCoordinator alloc] initWithManagedObjectModel:mom];
    
    [psc addPersistentStoreWithType:NSInMemoryStoreType configuration:nil URL:nil options:nil error:NULL];
    
    context = [[NSManagedObjectContext alloc] init];
    context.persistentStoreCoordinator = psc;
    
    dataManager = [ODMDataManager sharedInstance];
    
    objectManager = [RKObjectManager sharedManager];
}

- (void)tearDown
{
    context = nil;
    [super tearDown];
}

- (void)testInitializeDataManager
{
    STAssertNotNil(dataManager, @"DataManager should not nil");
    
    STAssertNotNil(objectManager, @"RestKit Manager should not nil");
}

- (void)testListReport
{
    [objectManager loadObjectsAtResourcePath:@"/api/reports" delegate:self];
}

- (void)testPostNewReport
{
    ODMReport *report = [ODMReport new];
    report.title = @"Post from RestKit";
    report.note = @"Note from RestKit";
    report.latitude = @13.791343;
    report.longitude = @100.587473;
    report.fullImage = [UIImage imageNamed:@"1.jpeg"];
    report.thumbnailImage = [UIImage imageNamed:@"1.jpeg"];
    [dataManager postNewReport:report];
}

- (void)testCategoryList
{
    NSArray *categoires = [dataManager categories];
    
    STAssertTrue([categoires count] > 0, @"Category List should not equal to 0");
}

- (void)objectLoader:(RKObjectLoader *)objectLoader didFailWithError:(NSError *)error
{
    ODMLog(@"Loader Failed %@", error);
}

- (void)objectLoader:(RKObjectLoader *)objectLoader didLoadObjects:(NSArray *)objects
{
    ODMLog(@"Finish load with object %@", objects);
}

@end
