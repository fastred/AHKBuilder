//
//  Reminder.m
//  AHKBuilder
//
//  Created by Arkadiusz Holko on 11-05-15.
//
//

#import "Reminder.h"

#import "NSObject+AHKBuilder.h"


@implementation Reminder

- (instancetype)init
{
  self = [super init];
  if (self) {
    _showsAlert = YES;
  }
  return self;
}

@end
