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
    NSManagedObjectContext *context;
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
    context = nil;
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

- (void)testCategoryList
{
    NSArray *categoires = [dataManager categories];
    
    STAssertTrue([categoires count] > 0, @"Category List should not equal to 0");
}

@end
