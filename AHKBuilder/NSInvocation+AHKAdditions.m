//
//  NSInvocation+AHKAdditions.m
//  AHKBuilder
//
//  Created by Arkadiusz Holko on 21-04-15.
//  Copyright (c) 2015 Arkadiusz Holko. All rights reserved.
//

#import "NSInvocation+AHKAdditions.h"


@implementation NSInvocation (AHKAdditions)

// Thanks to ReactiveCocoa team for providing this method
// Source: https://github.com/ReactiveCocoa/ReactiveCocoa/blob/a2e1f636f98e16e35f8d53201da6ae9d91e232de/ReactiveCocoa/Objective-C/NSInvocation%2BRACTypeParsing.m
- (id)ahk_argumentAtIndex:(NSUInteger)index
{

#define WRAP_AND_RETURN(type) \
do { \
type val = 0; \
[self getArgument:&val atIndex:(NSInteger)index]; \
return @(val); \
} while (0)

  const char *argType = [self.methodSignature getArgumentTypeAtIndex:index];
  // Skip const type qualifier.
  if (argType[0] == 'r') {
    argType++;
  }

  if (strcmp(argType, @encode(id)) == 0 || strcmp(argType, @encode(Class)) == 0) {
    __autoreleasing id returnObj;
    [self getArgument:&returnObj atIndex:(NSInteger)index];
    return returnObj;
  } else if (strcmp(argType, @encode(char)) == 0) {
    WRAP_AND_RETURN(char);
  } else if (strcmp(argType, @encode(int)) == 0) {
    WRAP_AND_RETURN(int);
  } else if (strcmp(argType, @encode(short)) == 0) {
    WRAP_AND_RETURN(short);
  } else if (strcmp(argType, @encode(long)) == 0) {
    WRAP_AND_RETURN(long);
  } else if (strcmp(argType, @encode(long long)) == 0) {
    WRAP_AND_RETURN(long long);
  } else if (strcmp(argType, @encode(unsigned char)) == 0) {
    WRAP_AND_RETURN(unsigned char);
  } else if (strcmp(argType, @encode(unsigned int)) == 0) {
    WRAP_AND_RETURN(unsigned int);
  } else if (strcmp(argType, @encode(unsigned short)) == 0) {
    WRAP_AND_RETURN(unsigned short);
  } else if (strcmp(argType, @encode(unsigned long)) == 0) {
    WRAP_AND_RETURN(unsigned long);
  } else if (strcmp(argType, @encode(unsigned long long)) == 0) {
    WRAP_AND_RETURN(unsigned long long);
  } else if (strcmp(argType, @encode(float)) == 0) {
    WRAP_AND_RETURN(float);
  } else if (strcmp(argType, @encode(double)) == 0) {
    WRAP_AND_RETURN(double);
  } else if (strcmp(argType, @encode(BOOL)) == 0) {
    WRAP_AND_RETURN(BOOL);
  } else if (strcmp(argType, @encode(char *)) == 0) {
    WRAP_AND_RETURN(const char *);
  } else if (strcmp(argType, @encode(void (^)(void))) == 0) {
    __unsafe_unretained id block = nil;
    [self getArgument:&block atIndex:(NSInteger)index];
    return [block copy];
  } else {
    NSUInteger valueSize = 0;
    NSGetSizeAndAlignment(argType, &valueSize, NULL);

    unsigned char valueBytes[valueSize];
    [self getArgument:valueBytes atIndex:(NSInteger)index];

    return [NSValue valueWithBytes:valueBytes objCType:argType];
  }
  
  return nil;
  
#undef WRAP_AND_RETURN
}

@end
