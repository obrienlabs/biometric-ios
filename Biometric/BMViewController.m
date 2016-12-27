//
//  BMViewController.m
//  Biometric
//
//  Created by Michael O'Brien on 2013-09-22.
//  Copyright (c) 2013 Michael O'Brien. All rights reserved.
//

#import "BMViewController.h"
// https://developer.apple.com/library/ios/documentation/userexperience/conceptual/LocationAwarenessPG/CoreLocation/CoreLocation.html
#import <CoreLocation/CoreLocation.h>
#import <UIKit/UIKit.h>
#import <CoreMotion/CoreMotion.h>

@interface BMViewController ()
@property (weak, nonatomic) IBOutlet UITextField *ratePeakField;
@property (weak, nonatomic) IBOutlet UITextField *rateMinField;

@property (weak, nonatomic) IBOutlet UITextField *rateField;
@property (weak, nonatomic) IBOutlet UITextField *statusField;
@property (weak, nonatomic) IBOutlet UITextField *statusTextField;

//@property (nonatomic, strong) CLLocationManager *locationManager;
// https://developer.apple.com/library/ios/documentation/CoreMotion/Reference/CoreMotion_Reference/CoreMotion_Reference.pdf
// https://developer.apple.com/library/ios/documentation/EventHandling/Conceptual/EventHandlingiPhoneOS/motion_event_basics/motion_event_basics.html#//apple_ref/doc/uid/TP40009541-CH6-SW4
@property (nonatomic, strong) CMMotionManager *motionManager;
@property(readonly, nonatomic) CMAcceleration acceleration;



@property(readonly) CMAccelerometerData *accelerometerData;
// roll
// pitch
// yaw
// rotationMatrix
// quaternion
// attitude
// rotationRate
// gravity
// userAcceleration
// magneticField
// timestamp
// motionActivity (M7 chip in 5s - stationary/running/walking/automotive/unknown, startdate/confidence
@end

@implementation BMViewController

//2013-09-25 20:49:59.453 Biometric[254:60b] Connecting to peripheral <CBPeripheral: 0x14e23380 identifier = 398D853C-FE6D-A669-0E72-4A19D103CF0D, Name = "MIO GLOBAL", state = disconnected>
//2013-10-30 12:37:59.064 Biometric[806:60b] Connected to peripheral <CBPeripheral: 0x15557710 identifier = 4A90672B-EC3A-BEC2-5833-AD5A559DEE87, Name = "Wahoo HRM v2.1", state = connected>
//static NSString * const kServiceUUID = @"C15191A3-D214-4E6A-B533-0BCE41B833A6";
//static NSString * const kCharacteristicUUID = @"2208559C-21AB-4263-B334-0CFE1946DF17";
static NSString * const kServiceUUID_mio = @"398D853C-FE6D-A669-0E72-4A19D103CF0D";
static NSString * const kServiceUUID_wahoo = @"4A90672B-EC3A-BEC2-5833-AD5A559DEE87";
//static NSString * const kCharacteristicUUID = @"2208559C-21AB-4263-B334-0CFE1946DF17";
//static NSString * const kCharacteristicUUID = @"6c721826 5bf14f64 9170381c 08ec57ee";
static NSString * const HEARTRATE_UUID = @"2a37";
//static NSString * const cloudURLString = @"https://obrienscience-obrienlabs.java.us1.oraclecloudapps.com/gps/FrontController?action=setGps";//&u=20131027&lt=0&lg=0&al=0&hr=999
static NSString * const cloudURLString = @"http://obrienlabs.com/gps/FrontController?action=setGps";//&u=20131027&lt=0&lg=0&al=0&hr=999
static int uploads = 0;
static int uploadsColor = 0;
static int locationCount = 0;
static int LocationCountColor = 0;
//static int uploadFlag = 1;
static NSString * const USER_ID = @"2013110462";
static double G = 9.8;
int hrMonitorsFound = 0;

/*UIColor RED_COLOR = [UIColor colorWithRed: 255.0/255.0f green:0.0/255.0f blue:80.0/255.0f alpha:1.0];//[UIColor redColor];
UIColor *GREEN_COLOR = [UIColor colorWithRed: 0.0/255.0f green:64.0/255.0f blue:255.0/255.0f alpha:1.0];//[UIColor greenColor];
UIColor *YELLOW_COLOR = [UIColor colorWithRed: 192.0/255.0f green:255.0/255.0f blue:32.0/255.0f alpha:1.0];//[UIColor yellowColor];
    */

CLLocationManager *locationManager;// = [[CLLocationManager alloc] init];
double currentMaxAccelX;
double currentMaxAccelY;
double currentMaxAccelZ;
double currentMaxRotX;
double currentMaxRotY;
double currentMaxRotZ;
double rotX;
double rotY;
double rotZ;
double accelX;
double accelY;
double accelZ;
double bearing;
double longitude;
double latitude;
double lastBearing;
double lastLongitude;
double lastLatitude;
double lastAltitude;
double lastLongitude;
double lastLatitude;
double altitude;
double accuracyHorizontal;
double accuracyVertical;
double gravityX;
double gravityY;
double gravityZ;
double speed;

- (void)startSignificantChangeUpdates
{
     // Create the location manager if this object does not
     // already have one.
     if (nil == locationManager)
          locationManager = [[CLLocationManager alloc] init];
     
     locationManager.delegate = self;
     [locationManager startMonitoringSignificantLocationChanges];
}

// Delegate method from the CLLocationManagerDelegate protocol.
- (void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray *)locations {
     // If it's a relatively recent event, turn off updates to save power.
     CLLocation* location = [locations lastObject];
     NSDate* eventDate = location.timestamp;
     locationCount++;
     //NSTimeInterval howRecent = [eventDate timeIntervalSinceNow];
     //if (abs(howRecent) < 15.0) {
          // If the event is recent, do something with it.
          //NSLog(@"latitude %+.6f, longitude %+.6f\n",
          //      location.coordinate.latitude,
          //      location.coordinate.longitude);
     lastLongitude = longitude;
     lastLatitude = latitude;
     speed = location.speed;
          longitude = location.coordinate.longitude;
          latitude = location.coordinate.latitude;
          NSString *latString = [NSString stringWithFormat:@"%+.5f", latitude];
          NSString *lonString = [NSString stringWithFormat:@"%+.5f", longitude];
          [self toggleColor: longitude - lastLongitude onField: self.longTextField withFilter:0.000001 colorSet: 1];
     [self toggleColor: latitude - lastLatitude onField: self.latTextField withFilter:0.000001 colorSet: 1];
     self.longTextField.text = lonString;
          self.latTextField.text = latString;
          _altTextField.text = [NSString stringWithFormat:@"%.1f", location.altitude];
     self.locationCountTextField.text = [NSString stringWithFormat:@"%d", locationCount];
     
          
          // altitude and accuracy
     lastAltitude = altitude;
          altitude = location.altitude;
          accuracyVertical = location.verticalAccuracy;
          accuracyHorizontal = location.horizontalAccuracy;
               [self toggleColor: altitude - lastAltitude onField: self.altTextField withFilter:0.5 colorSet: 0];
          
     //}
}

- (void)startStandardUpdates
{
     // Create the location manager if this object does not
     // already have one.
     if (nil == locationManager)
          locationManager = [[CLLocationManager alloc] init];
     
     locationManager.delegate = self;
     locationManager.desiredAccuracy = kCLLocationAccuracyKilometer;
     
     // Set a movement threshold for new events.
     locationManager.distanceFilter = 5;//500; // meters
     
     [locationManager startUpdatingLocation];
}



// heading
- (void)startHeadingEvents {
     //if (!self.locationManager) {
          //CLLocationManager* theManager = [[[CLLocationManager alloc] init] autorelease];
          
          // Retain the object in a property.
          //self.locManager = theManager;
          //locationManager.delegate = self;
     //}
     
     // Start location services to get the true heading.
     locationManager.distanceFilter = 1;
     locationManager.desiredAccuracy = kCLLocationAccuracyBest;//;kCLLocationAccuracyKilometer;
     [locationManager startUpdatingLocation];
     
     // Start heading updates.
     if ([CLLocationManager headingAvailable]) {
          locationManager.headingFilter = 1;
          [locationManager startUpdatingHeading];
     }
}

- (void)locationManager:(CLLocationManager *)manager didUpdateHeading:(CLHeading *)newHeading {
     if (newHeading.headingAccuracy < 0)
          return;
     
     // Use the true heading if it is valid.
     CLLocationDirection  theHeading = ((newHeading.trueHeading > 0) ?
                                        newHeading.trueHeading : newHeading.magneticHeading);
     self.lastHeading = self.currHeading;
     self.currHeading = theHeading;
     [self toggleColor: self.currHeading - self.lastHeading onField:self.bearingTextField withFilter: 3 colorSet: 0];
     NSString *headingString = [NSString stringWithFormat:@"%.0f", theHeading]; // integer field
     self.bearingTextField.text = headingString;
     bearing = theHeading;
     //[self updateHeadingDisplays];
     
     // max x,y,z
     double teslaX = newHeading.x;
     double teslaY = newHeading.y;
     double teslaZ = newHeading.z;
     self.headingXTextField.text = [NSString stringWithFormat:@"%+.2f", teslaX];
     self.headingYTextField.text = [NSString stringWithFormat:@"%+.2f", teslaY];
     self.headingZTextField.text = [NSString stringWithFormat:@"%+.2f", teslaZ];
     [self toggleColor: teslaX onField:self.headingXTextField withFilter:3 colorSet: 0];
     [self toggleColor: teslaY onField:self.headingYTextField withFilter:3 colorSet: 0];
     [self toggleColor: teslaZ onField:self.headingZTextField withFilter:3 colorSet: 0];
     
}

- (void) toggleColor:(double) diff onField:(UITextField*) control withFilter:(double) filter colorSet: (int) colorSet {
     
     if(diff <  -filter) {
          if(colorSet == 1) {
               control.backgroundColor = [UIColor colorWithRed: 136.0/255.0f green:32.0/255.0f blue:255.0/255.0f alpha:1.0];//[UIColor redColor];
          } else {
               control.backgroundColor = [UIColor colorWithRed: 255.0/255.0f green:0.0/255.0f blue:80.0/255.0f alpha:1.0];//[UIColor redColor];
          }
          [control setTextColor: [UIColor whiteColor]];
     } else {
          if(diff > filter) {
               if(colorSet == 1) {
                    control.backgroundColor = [UIColor colorWithRed: 32.0/255.0f green:64.0/255.0f blue:255.0/255.0f alpha:1.0];//[UIColor greenColor];
               } else {
                    control.backgroundColor = [UIColor colorWithRed: 0.0/255.0f green:64.0/255.0f blue:255.0/255.0f alpha:1.0];
               }
               [control setTextColor: [UIColor whiteColor]];
          } else {
               control.backgroundColor = [UIColor colorWithRed: 192.0/255.0f green:255.0/255.0f blue:48.0/255.0f alpha:1.0];//[UIColor yellowColor];
               [control setTextColor: [UIColor blackColor]];
          }
     }
}
// device motion

// accelerometer


// gyroscope


// magnetometer
// https://developer.apple.com/library/ios/samplecode/Teslameter/Introduction/Intro.html



// proximity
- (void)proximityChanged:(NSNotification *)notification {
     UIDevice *device = [notification object];
     if (device.proximityState == 1) {
          self.proximityTextField.text = @"1";
          self.proximityTextField.backgroundColor = [UIColor greenColor];
          [self.proximityTextField setTextColor: [UIColor blackColor]];
     } else {
          self.proximityTextField.text = @"0";
          self.proximityTextField.backgroundColor = [UIColor blueColor];
          [self.proximityTextField setTextColor: [UIColor whiteColor]];
     }
}

// ambient light


-(void)outputAccelertionData:(CMAcceleration)acceleration
{
     
     accelX = acceleration.x;
     accelY = acceleration.y;
     accelZ = acceleration.z;
     
     self.accelXtextField.text = [NSString stringWithFormat:@"%.3fg",accelX];
     if(fabs(acceleration.x) > fabs(currentMaxAccelX))
     {
          currentMaxAccelX = acceleration.x;
     }
     self.accelYtextField.text = [NSString stringWithFormat:@"%.3fg",accelY];
     if(fabs(acceleration.y) > fabs(currentMaxAccelY))
     {
          currentMaxAccelY = acceleration.y;
     }
     self.accelZtextField.text = [NSString stringWithFormat:@"%.3fg",accelZ];
     if(fabs(acceleration.z) > fabs(currentMaxAccelZ))
     {
          currentMaxAccelZ = acceleration.z;
     }
     
     self.maxAccelXtextField.text = [NSString stringWithFormat:@"%.3f",currentMaxAccelX];
     self.maxAccelYtextField.text = [NSString stringWithFormat:@"%.3f",currentMaxAccelY];
     self.maxAccelZtextField.text = [NSString stringWithFormat:@"%.3f",currentMaxAccelZ];
     

     // set colors
     [self toggleColor: currentMaxAccelX onField: self.maxAccelXtextField withFilter:0.05 colorSet: 0];
     [self toggleColor: currentMaxAccelY onField: self.maxAccelYtextField withFilter:0.05 colorSet: 0];
     [self toggleColor: currentMaxAccelZ onField: self.maxAccelZtextField withFilter:0.05 colorSet: 0];
     [self toggleColor: accelX onField: self.accelXtextField withFilter:0.05 colorSet: 0];
     [self toggleColor: accelY onField: self.accelYtextField withFilter:0.05 colorSet: 0];
     [self toggleColor: accelZ onField: self.accelZtextField withFilter:0.05 colorSet: 0];

     //
     //gravityX =
     
     
     
}
-(void)outputRotationData:(CMRotationRate)rotation
{
     
     self.rotXtextField.text = [NSString stringWithFormat:@"%.3fr/s",rotation.x];
     if(fabs(rotation.x) > fabs(currentMaxRotX))
     {
          currentMaxRotX = rotation.x;
     }
     self.rotYtextField.text = [NSString stringWithFormat:@"%.3fr/s",rotation.y];
     if(fabs(rotation.y) > fabs(currentMaxRotY))
     {
          currentMaxRotY = rotation.y;
     }
     self.rotZtextField.text = [NSString stringWithFormat:@"%.3fr/s",rotation.z];
     if(fabs(rotation.z) > fabs(currentMaxRotZ))
     {
          currentMaxRotZ = rotation.z;
     }
     
     self.maxRotXtextField.text = [NSString stringWithFormat:@"%.3f",currentMaxRotX];
     self.maxRotYtextField.text = [NSString stringWithFormat:@"%.3f",currentMaxRotY];
     self.maxRotZtextField.text = [NSString stringWithFormat:@"%.3f",currentMaxRotZ];

     // set colors
     [self toggleColor: rotation.x onField: self.rotXtextField withFilter:0.05 colorSet: 0];
     [self toggleColor: rotation.y onField: self.rotYtextField withFilter:0.05 colorSet: 0];
     [self toggleColor: rotation.z onField: self.rotZtextField withFilter:0.05 colorSet: 0];
     [self toggleColor: currentMaxRotX onField: self.maxRotXtextField withFilter:0.1 colorSet: 0];
     [self toggleColor: currentMaxRotY onField: self.maxRotYtextField withFilter:0.1 colorSet: 0];
     [self toggleColor: currentMaxRotZ onField: self.maxRotZtextField withFilter:0.1 colorSet: 0];
     rotX = rotation.x;
     rotY = rotation.y;
     rotZ = rotation.z;

     
}

- (void)viewDidLoad
{
     [super viewDidLoad];
     // Do any additional setup after loading the view, typically from a nib.
     // start Bluetooth 4.0 LE
     self.manager = [[CBCentralManager alloc] initWithDelegate:self queue:nil];
     // start Core Location
     //locationManager = [[CLLocationManager alloc] init];
     [self startStandardUpdates];
     [self startHeadingEvents];
     self.bearingTextField.text = @"0";
     self.longTextField.backgroundColor = [UIColor colorWithRed: 0.0/255.0f green:64.0/255.0f blue:255.0/255.0f alpha:1.0];
     self.latTextField.backgroundColor = [UIColor colorWithRed: 0.0/255.0f green:64.0/255.0f blue:255.0/255.0f alpha:1.0];
     self.rate2TextView.textColor = [UIColor colorWithRed: 255.0/255.0f green:0.0/255.0f blue:80.0/255.0f alpha:1.0];
     // motion
     self.motionManager = [[CMMotionManager alloc] init];
     self.motionManager.accelerometerUpdateInterval = .2;
     self.motionManager.gyroUpdateInterval = .2;
     [self.motionManager startAccelerometerUpdatesToQueue:[NSOperationQueue currentQueue]
          withHandler:^(CMAccelerometerData  *accelerometerData, NSError *error) {
               [self outputAccelertionData:accelerometerData.acceleration];
                    if(error){
                         NSLog(@"%@", error);
                    }}];
     [self.motionManager startGyroUpdatesToQueue:[NSOperationQueue currentQueue]
          withHandler:^(CMGyroData *gyroData, NSError *error) {
               [self outputRotationData:gyroData.rotationRate];}];
     
     // proximity
     self.proximityTextField.text = @"0";
     self.proximityTextField.backgroundColor = [UIColor blueColor];
     [self.proximityTextField setTextColor: [UIColor whiteColor]];
     // Proximity Sensor Notification
     /*UIDevice *device = [UIDevice currentDevice];
     device.proximityMonitoringEnabled = YES;
     [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(proximityChanged:) name:@"UIDeviceProximityStateDidChangeNotification" object:device];
     */
     
     // initially disable upload
     self.uploadUISwitch.selected = false;
     self.uploadUISwitch.on = false;

}

- (void)didReceiveMemoryWarning
{
     [super didReceiveMemoryWarning];
     // Dispose of any resources that can be recreated.
}

// unused
- (IBAction)readButtonTouchUpInside:(id)sender {
     [self.peripheral1 readValueForCharacteristic:self.aCharacteristic1];
     NSLog(@"reading");
     self.rateField.text = @"Reading...";
     //uploadFlag = 1 - uploadFlag;
}

- (void)centralManagerDidUpdateState:(CBCentralManager *)central {
    switch (central.state) {
        case CBCentralManagerStatePoweredOn:
            // Scans for any peripheral
            NSLog(@"Setup");
            [self.manager scanForPeripheralsWithServices:[NSArray arrayWithObject:[CBUUID UUIDWithString:@"180D"]] options:nil];
            //self.statusField.text = @"Setup";
            self.rateField.text = @"0";
            //self.cloudField.text = cloudURLString;
            /*self.statusTextView.text = @"Discovering LE Bluetooth devices";*/
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
     if(hrMonitorsFound == 0) {
     //if ([peripheral.name isEqual: ]) {
          self.peripheral1 = peripheral;
          NSLog(@"Connecting to peripheral1 %@", peripheral);
          self.deviceTextField.text = peripheral.name;
          //self.statusTextView.text = peripheral.description;
          //self.statusField.text = peripheral.identifier.UUIDString;
          self.statusField.text = USER_ID;
          // Connects to the discovered peripheral
          //[self.manager connectPeripheral:peripheral options:nil];
          [self.manager connectPeripheral:peripheral options:[NSDictionary dictionaryWithObject:[NSNumber numberWithBool:YES] forKey:CBConnectPeripheralOptionNotifyOnDisconnectionKey]];
          //self.statusTextView.text = peripheral.description;
          hrMonitorsFound++;
          
     //}
     } else {
          self.peripheral2 = peripheral;
          NSLog(@"Connecting to peripheral2 %@", peripheral);
          self.device2TextField.text = peripheral.name;
          //self.statusField.text = USER_ID;
          // Connects to the discovered peripheral
          [self.manager connectPeripheral:self.peripheral2 options:[NSDictionary dictionaryWithObject:[NSNumber numberWithBool:YES] forKey:CBConnectPeripheralOptionNotifyOnDisconnectionKey]];
          hrMonitorsFound++;
     
     
     }
}

- (void)centralManager:(CBCentralManager *)central didConnectPeripheral:(CBPeripheral *)peripheral {
     NSLog(@"Connected to peripheral %@", peripheral);
     if([peripheral isEqual: self.peripheral1]) {
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

/* callback capable */
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
               NSString *rateString = [NSString stringWithFormat:@"%hu", self.heartRate1];
               self.rateField.text = rateString;
               if(peripheral == self.peripheral2) {
                    rateString = [NSString stringWithFormat:@"%hu", self.heartRate1];
                    self.rate2TextView.text = [NSString stringWithFormat:@"%hu", self.heartRate2];;
                    self.rate2TextView.text = [NSString stringWithFormat:@"%hu", self.lastHeartRate2];
               }

               NSLog(@"size: %lu value:%@ %@ %@",(unsigned long)data.length, dataString, myString, rateString);
               if(self.heartRate1 > self.heartRateMax1) {
                    self.heartRateMax1 = self.heartRate1;
                    self.ratePeakField.text = rateString;
                    //self.maxRate2TextField.text = rateString;
               }
               if(self.heartRate1 < self.heartRateMin1) {
                    self.heartRateMin1 = self.heartRate1;
                    self.rateMinField.text = rateString;
                    //self.minRate2TextField.text = rateString;
               }
          
               if(self.lastHeartRate1 < self.heartRate1) {
                    self.rateField.backgroundColor = [UIColor colorWithRed: 0.0/255.0f green:64.0/255.0f blue:255.0/255.0f alpha:1.0];
                    [self.rateField setTextColor: [UIColor whiteColor]];
               }
               if(self.lastHeartRate1 == self.heartRate1) {
                    self.rateField.backgroundColor = [UIColor colorWithRed: 192.0/255.0f green:255.0/255.0f blue:32.0/255.0f alpha:1.0];
                    [self.rateField setTextColor: [UIColor blackColor]];
               }
               if(self.lastHeartRate1 > self.heartRate1) {
                    self.rateField.backgroundColor = [UIColor colorWithRed: 255.0/255.0f green:0.0/255.0f blue:80.0/255.0f alpha:1.0];
                    [self.rateField setTextColor: [UIColor whiteColor]];
               }

               // copy of above
               if(self.heartRate2 > self.heartRateMax2) {
                    self.heartRateMax2 = self.heartRate2;
                    //self.ratePeakField.text = rateString;
                    self.maxRate2TextField.text = rateString;
               }
               if(self.heartRate2 < self.heartRateMin2) {
                    self.heartRateMin2 = self.heartRate2;
                    //self.rateMinField.text = rateString;
                    self.minRate2TextField.text = rateString;
               }
               
               if(self.lastHeartRate2 < self.heartRate2) {
                    self.rate2TextView.backgroundColor = [UIColor colorWithRed: 0.0/255.0f green:64.0/255.0f blue:255.0/255.0f alpha:1.0];
                    [self.rate2TextView setTextColor: [UIColor whiteColor]];
               }
               if(self.lastHeartRate2 == self.heartRate2) {
                    self.rate2TextView.backgroundColor = [UIColor colorWithRed: 192.0/255.0f green:255.0/255.0f blue:32.0/255.0f alpha:1.0];
                    [self.rate2TextView setTextColor: [UIColor blackColor]];
               }
               if(self.lastHeartRate2 > self.heartRate2) {
                    self.rate2TextView.backgroundColor = [UIColor colorWithRed: 255.0/255.0f green:0.0/255.0f blue:80.0/255.0f alpha:1.0];
                    [self.rate2TextView setTextColor: [UIColor whiteColor]];
               }
          
               // get upload state from the switch
               if(self.uploadUISwitch.isOn) {
                    //if(uploadFlag > 0) {
                    [self httpPushToDataCenter];
                    self.uploadConterTextField.backgroundColor = [UIColor greenColor];
                    [self.uploadConterTextField setTextColor: [UIColor blackColor]];
               } else {
                    //self.cloudField.text = @"Upload disabled";
                    self.uploadConterTextField.backgroundColor = [UIColor redColor];
                    [self.uploadConterTextField setTextColor: [UIColor whiteColor]];
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

- (void) extractHeartRate:(NSData *)hrData onPeripheral: (CBPeripheral*) peripheral {
     /*const uint8_t *hrDataBytes = [hrData bytes];
      uint16_t bpm = 0;
      
      if((hrDataBytes[0] & 0x01)==0) { // get uint8 variant
      bpm = hrDataBytes[1];
      } else { // get uint16 variant
      bpm = CFSwapInt16LittleToHost(*(uint16_t *)(&hrDataBytes[1]));
      }
      self.heartRate = bpm;*/
     const uint8_t *reportData = [hrData bytes];
     uint16_t bpm = 0;
     if ((reportData[0] & 0x01) == 0) // intermittent bad access
     //if (null != reportData & (reportData[0] & 0x01) == 0)
     {
          /* uint8 bpm */
          bpm = reportData[1];
     }
     else
     {
          /* uint16 bpm */
          bpm = CFSwapInt16LittleToHost(*(uint16_t *)(&reportData[1]));
     }
     
     //uint16_t oldBpm = self.heartRate;
     if(peripheral == self.peripheral2) {
          self.lastHeartRate2 = self.heartRate2;
          self.heartRate2 = bpm;
     } else {
          self.lastHeartRate1 = self.heartRate1;
          self.heartRate1 = bpm;
     }
}
- (IBAction)rateDown:(id)sender {
     [[self view] endEditing:YES];
}

// use case: reconnect after bt signal lost/regained

// dismiss keyboard for all editing textviews
/*-(IBACTION)DISmissKeyboardOnTap:(id)sender {
 [[self view] endEditing:YES];
 }*/


// https://developer.apple.com/library/mac/documentation/Cocoa/Conceptual/URLLoadingSystem/Tasks/UsingNSURLConnection.html
- (void) httpPushToDataCenter {
     NSMutableString *url = [[NSMutableString alloc ]init ];
     [url appendString: cloudURLString];
     [url appendString: @"&u="];
     
     [url appendString: self.statusField.text];
     [url appendString: @"&pr=ios"];
     [url appendString: @"&hr="];
     [url appendString: [NSString stringWithFormat:@"%hu", self.heartRate1]];
     [url appendString: @"&hr2="];
     [url appendString: [NSString stringWithFormat:@"%hu", self.heartRate2]];
     [url appendString: @"&hr1="];
     [url appendString: [NSString stringWithFormat:@"%hu", self.heartRate1]];
     [url appendString: @"&lg="];
     [url appendString: [NSString stringWithFormat:@"%f", longitude]];
     [url appendString: @"&lt="];
     [url appendString: [NSString stringWithFormat:@"%f", latitude]];
     [url appendString: @"&al=0"];
     [url appendString: [NSString stringWithFormat:@"%f", altitude]];
     [url appendString: @"&ac="]; // accuracy (grid on ios)
     [url appendString: [NSString stringWithFormat:@"%f", accuracyHorizontal]];
     //[url appendString: @"&ts=1383504393030"];
     //[url appendString: [NSString stringWithFormat:@"%hu", self.heartRate1]];
     [url appendString: @"&be="];
     [url appendString: self.bearingTextField.text];//] substringWithRange:NSMakeRange(1, self.bearingTextField.text.length - 1)]]; // fix the plus
     [url appendString: @"&s="]; // speed
     [url appendString: [NSString stringWithFormat:@"%f", speed]];
     //[url appendString: @"&te="]; // temp
     //[url appendString: [NSString stringWithFormat:@"%hu", self.heartRate1]];
     //[url appendString: @"&p="]; // pressure
     //[url appendString: [NSString stringWithFormat:@"%hu", self.heartRate1]];
     //[url appendString: @"&hu="]; // humidity
     //[url appendString: [NSString stringWithFormat:@"%hu", self.heartRate1]];
     //[url appendString: @"&li="]; // light
     //[url appendString: [NSString stringWithFormat:@"%hu", self.heartRate1]];
     // gravity
     //[url appendString: @"&grx="];
     //[url appendString: [NSString stringWithFormat:@"%hu", self.heartRate1]];
     //[url appendString: @"&gry="];
     //[url appendString: [NSString stringWithFormat:@"%hu", self.heartRate1]];
     //[url appendString: @"&grz="];
     //[url appendString: [NSString stringWithFormat:@"%hu", self.heartRate1]];
     // acceleration
     [url appendString: @"&arx="];
     [url appendString: [NSString stringWithFormat:@"%f", accelX]];
     [url appendString: @"&ary="];
     [url appendString: [NSString stringWithFormat:@"%f", accelY]];
     [url appendString: @"&arz="];
     [url appendString: [NSString stringWithFormat:@"%f", accelZ]];
     // linear acceleration
     //[url appendString: @"&lax="];
     //[url appendString: [NSString stringWithFormat:@"%hu", self.heartRate1]];
     //[url appendString: @"&lay="];
     //[url appendString: [NSString stringWithFormat:@"%hu", self.heartRate1]];
     //[url appendString: @"&laz="];
     //[url appendString: [NSString stringWithFormat:@"%hu", self.heartRate1]];
     // rotational vector
     [url appendString: @"&rvx="];
     [url appendString: [NSString stringWithFormat:@"%f", rotX]];
     [url appendString: @"&rvy="];
     [url appendString: [NSString stringWithFormat:@"%f", rotY]];
     [url appendString: @"&rvz="];
     [url appendString: [NSString stringWithFormat:@"%f", rotZ]];
     // gyro
     //[url appendString: @"&ts="];
     //[url appendString: [NSString stringWithFormat:@"%hu", self.heartRate1]];
     //[url appendString: @"&ts="];
     //[url appendString: [NSString stringWithFormat:@"%hu", self.heartRate1]];
     //[url appendString: @"&ts="];
     //[url appendString: [NSString stringWithFormat:@"%hu", self.heartRate1]];
     // tesla
     //url appendString: @"&mfx="];
     //[url appendString: [NSString stringWithFormat:@"%f", self.]];
     
     NSLog(@"Sending: %@",url);
     
     NSURLRequest *theRequest=[NSURLRequest requestWithURL:[NSURL URLWithString: url ]
                    cachePolicy:NSURLRequestUseProtocolCachePolicy
                    timeoutInterval:60.0];
     
     // Create the NSMutableData to hold the received data.
     //receivedData = [NSMutableData dataWithCapacity: 0];
     
     
     // create the connection with the request
     // and start loading the data
     NSURLConnection *theConnection=[[NSURLConnection alloc] initWithRequest:theRequest delegate:self];
     if (!theConnection) {
          // Release the receivedData object.
          //receivedData = nil;
          
          // Inform the user that the connection failed.
          self.uploadConterTextField.text = @"No connection";
     } else {
          uploads++;
          NSString *uploadsString = [NSString stringWithFormat:@"%i", uploads];
          self.uploadConterTextField.text = uploadsString;
     }
}

// reset keyboard
-(IBAction)backgroundTap:(id)sender {
     [[self view] endEditing:YES];
}

- (CGFloat) DegreesToRadians: (CGFloat) degrees {
     return degrees * M_PI / 180;
}

- (CGFloat) RadiansToDegrees: (CGFloat) radians {
     return radians * 180 / M_PI;
}

// cleanup
/*- (void)viewDidDisappear:(BOOL)animated {
     [super viewDidDisappear:animated];
     [self.motionManager stopAccelerometerUpdates];
}*/


@end
