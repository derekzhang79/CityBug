//
//  ODMEntryTest.m
//  OpendreamBug
//
//  Created by InICe on 10/9/2555.
//  Copyright (c) พ.ศ. 2555 opendream. All rights reserved.
//

#import "ODMEntryTest.h"
#import <CoreData/CoreData.h>
#import "ODMEntry.h"

@implementation ODMEntryTest {
    NSManagedObjectContext *context;
}

- (void)setUp
{
    [super setUp];
    
    NSManagedObjectModel *mom = [NSManagedObjectModel mergedModelFromBundles:[NSBundle allBundles]];
    NSPersistentStoreCoordinator *psc = [[NSPersistentStoreCoordinator alloc] initWithManagedObjectModel:mom];
    
    [psc addPersistentStoreWithType:NSInMemoryStoreType configuration:nil URL:nil options:nil error:NULL];
    
    context = [[NSManagedObjectContext alloc] init];
    context.persistentStoreCoordinator = psc;
}

- (void)tearDown
{
    context = nil;
    [super tearDown];
}

- (void)testCreateEntry
{
    ODMEntry *entry = [NSEntityDescription insertNewObjectForEntityForName:@"ODMEntry" inManagedObjectContext:context];
    NSError *error;
    
    NSString *title = @"น้ำท่วมแล้วเจ้า";
    [entry setValue:title forKey:@"title"];
    
    STAssertTrue([entry validateValue:&title forKey:@"title" error:&error], @"Validate failed with error %@", error);
    [context save:&error];
    
    STAssertFalse([entry isFault], @"Entry is fault");
}

@end
