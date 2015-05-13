//
// Created by Kamil Tustanowski on 26.02.15.
// Copyright (c) 2015 Kamil Tustanowski. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface KTNotificationDispatcher : NSObject

@property  (nonatomic, weak) id defaultSender;

- (instancetype)initWithDefaultSender:(id)defaultSender;

- (void)postNotificationWith:(NSString *)notificationName
                      sender:(id)sender
                        data:(NSDictionary *)data;

- (void)postNotificationWithName:(NSString *)name
                            data:(NSDictionary *)data;

@end