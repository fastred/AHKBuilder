//
//  NSInvocation+AHKAdditions.h
//  AHKBuilder
//
//  Created by Arkadiusz Holko on 21-04-15.
//  Copyright (c) 2015 Arkadiusz Holko. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface NSInvocation (AHKAdditions)

- (id)ahk_argumentAtIndex:(NSUInteger)index;

@end
