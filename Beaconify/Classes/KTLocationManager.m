//
// Created by Kamil Tustanowski on 16.02.15.
// Copyright (c) 2015 Kamil Tustanowski. All rights reserved.
//

#import "KTLocationManager.h"
#import "KTNotificationDispatcher.h"
#import "KTNotificationDispatcher+RegionMonitoringNotifications.h"

static NSUInteger const kMaxRegionCount = 20;

@interface KTLocationManager () <CLLocationManagerDelegate>

@property (nonatomic, strong) KTNotificationDispatcher *notificationDispatcher;

@end

@implementation KTLocationManager

#pragma mark - Singleton Creation

+ (KTLocationManager *)sharedInstance {
    static KTLocationManager *sharedInstance;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedInstance = [[self alloc] init];
    });
    return sharedInstance;
}

- (instancetype)init {
    self = [super init];
    if (self) {
        _authorizationType = LocationManagerAuthorizationTypeWhenInUse;
        _rangeBeaconsWhenInBeaconRegion = YES;
    }
    return self;
}

- (KTNotificationDispatcher *)notificationDispatcher {
    if (!_notificationDispatcher) {
        _notificationDispatcher = [[KTNotificationDispatcher alloc] initWithDefaultSender:self];
    }

    return _notificationDispatcher;
}

- (void)setRegionsToMonitor:(NSArray *)regionsToMonitor {
    BOOL canMonitorProposedNumberOfRegions = [regionsToMonitor count] <= kMaxRegionCount;

    if (canMonitorProposedNumberOfRegions) {
        [self stopMonitoringRegions];
        _regionsToMonitor = [regionsToMonitor copy];
    } else {
        [self throwExceptionBecauseOfExceededMaxRegionCount];
    }
}

- (void)stopMonitoringRegions {
    /* TODO: stop monitoring only for regions not present in new regionsToMonitor array */
    for (CLRegion *region in self.locationManager.monitoredRegions) {
        [self.locationManager stopMonitoringForRegion:region];
    }
}

- (CLLocationManager *)locationManager
{
    if (!_locationManager) {
        _locationManager = [[CLLocationManager alloc] init];
        _locationManager.delegate = self;
    }
    
    return _locationManager;
}

- (void)throwExceptionBecauseOfExceededMaxRegionCount {
    @throw([[NSException alloc] initWithName:NSInternalInconsistencyException
                                      reason:[NSString stringWithFormat:@"Can't monitor more than %lu regions at a time!", (unsigned long)kMaxRegionCount]
                                    userInfo:nil]);
}

- (void)startMonitoring {
    SEL authorizationSelector = [self authorizationSelector];
    if ([self.locationManager respondsToSelector:authorizationSelector]) {
        [self safelyPerformSelector:authorizationSelector]; /* iOS 8 */
    } else {
        [self startMonitoringRegions]; /* iOS 7 */
    }
}

- (void)safelyPerformSelector:(SEL)selector
{
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Warc-performSelector-leaks"
    [self.locationManager performSelector:selector];
#pragma clang diagnostic pop
/* TODO: Solve problem of null imp when using mock in tests */
//    IMP imp = [self.locationManager methodForSelector:selector];
//    void (*function)(id, SEL) = (void *)imp;
//    function(self.locationManager, selector);
}

- (void)startMonitoringRegions {
    for (CLRegion *region in self.regionsToMonitor) {
        [self.locationManager startMonitoringForRegion:region];
    }
}

- (SEL)authorizationSelector /* factory ?? */
{
    switch (self.authorizationType) {
        case LocationManagerAuthorizationTypeAlways:
            return @selector(requestAlwaysAuthorization);
        case LocationManagerAuthorizationTypeWhenInUse:
            return @selector(requestWhenInUseAuthorization);
    }
}

- (void)stopMonitoring {
    [self stopMonitoringRegions];
}

#pragma mark - Location Manager Delegate

- (void)locationManager:(CLLocationManager *)manager didChangeAuthorizationStatus:(CLAuthorizationStatus)status {
    if ([self accessIsGrantedWithStatus:status]) {
        [self startMonitoringRegions];
    } else {
        [self.notificationDispatcher postAuthorizationDeniedNotificationWithStatus:status];
    }
}

- (BOOL)accessIsGrantedWithStatus:(CLAuthorizationStatus)status {
    return status == kCLAuthorizationStatusAuthorizedAlways || status == kCLAuthorizationStatusAuthorizedWhenInUse;
}


- (void)locationManager:(CLLocationManager *)manager
        monitoringDidFailForRegion:(CLRegion *)region
              withError:(NSError *)error {
    [self.notificationDispatcher postErrorNotificationWithError:error
                                                      forRegion:region
                                                   beaconRegion:nil];
}

- (void)locationManager:(CLLocationManager *)manager didFailWithError:(NSError *)error {
    [self.notificationDispatcher postErrorNotificationWithError:error
                                                      forRegion:nil
                                                   beaconRegion:nil];
}

- (void)locationManager:(CLLocationManager *)manager
      didDetermineState:(CLRegionState)state
              forRegion:(CLRegion *)region {
    [self.notificationDispatcher postStateNotification:state
                                             forRegion:region];
    BOOL isInside = state == CLRegionStateInside;

    if (isInside) {
        [self postDidEnterRegionNotification:region];
    }

    if ([self isBeaconRegion:region]) {
        [self handleBeaconRegion:(CLBeaconRegion *)region
                          inside:isInside];
    }
}

- (void)postDidEnterRegionNotification:(CLRegion *)region {
    [self.notificationDispatcher postDidEnterRegionNotificationWithRegion:region];
}

- (void)handleBeaconRegion:(CLBeaconRegion *)region
                    inside:(BOOL)isInside {
    if (isInside) {
        [self startRangingBeaconsForRegion:region];
    } else {
        [self stopRangingBeaconsForRegion:region];
    }
}

- (BOOL)isBeaconRegion:(CLRegion *)region {
    return [region isKindOfClass:[CLBeaconRegion class]];
}

- (void)startRangingBeaconsForRegion:(CLBeaconRegion *)region
{
    if (self.rangeBeaconsWhenInBeaconRegion) {
        [self.locationManager startRangingBeaconsInRegion:region];
    }
}

- (void)stopRangingBeaconsForRegion:(CLBeaconRegion *)region {
    [self.locationManager stopRangingBeaconsInRegion:region];
}

- (void)locationManager:(CLLocationManager *)manager didEnterRegion:(CLRegion *)region {
    [self.notificationDispatcher postDidEnterRegionNotificationWithRegion:region];
    if ([CLLocationManager isRangingAvailable]) {
        [self startRangingBeaconsForRegion:(CLBeaconRegion *) region];
    }
}

- (void)locationManager:(CLLocationManager *)manager didExitRegion:(CLRegion *)region {
    [self.notificationDispatcher postDidExitRegionNotificationWithRegion:region];
    [self stopRangingBeaconsForRegion:(CLBeaconRegion *) region];
}

- (void)locationManager:(CLLocationManager *)manager rangingBeaconsDidFailForRegion:(CLBeaconRegion *)region
              withError:(NSError *)error {
    [self.notificationDispatcher postErrorNotificationWithError:error
                                                      forRegion:nil
                                                   beaconRegion:region];
}

- (void)locationManager:(CLLocationManager *)manager
        didRangeBeacons:(NSArray *)beacons
               inRegion:(CLBeaconRegion *)region {
    [self.notificationDispatcher postDidRangeBeaconsNotificationWithBeacons:beacons
                                                                  andRegion:region];
}

@end