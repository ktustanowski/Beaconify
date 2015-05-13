//
// Created by Kamil Tustanowski on 26.02.15.
// Copyright (c) 2015 Kamil Tustanowski. All rights reserved.
//

#import "KTNotificationDispatcher.h"


@implementation KTNotificationDispatcher


- (instancetype)initWithDefaultSender:(id)defaultSender {
    self = [super init];
    if (self) {
        _defaultSender = defaultSender;
    }

    return self;
}

- (void)postNotificationWith:(NSString *)notificationName
                      sender:(id)sender
                        data:(NSDictionary *)data {
    [[NSNotificationCenter defaultCenter] postNotificationName:notificationName
                                                        object:sender
                                                      userInfo:data];
}

- (void)postNotificationWithName:(NSString *)name
                            data:(NSDictionary *)data {
    [self postNotificationWith:name
                        sender:self.defaultSender
                          data:data];
}

@end