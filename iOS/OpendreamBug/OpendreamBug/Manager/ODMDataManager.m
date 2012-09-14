//
//  ODMDataManager.m
//  OpendreamBug
//
//  Created by InICe on 11/9/2555.
//  Copyright (c) พ.ศ. 2555 opendream. All rights reserved.
//

#import "ODMDataManager.h"
#import <CoreData/CoreData.h>
#import "ODMEntry.h"

#import "AFJSONRequestOperation.h"
#import "AFHTTPClient.h"
#import "AFHTTPRequestOperation.h"
static ODMDataManager *sharedDataManager = nil;




@implementation ODMDataManager

#pragma mark - Application's Documents directory

/**
 Returns the URL to the application's Documents directory.
 */
- (NSURL *)applicationDocumentsDirectory
{
    return [[[NSFileManager defaultManager] URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask] lastObject];
}

#pragma mark - Initialize

- (id)init
{
    self = [super init];
    if (self) {
        NSURL *storeURL = [[self applicationDocumentsDirectory] URLByAppendingPathComponent:@"ODMCache.sqlite"];
        
        NSManagedObjectModel *mom = [NSManagedObjectModel mergedModelFromBundles:[NSBundle allBundles]];
        NSPersistentStoreCoordinator *psc = [[NSPersistentStoreCoordinator alloc] initWithManagedObjectModel:mom];
        
        [psc addPersistentStoreWithType:NSSQLiteStoreType configuration:nil URL:storeURL options:nil error:NULL];
        
        defaultContext = [[NSManagedObjectContext alloc] init];
        defaultContext.persistentStoreCoordinator = psc;
    }
    return self;
}

+ (ODMDataManager *)sharedInstance
{
    @synchronized(self) {
        if (sharedDataManager == nil) {
            sharedDataManager = [[self alloc] init];
        }
    }
    return sharedDataManager;

}

/*
 * Method :GET
 */
- (NSArray *)get:(NSString *)api
{
    if ([api isEqualToString:@"/api/entries"]) {
        
        NSError *error;
        NSData *data = [NSData dataWithContentsOfURL:[NSURL URLWithString:API_LIST_ENTRIES]];

        if (error) {
            ODMLog(@"error when get api %@ with error %@", api, error);
        }
        return [[NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingAllowFragments error:&error] objectForKey:@"entries"];
    }
    
    return nil;
}


- (NSArray *)getEntryList
{
        NSError *error;
        NSString *url = [BASE_URL stringByAppendingString:API_LIST];
          NSData *data = [NSData dataWithContentsOfURL:[NSURL URLWithString:url]];
//        NSData *data = [NSData dataWithContentsOfURL:[NSURL URLWithString:API_LIST_ENTRIES]];

        if (error) {
            ODMLog(@"error when get api %@ with error %@", API_LIST_ENTRIES, error);
                return nil;
        }
        return [[NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingAllowFragments error:&error] objectForKey:@"entries"];
    
}

- (void)postNewEntry:(UIImage *)aImage
{
    
    NSURL *url = [NSURL URLWithString:BASE_URL];
    AFHTTPClient *httpClient = [[AFHTTPClient alloc] initWithBaseURL:url];
    NSData *fullImageData = UIImageJPEGRepresentation(aImage, 1);
    NSData *thumbnailImageData = UIImageJPEGRepresentation(aImage, 0.3);
    NSString *timeStamp = [NSString stringWithFormat:@"%@", [NSDate date]];
//    NSDateFormatter *formatter = [NSDateFormatter ]
    
    NSMutableURLRequest *request = [httpClient multipartFormRequestWithMethod:@"POST" path:@"/api/entries" parameters:nil constructingBodyWithBlock: ^(id <AFMultipartFormData>formData) {
        [formData appendPartWithFileData:fullImageData name:@"full_image"
                                fileName:@"avatar.jpg" mimeType:@"image/jpeg"];
        [formData appendPartWithFileData:thumbnailImageData name:@"thumbnail_image"
                                fileName:@"avatar.jpg" mimeType:@"image/jpeg"];
        [formData appendPartWithFormData:[@"myTitle" dataUsingEncoding:NSUTF8StringEncoding] name:@"title"];
        [formData appendPartWithFormData:[@"AreyaMandarina" dataUsingEncoding:NSUTF8StringEncoding] name:@"latitude"];
        [formData appendPartWithFormData:[@"Bangkok" dataUsingEncoding:NSUTF8StringEncoding] name:@"latitude"];
    }];
    
    AFHTTPRequestOperation *operation = [[AFHTTPRequestOperation alloc] initWithRequest:request];
    [operation start];
            
}

- (id)insertEntry:(NSDictionary *)entry withError:(NSError **)error withManagedObjectContext:(NSManagedObjectContext *)context
{
    ODMEntry *newEntry = [NSEntityDescription insertNewObjectForEntityForName:NSStringFromClass([ODMEntry class]) inManagedObjectContext:context];
    
    [newEntry setValue:[entry objectForKey:@"id"] forKey:@"entryID"];
    
    [newEntry setValue:[entry objectForKey:@"title"] forKey:@"title"];
    [newEntry setValue:[entry objectForKey:@"note"] forKey:@"note"];
    [newEntry setValue:[entry objectForKey:@"note"] forKey:@"note"];
    [newEntry setValue:[entry objectForKey:@"thumbnail_image"] forKey:@"thumbnailImage"];
    [newEntry setValue:[entry objectForKey:@"full_image"] forKey:@"fullImage"];
    
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:DATE_FORMAT];
    
    NSDate *lastModifiedDate = [dateFormatter dateFromString:[entry objectForKey:@"lastModified"]];
    [newEntry setValue:lastModifiedDate forKey:@"lastModified"];

    NSNumber *latitudeNum = [NSNumber numberWithDouble:[[entry objectForKey:@"latitude"] doubleValue]];
    NSNumber *longitudeNum = [NSNumber numberWithDouble:[[entry objectForKey:@"longitude"] doubleValue]];

    [newEntry setValue:latitudeNum forKey:@"latitude"];
    [newEntry setValue:longitudeNum forKey:@"longitude"];
    
    return newEntry;
}

- (BOOL)insertEntriesToPersistentStore:(NSArray *)entries
{
    return [self insertEntriesToPersistentStore:entries withManagedObjectContext:defaultContext];
}


- (BOOL)insertEntriesToPersistentStore:(NSArray *)entries withManagedObjectContext:(NSManagedObjectContext *)context
{
    for (NSDictionary *entry in entries) {

        NSError *error;
        if ([self insertEntry:entry withError:&error withManagedObjectContext:context] == nil) {
            ODMLog(@"insert error %@", error);
            break;
        }
    }
    
    NSError *error;
    if ([defaultContext save:&error]) {
        ODMLog(@"save error %@", error);
    };
    
    return YES;
}

@end
