[![Build Status](https://travis-ci.org/fastred/AHKBuilder.svg?branch=master)](https://travis-ci.org/fastred/AHKBuilder)
[![Carthage compatible](https://img.shields.io/badge/Carthage-compatible-4BC51D.svg?style=flat)](https://github.com/Carthage/Carthage)

# AHKBuilder


`AHKBuilder` allows you to add initialization based on the builder pattern to your immutable objects with ease. Implementation is described in the blog post: http://holko.pl/2015/05/12/immutable-object-initialization/

## Usage

Let's say you have a simple `Reminder` class:

```obj-c
@interface Reminder : NSObject

@property (nonatomic, copy, readonly) NSString *title;
@property (nonatomic, strong, readonly) NSDate *date;
@property (nonatomic, assign, readonly) BOOL showsAlert;

@end
```

With just three simple steps you can add ability to your classes to be initialized with the builder block:

1. Import `AHKBuilder` with `#import <AHKBuilder/AHKBuilder.h>`

2. Add a protocol declaring same properties as your immutable class, but with `readwrite` modifier, in our case:
  
  ```obj-c
  @protocol ReminderBuilder <NSObject>
  
  @property (nonatomic, copy, readwrite) NSString *title;
  @property (nonatomic, strong, readwrite) NSDate *date;
  @property (nonatomic, assign, readwrite) BOOL showsAlert;
  
  @end
  ```

3. Declare initialization and/or copying method using the name of protocol from 1.
  
  ```obj-c
  @interface Reminder (Builder)
  
  - (instancetype)initWithBuilder_ahk:(void (^)(id<ReminderBuilder> builder))builderBlock;
  - (instancetype)copyWithBuilder_ahk:(void (^)(id<ReminderBuilder> builder))builderBlock;
  
  @end
  ```
  Note: These methods have to be declared in a category, otherwise Xcode will complain that their definitions are missing.

That's all! You can now create instances and copies using these methods, e.g.:

```obj-c
Reminder *reminder = [[Reminder alloc] initWithBuilder_ahk:^(id<ReminderBuilder> builder) {
  builder.title = @"Test reminder";
}];
```

## Requirements

 * iOS 8 and above

## Installation

Source files can be found in `AHKBuilder` folder. `AHKBuilder` is compatible with Carthage.

## Changelog

### 0.2
Fixed crash when working with objects conforming to protocols inheriting from NSObject.

### 0.1
Initial release.

## Author

Arkadiusz Holko:

* [Blog](http://holko.pl/)
* [@arekholko on Twitter](https://twitter.com/arekholko)
