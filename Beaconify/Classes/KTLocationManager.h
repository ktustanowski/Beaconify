//
// Created by Kamil Tustanowski on 16.02.15.
// Copyright (c) 2015 Kamil Tustanowski. All rights reserved.
//

#import <Foundation/Foundation.h>
@class CLLocationManager;

typedef NS_ENUM(NSUInteger, LocationManagerAuthorization) {
    LocationManagerAuthorizationTypeAlways = 1,
    LocationManagerAuthorizationTypeWhenInUse = 2
};


@interface KTLocationManager : NSObject

/* 
 * Default authorization type is LocationManagerAuthorizationTypeWhenInUse.
 */
@property (nonatomic) LocationManagerAuthorization authorizationType;

/* 
 * Array of regions to monitor.
 * Max regions count per application is 20!
 */
@property (nonatomic, copy) NSArray *regionsToMonitor;

/*
 * Setting that determines whether beacons ranging will be automatically turned on when entered beacon region.
 * Default value is YES.
 */
@property (nonatomic) BOOL rangeBeaconsWhenInBeaconRegion;

/*
 * Location manager
 */
@property (nonatomic, strong) CLLocationManager *locationManager;

+ (KTLocationManager *)sharedInstance;

/* 
 * Will start monitoring for regions provided in regionsToMonitor.
 * Shows user authorization acceptance dialog.
 */
- (void)startMonitoring;

/* 
 * Will stop monitoring for regions provided in regionsToMonitor.
 */
- (void)stopMonitoring;

@end