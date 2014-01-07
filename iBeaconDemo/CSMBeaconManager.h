//
//  CSMBeaconManager.h
//  iBeaconDemo
//
//  Created by Ronald Li on 7/1/14.
//  Copyright (c) 2014 Christopher Mann. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface CSMBeaconSetting : NSObject
@property (nonatomic, readonly) NSInteger major;
@property (nonatomic, readonly) NSInteger minor;
@property (nonatomic, readonly) NSString *beaconId;
@property (nonatomic, readonly) NSDictionary *dictionary;
- (id)initWithDictionary:(NSDictionary *)dictionary;
@end

@interface CSMBeaconManager : NSObject
+ (instancetype)defaultManager;
- (CSMBeaconSetting *) beaconSettingWithId:(NSString *)beaconId;
- (void) requestUpdateBeaconSettingWithHandler:(void (^)(NSArray *settings)) handler;
- (CSMBeaconSetting *) beaconSettingWithMajor:(NSInteger)major minor:(NSInteger)minor;
@end