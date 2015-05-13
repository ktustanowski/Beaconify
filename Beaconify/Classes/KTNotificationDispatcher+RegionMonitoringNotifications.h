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