//
//  ODMEntryTest.m
//  CityBug
//
//  Created by InICe on 10/9/2555.
//  Copyright (c) พ.ศ. 2555 opendream. All rights reserved.
//

#import "ODMEntryTest.h"
#import <CoreData/CoreData.h>
#import "ODMEntry.h"
#import "ODMCategory.h"

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
    
    // create over title lenght
    title = @"Vivamus suscipit tempor arcu, eu facilisis purus laoreet et. Aenean facilisis libero vitae eros bibendum eu malesuada elit tincidunt. Aliquam id massa eu augue pellentesque cursus in at dui. Curabitur leo odio, faucibus quis tempor ac, rhoncus ac lorem. Mauris at neque quis libero fermentum pharetra ac eget dui. Suspendisse potenti. Fusce tempor, velit in congue elementum, neque dolor imperdiet justo, non varius tortor lacus vel nulla. Vivamus consectetur enim id nibh lacinia ultricies. Quisque eget tortor diam. Maecenas malesuada magna ut felis varius vulputate. Nam varius vulputate volutpat. Aenean pellentesque rutrum tortor, et suscipit justo ultricies a. Phasellus eget nisl ac leo varius gravida sed ut sapien. Donec viverra augue at nulla lobortis venenatis. Proin ullamcorper porttitor augue at iaculis. Phasellus elit lectus, condimentum in vehicula vitae, pulvinar quis nibh. Fusce et sapien a justo lobortis tincidunt. Maecenas eget aliquam urna. Praesent a velit est, in bibendum mi. Vivamus feugiat, erat sed dictum lobortis, est enim suscipit turpis, ut venenatis augue justo et ipsum. Vestibulum ante ipsum primis in faucibus orci luctus et ultrices posuere cubilia Curae; Nulla facilisi. Suspendisse ligula metus, consequat porttitor congue et, fermentum accumsan metus. Aliquam tempor nisi tincidunt nisi imperdiet mattis.";
    [entry setValue:title forKey:@"title"];
    STAssertFalse([entry validateValue:&title forKey:@"title" error:&error], @"Validate failed with error %@", error);
    
    // save
    [context save:&error];
    STAssertFalse([entry isFault], @"Entry is fault");
}

- (void)testCreateEntryWithCategory
{
    NSError *error;
    
    ODMEntry *entry = [NSEntityDescription insertNewObjectForEntityForName:@"ODMEntry" inManagedObjectContext:context];
    ODMCategory *category = [NSEntityDescription insertNewObjectForEntityForName:@"ODMCategory" inManagedObjectContext:context];
    
    // test category field
    NSString *catTitle = @"ร่างกายสดใส";
    [category setValue:catTitle forKey:@"title"];
    STAssertTrue([category validateValue:&catTitle forKey:@"title" error:&error], @"Validate failed with error %@", error);
    
    // test title field
    NSString *title = @"น้ำท่วมแล้วเจ้า v2";
    [entry setValue:title forKey:@"title"];
    STAssertTrue([entry validateValue:&title forKey:@"title" error:&error], @"Validate failed with error %@", error);
    
    // set category to entry
    [entry setValue:category forKey:@"category"];
    
    // save
    [context save:&error];
    STAssertFalse([entry isFault], @"Entry is fault");
}

@end
