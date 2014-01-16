//
//  CSMHomeViewController.m
//  iBeacons_Demo
//
//  Created by Christopher Mann on 9/5/13.
//  Copyright (c) 2013 Christopher Mann. All rights reserved.
//

#import "CSMHomeViewController.h"
#import "CSMLocationUpdateController.h"
#import "CSMAppDelegate.h"
#import <SBJson/SBJson.h>
#import "CSMBeaconManager.h"
#import <VSBeaconManager/VSBeaconManager.h>


#define kHorizontalPadding 20
#define kVerticalPadding 10

@interface CSMHomeViewController () <UIAlertViewDelegate>

@property (nonatomic, strong) UILabel            *instructionLabel;
@property (nonatomic, strong) UISegmentedControl *segmentedControl;

@end

@implementation CSMHomeViewController

- (id)init {
    self = [super init];
    if (self) {

    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.title = @"iBeacons Demo";
    self.view.backgroundColor = [UIColor whiteColor];
    
    self.instructionLabel = [UILabel new];
    self.instructionLabel.textAlignment = NSTextAlignmentCenter;
    self.instructionLabel.preferredMaxLayoutWidth = self.view.frame.size.width - 2*kHorizontalPadding;
    self.instructionLabel.numberOfLines = 0;
    self.instructionLabel.text = @"Select the mode you would like to use for this device:";
    self.instructionLabel.translatesAutoresizingMaskIntoConstraints = NO;
    [self.view addSubview:self.instructionLabel];
    
    self.segmentedControl = [[UISegmentedControl alloc] initWithItems:@[@"iBeacon",@"Region Monitoring"]];
    self.segmentedControl.momentary = YES;
    self.segmentedControl.translatesAutoresizingMaskIntoConstraints = NO;
    [self.segmentedControl addTarget:self action:@selector(handleToggle:) forControlEvents:UIControlEventValueChanged];
    [self.view addSubview:self.segmentedControl];
    
    // define auto layout constraints
    NSDictionary *constraintMetrics = @{@"horizontalPadding" : @kHorizontalPadding,
                                       @"verticalPadding" : @(5*kVerticalPadding),
                                        @"verticalSpacing" : @(2*kVerticalPadding)};
    NSDictionary *constraintViews = @{@"label" : self.instructionLabel,
                                       @"segmentedControl" : self.segmentedControl,
                                      @"topGuide" : self.topLayoutGuide};
    
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"|-horizontalPadding-[label]-horizontalPadding-|"
                                                                     options:0
                                                                     metrics:constraintMetrics
                                                                        views:constraintViews]];
    
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"|-horizontalPadding-[segmentedControl]-horizontalPadding-|"
                                                                      options:0
                                                                      metrics:constraintMetrics
                                                                        views:constraintViews]];
    
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|[topGuide]-verticalPadding-[label]-verticalSpacing-[segmentedControl(==60)]-(>=verticalPadding)-|"
                                                                      options:0
                                                                      metrics:constraintMetrics
                                                                        views:constraintViews]];
}

- (void)handleToggle:(id)sender {
    
    if (self.segmentedControl.selectedSegmentIndex == 0) {
        [self promptBeaconId];
    }else {
        // initate peripheral iBeacon monitoring mode
        [self presentControllerInLocationMode:CSMApplicationModeRegionMonitoring];
    }
}

- (void) presentControllerInLocationMode:(CSMApplicationMode)mode{
    
    CSMLocationUpdateController *monitoringController = [[CSMLocationUpdateController alloc] initWithLocationMode:mode];
//        // initiate iBeacon broadcasting mode
//        monitoringController = [[CSMLocationUpdateController alloc] initWithLocationMode:CSMApplicationModePeripheral];
//        
//    } else {
//        
//        // initate peripheral iBeacon monitoring mode
//        monitoringController = [[CSMLocationUpdateController alloc] initWithLocationMode:CSMApplicationModeRegionMonitoring];
//    }
    
    // present update controller
    UINavigationController *navController = [[UINavigationController alloc] initWithRootViewController:monitoringController];
    [self presentViewController:navController animated:YES completion:NULL];
}

#pragma mark - Beacon Identification
- (void) promptBeaconId {
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Beacon ID" message:@"Input a identifier for this beacon" delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:@"OK", nil];
    [alertView setAlertViewStyle:UIAlertViewStylePlainTextInput];
    [alertView show];
}

- (void) didRequestBeaconSetting:(VSBeaconSetting *) setting {
    // initiate iBeacon broadcasting mode
    [VSBeaconRegion setBoardcastRegionProximityUUID:[CSMAppDelegate appDelegate].myUUID identifier:kUniqueRegionIdentifier major:setting.major minor:setting.minor];
    [self presentControllerInLocationMode:CSMApplicationModePeripheral];
}

#pragma mark - UI Alert View Delegate
- (void)alertView:(UIAlertView *)alertView didDismissWithButtonIndex:(NSInteger)buttonIndex
{
    NSString *beaconId = [alertView textFieldAtIndex:0].text;
    if (beaconId.length != 0) {
        [[CSMBeaconManager defaultManager] requestUpdateBeaconSettingWithHandler:^(NSArray *array) {
            for (NSDictionary *dict in array) {
                [[VSBeaconManager defaultManager] addSetting:[[VSBeaconSetting alloc] initWithDictionary:dict]];
            }
            [self didRequestBeaconSetting:[[VSBeaconManager defaultManager] beaconSettingWithId:beaconId]];
        }];
    }
}
@end
