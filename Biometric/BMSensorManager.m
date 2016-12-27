//
//  BMSensorManager.m
//  Biometric
//
//  Created by Michael O'Brien on 2014-05-21.
//  Copyright (c) 2014 Michael O'Brien. All rights reserved.
//

#import "BMSensorManager.h"

@implementation BMSensorManager

int GH_BITS[] = {16,8,4,2,1};

#define GH_RIGHT @"right"
#define GH_LEFT @"left"
#define GH_TOP @"top"
#define GH_BOTTOM @"bottom"
#define GH_ODD @"odd"
#define GH_EVEN @"even"

NSString *_gh_base_32;
NSDictionary *_neighbours;
NSDictionary *_borders;
- (id) init
{
    self = [super init];
    if (self) {
        _gh_base_32 = @"0123456789bcdefghjkmnpqrstuvwxyz";
        _neighbours = [NSDictionary dictionaryWithObjectsAndKeys:
                       [NSDictionary dictionaryWithObjectsAndKeys:@"bc01fg45238967deuvhjyznpkmstqrwx", GH_EVEN,
                        @"p0r21436x8zb9dcf5h7kjnmqesgutwvy", GH_ODD, nil], GH_RIGHT,
                       [NSDictionary dictionaryWithObjectsAndKeys:@"238967debc01fg45kmstqrwxuvhjyznp", GH_EVEN,
                        @"14365h7k9dcfesgujnmqp0r2twvyx8zb", GH_ODD, nil], GH_LEFT,
                       [NSDictionary dictionaryWithObjectsAndKeys:@"p0r21436x8zb9dcf5h7kjnmqesgutwvy", GH_EVEN,
                        @"bc01fg45238967deuvhjyznpkmstqrwx", GH_ODD, nil], GH_TOP,
                       [NSDictionary dictionaryWithObjectsAndKeys:@"14365h7k9dcfesgujnmqp0r2twvyx8zb", GH_EVEN,
                        @"238967debc01fg45kmstqrwxuvhjyznp", GH_ODD, nil], GH_BOTTOM,
                       nil];

    }
    return self;
}
/*

- (void)centralManagerDidUpdateState:(CBCentralManager *)central {
    switch (central.state) {
        case CBCentralManagerStatePoweredOn:
            // Scans for any peripheral
            NSLog(@"Setup");
            [self.manager scanForPeripheralsWithServices:[NSArray arrayWithObject:[CBUUID UUIDWithString:@"180D"]] options:nil];
            //self.statusField.text = @"Setup";
            self.rateField.text = @"0";
            //self.cloudField.text = cloudURLString;
 
            self.heartRateMax1 = 0;
            self.heartRateMin1 = 255;
            break;
        default:
            NSLog(@"Central Manager did change state");
            break;
    }
}
- (void)centralManager:(CBCentralManager *)central didDiscoverPeripheral:(CBPeripheral *)peripheral advertisementData:(NSDictionary *)advertisementData RSSI:(NSNumber *)RSSI {
    // Stops scanning for peripheral
    if(hrMonitorsFound > 1) {
        [self.manager stopScan];
        hrMonitorsFound++;
    }
    if(![peripheral.name isEqual: @"MIO GLOBAL"]) {
        self.sensorManager.peripheral1 = peripheral;
        
        NSLog(@"Connecting to peripheral1 %@", self.sensorManager.peripheral1);
        self.deviceTextField.text = peripheral.name;
        // Connects to the discovered peripheral
        //[self.manager connectPeripheral:peripheral options:nil];
        //[self.manager connectPeripheral:peripheral options:[NSDictionary dictionaryWithObject:[NSNumber numberWithBool:YES] forKey:CBConnectPeripheralOptionNotifyOnDisconnectionKey]];
        //self.statusTextView.text = peripheral.description;
        //hrMonitorsFound++;
        
    } else {
        //if(hrMonitorsFound == 1 || [peripheral.name isEqual: @"MIO GLOBAL"]) {
        self.sensorManager.peripheral2 = peripheral;
        NSLog(@"Connecting to peripheral2 %@", self.sensorManager.peripheral2);
        self.device2TextField.text = peripheral.name;
        //self.statusField.text = USER_ID;
        // Connects to the discovered peripheral
    }
    [self.manager connectPeripheral:self.sensorManager.peripheral2 options:[NSDictionary dictionaryWithObject:[NSNumber numberWithBool:YES] forKey:CBConnectPeripheralOptionNotifyOnDisconnectionKey]];
    hrMonitorsFound++;
    
    
}

- (void)centralManager:(CBCentralManager *)central didConnectPeripheral:(CBPeripheral *)peripheral {
    NSLog(@"Connected to peripheral %@", peripheral);
    if([peripheral isEqual: self.sensorManager.peripheral1]) {
        //self.deviceTextField.text = peripheral.name;
        // Clears the data that we may already have
        [self.data1 setLength:0];
    } else {
        //self.device2TextField.text = peripheral.name;
        // Clears the data that we may already have
        [self.data2 setLength:0];
    }
    // Sets the peripheral delegate
    [peripheral setDelegate:self];
    // Asks the peripheral to discover the service
    [peripheral discoverServices:@[  ]];
}



- (void)peripheral:(CBPeripheral *)aPeripheral didDiscoverServices:(NSError *)error {
    if (error) {
        NSLog(@"Error discovering service: %@", [error localizedDescription]);
        //[self cleanup];
        return;
    }
    //self.statusField.text = aPeripheral.services.description;
    for (CBService *service in aPeripheral.services) {
        NSLog(@"Service found with UUID: %@", service.UUID);
        
        // Discovers the characteristics for a given service
        //if ([service.UUID isEqual:[CBUUID UUIDWithString:kServiceUUID_wahoo]]) {
        //   [self.peripheral discoverCharacteristics:@[[CBUUID UUIDWithString:kCharacteristicUUID]] forService:service];
        //}
        // https://developer.apple.com/library/ios/documentation/NetworkingInternetWeb/Conceptual/CoreBluetooth_concepts/PerformingCommonCentralRoleTasks/PerformingCommonCentralRoleTasks.html#//apple_ref/doc/uid/TP40013257-CH3-SW7
        [aPeripheral discoverCharacteristics:nil forService:service];
        //}
    }
}

- (void)peripheral:(CBPeripheral *)peripheral didDiscoverCharacteristicsForService:(CBService *)service error:(NSError *)error {
    if (error) {
        NSLog(@"Error discovering characteristic: %@", [error localizedDescription]);
        //[self cleanup];
        return;
    }
    for (CBCharacteristic *characteristic in service.characteristics) {
        NSLog(@"Discovered characteristic %@ UUID: %@", characteristic,characteristic.UUID);
        if([characteristic.UUID isEqual:[CBUUID UUIDWithString:HEARTRATE_UUID]]) {
            //self.uuidField.text = characteristic.UUID.description;
            //self.aCharacteristic1 = characteristic;
            [peripheral readValueForCharacteristic:characteristic];
            [peripheral setNotifyValue:YES forCharacteristic:characteristic];
        }
        if([characteristic.UUID isEqual:[CBUUID UUIDWithString:@"2A39"]]) {
            uint8_t value = 1;
            NSData* valData = [NSData dataWithBytes:(void*)&value length:sizeof(value)];
            [peripheral writeValue:valData forCharacteristic:characteristic type:CBCharacteristicWriteWithResponse];
        }
    }
}
// callback capable
- (void)peripheral:(CBPeripheral *)peripheral didUpdateValueForCharacteristic:(CBCharacteristic *)characteristic
             error:(NSError *)error {
    if([characteristic.UUID isEqual:[CBUUID UUIDWithString:HEARTRATE_UUID]]) {
        // which device?
        //if([peripheral isEqual: self.peripheral2]) {
        //     NSLog(@"Peripheral %@", peripheral);
        //}
        
        NSData *data = characteristic.value;
        NSString *dataString = [NSString stringWithFormat:@"%@", data  ];
        NSString* myString;
        myString = [[NSString alloc] initWithData:data encoding:NSASCIIStringEncoding];
        //self.uuidField.text = dataString;
        // from apple
        if(nil != data) {
            [self extractHeartRate:characteristic.value onPeripheral: peripheral];
            NSString *rateString = [NSString stringWithFormat:@"%hu", self.dataObject.heartRate1];
            self.rateField.text = rateString;
            if(peripheral == self.sensorManager.peripheral2) {
                rateString = [NSString stringWithFormat:@"%hu", self.dataObject.heartRate1];
                self.rate2TextView.text = [NSString stringWithFormat:@"%hu", self.dataObject.heartRate2];;
                self.rate2TextView.text = [NSString stringWithFormat:@"%hu", self.sensorManager.lastHeartRate2];
            }
            
            //NSLog(@"size: %lu value:%@ %@ %@",(unsigned long)data.length, dataString, myString, rateString);
            if(self.dataObject.heartRate1 > self.heartRateMax1) {
                self.heartRateMax1 = self.dataObject.heartRate1;
                self.ratePeakField.text = rateString;
                //self.maxRate2TextField.text = rateString;
            }
            if(self.dataObject.heartRate1 < self.heartRateMin1) {
                self.heartRateMin1 = self.dataObject.heartRate1;
                self.rateMinField.text = rateString;
                //self.minRate2TextField.text = rateString;
            }
            
            if(self.sensorManager.lastHeartRate1 < self.dataObject.heartRate1) {
                //self.rateField.backgroundColor = [UIColor colorWithRed: 128.0/255.0f green:64.0/255.0f blue:255.0/255.0f alpha:1.0];
                //[self.rateField setTextColor: [UIColor whiteColor]];
                self.rateField.textColor = [UIColor colorWithRed: 128.0/255.0f green:224.0/255.0f blue:255.0/255.0f alpha:1.0];
            }
            if(self.sensorManager.lastHeartRate1 == self.dataObject.heartRate1) {
                //self.rateField.backgroundColor = [UIColor colorWithRed: 192.0/255.0f green:255.0/255.0f blue:32.0/255.0f alpha:1.0];
                //[self.rateField setTextColor: [UIColor blackColor]];
                self.rateField.textColor = [UIColor colorWithRed: 255.0/255.0f green:255.0/255.0f blue:255.0/255.0f alpha:1.0];
            }
            if(self.sensorManager.lastHeartRate1 > self.dataObject.heartRate1) {
                //self.rateField.backgroundColor = [UIColor colorWithRed: 255.0/255.0f green:0.0/255.0f blue:80.0/255.0f alpha:1.0];
                //[self.rateField setTextColor: [UIColor whiteColor]];
                self.rateField.textColor = [UIColor colorWithRed: 255.0/255.0f green:160.0/255.0f blue:64.0/255.0f alpha:1.0];
            }
            
            // flash HR
            //heartDuration+= (self.lastHeartRate1 / 60.0);
            if(self.dataObject.heartRate1 > warningHeartRate) {
                //self.dataObject.
            }
            
            // copy of above
            if(self.dataObject.heartRate2 > self.heartRateMax2) {
                self.heartRateMax2 = self.dataObject.heartRate2;
                //self.ratePeakField.text = rateString;
                self.maxRate2TextField.text = rateString;
            }
            if(self.dataObject.heartRate2 < self.heartRateMin2) {
                self.heartRateMin2 = self.dataObject.heartRate2;
                //self.rateMinField.text = rateString;
                self.minRate2TextField.text = rateString;
            }
            
            if(self.sensorManager.lastHeartRate2 < self.dataObject.heartRate2) {
                self.rate2TextView.backgroundColor = [UIColor colorWithRed: 0.0/255.0f green:64.0/255.0f blue:255.0/255.0f alpha:1.0];
                [self.rate2TextView setTextColor: [UIColor whiteColor]];
            }
            if(self.sensorManager.lastHeartRate2 == self.dataObject.heartRate2) {
                self.rate2TextView.backgroundColor = [UIColor colorWithRed: 192.0/255.0f green:255.0/255.0f blue:32.0/255.0f alpha:1.0];
                [self.rate2TextView setTextColor: [UIColor blackColor]];
            }
            if(self.sensorManager.lastHeartRate2 > self.dataObject.heartRate2) {
                self.rate2TextView.backgroundColor = [UIColor colorWithRed: 255.0/255.0f green:0.0/255.0f blue:80.0/255.0f alpha:1.0];
                [self.rate2TextView setTextColor: [UIColor whiteColor]];
            }

        }
    }
}

- (void)peripheral:(CBPeripheral *)peripheral didUpdateNotificationStateForCharacteristic:(CBCharacteristic *)characteristic error:(NSError *)error {
    if (error) {
        NSLog(@"Error changing notification state: %@", error.localizedDescription);
    }
    
    // Notification has started
    if (characteristic.isNotifying) {
        NSLog(@"Notification began on %@", characteristic);
        [peripheral readValueForCharacteristic:characteristic];
    } else { // Notification has stopped
        // so disconnect from the peripheral
        NSLog(@"Notification stopped on %@.  Disconnecting", characteristic);
        [self.manager cancelPeripheralConnection:peripheral];
    }
}

// from Apple Inc
- (void) extractHeartRate:(NSData *)hrData onPeripheral: (CBPeripheral*) peripheral {
    uint16_t bpm = [BMBluetoothLE extractHeartRate: hrData ];
    //
    //[BMSensorManager setHeartRate: bpm onPeripheral: peripheral onDataObject: self.dataObject onSensorManager: self.sensorManager];
    if(peripheral == self.sensorManager.peripheral2) {
        self.sensorManager.lastHeartRate2 = self.dataObject.heartRate2;
        self.dataObject.heartRate2 = bpm;
    } else {
        self.sensorManager.lastHeartRate1 = self.dataObject.heartRate1;
        self.dataObject.heartRate1 = bpm;
    }
}
*/




- (void) refineIntervalForLongitude:(double *) interval location:(int) cd andMask:(int) mask
{
    if (cd&mask)
		interval[0] = (interval[0] + interval[1])/2;
    else
		interval[1] = (interval[0] + interval[1])/2;
}

- (NSString *) encodeGeohash:(CLLocationCoordinate2D)coordinate
{
    return [self encodeGeohash:coordinate withPrecision:12];
}

- (NSString *) encodeGeohash:(CLLocationCoordinate2D)coordinate withPrecision:(NSUInteger) precision
{
    NSMutableString *result = [[NSMutableString alloc] initWithCapacity:precision];
    BOOL even = YES;
    int bit = 0;
    int ch = 0;
    
    
    double lat[2] = {-90.0, 90.0};
    double lng[2] = {-180.0, 180.0};
    
    while (result.length < precision) {
        if (even) {
            double mid = (lng[0] + lng[1]) / 2;
            if (coordinate.longitude > mid) {
                ch |= GH_BITS[bit];
                lng[0] = mid;
            } else {
                lng[1] = mid;
            }
        } else {
            double mid = (lat[0] + lat[1]) / 2;
            if (coordinate.latitude > mid) {
                ch |= GH_BITS[bit];
                lat[0] = mid;
            } else {
                lat[1] = mid;
            }
        }
        even = !even;
        if (bit < 4) {
            bit++;
        } else
        {
            [result appendString:[_gh_base_32 substringWithRange:NSMakeRange(ch, 1)]];
            bit = 0;
            ch = 0;
        }
    }
    
    return result;
}

- (NSString *) encodeGeohashFromLocation:(CLLocation *)location
{
    return [self encodeGeohash:location.coordinate];
}

- (NSString *) encodeGeohashFromLocation:(CLLocation *)location withPrecision:(NSUInteger)precision
{
    return [self encodeGeohash:location.coordinate withPrecision:precision];
}

@end
