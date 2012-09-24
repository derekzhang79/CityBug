//
//  ODMDataManagerTest.m
//  CityBug
//
//  Created by InICe on 11/9/2555.
//  Copyright (c) พ.ศ. 2555 opendream. All rights reserved.
//

#import "ODMDataManagerTest.h"

#import "ODMDataManager.h"
#import "ODMReport.h"

@implementation ODMDataManagerTest {
    ODMDataManager *dataManager;
    RKObjectManager *objectManager;
}

- (void)setUp
{
    [super setUp];
    
    dataManager = [ODMDataManager sharedInstance];
    objectManager = [RKObjectManager sharedManager];
    
    STAssertNotNil(dataManager, @"DataManager should not nil");
    
    STAssertNotNil(objectManager, @"RestKit Manager should not nil");
}

- (void)tearDown
{
    dataManager = nil;
    objectManager = nil;
    
    [super tearDown];
}

- (void)testPostNewReportShouldErrorWhenTitleInputContainsHTMLTag
{
    ODMReport *report = [ODMReport newReportWithTitle:@"TestNewReport" note:@"TestNewReportWithNote"];
    report.title = @"wrsdfeiuasdpoi <INPUT> oiuwrsdfeiuasdpoiuwrsdfeiuasdpoiuwrsdfeiuasdpoiu";
    NSError *error = nil;
    BOOL passValidateLength = [report validateValue:NULL forKey:@"title" error:&error];
    STAssertFalse(passValidateLength, @"Report title should be invalidated");
    STAssertNotNil(error, @"Report title should not contain HTML Tags");
}

- (void)testPostNewReportShouldErrorWhenTitleInputMoreThan256Characters
{
    ODMReport *report = [ODMReport newReportWithTitle:@"TestNewReport" note:@"TestNewReportWithNote"];
    report.title = @"wrsdfeiuasdpoiuwrsdfeiuasdpoiuwrsdfeiuasdpoiuwrsdfeiuasdpoiuwrsdfeiuasdpoiuwrsdfeiuasdpoiuwrsdfeiuasdpoiuwrsdfeiuasdpoiuwrsdfeiuasdpoiuwrsdfeiuasdpoiuwrsdfeiuasdpoiuwrsdfeiuasdpoiuwrsdfeiuasdpoiuwrsdfeiuasdpoiuwrsdfeiuasdpoiuwrsdfeiuasdpoiuwrsdfeiuasdpoiuwrsdfeiuasdpoiu";
    NSError *error = nil;
    BOOL passValidateLength = [report validateValue:NULL forKey:@"title" error:&error];
    STAssertFalse(passValidateLength, @"Report title should be invalidated");
    STAssertNotNil(error, @"Report title should more than 256 characters");
}

- (void)testPostNewReportShouldErrorWhenNoteInputMoreThan1024Characters
{
    ODMReport *report = [ODMReport newReportWithTitle:@"TestNewReport" note:@"TestNewReportWithNote"];
    report.note = @"werwex poiu sadwerqpwoe sadiruasdn d2werwex poiu sadwerqpwoe sadiruasdn d2werwex poiu sadwerqpwoe sadiruasdn d2werwex poiu sadwerqpwoe sadiruasdn d2werwex poiu sadwerqpwoe sadiruasdn d2werwex poiu sadwerqpwoe sadiruasdn d2werwex poiu sadwerqpwoe sadiruasdn d2werwex poiu sadwerqpwoe sadiruasdn d2werwex poiu sadwerqpwoe sadiruasdn d2werwex poiu sadwerqpwoe sadiruasdn d2werwex poiu sadwerqpwoe sadiruasdn d2werwex poiu sadwerqpwoe sadiruasdn d2werwex poiu sadwerqpwoe sadiruasdn d2werwex poiu sadwerqpwoe sadiruasdn d2werwex poiu sadwerqpwoe sadiruasdn d2werwex poiu sadwerqpwoe sadiruasdn d2werwex poiu sadwerqpwoe sadiruasdn d2werwex poiu sadwerqpwoe sadiruasdn d2werwex poiu sadwerqpwoe sadiruasdn d2werwex poiu sadwerqpwoe sadiruasdn d2werwex poiu sadwerqpwoe sadiruasdn d2werwex poiu sadwerqpwoe sadiruasdn d2werwex poiu sadwerqpwoe sadiruasdn d2werwex poiu sadwerqpwoe sadiruasdn d2werwex poiu sadwerqpwoe sadiruasdn d2werwex poiu sadwerqpwoe sadiruasdn d2werwex poiu sadwerqpwoe sadiruasdn d2werwex poiu sadwerqpwoe sadiruasdn d2";
    
    NSError *error = nil;
    BOOL passValidateLength = [report validateValue:NULL forKey:@"note" error:&error];
    STAssertFalse(passValidateLength, @"Report note should be invalidated");
    STAssertNotNil(error, @"Report note should more than 1024 characters");
}

- (void)testPostNewReportShouldErrorWhenLocationIsEmpty
{
    ODMReport *report = [ODMReport newReportWithTitle:@"TestNewReport" note:@"TestNewReportWithNote"];
    NSError *error = nil;
    
    report.latitude = nil;
    report.longitude = nil;
    BOOL passValidateLocation = [report validateValue:NULL forKey:@"location" error:&error];
    STAssertFalse(passValidateLocation, @"Report location should present before send to server-side");
}

- (void)testPostNewReportShouldErrorWhenLocationIsIncorrectStandardByLatitude
{
    ODMReport *report = [ODMReport newReportWithTitle:@"TestNewReport" note:@"TestNewReportWithNote"];
    report.longitude = @123.124354;
    NSError *error = nil;
    
    report.latitude = [NSNumber numberWithDouble:-90.99];
    BOOL passValidateLocation = [report validateValue:NULL forKey:@"location" error:&error];
    STAssertFalse(passValidateLocation, @"Report location should present before send to server-side %@", error);
    
    report.latitude = [NSNumber numberWithDouble:-90.f];
    passValidateLocation = [report validateValue:NULL forKey:@"location" error:&error];
    STAssertFalse(passValidateLocation, @"Report location should present before send to server-side %@", error);
    
    report.latitude = [NSNumber numberWithDouble:-89.99];
    passValidateLocation = [report validateValue:NULL forKey:@"location" error:&error];
    STAssertFalse(passValidateLocation, @"Report location should present before send to server-side %@", error);
    
    report.latitude = [NSNumber numberWithDouble:89.99];
    passValidateLocation = [report validateValue:NULL forKey:@"location" error:&error];
    STAssertFalse(passValidateLocation, @"Report location should present before send to server-side %@", error);
    
    report.latitude = [NSNumber numberWithDouble:90.f];
    passValidateLocation = [report validateValue:NULL forKey:@"location" error:&error];
    STAssertFalse(passValidateLocation, @"Report location should present before send to server-side %@", error);
    
    report.latitude = [NSNumber numberWithDouble:90.001f];
    passValidateLocation = [report validateValue:NULL forKey:@"location" error:&error];
    STAssertFalse(passValidateLocation, @"Report location should present before send to server-side %@", error);
}

- (void)testPostNewReportShouldErrorWhenLocationIsIncorrectStandardByLongitude
{
    ODMReport *report = [ODMReport newReportWithTitle:@"TestNewReport" note:@"TestNewReportWithNote"];
    report.latitude = @10.42413;
    NSError *error = nil;
    
    report.longitude = [NSNumber numberWithDouble:-180.01f];
    BOOL passValidateLocation = [report validateValue:NULL forKey:@"location" error:&error];
    STAssertFalse(passValidateLocation, @"Report location should present before send to server-side %@", error);
    
    report.longitude = [NSNumber numberWithDouble:-180.f];
    passValidateLocation = [report validateValue:NULL forKey:@"location" error:&error];
    STAssertFalse(passValidateLocation, @"Report location should present before send to server-side %@", error);
    
    report.longitude = [NSNumber numberWithDouble:-179.99];
    passValidateLocation = [report validateValue:NULL forKey:@"location" error:&error];
    STAssertFalse(passValidateLocation, @"Report location should present before send to server-side %@", error);
    
    report.longitude = [NSNumber numberWithDouble:179.99];
    passValidateLocation = [report validateValue:NULL forKey:@"location" error:&error];
    STAssertFalse(passValidateLocation, @"Report location should present before send to server-side %@", error);
    
    report.longitude = [NSNumber numberWithDouble:180.f];
    passValidateLocation = [report validateValue:NULL forKey:@"location" error:&error];
    STAssertFalse(passValidateLocation, @"Report location should present before send to server-side %@", error);
    
    report.longitude = [NSNumber numberWithDouble:180.01f];
    passValidateLocation = [report validateValue:NULL forKey:@"location" error:&error];
    STAssertFalse(passValidateLocation, @"Report location should present before send to server-side %@", error);
}

#pragma mark - PLACE

- (void)testGroupPlaces
{
    ODMPlace *place1 = [[ODMPlace alloc] init];
    place1.title = @"Opendream@BKK";
    place1.latitude = @13.791343;
    place1.longitude = @100.587473;
    place1.type = @"suggested_place";
    
    ODMPlace *place2 = [[ODMPlace alloc] init];
    place2.title = @"Opendream@CHX";
    place2.latitude = @13.791343;
    place2.longitude = @100.587473;
    place2.type = @"suggested_place";
    
    ODMPlace *place3 = [[ODMPlace alloc] init];
    place3.title = @"Opendream@CHX สวนดอก";
    place3.latitude = @13.791343;
    place3.longitude = @100.587473;
    place3.type = @"suggested_place";
    
    ODMPlace *place4 = [[ODMPlace alloc] init];
    place4.title = @"Opendream@CHX สวนดอกจ้าาาาาา";
    place4.latitude = @13.791343;
    place4.longitude = @100.587473;
    place4.type = @"additional_place";
    
//    ODMLog(@"group place %@", [dataManager groupPlaceByType:[NSArray arrayWithObjects:place1, place2, place3, place4, nil]]);
    
    NSDictionary *params = [NSDictionary dictionaryWithObject:@"ดอก" forKey:@"title"];
    [dataManager placesWithQueryParams:params];
    
//    STAssertTrue([results count] > 0, @"Places result should contain any places");
    
}

#pragma mark - REPORT

- (void)testShouldGetReportFromService
{
    NSArray *reports = [dataManager reports];
    
    ODMLog(@"reports %@", reports);
}

@end
