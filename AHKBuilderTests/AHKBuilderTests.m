//
//  AHKBuilderTests.m
//  AHKBuilderTests
//
//  Created by Arkadiusz Holko on 11-05-15.
//
//

#import <UIKit/UIKit.h>
#import <XCTest/XCTest.h>

#import "Reminder.h"


@interface AHKBuilderTests : XCTestCase

@end

@implementation AHKBuilderTests

- (void)setUp
{
    [super setUp];
    // Put setup code here. This method is called before the invocation of each test method in the class.
}

- (void)tearDown
{
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    [super tearDown];
}

- (void)testUseOfDefaultInit
{
  Reminder *reminder = [[Reminder alloc] initWithBuilder_ahk:^(id<ReminderBuilder> builder) {
    // intentionally empty
  }];

  XCTAssert(reminder.showsAlert);
}

- (void)testCorrectlySetsValues
{
  NSString *title = @"test";
  NSDate *date = [NSDate dateWithTimeIntervalSinceNow:60 * 60 * 24];
  BOOL showsAlert = NO;

  Reminder *reminder = [[Reminder alloc] initWithBuilder_ahk:^(id<ReminderBuilder> builder) {
    builder.title = title;
    builder.date = date;
    builder.showsAlert = showsAlert;
  }];

  XCTAssertEqual(reminder.title, title);
  XCTAssertEqual(reminder.date, date);
  XCTAssertEqual(reminder.showsAlert, showsAlert);
}

- (void)testAllowsReadingValuesInBlock
{
  NSString *title = @"test";
  __unused Reminder *reminder = [[Reminder alloc] initWithBuilder_ahk:^(id<ReminderBuilder> builder) {
    builder.title = title;
    XCTAssertEqual(builder.title, title);
  }];
}

- (void)testCopiesAllPropertiesCorrectly
{
  NSString *title = @"test";
  NSDate *date = [NSDate dateWithTimeIntervalSinceNow:60 * 60 * 24];
  BOOL showsAlert = NO;

  Reminder *reminder = [[Reminder alloc] initWithBuilder_ahk:^(id<ReminderBuilder> builder) {
    builder.title = title;
    builder.date = date;
    builder.showsAlert = showsAlert;
  }];

  NSString *copyTitle = @"test2";
  Reminder *copy = [reminder copyWithBuilder_ahk:^(id<ReminderBuilder> builder) {
    builder.title = copyTitle;
  }];

  XCTAssertEqual(reminder.title, title);
  XCTAssertEqual(copy.title, copyTitle);
  XCTAssertEqual(copy.date, date);
  XCTAssertEqual(copy.showsAlert, showsAlert);
}

@end
