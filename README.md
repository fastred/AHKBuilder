# AHKBuilder

`AHKBuilder` allows you to add initialization based on the builder pattern to your immutable objects with ease.

## Usage

Let's say you have a simple `Reminder` class:

```obj-c
@interface Reminder : NSObject

@property (nonatomic, copy, readonly) NSString *title;
@property (nonatomic, strong, readonly) NSDate *date;
@property (nonatomic, assign, readonly) BOOL showsAlert;

@end
```

You have to perform two steps to allow initialization using a builder block:

1. Add a protocol declaring same properties as your immutable class, but with `readwrite` modifier, in our case:
  
  ```obj-c
  @protocol ReminderBuilder <NSObject>
  
  @property (nonatomic, copy, readwrite) NSString *title;
  @property (nonatomic, strong, readwrite) NSDate *date;
  @property (nonatomic, assign, readwrite) BOOL showsAlert;
  
  @end
  ```

2. Declare initialization and/or copying method using the name of protocol from 1.
  
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

 * iOS 7 and above

## Installation

Source files can be found in `AHKBuilder` folder.

## Author

Arkadiusz Holko:

* [Blog](http://holko.pl/)
* [@arekholko on Twitter](https://twitter.com/arekholko)
