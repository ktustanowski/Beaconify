//
// Created by Kamil Tustanowski on 05.03.15.
// Copyright (c) 2015 Kamil Tustanowski. All rights reserved.
//

#import "NSMutableDictionary+InsertValidObjects.h"


@implementation NSMutableDictionary (InsertValidObjects)

- (void)ifPossibleInsertObject:(id)object forKey:(id <NSCopying>)key {
    if (object && key) {
        [self setObject:object forKey:key];
    }
}

@end