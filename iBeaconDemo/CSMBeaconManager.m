//
//  CSMBeaconManager.m
//  iBeaconDemo
//
//  Created by Ronald Li on 7/1/14.
//  Copyright (c) 2014 Christopher Mann. All rights reserved.
//

#import "CSMBeaconManager.h"
#import <SBJson/SBJson.h>

static CSMBeaconManager *_sharedInstance = nil;

@interface CSMBeaconManager ()
@property (nonatomic, readonly) NSArray *settings;
@end

@implementation CSMBeaconManager
+ (instancetype)defaultManager {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _sharedInstance = [[CSMBeaconManager alloc] init];
    });
    return _sharedInstance;
}

- (void) requestUpdateBeaconSettingWithHandler:(void (^)(NSArray *))handler{
    // perform network request in background thread
    [[NSOperationQueue new] addOperationWithBlock:^{
        SBJsonParser *parser = [[SBJsonParser alloc] init];
        NSData *jsonData = [NSData dataWithContentsOfURL:[NSURL URLWithString:@"https://dl.dropboxusercontent.com/u/76543370/beacons.json"]];
        id dict = [parser objectWithData:jsonData];
        
        // update beacons.json file in project
        NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
        NSString *documentsDirectory = [paths objectAtIndex:0];
        NSString *filePath = [NSString stringWithFormat:@"%@/%@", documentsDirectory, @"beacons.json"];
        BOOL saved = [jsonData writeToFile:filePath atomically:YES];
        
        // call handler in main thread
        [[NSOperationQueue mainQueue] addOperationWithBlock:^{
            if (handler)
                handler(dict);
        }];
    }];
}
@end
