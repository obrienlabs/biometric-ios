//
//  BMBluetoothLE.m
//  Biometric
//
//  Created by Michael O'Brien on 2014-05-20.
//  Copyright (c) 2014 Michael O'Brien. All rights reserved.
//

#import "BMBluetoothLE.h"

@implementation BMBluetoothLE

// from Apple Inc
+(uint16_t) extractHeartRate:(NSData *) hrData {
    const uint8_t *reportData = [hrData bytes];
    uint16_t bpm = 0;
    if ((reportData[0] & 0x01) == 0) // intermittent bad access
    //if (null != reportData & (reportData[0] & 0x01) == 0)
    {
        /* uint8 bpm */
        bpm = reportData[1];
    } else {
        /* uint16 bpm */
        bpm = CFSwapInt16LittleToHost(*(uint16_t *)(&reportData[1]));
    }
    return bpm;
}

@end
