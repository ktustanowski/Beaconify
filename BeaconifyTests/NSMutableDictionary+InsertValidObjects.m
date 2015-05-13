//
//  NSMutableDictionary+InsertValidObjects.m
//  BLEchat
//
//  Created by Kamil Tustanowski on 05.03.15.
//  Copyright (c) 2015 Kamil Tustanowski. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <XCTest/XCTest.h>
#import "NSMutableDictionary+InsertValidObjects.h"
#import "Expecta.h"

static NSString *const kObject = @"string";
static NSString *const kKey = @"key";

@interface NSMutableDictionary_InsertValidObjects : XCTestCase

@property (nonatomic, strong) NSMutableDictionary *mutableDictionary;

@end

@implementation NSMutableDictionary_InsertValidObjects

- (void)setUp {
    [super setUp];
    self.mutableDictionary = [[NSMutableDictionary alloc] init];
}

- (void)testIfSettingNilObjectAndNilKeyDontRaiseException {
    expect(^{
        [self.mutableDictionary ifPossibleInsertObject:nil forKey:nil];
    }).toNot.raiseAny();
}

- (void)testIfSettingNilObjectDontRaiseException {
    expect(^{
        [self.mutableDictionary ifPossibleInsertObject:nil forKey:kKey];
    }).toNot.raiseAny();
}

- (void)testIfSettingNilKeyDontRaiseException {
    expect(^{
        [self.mutableDictionary ifPossibleInsertObject:kObject forKey:nil];
    }).toNot.raiseAny();
}

- (void)testIfSettingObjectAndKeyWorksProperly {
    [self.mutableDictionary ifPossibleInsertObject:kObject forKey:kKey];

    expect([self.mutableDictionary count]).to.equal(1);
    expect(self.mutableDictionary[kKey]).to.beIdenticalTo(kObject);
}

@end
