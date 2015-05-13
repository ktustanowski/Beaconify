//
//  KTLocationManagerTests.m
//  BLEchat
//
//  Created by Kamil Tustanowski on 18.02.15.
//  Copyright (c) 2015 Kamil Tustanowski. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <XCTest/XCTest.h>
#import "KTLocationManager.h"
#import "Expecta.h"
#import "CoreLocation/CoreLocation.h"
#import "HCIsAnything.h"
#import "KTNotificationDispatcher+RegionMonitoringNotifications.h"

#define HC_SHORTHAND

#import <OCHamcrest/OCHamcrest.h>

#define MOCKITO_SHORTHAND

#import <OCMockito/OCMockito.h>

@interface KTLocationManager () <CLLocationManagerDelegate>

- (SEL)authorizationSelector;
- (void)startMonitoringRegions;
- (BOOL)accessIsGrantedWithStatus:(CLAuthorizationStatus)status;
- (BOOL)isBeaconRegion:(CLRegion *)region;
- (void)startRangingBeaconsForRegion:(CLBeaconRegion *)region;

@end

@interface KTLocationManagerTests : XCTestCase

@property (nonatomic, strong) KTLocationManager *manager;

@end

@implementation KTLocationManagerTests

- (void)setUp {
    [super setUp];
    self.manager = [[KTLocationManager alloc] init];
}

- (void)testIfClassIsSingleton {
    KTLocationManager *managerOne = [KTLocationManager sharedInstance];
    KTLocationManager *managerTwo = [KTLocationManager sharedInstance];

    expect(managerOne).toNot.beNil();
    expect(managerOne).to.beIdenticalTo(managerTwo);
}

- (void)testIfAuthorizationTypeCanBeSet {
    [self provideAuthorizationType:LocationManagerAuthorizationTypeAlways];

    expect(self.manager.authorizationType).to.equal(LocationManagerAuthorizationTypeAlways);
}

- (void)testIfDefaultAuthorizationTypeIsWhenInUse {
    expect(self.manager.authorizationType).to.equal(LocationManagerAuthorizationTypeWhenInUse);
}

- (void)testIfForAuthorizationAlwaysCorrectSelectorIsReturned {
    SEL selector = [self simulateSelectorRequestForAuthorization:LocationManagerAuthorizationTypeAlways];

    expect(selector).to.equal(@selector(requestAlwaysAuthorization));
}

- (void)testIfForAuthorizationWhenInUseCorrectSelectorIsReturned {
    SEL selector = [self simulateSelectorRequestForAuthorization:LocationManagerAuthorizationTypeWhenInUse];

    expect(selector).to.equal(@selector(requestWhenInUseAuthorization));
}

- (void)testIfSelectedSelectorIsPassedToCLLocationManagerOnIos8 {
    [self provideAuthorizationType:LocationManagerAuthorizationTypeWhenInUse];
    [self connectLocationManagerMock];
    [self.manager startMonitoring];

    [verify([self locationManagerMock]) requestWhenInUseAuthorization];
}

- (void)testIfRegionsToMonitorByDefaultAreNil {
    expect(self.manager.regionsToMonitor).to.beNil();
}

- (void)testIfRegionsToMonitorCanBeSet {
    NSArray *array = [NSArray array];
    self.manager.regionsToMonitor = array;

    expect(self.manager.regionsToMonitor).to.beIdenticalTo(array);
}

- (void)testIfRegionsToMonitorCantBeSetToAboveTwenty {
    NSUInteger regionCount = 21;

    expect(^{
        [self simulateAddingRegionsCount:regionCount];
    }).to.raise(NSInternalInconsistencyException);
}

- (void)testIfStartMonitoringRegionsInvokesStartMonitoringRegionOneTimeForEveryRegionWhenThereAreRegions {
    NSUInteger regionCount = 3;
    [self simulateAddingRegionsCount:regionCount];
    [self connectLocationManagerMock];
    [self.manager startMonitoringRegions];

    expect([self numberOfRegions]).to.beGreaterThan(0);
    [verifyCount([self locationManagerMock], times(regionCount)) startMonitoringForRegion:HC_anything()];
}

- (void)testIfSettingRegionsToMonitorCausesInvocationOfStopMonitoringForRegionForEveryRegionAlreadyRegistered {
    NSUInteger regionCount = 3;
    [self simulateAddingRegionsCount:regionCount];
    [self connectLocationManagerMock];
    [given([[self locationManagerMock] monitoredRegions]) willReturn:self.manager.regionsToMonitor];
    [self simulateAddingRegionsCount:1];

    [verifyCount([self locationManagerMock], times(regionCount)) stopMonitoringForRegion:HC_anything()];
}

- (void)testIfAuthorizationStateAlwaysResultsInAccessGrantedYes {
    BOOL accessIsGranted = [self.manager accessIsGrantedWithStatus:kCLAuthorizationStatusAuthorizedAlways];

    expect(accessIsGranted).to.beTruthy();
}

- (void)testIfAuthorizationStateWhenInUseResultsInAccessGrantedYes {
    BOOL accessIsGranted = [self.manager accessIsGrantedWithStatus:kCLAuthorizationStatusAuthorizedWhenInUse];

    expect(accessIsGranted).to.beTruthy();
}

- (void)testIfAuthorizationStateDeniedResultsInAccessGrantedNo {
    BOOL accessIsGranted = [self.manager accessIsGrantedWithStatus:kCLAuthorizationStatusDenied];

    expect(accessIsGranted).to.beFalsy();
}

- (void)testIfAuthorizationStateNotDeterminedResultsInAccessGrantedNo {
    BOOL accessIsGranted = [self.manager accessIsGrantedWithStatus:kCLAuthorizationStatusNotDetermined];

    expect(accessIsGranted).to.beFalsy();
}

- (void)testIfAuthorizationStateRestrictedResultsInAccessGrantedNo {
    BOOL accessIsGranted = [self.manager accessIsGrantedWithStatus:kCLAuthorizationStatusRestricted];

    expect(accessIsGranted).to.beFalsy();
}

- (void)testIfAuthorizationIsSuccessfulManagerStartToMonitoringRegions {
    [self simulateAddingRegionsCount:1];
    [self connectLocationManagerMock];

    [(id <CLLocationManagerDelegate>) self.manager locationManager:nil
                                      didChangeAuthorizationStatus:kCLAuthorizationStatusAuthorizedAlways];

    [verify([self locationManagerMock]) startMonitoringForRegion:HC_anything()];
}

- (void)testIfAuthorizationIsDeniedNotificationIsSent {
    expect(^{
        [self.manager locationManager:nil
         didChangeAuthorizationStatus:kCLAuthorizationStatusDenied];
    }).to.postNotification(kRegionMonitoringAuthorizationDeniedNotification);
}

- (void)testIfErrorNotificationIsSentWhenMonitoringFail {
    expect(^{
        [self.manager locationManager:nil didFailWithError:[[NSError alloc] init]];
    }).to.postNotification(kRegionMonitoringErrorNotification);
}

- (void)testIfErrorNotificationIsSentWhenMonitoringFailForRegion {
    expect(^{
        [self.manager locationManager:nil
           monitoringDidFailForRegion:[[CLRegion alloc] init]
                            withError:[[NSError alloc] init]];
    }).to.postNotification(kRegionMonitoringErrorNotification);
}

- (void)testIfErrorNotificationIsSentWhenRangingBeaconsFail {
    expect(^{
        [self.manager locationManager:nil
       rangingBeaconsDidFailForRegion:[[CLBeaconRegion alloc] init]
                            withError:[[NSError alloc] init]];
    }).to.postNotification(kRegionMonitoringErrorNotification);
}

//- (void)testIfStartMonitoringForRegionIsPassedToCLLocationManagerOnIos7 {
//    /* TODO: will work when simulateIos7 will be implemented */
//    [self simulateAddingRegionsCount:1];
//    [self connectLocationManagerMock];
//    [self simulateIos7];
//
//    [self.manager startMonitoring];
//
//    [verify([self locationManagerMock]) startMonitoringForRegion:HC_anything()];
//}

- (void)testIfDidDetermineStateForRegionSendsStatusNotification {
    [self connectLocationManagerMock];

    NSArray *states = [self regionStates];
    for (NSNumber *stateNumber in states) {
        expect(^{
            [self simulateDeterminingStateForRegion:[stateNumber intValue]];
        }).to.postNotification(kRegionMonitoringStateNotification);
    }

    [verifyCount(self.manager.locationManager, times(0)) startRangingBeaconsInRegion:HC_anything()];
    [verifyCount(self.manager.locationManager, times(0)) stopRangingBeaconsInRegion:HC_anything()];
}

- (void)testIfDidDetermineStateForRegionDoNotRangeBeaconsWhenConfiguredNotTo {
    [self connectLocationManagerMock];
    self.manager.rangeBeaconsWhenInBeaconRegion = NO;

    [self.manager startRangingBeaconsForRegion:nil];
    
    [verifyCount(self.manager.locationManager, times(0)) startRangingBeaconsInRegion:HC_anything()];
    [verifyCount(self.manager.locationManager, times(0)) stopRangingBeaconsInRegion:HC_anything()];
}

- (void)testIfDidDetermineStateForRegionDoesNothingForCircularRegion {
    [self connectLocationManagerMock];

    NSArray *states = [self regionStates];
    for (NSNumber *stateNumber in states) {
        [self simulateDeterminingStateForCircularRegion:[stateNumber integerValue]];
    }

    [verifyCount(self.manager.locationManager, times(0)) startRangingBeaconsInRegion:HC_anything()];
    [verifyCount(self.manager.locationManager, times(0)) stopRangingBeaconsInRegion:HC_anything()];
}

- (void)testIfDidDetermineStateForRegionStartOrStopRangingBeaconsDependingOnState {
    [self connectLocationManagerMock];

    NSArray *states = [self regionStates];
    for (NSNumber *stateNumber in states) {
        [self simulateDeterminingStateForBeaconRegion:[stateNumber integerValue]];
    }

    [verifyCount(self.manager.locationManager, times(1)) startRangingBeaconsInRegion:HC_anything()];
    [verifyCount(self.manager.locationManager, times(2)) stopRangingBeaconsInRegion:HC_anything()];
}

- (void)testIfDidDetermineStateForRegionStartRangingBeaconsIfIsInsideBeaconRegion {
    [self connectLocationManagerMock];

    [self simulateDeterminingStateForBeaconRegion:CLRegionStateInside];

    [verify([self locationManagerMock]) startRangingBeaconsInRegion:HC_anything()];
}

- (void)testIfDidDetermineStateForRegionStopRangingBeaconsIfIsNotInsideBeaconRegion {
    [self connectLocationManagerMock];

    [self simulateDeterminingStateForBeaconRegion:CLRegionStateOutside];
    [self simulateDeterminingStateForBeaconRegion:CLRegionStateUnknown];

    [verifyCount(self.manager.locationManager, times(2)) stopRangingBeaconsInRegion:HC_anything()];
}

- (void)testIfIsBeaconRegionReturnYesOnlyForBeaconRegion {
    expect([self .manager isBeaconRegion:[[CLRegion alloc] init]]).to.beFalsy();
    expect([self .manager isBeaconRegion:nil]).to.beFalsy();
    expect([self .manager isBeaconRegion:[self testCircularRegion]]).to.beFalsy();
    expect([self .manager isBeaconRegion:[self testBeaconRegion]]).to.beTruthy();
}

- (void)testIfDidEnterNotificationIsSentIfStateIsInside {
    expect(^{[self.manager locationManager:nil
                         didDetermineState:CLRegionStateInside
                                 forRegion:[self testCircularRegion]]
            ;}).to.postNotification(kRegionMonitoringDidEnterNotification);
}

- (void)testIfDidEnterNotificationIsSentWhenLocationManagerInformsAboutEntering {
    expect(^{ [self.manager locationManager:nil didEnterRegion:[self testRegion]];}).to.postNotification(kRegionMonitoringDidEnterNotification);
}

- (void)testIfDidExitNotificationIsSentWhenLocationManagerInformsAboutExiting {
    expect(^{ [self.manager locationManager:nil didExitRegion:[self testRegion]];}).to.postNotification(kRegionMonitoringDidExitNotification);
}

- (void)testIfDidRangeBeaconsNotificationIsSentBeaconsAreRangedSuccesfully {
    expect(^{ [self.manager locationManager:nil
                            didRangeBeacons:@[[self testBeaconRegion]]
                                   inRegion:[self testBeaconRegion]]
            ;}).to.postNotification(kRegionMonitoringDidRangeBeaconsNotification);
}

#pragma mark - Helper methods

- (void)simulateDeterminingStateForRegion:(CLRegionState)state {
    [self.manager locationManager:nil
                didDetermineState:state
                        forRegion:[[CLRegion alloc] init]];
}

- (void)simulateDeterminingStateForBeaconRegion:(CLRegionState)state {
    [self.manager locationManager:nil
                didDetermineState:state
                        forRegion:[self testBeaconRegion]];
}

- (CLRegion *)testRegion {
    return [[CLRegion alloc] init];
}

- (CLBeaconRegion *)testBeaconRegion {
    return [[CLBeaconRegion alloc] initWithProximityUUID:[[NSUUID alloc] init] major:0
                                                   minor:0
                                              identifier:@"TestBeaconRegion"];
}

- (void)simulateDeterminingStateForCircularRegion:(CLRegionState)state {
    [self.manager locationManager:nil
                didDetermineState:state
                        forRegion:[self testCircularRegion]];
}

- (CLCircularRegion *)testCircularRegion {
    return [[CLCircularRegion alloc] initWithCenter:CLLocationCoordinate2DMake(0, 0)
                                             radius:CLLocationDistanceMax
                                         identifier:@"TestCircularRegion"];
}

- (NSArray *)regionStates {
    return @[[NSNumber numberWithUnsignedInt:CLRegionStateInside], [NSNumber numberWithUnsignedInt:CLRegionStateOutside], [NSNumber numberWithUnsignedInt:CLRegionStateUnknown]];
}

- (void)simulateAddingRegionsCount:(NSUInteger)count {
    NSMutableArray *regions = [NSMutableArray arrayWithCapacity:count];
    for (int i = 0; i < count; i++) {
        [regions addObject:[NSNumber numberWithInt:i]];
    }
    self.manager.regionsToMonitor = [regions copy];
}

- (NSUInteger)numberOfRegions {
    return [self.manager.regionsToMonitor count];
}

- (void)simulateIos7 {
    /* TODO: Implement to test iOS7 Behavior */
}

- (CLLocationManager *)locationManagerMock {
    return self.manager.locationManager;
}

- (void)connectLocationManagerMock {
    self.manager.locationManager = mock([CLLocationManager class]);
}


- (SEL)simulateSelectorRequestForAuthorization:(LocationManagerAuthorization)type {
    [self provideAuthorizationType:type];

    return [self.manager authorizationSelector];
}

- (void)provideAuthorizationType:(LocationManagerAuthorization)type {
    self.manager.authorizationType = type;
}

@end
