//
// Created by Kamil Tustanowski on 26.02.15.
// Copyright (c) 2015 Kamil Tustanowski. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "KTNotificationDispatcher.h"
#import <CoreLocation/CoreLocation.h>

static NSString *const kRegionMonitoringAuthorizationDeniedNotification = @"RegionMonitoringAuthorizationDeniedNotification";
static NSString *const kRegionMonitoringAuthorizationDeniedStatusKey = @"RegionMonitoringAuthorizationDeniedStatus";

static NSString *const kRegionMonitoringErrorNotification = @"RegionMonitoringErrorNotification";
static NSString *const kRegionMonitoringErrorNotificationErrorKey = @"RegionMonitoringErrorNotification";
static NSString *const kRegionMonitoringFailedRegionErrorKey = @"RegionMonitoringFailedRegionErrorKey";
static NSString *const kRegionMonitoringFailedBeaconRegionErrorKey = @"RegionMonitoringFailedBeaconRegionErrorKey";

static NSString *const kRegionMonitoringStateNotification = @"RegionMonitoringStateNotification";
static NSString *const kRegionMonitoringStateKey = @"RegionMonitoringStateKey";

static NSString *const kRegionMonitoringRegionKey = @"RegionMonitoringStateKey";

static NSString *const kRegionMonitoringDidEnterNotification = @"RegionMonitoringDidEnterNotification";
/* also posts kRegionMonitoringRegionKey : CLRegion in data */

static NSString *const kRegionMonitoringDidExitNotification = @"RegionMonitoringDidExitNotification";
/* also posts kRegionMonitoringRegionKey : CLRegion in data */

static NSString *const kRegionMonitoringDidRangeBeaconsNotification = @"RegionMonitoringDidRangeBeaconsNotification";
static NSString *const kRegionMonitoringBeaconArrayKey = @"kRegionMonitoringBeaconArrayKey";
/* also posts kRegionMonitoringRegionKey : CLBeaconRegion in data */

@interface KTNotificationDispatcher (RegionMonitoringNotifications)

- (void)postAuthorizationDeniedNotificationWithStatus:(CLAuthorizationStatus)status;

- (void)postErrorNotificationWithError:(NSError *)error
                             forRegion:(CLRegion *)region
                          beaconRegion:(CLBeaconRegion *)beaconRegion;

- (void)postStateNotification:(CLRegionState)state
                    forRegion:(CLRegion *)region;

- (void)postDidEnterRegionNotificationWithRegion:(CLRegion *)region;

- (void)postDidExitRegionNotificationWithRegion:(CLRegion *)region;

- (void)postDidRangeBeaconsNotificationWithBeacons:(NSArray *)beacons
                                         andRegion:(CLBeaconRegion *)region;

@end