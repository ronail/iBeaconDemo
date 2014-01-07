//
//  CSMBeaconManager.m
//  iBeaconDemo
//
//  Created by Ronald Li on 7/1/14.
//  Copyright (c) 2014 Christopher Mann. All rights reserved.
//

#import "CSMBeaconManager.h"
#import <SBJson/SBJson.h>

@implementation CSMBeaconSetting
- (id)initWithDictionary:(NSDictionary *)dictionary
{
    self = [super init];
    if (self) {
        _dictionary = dictionary;
    }
    return self;
}

- (NSString *)beaconId
{
    return [self.dictionary objectForKey:@"id"];
}

- (NSInteger) major
{
    return [[self.dictionary objectForKey:@"major"] integerValue];
}

- (NSInteger) minor
{
    return [[self.dictionary objectForKey:@"minor"] integerValue];
}
@end

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

- (CSMBeaconSetting *) beaconSettingWithId:(NSString *)beaconId{
    CSMBeaconSetting *setting = nil;
    for (NSDictionary *dict in self.settings) {
        if ([[dict objectForKey:@"id"] isEqualToString:beaconId]) {
            return [[CSMBeaconSetting alloc] initWithDictionary:dict];
        }
    }
    return setting;
}

- (NSArray *)settings {
    SBJsonParser *parser = [[SBJsonParser alloc] init];
//    NSString *filePath = [[NSBundle mainBundle] pathForResource:@"beacons" ofType:@"json"];
    
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    NSString *filePath = [NSString stringWithFormat:@"%@/%@", documentsDirectory, @"beacons.json"];
    
    NSError *error = nil;
    return [parser objectWithData:[NSData dataWithContentsOfFile:filePath options:NSDataReadingMappedIfSafe error:&error]];
}

- (CSMBeaconSetting *)beaconSettingWithMajor:(NSInteger)major minor:(NSInteger)minor {
    CSMBeaconSetting *setting = nil;
    for (NSDictionary *dict in self.settings) {
        if ([[dict objectForKey:@"major"] integerValue] == major && [[dict objectForKey:@"minor"] integerValue] == minor ) {
            setting = [[CSMBeaconSetting alloc] initWithDictionary:dict];
            break;
        }
    }
    return setting;
}
@end
