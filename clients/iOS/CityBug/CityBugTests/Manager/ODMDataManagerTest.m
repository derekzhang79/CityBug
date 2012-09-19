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
    
    RKObjectManager *shareObjManager = [RKObjectManager sharedManager];
    shareObjManager.client.baseURL = [RKURL URLWithString:@"http://localhost:3003"];
    
    RKObjectMapping *reportMapping = [RKObjectMapping mappingForClass:[ODMReport class]];
    [reportMapping mapKeyPath:@"title" toAttribute:@"title"];
    [reportMapping mapKeyPath:@"note" toAttribute:@"note"];
    
    [shareObjManager.mappingProvider setMapping:reportMapping forKeyPath:@"entries"];
}

- (void)tearDown
{
    context = nil;
    [super tearDown];
}

- (void)testInitializeDataManager
{
    STAssertNotNil(dataManager, @"DataManager should not nill");
}

- (void)testListReport
{
    [shareObjManager loadObjectsAtResourcePath:@"/api/entries" delegate:self];
}
- (void)testPostNewReport
{
    [dataManager postNewReport:nil];
}
@end
