/* The MIT License (MIT)
 *
 * Copyright (c) 2015 Kamil Tustanowski (ktustanowski)
 *
 * Permission is hereby granted, free of charge, to any person obtaining a copy
 * of this software and associated documentation files (the "Software"), to deal
 * in the Software without restriction, including without limitation the rights
 * to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
 * copies of the Software, and to permit persons to whom the Software is
 * furnished to do so, subject to the following conditions:
 *
 * The above copyright notice and this permission notice shall be included in all
 * copies or substantial portions of the Software.
 *
 * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 * IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 * FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
 * AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 * LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
 * OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
 * SOFTWARE.
 */

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