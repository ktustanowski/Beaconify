//
//  ViewController.m
//  Regionify
//
//  Created by Kamil Tustanowski on 15.03.2015.
//  Copyright (c) 2015 Kamil Tustanowski. All rights reserved.
//

#import "ViewController.h"
#import "KTLocationManager.h"
#import "KTNotificationDispatcher+RegionMonitoringNotifications.h"

static NSString *kBeaconCellIdentifier = @"BeaconCellIdentifier";
static NSString *kEstimoteBeaconProximityUUIDString = @"B9407F30-F5F8-466E-AFF9-25556B57FE6D";
static NSString *kEstimoteVirtualBeaconProximityUUIDString = @"8492E75F-4FD6-469D-B132-043FE94921D8";

@interface ViewController ()

@property (nonatomic, strong) NSArray *beacons;
@property (nonatomic, strong) NSArray *actualBeacons;
@property (nonatomic, strong) NSArray *virtualBeacons;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self startRegionMonitoring];
    [self registerForNotifications];
}

- (void)startRegionMonitoring
{
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
}

- (void)registerForNotifications
{
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didReceiveBeaconList:) name:kRegionMonitoringDidRangeBeaconsNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didEnterRegion:) name:kRegionMonitoringDidEnterNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didExitRegion:) name:kRegionMonitoringDidExitNotification object:nil];
}

- (void)didEnterRegion:(NSNotification *)notification {
    CLRegion *region = notification.userInfo[kRegionMonitoringRegionKey];
    NSLog(@"Did enter %@ region!", [region identifier]);
}

- (void)didExitRegion:(NSNotification *)notification {
    CLRegion *region = notification.userInfo[kRegionMonitoringRegionKey];
    NSLog(@"Did exit %@ region!", [region identifier]);
}

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

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [self.beacons count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:kBeaconCellIdentifier forIndexPath:indexPath];
    
    CLBeacon *beacon = self.beacons[indexPath.row];
    cell.textLabel.text = [NSString stringWithFormat:@"Major: %@ Minor: %@ RSSI: %ld", beacon.major, beacon.minor, (long)beacon.rssi];
    cell.detailTextLabel.text = [beacon.proximityUUID UUIDString];
    
    return cell;
}

- (void)dealloc
{
    [self unregisterFromNotifications];
}

- (void)unregisterFromNotifications
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

@end
