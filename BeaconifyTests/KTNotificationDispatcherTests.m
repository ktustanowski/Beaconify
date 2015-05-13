//
//  KTNotificationDispatcherTests.m
//  BLEchat
//
//  Created by Kamil Tustanowski on 26.02.15.
//  Copyright (c) 2015 Kamil Tustanowski. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <XCTest/XCTest.h>
#import "KTNotificationDispatcher.h"
#import "Expecta.h"
#import "KTNotificationDispatcher+RegionMonitoringNotifications.h"

static NSString  *kTestNotificationName = @"test_notification_name";

@interface KTNotificationDispatcherTests : XCTestCase

@property  (nonatomic, strong) KTNotificationDispatcher *dispatcher;

@end

@implementation KTNotificationDispatcherTests

- (void)setUp {
    [super setUp];
    self.dispatcher = [[KTNotificationDispatcher alloc] init];
}

#pragma mark - Base sending method test

- (void)testIfSenderCanBeSetInInit {
    self.dispatcher = [[KTNotificationDispatcher alloc] initWithDefaultSender:self];

    expect(self.dispatcher.defaultSender).to.beIdenticalTo(self);
}


- (void)testIfNotificationIsSentWhenFullDataIsProvided {
    expect(^{
        [self.dispatcher postNotificationWith:kTestNotificationName
                                                sender:self
                                                  data:nil];
    }).to.postNotification(kTestNotificationName);
}

- (void)testIfNotificationIsSentWhenUsingShorterVersion {
    expect(^{
        [self.dispatcher postNotificationWithName:kTestNotificationName
                                             data:nil];
    }).to.postNotification(kTestNotificationName);
}

#pragma mark - Region monitoring notifications

- (void)testIfAuthorizationDeniedNotificationIsSent {
    expect(^{
        [self.dispatcher postAuthorizationDeniedNotificationWithStatus:kCLAuthorizationStatusNotDetermined];
    }).to.postNotification(kRegionMonitoringAuthorizationDeniedNotification);
}

- (void)testIfErrorNotificationIsSent {
    expect(^{
        [self.dispatcher postErrorNotificationWithError:[[NSError alloc] init]
                                              forRegion:nil
                                           beaconRegion:nil];
    }).to.postNotification(kRegionMonitoringErrorNotification);
}

- (void)testIfStatusNotificationIsSent {
    expect(^{
        [self.dispatcher postStateNotification:CLRegionStateInside forRegion:[[CLRegion alloc] init]];
    }).to.postNotification(kRegionMonitoringStateNotification);
}

- (void)testIfDidEnterRegionNotificationIsSent {
    expect(^{
        [self.dispatcher postDidEnterRegionNotificationWithRegion:[[CLRegion alloc] init]];
    }).to.postNotification(kRegionMonitoringDidEnterNotification);
}

- (void)testIfDidExitRegionNotificationIsSent {
    expect(^{
        [self.dispatcher postDidExitRegionNotificationWithRegion:[[CLRegion alloc] init]];
    }).to.postNotification(kRegionMonitoringDidExitNotification);
}

- (void)testIfDidRangeBeaconsNotificationIsSent {
    expect(^{
        [self.dispatcher postDidRangeBeaconsNotificationWithBeacons:@[] andRegion:(CLBeaconRegion *)[[CLRegion alloc] init]];
    }).to.postNotification(kRegionMonitoringDidRangeBeaconsNotification);
}

@end
