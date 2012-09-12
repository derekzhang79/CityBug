//
//  ODMDataManagerTest.m
//  OpendreamBug
//
//  Created by InICe on 11/9/2555.
//  Copyright (c) พ.ศ. 2555 opendream. All rights reserved.
//

#import "ODMDataManagerTest.h"
#import <CoreData/CoreData.h>
#import "ODMEntry.h"
#import "ODMDataManager.h"

@implementation ODMDataManagerTest {
    NSManagedObjectContext *context;
    ODMDataManager *dataManager;
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

- (void)testGetJSONFromServer
{
    NSArray *entries = [dataManager get:@"/api/entries"];
    
    STAssertNotNil(entries, @"Entries should not return nil");
    
    STAssertTrue([entries count] > 0, @"DataManager should not empty array");
    
    BOOL success = [dataManager insertEntriesToPersistentStore:entries withManagedObjectContext:context];
    
    STAssertTrue(success, @"DataManager should not failed when insert entries to persistenstore");
    
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    
    [fetchRequest setEntity:[NSEntityDescription entityForName:@"ODMEntry" inManagedObjectContext:context]];
    
    NSError *error;
    
    NSArray *results = [context executeFetchRequest:fetchRequest error:&error];
    
    STAssertNil(error, @"DataManager cannot fetch entries from persistentstore with error %@", error);
    
    STAssertTrue([results count] > 0, @"FetchedArray should not empty after insert any entries to persistentstore");
}

@end
