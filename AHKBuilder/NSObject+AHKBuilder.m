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

@interface NSObject (AHKCodableProperties)

- (NSDictionary *)codableProperties;

@end


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

  for (NSString *propertyName in [self codableProperties]) {
    id value = [self valueForKey:propertyName];
    
    if (value && ![value isEqual:[NSNull null]]) {
      [copy setValue:value forKey:propertyName];
    }
  }

  AHKForwarder *forwarder = [[AHKForwarder alloc] initWithTargetObject:copy];
  builderBlock(forwarder);

  return copy;
}

@end

// Original implementation by Nick Lockwood: https://github.com/nicklockwood/AutoCoding/blob/master/AutoCoding/AutoCoding.m
@implementation NSObject (AHKCodableProperties)

+ (NSDictionary *)codablePropertiesForClass
{
  unsigned int propertyCount;
  __autoreleasing NSMutableDictionary *codableProperties = [NSMutableDictionary dictionary];
  objc_property_t *properties = class_copyPropertyList(self, &propertyCount);
  for (unsigned int i = 0; i < propertyCount; i++)
  {
    //get property name
    objc_property_t property = properties[i];
    const char *propertyName = property_getName(property);
    __autoreleasing NSString *key = @(propertyName);
    
    //get property type
    Class propertyClass = nil;
    char *typeEncoding = property_copyAttributeValue(property, "T");
    switch (typeEncoding[0])
    {
      case '@':
      {
        if (strlen(typeEncoding) >= 3)
        {
          char *className = strndup(typeEncoding + 2, strlen(typeEncoding) - 3);
          __autoreleasing NSString *name = @(className);
          NSRange range = [name rangeOfString:@"<"];
          if (range.location != NSNotFound)
          {
            name = [name substringToIndex:range.location];
          }
          propertyClass = NSClassFromString(name) ?: [NSObject class];
          free(className);
        }
        break;
      }
      case 'c':
      case 'i':
      case 's':
      case 'l':
      case 'q':
      case 'C':
      case 'I':
      case 'S':
      case 'L':
      case 'Q':
      case 'f':
      case 'd':
      case 'B':
      {
        propertyClass = [NSNumber class];
        break;
      }
      case '{':
      {
        propertyClass = [NSValue class];
        break;
      }
    }
    free(typeEncoding);
    
    if (propertyClass)
    {
      //check if there is a backing ivar
      char *ivar = property_copyAttributeValue(property, "V");
      if (ivar)
      {
        //check if ivar has KVC-compliant name
        __autoreleasing NSString *ivarName = @(ivar);
        if ([ivarName isEqualToString:key] || [ivarName isEqualToString:[@"_" stringByAppendingString:key]])
        {
          //no setter, but setValue:forKey: will still work
          codableProperties[key] = propertyClass;
        }
        free(ivar);
      }
      else
      {
        //check if property is dynamic and readwrite
        char *dynamic = property_copyAttributeValue(property, "D");
        char *readonly = property_copyAttributeValue(property, "R");
        if (dynamic && !readonly)
        {
          //no ivar, but setValue:forKey: will still work
          codableProperties[key] = propertyClass;
        }
        free(dynamic);
        free(readonly);
      }
    }
  }
  
  free(properties);
  return codableProperties;
}

- (NSDictionary *)codableProperties
{
  __autoreleasing NSDictionary *codableProperties = objc_getAssociatedObject([self class], _cmd);
  if (!codableProperties)
  {
    codableProperties = [NSMutableDictionary dictionary];
    Class subclass = [self class];
    while (subclass != [NSObject class])
    {
      [(NSMutableDictionary *)codableProperties addEntriesFromDictionary:[subclass codablePropertiesForClass]];
      subclass = [subclass superclass];
    }
    codableProperties = [NSDictionary dictionaryWithDictionary:codableProperties];

    //make the association atomically so that we don't need to bother with an @synchronize
    objc_setAssociatedObject([self class], _cmd, codableProperties, OBJC_ASSOCIATION_RETAIN);
  }
  return codableProperties;
}

@end
