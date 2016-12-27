//
//  BMViewController.m
//  Biometric
//
//  Created by Michael O'Brien on 2013-09-22.
//  Copyright (c) 2013 Michael O'Brien. All rights reserved.
//

#import "BMViewController.h"

@interface BMViewController ()
@property (weak, nonatomic) IBOutlet UITextField *ratePeakField;
@property (weak, nonatomic) IBOutlet UITextField *rateMinField;

@property (weak, nonatomic) IBOutlet UITextField *rateField;
@property (weak, nonatomic) IBOutlet UITextField *statusField;

@end

@implementation BMViewController

//2013-09-25 20:49:59.453 Biometric[254:60b] Connecting to peripheral <CBPeripheral: 0x14e23380 identifier = 398D853C-FE6D-A669-0E72-4A19D103CF0D, Name = "MIO GLOBAL", state = disconnected>
//static NSString * const kServiceUUID = @"C15191A3-D214-4E6A-B533-0BCE41B833A6";
//static NSString * const kCharacteristicUUID = @"2208559C-21AB-4263-B334-0CFE1946DF17";
static NSString * const kServiceUUID = @"398D853C-FE6D-A669-0E72-4A19D103CF0D";
//static NSString * const kCharacteristicUUID = @"2208559C-21AB-4263-B334-0CFE1946DF17";
//static NSString * const kCharacteristicUUID = @"6c721826 5bf14f64 9170381c 08ec57ee";
static NSString * const HEARTRATE_UUID = @"2a37";
static NSString * const cloudURLString = @"https://obrienscience-obrienlabs.java.us1.oraclecloudapps.com/blackbox/";

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
    //self.peripheralManager = [[CBPeripheralManager alloc] initWithDelegate:self queue:nil];
    self.manager = [[CBCentralManager alloc] initWithDelegate:self queue:nil];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
/*
- (void)setupService {
    // Creates the characteristic UUID
    CBUUID *characteristicUUID = [CBUUID UUIDWithString:kCharacteristicUUID];
    
    // Creates the characteristic
    self.customCharacteristic = [[CBMutableCharacteristic alloc] initWithType:characteristicUUID properties:CBCharacteristicPropertyNotify value:nil permissions:CBAttributePermissionsReadable];
    
    // Creates the service UUID
    CBUUID *serviceUUID = [CBUUID UUIDWithString:kServiceUUID];
    
    // Creates the service and adds the characteristic to it
    self.customService = [[CBMutableService alloc] initWithType:serviceUUID primary:YES];
    
    // Sets the characteristics for this service
    [self.customService setCharacteristics:@[self.customCharacteristic]];
    
    // Publishes the service
    [self.peripheralManager addService:self.customService];
}

- (void)peripheralManager:(CBPeripheralManager *)peripheral didAddService:(CBService *)service error:(NSError *)error {
    if (error == nil) {
        // Starts advertising the service
        [self.peripheralManager startAdvertising:@{ CBAdvertisementDataLocalNameKey : @"ICServer", CBAdvertisementDataServiceUUIDsKey : @[[CBUUID UUIDWithString:kServiceUUID]] }];
    }
}
*/

- (IBAction)readButtonTouchUpInside:(id)sender {
    [self.peripheral readValueForCharacteristic:self.aCharacteristic];
    NSLog(@"reading");
    self.rateField.text = @"Reading...";
}

- (void)centralManager:(CBCentralManager *)central didDiscoverPeripheral:(CBPeripheral *)peripheral advertisementData:(NSDictionary *)advertisementData RSSI:(NSNumber *)RSSI {
    // Stops scanning for peripheral
    [self.manager stopScan];
    
    if (self.peripheral != peripheral) {
        self.peripheral = peripheral;
        NSLog(@"Connecting to peripheral %@", peripheral);
        self.statusTextView.text = peripheral.description;
        self.statusField.text = peripheral.identifier.UUIDString;
        // Connects to the discovered peripheral
        //[self.manager connectPeripheral:peripheral options:nil];
         [self.manager connectPeripheral:peripheral options:[NSDictionary dictionaryWithObject:[NSNumber numberWithBool:YES] forKey:CBConnectPeripheralOptionNotifyOnDisconnectionKey]];
        self.statusTextView.text = peripheral.description;
    }
}

- (void)centralManager:(CBCentralManager *)central didConnectPeripheral:(CBPeripheral *)peripheral {
    NSLog(@"Connected to peripheral %@", peripheral);

    // Clears the data that we may already have
    [self.data setLength:0];
    // Sets the peripheral delegate
    [self.peripheral setDelegate:self];
    // Asks the peripheral to discover the service
    //[self.peripheral discoverServices:@[ [CBUUID UUIDWithString:kServiceUUID] ]];
    [self.peripheral discoverServices:@[  ]];
     //[self.peripheral discoverServices:nil forService:@[  ]];
}

- (void)centralManagerDidUpdateState:(CBCentralManager *)central {
    switch (central.state) {
        case CBCentralManagerStatePoweredOn:
            // Scans for any peripheral
            NSLog(@"Setup");
            //[self.manager scanForPeripheralsWithServices:@[ [CBUUID UUIDWithString:kServiceUUID] ] options:@{CBCentralManagerScanOptionAllowDuplicatesKey : @YES }];
            //self.manager scanForPeripheralsWithServices:@[  ]
            //                                     options:@{CBCentralManagerScanOptionAllowDuplicatesKey : @YES }]; // discover only - stop later
            [self.manager scanForPeripheralsWithServices:[NSArray arrayWithObject:[CBUUID UUIDWithString:@"180D"]] options:nil];
            self.statusField.text = @"Setup";
            self.rateField.text = @"0";
            self.cloudField.text = cloudURLString;
            self.statusTextView.text = @"Discovering LE Bluetooth devices";
              self.heartRateMax = 0;
              self.heartRateMin = 999;
            break;
        default:
            NSLog(@"Central Manager did change state");
            break;
    }
}

- (void)peripheral:(CBPeripheral *)aPeripheral didDiscoverServices:(NSError *)error {
    if (error) {
        NSLog(@"Error discovering service: %@", [error localizedDescription]);
        //[self cleanup];
        return;
    }
    self.statusField.text = aPeripheral.services.description;
    for (CBService *service in aPeripheral.services) {
        NSLog(@"Service found with UUID: %@", service.UUID);
        
        // Discovers the characteristics for a given service
        //if ([service.UUID isEqual:[CBUUID UUIDWithString:kServiceUUID]]) {
         //   [self.peripheral discoverCharacteristics:@[[CBUUID UUIDWithString:kCharacteristicUUID]] forService:service];
        //}
        //f ([service.UUID isEqual:[CBUUID UUIDWithString:kServiceUUID]]) {
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
    //if ([service.UUID isEqual:[CBUUID UUIDWithString:kServiceUUID]]) {
        for (CBCharacteristic *characteristic in service.characteristics) {
            //if ([characteristic.UUID isEqual:[CBUUID UUIDWithString:kCharacteristicUUID]]) {
            //[peripheral setNotifyValue:YES forCharacteristic:characteristic];
            NSLog(@"Discovered characteristic %@ UUID: %@", characteristic,characteristic.UUID);
            if([characteristic.UUID isEqual:[CBUUID UUIDWithString:HEARTRATE_UUID]]) {
                self.statusField.text = @"C:2A37 heartrate found";
                self.uuidField.text = characteristic.UUID.description;
                self.aCharacteristic = characteristic;
                [peripheral readValueForCharacteristic:characteristic];
                 [peripheral setNotifyValue:YES forCharacteristic:characteristic];

            }
             /* Write heart rate control point - key repeating callback to didUpdateValueForCharacteristic listener */
             if ([characteristic.UUID isEqual:[CBUUID UUIDWithString:@"2A39"]])
             {
                  uint8_t val = 1;
                  NSData* valData = [NSData dataWithBytes:(void*)&val length:sizeof(val)];
                  [peripheral writeValue:valData forCharacteristic:characteristic type:CBCharacteristicWriteWithResponse];
             }
        }
    //}
}

/* callback capable */
- (void)peripheral:(CBPeripheral *)peripheral didUpdateValueForCharacteristic:(CBCharacteristic *)characteristic
             error:(NSError *)error {
     if([characteristic.UUID isEqual:[CBUUID UUIDWithString:HEARTRATE_UUID]]) {
    
    NSData *data = characteristic.value;
    NSString *dataString = [NSString stringWithFormat:@"%@", data  ];
    //NSString *dataText = [NSString stringWithUTF8String:@"%@", data];
    // NSData *data = [NSData data];
    NSString *string = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
    // parse the data as needed
    //NSLog(@"Value: %@", characteristic.description);//*data.description);
    //for(NSObject *object in data.
        //)
    NSString* myString;
    myString = [[NSString alloc] initWithData:data encoding:NSASCIIStringEncoding];
    self.uuidField.text = dataString;
          // from apple
          [self updateWithHRMData:characteristic.value];
          NSString *rateString = [NSString stringWithFormat:@"%hu", self.heartRate];
          self.rateField.text = rateString;
          NSLog(@"size: %d value:%@ %@ %@",data.length, dataString, myString, rateString);
          if(self.heartRate > self.heartRateMax) {
               self.heartRateMax = self.heartRate;
               self.ratePeakField.text = rateString;
          }
          if(self.heartRate < self.heartRateMin) {
               self.heartRateMin = self.heartRate;
               self.rateMinField.text = rateString;
          }

     }
}

- (void)peripheral:(CBPeripheral *)peripheral didUpdateNotificationStateForCharacteristic:(CBCharacteristic *)characteristic error:(NSError *)error {
    if (error) {
        NSLog(@"Error changing notification state: %@", error.localizedDescription);
    }
    
    // Exits if it's not the transfer characteristic
    /*if (![characteristic.UUID isEqual:[CBUUID UUIDWithString:kCharacteristicUUID]]) {
        return;
    }*/
    
    // Notification has started
    if (characteristic.isNotifying) {
        NSLog(@"Notification began on %@", characteristic);
        [peripheral readValueForCharacteristic:characteristic];
    } else { // Notification has stopped
        // so disconnect from the peripheral
        NSLog(@"Notification stopped on %@.  Disconnecting", characteristic);
        [self.manager cancelPeripheralConnection:self.peripheral];
    }
}
/*
- (void)peripheralManagerDidUpdateState:(CBPeripheralManager *)peripheral {
    switch (peripheral.state) {
        case CBPeripheralManagerStatePoweredOn:
            [self setupService];
            NSLog(@"Setup");
            self.statusField.text = @"Setup";
            self.rateField.text = @"0";
            break;
        default:
            NSLog(@"Peripheral Manager did change state");
            break;
    }
}*/


- (void) updateWithHRMData:(NSData *)data
{
    const uint8_t *reportData = [data bytes];
    uint16_t bpm = 0;
    
    if ((reportData[0] & 0x01) == 0)
    {
        /* uint8 bpm */
        bpm = reportData[1];
    }
    else
    {
        /* uint16 bpm */
        bpm = CFSwapInt16LittleToHost(*(uint16_t *)(&reportData[1]));
    }
    
    uint16_t oldBpm = self.heartRate;
    self.heartRate = bpm;
    if (oldBpm == 0)
    {
        //[self pulse];
        //self.pulseTimer = [NSTimer scheduledTimerWithTimeInterval:(60. / heartRate) target:self selector:@selector(pulse) userInfo:nil repeats:NO];
//        NSString myString = [[NSString alloc] initWithData:self.heartRate encoding:NSASCIIStringEncoding];
//        NSLog(@"hr %d",self.heartRate);

        //self.ratePeakField.text = self.heartRate;
    }
}


- (IBAction)readTouchDown:(id)sender {
}
@end
