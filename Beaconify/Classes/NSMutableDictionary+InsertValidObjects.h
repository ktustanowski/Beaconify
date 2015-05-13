//
// Created by Kamil Tustanowski on 05.03.15.
// Copyright (c) 2015 Kamil Tustanowski. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSMutableDictionary (InsertValidObjects)

- (void)ifPossibleInsertObject:(id)object forKey:(id <NSCopying>)key;

@end