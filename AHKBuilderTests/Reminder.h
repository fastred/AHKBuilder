//
//  Reminder.h
//  AHKBuilder
//
//  Created by Arkadiusz Holko on 11-05-15.
//
//

#import <Foundation/Foundation.h>


@protocol ReminderBuilder <NSObject>

@property (nonatomic, copy, readwrite) NSString *title;
@property (nonatomic, strong, readwrite) NSDate *date;
@property (nonatomic, assign, readwrite) BOOL showsAlert;

@end


@interface Reminder : NSObject

@property (nonatomic, copy, readonly) NSString *title;
@property (nonatomic, strong, readonly) NSDate *date;
@property (nonatomic, assign, readonly) BOOL showsAlert;

@end


@interface Reminder (Builder)

- (instancetype)initWithBuilder_ahk:(void (^)(id<ReminderBuilder> builder))builderBlock;
- (instancetype)copyWithBuilder_ahk:(void (^)(id<ReminderBuilder> builder))builderBlock;

@end