//
//  NSObject+AHKBuilder.h
//  AHKBuilder
//
//  Created by Arkadiusz Holko on 19-04-15.
//  Copyright (c) 2015 Arkadiusz Holko. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface NSObject (AHKBuilder)

- (instancetype)initWithBuilder_ahk:(void (^)(id))builderBlock;
- (instancetype)copyWithBuilder_ahk:(void (^)(id))builderBlock;

@end
