//
// Created by Kamil Tustanowski on 26.02.15.
// Copyright (c) 2015 Kamil Tustanowski. All rights reserved.
//

#import "KTNotificationDispatcher+RegionMonitoringNotifications.h"
#import "NSMutableDictionary+InsertValidObjects.h"


@implementation KTNotificationDispatcher (RegionMonitoringNotifications)

- (void)postAuthorizationDeniedNotificationWithStatus:(CLAuthorizationStatus)status {
    [self postNotificationWithName:kRegionMonitoringAuthorizationDeniedNotification
                              data:@{kRegionMonitoringAuthorizationDeniedStatusKey :[NSNumber numberWithInt:status]}];
}

- (void)postErrorNotificationWithError:(NSError *)error
                             forRegion:(CLRegion *)region
                          beaconRegion:(CLBeaconRegion *)beaconRegion {

    NSMutableDictionary *mutableData = [NSMutableDictionary dictionary];
    [mutableData ifPossibleInsertObject:error forKey:kRegionMonitoringErrorNotificationErrorKey];
    [mutableData ifPossibleInsertObject:region forKey:kRegionMonitoringFailedRegionErrorKey];
    [mutableData ifPossibleInsertObject:beaconRegion forKey:kRegionMonitoringFailedBeaconRegionErrorKey];

    [self postNotificationWithName:kRegionMonitoringErrorNotification
                              data:[mutableData copy]];
}

- (void)postStateNotification:(CLRegionState)state
                    forRegion:(CLRegion *)region {
    [self postNotificationWithName:kRegionMonitoringStateNotification
                              data:@{kRegionMonitoringStateKey : [NSNumber numberWithInt:state],
                                      kRegionMonitoringRegionKey : region}];
}

- (void)postDidEnterRegionNotificationWithRegion:(CLRegion *)region {
    [self postNotificationWithName:kRegionMonitoringDidEnterNotification andRegion:region];
}

- (void)postDidExitRegionNotificationWithRegion:(CLRegion *)region {
    [self postNotificationWithName:kRegionMonitoringDidExitNotification andRegion:region];
}

- (void)postDidRangeBeaconsNotificationWithBeacons:(NSArray *)beacons
                                         andRegion:(CLBeaconRegion *)region {
    [self postNotificationWithName:kRegionMonitoringDidRangeBeaconsNotification
                              data:@{kRegionMonitoringBeaconArrayKey : beacons,
                                      kRegionMonitoringRegionKey : region}];
}

- (void)postNotificationWithName:(NSString *)name andRegion:(CLRegion *)region {
    [self postNotificationWithName:name
                              data:@{kRegionMonitoringRegionKey : region}];
}

@end