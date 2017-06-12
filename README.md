# Beaconify [![Build Status](https://travis-ci.org/ktustanowski/Beaconify.svg?branch=master)](https://travis-ci.org/ktustanowski/Beaconify)
Simple and fast way to add beacons support to your application. 

# Integration
## Dependencies
You have to import CoreLocation Framework to your project.
## Neolithic-style
Get files from Beaconify/Classes and paste them in your application.
##Cocoapods
Coming soon...

Remember about **changes in CoreLocation in iOS8** -> 
http://nevan.net/2014/09/core-location-manager-changes-in-ios-8/ 


# Example
Imports.
```objective-c
#import "KTLocationManager.h"
#import "KTNotificationDispatcher+RegionMonitoringNotifications.h"
```
First the location manager must be configured. You have to provide regions to monitor (in this case real beacon and virtual one). Then you specify what type of authorization you are interested in (more information in Changes in CL document linked above). Then you can start monitoring.
```objective-c
    [KTLocationManager sharedInstance].authorizationType = LocationManagerAuthorizationTypeAlways;

    /* Actual estimote beacon region */
    NSUUID *uuid = [[NSUUID alloc] initWithUUIDString:kEstimoteBeaconProximityUUIDString];
    CLBeaconRegion *region = [[CLBeaconRegion alloc] initWithProximityUUID:uuid
                                                                identifier:@"EstimoteBeaconRegion"];

    /* Estimote beacon region emulated on device */
    NSUUID *secondUuid = [[NSUUID alloc] initWithUUIDString:kEstimoteVirtualBeaconProximityUUIDString];
    CLBeaconRegion *secondRegion = [[CLBeaconRegion alloc] initWithProximityUUID:secondUuid
                                                                identifier:@"VirtualEstimoteBeaconRegion"];

    [KTLocationManager sharedInstance].regionsToMonitor = @[region, secondRegion];
    [KTLocationManager sharedInstance].authorizationType = LocationManagerAuthorizationTypeAlways;
    [[KTLocationManager sharedInstance] startMonitoring];
```
Next step is registering to notifications. This three notifications is must-have for most of beacon-related issues and features but you can, and probably should, get more i.e. errors. Consult KTNotificationDispatcher+RegionMonitoringNotifications.h for details.
```objective-c
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didReceiveBeaconList:) name:kRegionMonitoringDidRangeBeaconsNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didEnterRegion:) name:kRegionMonitoringDidEnterNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didExitRegion:) name:kRegionMonitoringDidExitNotification object:nil];
```
When you enter beacon region you will get notification containing this region.
```objective-c
- (void)didEnterRegion:(NSNotification *)notification {
    CLRegion *region = notification.userInfo[kRegionMonitoringRegionKey];
    NSLog(@"Did enter %@ region!", [region identifier]);
}
```
When you exit beacon region you will get notification containing this region.
```objective-c
- (void)didExitRegion:(NSNotification *)notification {
    CLRegion *region = notification.userInfo[kRegionMonitoringRegionKey];
    NSLog(@"Did exit %@ region!", [region identifier]);
}
```
When you enter beacon region ranging will be triggered automatically (you can disable ranging by setting rangeBeaconsWhenInBeaconRegion to NO) and you will be receiving notifications about nearby beacons. Every beacon region (in this case actual and virtual) will create separate notification and beacon list. This example comes from sample application which merges actual and virtual beacons to produce full list.
```objective-c
- (void)didReceiveBeaconList:(NSNotification *)notification
{
    [self updateBeacons:notification.userInfo[kRegionMonitoringBeaconArrayKey]];
}

- (void)updateBeacons:(NSArray *)currentBeacons
{
    CLBeacon *beacon = [currentBeacons lastObject];
    
    if ([self isBeacon:beacon]) {
        self.actualBeacons = currentBeacons;
    } else if ([self isVirtualBeacon:beacon]) {
        self.virtualBeacons = currentBeacons;
    }
    
    self.beacons = [self.actualBeacons arrayByAddingObjectsFromArray:self.virtualBeacons];
    [self.tableView reloadData];
}

- (BOOL)isBeacon:(CLBeacon *)beacon
{
    return [[beacon.proximityUUID UUIDString] isEqualToString:kEstimoteBeaconProximityUUIDString];
}

- (BOOL)isVirtualBeacon:(CLBeacon *)beacon
{
    return [[beacon.proximityUUID UUIDString] isEqualToString:kEstimoteVirtualBeaconProximityUUIDString];
}

```
And thats it. Your application knows the context now and endless possibilities lies on your doorstep.
Good Luck!
