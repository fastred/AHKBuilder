//
//  AHKBuilderTestsForProtocol.m
//  AHKBuilder
//
//  Created by Arkadiusz on 06-08-15.
//  Copyright (c) 2015 Arkadiusz Holko. All rights reserved.
//

#import <XCTest/XCTest.h>

#import "AHKBuilder.h"


@protocol FooBuilder <NSObject>

@property (nonatomic, copy) NSString *bar;
@property (nonatomic, assign) NSInteger baz;

@end

@protocol FooProtocol <NSObject>

@property (nonatomic, copy, readonly) NSString *bar;
@property (nonatomic, assign, readonly) NSInteger baz;

@end


@interface Foo : NSObject <FooProtocol>
@end

@implementation Foo

@synthesize bar = _bar, baz = _baz;

- (NSString *)bar
{
  if (!_bar) {
    _bar = @"default";
  }

  return _bar;
}

- (NSInteger)baz
{
  if (_baz == 0) {
    _baz = 1;
  }

  return _baz;
}

@end


@interface AHKBuilderTestsForProtocol : XCTestCase

@end

@implementation AHKBuilderTestsForProtocol

- (void)testInit
{
  Foo *foo = [[Foo alloc] initWithBuilder_ahk:^(id<FooBuilder> fooBuilder) {
    fooBuilder.baz = 2;
  }];

  XCTAssertEqualObjects(foo.bar, @"default");
  XCTAssertEqual(foo.baz, 2);
}

- (void)testCopy
{
  Foo *firstFoo = [Foo new];
  Foo *secondFoo = [firstFoo copyWithBuilder_ahk:^(id<FooBuilder> fooBuilder) {
    fooBuilder.bar = @"new";
    fooBuilder.baz = 2;
  }];

  XCTAssertEqualObjects(secondFoo.bar, @"new");
  XCTAssertEqual(secondFoo.baz, 2);
}


@end
