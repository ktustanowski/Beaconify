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