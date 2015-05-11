//
//  NSObject+AHKBuilder.m
//  AHKBuilder
//
//  Created by Arkadiusz Holko on 19-04-15.
//  Copyright (c) 2015 Arkadiusz Holko. All rights reserved.
//

#import "NSObject+AHKBuilder.h"

#import <objc/runtime.h>
#import "NSInvocation+AHKAdditions.h"


static  NSString *getterNameFromSetterSelector(SEL selector) {
  const NSString *setterName = NSStringFromSelector(selector);
  NSString *getterName = [setterName substringFromIndex:3];
  getterName = [getterName stringByReplacingCharactersInRange:NSMakeRange(0, 1) withString:[[getterName substringToIndex:1] lowercaseString]];
  getterName = [getterName substringToIndex:getterName.length - 1];

  return getterName;
}

static BOOL isSelectorASetter(SEL selector) {
  // simple implementation, won't work with custom setter names
  NSString *selectorString = NSStringFromSelector(selector);
  return [selectorString hasPrefix:@"set"];
}


@interface AHKForwarder : NSObject

@property (nonatomic, strong) id targetObject;

@end


@implementation AHKForwarder

- (instancetype)initWithTargetObject:(id)object
{
  NSParameterAssert(object);
  self = [super init];
  if (self) {
    self.targetObject = object;
  }

  return self;
}

- (NSMethodSignature *)methodSignatureForSelector:(SEL)sel
{
  if (isSelectorASetter(sel)) {
    NSString *getterName = getterNameFromSetterSelector(sel);
    Method method = class_getInstanceMethod([self.targetObject class], NSSelectorFromString(getterName));

    const NSInteger stringLength = 255;
    char dst[stringLength];
    method_getReturnType(method, dst, stringLength);

    NSString *returnType = @(dst);
    NSString *objCTypes = [@"v@:" stringByAppendingString:returnType];

    return [NSMethodSignature signatureWithObjCTypes:[objCTypes UTF8String]];
  } else {
    return [self.targetObject methodSignatureForSelector:sel];
  }
}

- (void)forwardInvocation:(NSInvocation *)invocation
{
  if (isSelectorASetter(invocation.selector)) {
    NSString *getterName = getterNameFromSetterSelector(invocation.selector);
    id argument = [invocation ahk_argumentAtIndex:2];
    [self.targetObject setValue:argument forKey:getterName];
  } else {
    invocation.target = self.targetObject;
    [invocation invoke];
  }
}

@end



@implementation NSObject (AHKBuilder)

- (instancetype)initWithBuilder_ahk:(void (^)(id))builderBlock
{
  NSParameterAssert(builderBlock);
  self = [self init];
  if (self) {
    AHKForwarder *forwarder = [[AHKForwarder alloc] initWithTargetObject:self];
    builderBlock(forwarder);
  }

  return self;
}

- (instancetype)copyWithBuilder_ahk:(void (^)(id))builderBlock
{
  id copy = [[[self class] alloc] init];

  unsigned int count = 0;
  objc_property_t *properties = class_copyPropertyList([self class], &count);

  for (unsigned int i = 0; i < count; i++) {
    objc_property_t property = properties[i];
    NSString *propertyName = @(property_getName(property));

    id value = [self valueForKey:propertyName];

    if (value && ![value isEqual:[NSNull null]]) {
      [copy setValue:value forKey:propertyName];
    }
  }

  free(properties);

  AHKForwarder *forwarder = [[AHKForwarder alloc] initWithTargetObject:copy];
  builderBlock(forwarder);

  return copy;
}

@end
