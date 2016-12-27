//
//  BMModelEvent.m
//  Biometric
//
//  Created by Michael O'Brien on 11/18/2013.
//  Copyright (c) 2013 Michael O'Brien. All rights reserved.
//

#import "BMModelEvent.h"
#import "BMBluetoothLE.h"
#import "BMSensorManager.h"

@implementation BMModelEvent


-(void) setHeartRate:(uint16_t)bpm onPeripheral: (CBPeripheral*) peripheral onDataObject: (BMModelEvent*) dataObject onSensorManager:(BMSensorManager*) sensorManager{
/*    if(peripheral == sensorManager.peripheral2) {
        sensorManager.lastHeartRate2 = dataObject.heartRate2;
        dataObject.heartRate2 = bpm;
    } else {
        sensorManager.lastHeartRate1 = dataObject.heartRate1;
        dataObject.heartRate1 = bpm;
    }*/
}

@end
