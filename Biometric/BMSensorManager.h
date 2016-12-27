//
//  BMSensorManager.h
//  Biometric
//
//  Created by Michael O'Brien on 2014-05-21.
//  Copyright (c) 2014 Michael O'Brien. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreBluetooth/CoreBluetooth.h>
#import <CoreLocation/CoreLocation.h>

@interface BMSensorManager : NSObject

@property (assign) uint16_t lastHeartRate1;
@property (assign) uint16_t lastHeartRate2;
@property (nonatomic, strong) CBPeripheral *peripheral1;
@property (nonatomic, strong) CBPeripheral *peripheral2;
//@property (nonatomic, strong) CBCharacteristic *aCharacteristic1;
//@property (nonatomic, strong) CBCharacteristic *aCharacteristic2;
//@property (nonatomic, strong) CBCentralManager *manager;



@end
