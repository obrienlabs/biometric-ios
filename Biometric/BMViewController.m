//
//  BMViewController.m
//  Biometric
//
//  Created by Michael O'Brien on 2013-09-22.
//  Copyright (c) 2013 Michael O'Brien. All rights reserved.
// 20141018: added iOS 8.0 support for required location permissions
// 20151018: added iOS 9.0 workaround for https requirement - still need rotation/heading
//           https://forums.developer.apple.com/thread/3544
// 20160406: fixed shifted screen after xcode 7 upgrade by setting project | general | launch screen to added launch screen storyboard
//

#import "BMViewController.h"
#import "BMSensorManager.h"
#import "BMUIView.h"
#import "BMBluetoothLE.h"
#import "BMPersistence.h"
// https://developer.apple.com/library/ios/documentation/userexperience/conceptual/LocationAwarenessPG/CoreLocation/CoreLocation.html
#import <CoreLocation/CoreLocation.h>
#import <UIKit/UIKit.h>
#import <CoreMotion/CoreMotion.h>

//BMModelEvent *dataObject2;
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

//static NSString * const kServiceUUID = @"C15191A3-D214-4E6A-B533-0BCE41B833A6";
//static NSString * const kCharacteristicUUID = @"2208559C-21AB-4263-B334-0CFE1946DF17";
static NSString * const kServiceUUID_mio1 = @"398D853C-FE6D-A669-0E72-4A19D103CF0D";
//Wahoo HRM v2.1
//DF5AAD76-FA92-9B42-41A4-AABFE9482C8D
//RHYTHM
//C6E19981-0396-6AA6-B701-3D57F72A596D
static NSString * const kServiceUUID_wahoo = @"4A90672B-EC3A-BEC2-5833-AD5A559DEE87";
//static NSString * const kCharacteristicUUID = @"2208559C-21AB-4263-B334-0CFE1946DF17";
//static NSString * const kCharacteristicUUID = @"6c721826 5bf14f64 9170381c 08ec57ee";
static NSString * const HEARTRATE_UUID = @"2a37";
//static NSString * const cloudURLPublicString = @"https://obrienscience-obrienlabs.java.us1.oraclecloudapps.com/gpsbio/FrontController?action=setGps";//&u=20131027&lt=0&lg=0&al=0&hr=999
//static NSString * const cloudURLPublicString = @"http://biometric.elasticbeanstalk.com/FrontController?action=setGps";//&u=20131027&lt=0&lg=0&al=0&hr=999
static NSString * const cloudURLPublicString = @"http://127.0.0.1:8180/biometric/FrontController?action=setGps";//
//static NSString * const cloudURLPrivateString = @"http://174.112.45.69:8180/biometric/FrontController?action=setGps";//&u=20131027&lt=0&lg=0&al=0&hr=99
static NSString * const cloudURLPrivateString = @"http://biometric-s.us-east-1.elasticbeanstalk.com/FrontController?action=setGps";//&u=20131027&lt=0&lg=0&al=0&hr=99
//static NSString * const cloudURLPrivateString = @"http://biometric-prd.elasticbeanstalk.com/FrontController?action=setGps";//&u=20131027&lt=0&lg=0&al=0&hr=99

//static NSString * const cloudURLPrivateString = @"http://obrien2.com/biometric/FrontController?action=setGps";//
//static NSString * const cloudURLPrivateString = @"http://obrienlabs.elasticbeanstalk.com/FrontController?action=setGps";//

static int uploads = 0;
static int serverRecordId = 0;
static int uploadsColor = 0;
static int locationCount = 0;
static int LocationCountColor = 0;
static int warningHeartRate = 156;
static NSString * const USER_ID = @"201703";
static double G = 9.8;
int hrMonitorsFound = 0;
int hrConnections = 0;
bool dataCenterFlip = false;
bool hrMonitor1Found = false;
bool hrMonitor2Found = false;
static NSTimer *anNSTimer;
static int frame = 0;
// flash the heart rate based on 100ms divisions
static double heartDuration = 0;
static double timerDuration = 0;
//static double timerDruationStep = 0.1f;

// track time since last connect
int timeSinceLastBluetoothData = 0;


/*UIColor RED_COLOR = [UIColor colorWithRed: 255.0/255.0f green:0.0/255.0f blue:80.0/255.0f alpha:1.0];//[UIColor redColor];
UIColor *GREEN_COLOR = [UIColor colorWithRed: 0.0/255.0f green:64.0/255.0f blue:255.0/255.0f alpha:1.0];//[UIColor greenColor];
UIColor *YELLOW_COLOR = [UIColor colorWithRed: 192.0/255.0f green:255.0/255.0f blue:32.0/255.0f alpha:1.0];//[UIColor yellowColor];
*/
CLLocationManager *locationManager;
double currentMaxAccelX;
double currentMaxAccelY;
double currentMaxAccelZ;
double currentMaxRotX;
double currentMaxRotY;
double currentMaxRotZ;
double lastBearing;
double lastLongitude;
double lastLatitude;
double lastAltitude;
double lastLongitude;
double lastLatitude;
double gravityX;
double gravityY;
double gravityZ;
NSDate *myDate;
//NSDate *bluetoothDate;
NSDateFormatter *dateFormat;

#define IS_OS_8_OR_LATER ([[[UIDevice currentDevice] systemVersion] floatValue] >= 8.0)

- (void)viewDidLoad {
     [super viewDidLoad];
     
     // preferences
     // https://developer.apple.com/library/ios/documentation/Cocoa/Conceptual/UserDefaults/Preferences/Preferences.html#//apple_ref/doc/uid/10000059i-CH6-SW6
     // register preferences
     NSString *userId = @"201505";
     
     // move the view back up
     self.navigationController.navigationBar.translucent = NO;
     
     NSDictionary *appDefaults = [NSDictionary dictionaryWithObject: userId forKey: @"user_id_preference"];
     [[NSUserDefaults standardUserDefaults] registerDefaults:appDefaults];
     
     // SQLlite
     self.persistence = [[BMPersistence alloc] init];
     //[self createObjects];
     [self fetchObjects];
     
     myDate = [[NSDate alloc] init];
     dateFormat = [[NSDateFormatter alloc] init];
     [dateFormat setDateFormat:@"cccc, MMMM dd, yyyy, hh:mm:ss.SSS"]; // Z
     // get data object
     self.dataObject = [[BMModelEvent alloc ] init];
     ((BMUIView*)self.view).dataObject = self.dataObject;
     
     // Do any additional setup after loading the view, typically from a nib.
     // start Bluetooth 4.0 LE
     self.manager = [[CBCentralManager alloc] initWithDelegate:self queue:nil];
     self.sensorManager = [[BMSensorManager alloc] init];
     
     // start Core Location
     [self startStandardUpdates];
     [self startHeadingEvents];
     self.bearingTextField.text = @"0";
     self.rateField.text = @"0";
     self.rate2TextView.text = @"0";
     self.device2TextField.text = @"HR Device n/a";
     self.deviceTextField.text = @"HR Device 2 n/a";
     self.longTextField.backgroundColor = [UIColor colorWithRed: 0.0/255.0f green:64.0/255.0f blue:255.0/255.0f alpha:1.0];
     self.latTextField.backgroundColor = [UIColor colorWithRed: 0.0/255.0f green:64.0/255.0f blue:255.0/255.0f alpha:1.0];
     self.rate2TextView.textColor = [UIColor colorWithRed: 255.0/255.0f green:0.0/255.0f blue:80.0/255.0f alpha:1.0];
     self.rateField.textColor = [UIColor colorWithRed: 255.0/255.0f green:0.0/255.0f blue:80.0/255.0f alpha:1.0];
     // motion
     self.motionManager = [[CMMotionManager alloc] init];
     self.motionManager.accelerometerUpdateInterval = .05;
     self.motionManager.gyroUpdateInterval = .05;
     [self.motionManager startAccelerometerUpdatesToQueue:[NSOperationQueue currentQueue]
               withHandler:^(CMAccelerometerData  *accelerometerData, NSError *error) {
                    [self outputAccelertionData:accelerometerData.acceleration];
                    if(error){
                         NSLog(@"%@", error);
                    }}];
     // gyroscope
     [self.motionManager startGyroUpdatesToQueue:[NSOperationQueue currentQueue]
               withHandler:^(CMGyroData *gyroData, NSError *error) {
                    [self outputRotationData:gyroData.rotationRate];}];
     
     // gravity
     // after 20 min we no longer get reliable updates
     // http://stackoverflow.com/questions/15646433/measuring-tilt-angle-with-cmmotionmanager
     /*[self.motionManager startDeviceMotionUpdatesUsingReferenceFrame:CMAttitudeReferenceFrameXArbitraryZVertical
               toQueue:[NSOperationQueue currentQueue]
               withHandler:^(CMDeviceMotion *motion, NSError *error) {
          [[NSOperationQueue mainQueue] addOperationWithBlock:^{
               gravityX = motion.gravity.x;
               self.dataObject.gravityX = gravityX;
               gravityY = motion.gravity.y;
               self.dataObject.gravityY = gravityY;
               gravityZ = motion.gravity.z;
               self.dataObject.gravityZ = gravityZ;
               //NSLog(@"grav %.3f",self.dataObject.gravityZ);
               
               //gravXtextField color
               [self toggleColor: self.dataObject.gravityX onField: self.gravXtextField withFilter:0.05 colorSet: 0];
               [self toggleColor: self.dataObject.gravityY onField: self.gravYtextField withFilter:0.05 colorSet: 0];
               [self toggleColor: self.dataObject.gravityZ onField: self.gravZtextField withFilter:0.05 colorSet: 0];
               // values
               self.gravXtextField.text = [NSString stringWithFormat:@"%+.3fg", self.dataObject.gravityX];
               self.gravYtextField.text = [NSString stringWithFormat:@"%+.3fg", self.dataObject.gravityY];
               self.gravZtextField.text = [NSString stringWithFormat:@"%+.3fg", self.dataObject.gravityZ];
               
          }];
     }];*/
     
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
     self.gpsSwitch.on = true;
     self.gpsSwitch.selected = false;
     
     // initially set datacenter to private
     self.datacenterUISwitch.selected = false;
     self.datacenterUISwitch.on = false;
     
     // get setting
     
     NSString *aUserId = [[NSUserDefaults standardUserDefaults] objectForKey:@"user_id_preference"];//USER_ID;
     NSLog(@"Pref: %@", aUserId);
     NSDate *aDate = [[NSDate alloc] init];
     NSDateFormatter *dateDayFormat = [[NSDateFormatter alloc] init];
     [dateDayFormat setDateFormat:@"yyyyMMdd"]; // Zulu
     NSString *dateDayString = [dateDayFormat stringFromDate: aDate];
     //NSString *ymd = [dateDayFormat dateFromString: dateDayString];
     self.statusField.text = dateDayString;
     // setup timer (0% loss on 0.02 or 50/sec) 1 vm at 
     //anNSTimer = [NSTimer scheduledTimerWithTimeInterval:0.02
                  
     anNSTimer = [NSTimer scheduledTimerWithTimeInterval:0.1
               target:self
               selector:@selector(onTimer)
               userInfo:nil
               repeats:YES];
     }

- (void)onTimer {
     // flash heartrate based on 100ms flash every 1000ms
     //heartDuration+=(self.sensorManager.lastHeartRate1 / 60.0);
     heartDuration+=(self.sensorManager.lastHeartRate1 / 60.0);
     if(heartDuration > 10) {
          heartDuration = 0;
          self.rateField.backgroundColor = [UIColor colorWithRed: 228.0/255.0f green:16.0/255.0f blue:255.0/255.0f alpha:1.0];
     } else {
          self.rateField.backgroundColor = [UIColor blackColor];
     }
     
     // get upload state from the switch
     if(self.uploadUISwitch.isOn) {
          //if((frame == 0 && !self.gpsSwitch.isOn) || frame == 50) {// 10
          if((frame == 0 && !self.gpsSwitch.isOn) || frame == 10) {// 10
               //[self computeGeoHashFromLatitude: self.dataObject.latitude longitude: self.dataObject.longitude];
               
               frame = 0;
               dataCenterFlip = 1 - dataCenterFlip;
               if(dataCenterFlip > 0) {
               self.uploadConterTextField.backgroundColor = [UIColor colorWithRed: 224.0/255.0f green:255.0/255.0f blue:64.0/255.0f alpha:1.0];
               [self.uploadConterTextField setTextColor: [UIColor blackColor]];
               
               } else {
                    self.uploadConterTextField.backgroundColor = [UIColor colorWithRed: 8.0/255.0f green:64.0/255.0f blue:16.0/255.0f alpha:1.0];
                    [self.uploadConterTextField setTextColor: [UIColor whiteColor]];
               }
               [self httpPushToDataCenter];
          } else {
               frame++;
               self.uploadConterTextField.backgroundColor = [UIColor colorWithRed: 8.0/255.0f green:64.0/255.0f blue:16.0/255.0f alpha:1.0];
               [self.uploadConterTextField setTextColor: [UIColor whiteColor]];
          }
     } else {
          self.uploadConterTextField.backgroundColor = [UIColor redColor];
          [self.uploadConterTextField setTextColor: [UIColor whiteColor]];
     }
     // pass values to the view
     ((BMUIView*)self.view).dataObject = self.dataObject;
     [((BMUIView*)self.view) update];
}

- (void)didReceiveMemoryWarning {
     [super didReceiveMemoryWarning];
     // Dispose of any resources that can be recreated.
}


- (void)createObjects {

     NSManagedObject *aDevice = [NSEntityDescription insertNewObjectForEntityForName:@"Device" inManagedObjectContext:self.persistence.managedObjectContext];
     [aDevice setValue:@"iphone5" forKey:@"id"];
     [self.persistence saveContext];
}

- (void)fetchObjects {
     // Fetch the objects
     NSFetchRequest *fetchRequest = [NSFetchRequest fetchRequestWithEntityName:@"Device"];
     NSArray *objects = [self.persistence.managedObjectContext executeFetchRequest:fetchRequest error:nil];
     // Log the objects
     for (NSManagedObject *object in objects) {
          NSLog(@"%@", object); }
}

- (void)startSignificantChangeUpdates {
     // lazy load   
     if (nil == locationManager) {
          locationManager = [[CLLocationManager alloc] init];
     }
     locationManager.delegate = self;
     if(IS_OS_8_OR_LATER) {
          // 20141018: iOS8 requires authorization
          //https://developer.apple.com/Library/ios/documentation/CoreLocation/Reference/CLLocationManager_Class/index.html#//apple_ref/occ/instm/CLLocationManager/requestAlwaysAuthorization
          [locationManager requestAlwaysAuthorization];
     }
     [locationManager startMonitoringSignificantLocationChanges];
}

- (void)startStandardUpdates {
     // lazy load
     if (nil == locationManager) {
          locationManager = [[CLLocationManager alloc] init];
     }
     locationManager.delegate = self;
     if(IS_OS_8_OR_LATER) {
     // 20141018: iOS8 requires authorization
     //https://developer.apple.com/Library/ios/documentation/CoreLocation/Reference/CLLocationManager_Class/index.html#//apple_ref/occ/instm/CLLocationManager/requestAlwaysAuthorization
     [locationManager requestAlwaysAuthorization];
     }
     locationManager.desiredAccuracy = kCLLocationAccuracyKilometer;
     
     // Set a movement threshold for new events.
     locationManager.distanceFilter = 3;//500; // meters
     
     [locationManager startUpdatingLocation];
}

     // Delegate method from the CLLocationManagerDelegate protocol.
- (void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray *)locations {
     // If it's a relatively recent event, turn off updates to save power.
     CLLocation* location = [locations lastObject];
     //NSDate* eventDate = location.timestamp;
     locationCount++;
     lastLongitude = self.dataObject.longitude;
     lastLatitude = self.dataObject.latitude;
     self.dataObject.speed = location.speed;
          self.dataObject.longitude = location.coordinate.longitude;
          self.dataObject.latitude = location.coordinate.latitude;
          NSString *latString = [NSString stringWithFormat:@"%+.5f", self.dataObject.latitude];
          NSString *lonString = [NSString stringWithFormat:@"%+.5f", self.dataObject.longitude];
          [self toggleColor: self.dataObject.longitude - lastLongitude onField: self.longTextField withFilter:0.000001 colorSet: 1];
     [self toggleColor: self.dataObject.latitude - lastLatitude onField: self.latTextField withFilter:0.000001 colorSet: 1];
     self.longTextField.text = lonString;
     self.latTextField.text = latString;
          _altTextField.text = [NSString stringWithFormat:@"%.1f", location.altitude];
     self.locationCountTextField.text = [NSString stringWithFormat:@"%d", locationCount];
          
     // altitude and accuracy
     lastAltitude = self.dataObject.altitude;
     self.dataObject.altitude = location.altitude;
     self.dataObject.accuracyVertical = location.verticalAccuracy;
     self.dataObject.accuracyHorizontal = location.horizontalAccuracy;
     [self toggleColor: self.dataObject.altitude - lastAltitude onField: self.altTextField withFilter:0.5 colorSet: 0];
}


- (void)startHeadingEvents {
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
     self.lastHeading = self.dataObject.heading;
     self.dataObject.heading = theHeading;
     [self toggleColor: self.dataObject.heading - self.lastHeading onField:self.bearingTextField withFilter: 3 colorSet: 0];
     NSString *headingString = [NSString stringWithFormat:@"%.0f", theHeading]; // integer field
     self.bearingTextField.text = headingString;
     self.dataObject.bearing = theHeading;
     
     // max x,y,z
     self.dataObject.teslaX = newHeading.x;
     self.dataObject.teslaY = newHeading.y;
     self.dataObject.teslaZ = newHeading.z;
     self.headingXTextField.text = [NSString stringWithFormat:@"%+.2f", self.dataObject.teslaX];
     self.headingYTextField.text = [NSString stringWithFormat:@"%+.2f", self.dataObject.teslaY];
     self.headingZTextField.text = [NSString stringWithFormat:@"%+.2f", self.dataObject.teslaZ];
     [self toggleColor: self.dataObject.teslaX onField:self.headingXTextField withFilter:1 colorSet: 0];
     [self toggleColor: self.dataObject.teslaY onField:self.headingYTextField withFilter:1 colorSet: 0];
     [self toggleColor: self.dataObject.teslaZ onField:self.headingZTextField withFilter:1 colorSet: 0];
}

- (void) toggleColor:(double) diff onField:(UITextField*) control withFilter:(double) filter colorSet: (int) colorSet {
     
     if(diff < -filter) {
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

-(void)outputAccelertionData:(CMAcceleration)acceleration {
     self.dataObject.accelX = acceleration.x;
     self.dataObject.accelY = acceleration.y;
     self.dataObject.accelZ = acceleration.z;
     // subtract gravity via quaternion
     self.dataObject.linAccelX = acceleration.x - self.dataObject.gravityX;
     self.dataObject.linAccelY = acceleration.y - self.dataObject.gravityY;
     self.dataObject.linAccelZ = acceleration.z - self.dataObject.gravityZ;
     
     self.accelXtextField.text = [NSString stringWithFormat:@"%.3fg", self.dataObject.linAccelX];
     if(fabs(acceleration.x) > fabs(currentMaxAccelX)) {
          currentMaxAccelX = acceleration.x;
     }
     self.accelYtextField.text = [NSString stringWithFormat:@"%.3fg", self.dataObject.linAccelY];
     if(fabs(acceleration.y) > fabs(currentMaxAccelY)) {
          currentMaxAccelY = acceleration.y;
     }
     self.accelZtextField.text = [NSString stringWithFormat:@"%.3fg", self.dataObject.linAccelZ];
     if(fabs(acceleration.z) > fabs(currentMaxAccelZ)) {
          currentMaxAccelZ = acceleration.z;
     }
     
     self.maxAccelXtextField.text = [NSString stringWithFormat:@"%.3f",currentMaxAccelX];
     self.maxAccelYtextField.text = [NSString stringWithFormat:@"%.3f",currentMaxAccelY];
     self.maxAccelZtextField.text = [NSString stringWithFormat:@"%.3f",currentMaxAccelZ];

     // set colors
     [self toggleColor: currentMaxAccelX onField: self.maxAccelXtextField withFilter:0.05 colorSet: 0];
     [self toggleColor: currentMaxAccelY onField: self.maxAccelYtextField withFilter:0.05 colorSet: 0];
     [self toggleColor: currentMaxAccelZ onField: self.maxAccelZtextField withFilter:0.05 colorSet: 0];
     [self toggleColor: self.dataObject.linAccelX onField: self.accelXtextField withFilter:0.05 colorSet: 0];
     [self toggleColor: self.dataObject.linAccelY onField: self.accelYtextField withFilter:0.05 colorSet: 0];
     [self toggleColor: self.dataObject.linAccelZ onField: self.accelZtextField withFilter:0.05 colorSet: 0];
}

-(void)outputRotationData:(CMRotationRate)rotation {
     self.rotXtextField.text = [NSString stringWithFormat:@"%.3fr/s",rotation.x];
     if(fabs(rotation.x) > fabs(currentMaxRotX)) {
          currentMaxRotX = rotation.x;
     }
     self.rotYtextField.text = [NSString stringWithFormat:@"%.3fr/s",rotation.y];
     if(fabs(rotation.y) > fabs(currentMaxRotY)) {
          currentMaxRotY = rotation.y;
     }
     self.rotZtextField.text = [NSString stringWithFormat:@"%.3fr/s",rotation.z];
     if(fabs(rotation.z) > fabs(currentMaxRotZ)) {
          currentMaxRotZ = rotation.z;
     }
     
     self.maxRotXtextField.text = [NSString stringWithFormat:@"%.3f",currentMaxRotX];
     self.maxRotYtextField.text = [NSString stringWithFormat:@"%.3f",currentMaxRotY];
     self.maxRotZtextField.text = [NSString stringWithFormat:@"%.3f",currentMaxRotZ];

     // set colors
     [self toggleColor: rotation.x onField: self.rotXtextField withFilter:0.01 colorSet: 0];
     [self toggleColor: rotation.y onField: self.rotYtextField withFilter:0.01 colorSet: 0];
     [self toggleColor: rotation.z onField: self.rotZtextField withFilter:0.01 colorSet: 0];
     [self toggleColor: currentMaxRotX onField: self.maxRotXtextField withFilter:0.1 colorSet: 0];
     [self toggleColor: currentMaxRotY onField: self.maxRotYtextField withFilter:0.1 colorSet: 0];
     [self toggleColor: currentMaxRotZ onField: self.maxRotZtextField withFilter:0.1 colorSet: 0];
     self.dataObject.rotationX = rotation.x;
     self.dataObject.rotationY = rotation.y;
     self.dataObject.rotationZ = rotation.z;
}

// unused
- (IBAction)readButtonTouchUpInside:(id)sender {
     [self.sensorManager.peripheral1 readValueForCharacteristic:self.aCharacteristic1];
}

// unused
- (IBAction)readTouchDown:(id)sender {
     [self.sensorManager.peripheral1 readValueForCharacteristic:self.aCharacteristic1];
}

- (void)centralManagerDidUpdateState:(CBCentralManager *)central {
    switch (central.state) {
        case CBCentralManagerStatePoweredOn:
            // Scans for any peripheral
            NSLog(@"Setup");
         // ios7
            [self.manager scanForPeripheralsWithServices:[NSArray arrayWithObject:[CBUUID UUIDWithString:@"180D"]] options:nil];
         // ios8
         //[self.manager scanForPeripheralsWithServices:[NSArray arrayWithObject:[CBUUID UUIDWithString:@"Heart Rate"]] options:nil];
            self.rateField.text = @"0";
            self.heartRateMax1 = 0;
            self.heartRateMin1 = 255;
            break;
        default:
            NSLog(@"Central Manager did change state");
            break;
    }
}
             
- (void)centralManager:(CBCentralManager *)central didDiscoverPeripheral:(CBPeripheral *)peripheral
     advertisementData:(NSDictionary *)advertisementData RSSI:(NSNumber *)RSSI {
     NSLog(@"Connecting to peripheral %@", peripheral);
     hrConnections++;
     self.proximityTextField.text = [NSString stringWithFormat:@"%d", hrConnections];;
     // Stops scanning for peripheral
     if(hrMonitorsFound > 1) {
          [self.manager stopScan]; // leave commented to handle reconnects
          hrMonitorsFound++;
     }
     // special handling for the less reliable MIO pulse watch - put it last
     if(![peripheral.name isEqual: @"MIO GLOBAL"] && ![peripheral.name isEqual: @"MIO GLOBAL LINK"]
        && ![peripheral.name isEqual: @"RHYTHM+"]) {
          hrMonitor1Found = true;
          self.sensorManager.peripheral1 = peripheral;
          self.deviceTextField.text = peripheral.name;
     } else {
          // handle 2 MIO watches
          if(hrMonitorsFound == 1 && !hrMonitor1Found) {
               hrMonitor1Found = true;
               self.sensorManager.peripheral1 = peripheral;
               self.deviceTextField.text = peripheral.name;
          } else {
               hrMonitor2Found = true;
               self.sensorManager.peripheral2 = peripheral;
               self.device2TextField.text = peripheral.name;
          }
     }
     
     
     [self.manager
          connectPeripheral: peripheral
          options: [NSDictionary
                    dictionaryWithObject:[NSNumber numberWithBool:YES]
                    forKey: CBConnectPeripheralOptionNotifyOnDisconnectionKey]];
     hrMonitorsFound++;
}

- (void)centralManager:(CBCentralManager *)central didConnectPeripheral:(CBPeripheral *)peripheral {
     NSLog(@"Connected to peripheral %@", peripheral);
     if([peripheral isEqual: self.sensorManager.peripheral1]) {
          [self.data1 setLength:0];
     } else {
          [self.data2 setLength:0];
     }
     [peripheral setDelegate:self];
     [peripheral discoverServices:@[  ]];
}

- (void)peripheral:(CBPeripheral *)aPeripheral didDiscoverServices:(NSError *)error {
     if (error) {
          NSLog(@"Error discovering service: %@", [error localizedDescription]);
          return;
     }
     for (CBService *service in aPeripheral.services) {
          NSLog(@"Service found with UUID: %@", service.UUID);
          //if ([service.UUID isEqual:[CBUUID UUIDWithString:kServiceUUID_wahoo]])
          //   [self.peripheral discoverCharacteristics:@[[CBUUID UUIDWithString:kCharacteristicUUID]] forService:service];
          // https://developer.apple.com/library/ios/documentation/NetworkingInternetWeb/Conceptual/CoreBluetooth_concepts/PerformingCommonCentralRoleTasks/PerformingCommonCentralRoleTasks.html#//apple_ref/doc/uid/TP40013257-CH3-SW7
          [aPeripheral discoverCharacteristics:nil forService:service];
     }
}

- (void)peripheral:(CBPeripheral *)peripheral didDiscoverCharacteristicsForService:(CBService *)service error:(NSError *)error {
     if (error) {
          NSLog(@"Error discovering characteristic: %@", [error localizedDescription]);
          return;
     }
     for (CBCharacteristic *characteristic in service.characteristics) {
          NSLog(@"Discovered characteristic %@ UUID: %@", characteristic,characteristic.UUID);
          if([characteristic.UUID isEqual:[CBUUID UUIDWithString:HEARTRATE_UUID]]) {
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

- (void)peripheral:(CBPeripheral *)peripheral didUpdateValueForCharacteristic:(CBCharacteristic *)characteristic
             error:(NSError *)error {
     // handle only HR monitors 2a37
     if([characteristic.UUID isEqual:[CBUUID UUIDWithString: HEARTRATE_UUID]]) {
          NSData *data = characteristic.value;
          //NSString *dataString = [NSString stringWithFormat:@"%@", data  ];
          NSString* myString;
          myString = [[NSString alloc] initWithData:data encoding:NSASCIIStringEncoding];
          // from apple
          if(nil != data) {
               
               // save time since last bluetooth update
               NSDate *bluetoothDate = [[NSDate alloc] init];
               NSString *dateString = [dateFormat stringFromDate: bluetoothDate];
               NSDate *startdate = [dateFormat dateFromString: dateString];
               //[url appendString: @"&ts="];
               double ts = [startdate timeIntervalSince1970];
               //lastTimestamp
               NSString *timeString = [NSString stringWithFormat:@"%0.0f",ts];
               //NSLog(@"Time: %@", timeString);
                
               
               [self extractHeartRate: characteristic.value onPeripheral: peripheral];
               NSString *rateString = [NSString stringWithFormat:@"%hu", self.dataObject.heartRate1];
               self.rateField.text = rateString;
               if(peripheral == self.sensorManager.peripheral2) {
                    rateString = [NSString stringWithFormat:@"%hu", self.dataObject.heartRate1];
                    self.rate2TextView.text = [NSString stringWithFormat:@"%hu", self.dataObject.heartRate2];
                    self.rate2TextView.text = [NSString stringWithFormat:@"%hu", self.sensorManager.lastHeartRate2];
               }

               if(self.dataObject.heartRate1 > self.heartRateMax1) {
                    self.heartRateMax1 = self.dataObject.heartRate1;
                    self.ratePeakField.text = rateString;
               }
               if(self.dataObject.heartRate1 < self.heartRateMin1) {
                    self.heartRateMin1 = self.dataObject.heartRate1;
                    self.rateMinField.text = rateString;
               }
          
               if(self.sensorManager.lastHeartRate1 < self.dataObject.heartRate1) {
                    self.rateField.textColor = [UIColor colorWithRed: 128.0/255.0f green:224.0/255.0f blue:255.0/255.0f alpha:1.0];
               }
               if(self.sensorManager.lastHeartRate1 == self.dataObject.heartRate1) {
                    self.rateField.textColor = [UIColor colorWithRed: 255.0/255.0f green:255.0/255.0f blue:255.0/255.0f alpha:1.0];
               }
               if(self.sensorManager.lastHeartRate1 > self.dataObject.heartRate1) {
                    self.rateField.textColor = [UIColor colorWithRed: 255.0/255.0f green:160.0/255.0f blue:64.0/255.0f alpha:1.0];
               }
               
               // flash HR
               //if(self.dataObject.heartRate1 > warningHeartRate) {
               //}

               // copy of above
               if(self.dataObject.heartRate2 > self.heartRateMax2) {
                    self.heartRateMax2 = self.dataObject.heartRate2;
                    self.maxRate2TextField.text = rateString;
               }
               if(self.dataObject.heartRate2 < self.heartRateMin2) {
                    self.heartRateMin2 = self.dataObject.heartRate2;
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
          } else {
               NSLog(@"No data on on %@", characteristic);
          }
     } else {
          // unrecognized hr
          NSLog(@"Unrecognized 2a37 HRM %@", characteristic);
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
          NSLog(@"Notification stopped on %@.  Disconnecting", characteristic);
          [self.manager cancelPeripheralConnection: peripheral];
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
- (IBAction)rateDown:(id)sender {
     [[self view] endEditing:YES];
}

// use case: reconnect after bt signal lost/regained

// https://developer.apple.com/library/mac/documentation/Cocoa/Conceptual/URLLoadingSystem/Tasks/UsingNSURLConnection.html
- (void) httpPushToDataCenter {
     NSMutableString *url = [[NSMutableString alloc ]init ];
     if(self.datacenterUISwitch.isOn) {
          [url appendString: cloudURLPublicString];
          self.obrienlabsUILabel.text = @"Public Cloud";
     } else {
          [url appendString: cloudURLPrivateString];
          self.obrienlabsUILabel.text = @"Private Cloud";
     }
     [url appendString: @"&u="];
     [url appendString: self.statusField.text];
          [url appendString: @"&de=iph5se"];
     [url appendString: @"&pr="];//ios7"];
     [url appendString: [NSString stringWithFormat:@"%f",[[[UIDevice currentDevice] systemVersion] floatValue]]];
     if(self.dataObject.heartRate1 > 0) {
          [url appendString: @"&hr="];
          [url appendString: [NSString stringWithFormat:@"%hu", self.dataObject.heartRate1]];
          [url appendString: @"&hr1="];
          [url appendString: [NSString stringWithFormat:@"%hu", self.dataObject.heartRate1]];
     }
     if(self.dataObject.heartRate2 > 0) {
          [url appendString: @"&hr2="];
          [url appendString: [NSString stringWithFormat:@"%hu", self.dataObject.heartRate2]];
     }
     [url appendString: @"&lg="];
     [url appendString: [NSString stringWithFormat:@"%f", self.dataObject.longitude]];
     [url appendString: @"&lt="];
     [url appendString: [NSString stringWithFormat:@"%f", self.dataObject.latitude]];
     [url appendString: @"&al=0"];
     [url appendString: [NSString stringWithFormat:@"%f", self.dataObject.altitude]];
     [url appendString: @"&ac="]; // accuracy (grid on ios)
     [url appendString: [NSString stringWithFormat:@"%f", self.dataObject.accuracyHorizontal]];
     [url appendString: @"&be="];
     [url appendString: self.bearingTextField.text];//] substringWithRange:NSMakeRange(1, self.bearingTextField.text.length - 1)]]; // fix the plus
     [url appendString: @"&s="]; // speed
     [url appendString: [NSString stringWithFormat:@"%f", self.dataObject.speed]];
     //[url appendString: @"&te="]; // temp
     //[url appendString: [NSString stringWithFormat:@"%hu", self.heartRate1]];
     //[url appendString: @"&p="]; // pressure
     //[url appendString: [NSString stringWithFormat:@"%hu", self.heartRate1]];
     //[url appendString: @"&hu="]; // humidity
     //[url appendString: [NSString stringWithFormat:@"%hu", self.heartRate1]];
     //[url appendString: @"&li="]; // light
     //[url appendString: [NSString stringWithFormat:@"%hu", self.heartRate1]];
      //gravity
     [url appendString: @"&grx="];
     [url appendString: [NSString stringWithFormat:@"%f", self.dataObject.gravityX]];
     [url appendString: @"&gry="];
     [url appendString: [NSString stringWithFormat:@"%f", self.dataObject.gravityY]];
     [url appendString: @"&grz="];
     [url appendString: [NSString stringWithFormat:@"%f", self.dataObject.gravityZ]];
     // acceleration
     [url appendString: @"&arx="];
     [url appendString: [NSString stringWithFormat:@"%f", self.dataObject.accelX]];
     [url appendString: @"&ary="];
     [url appendString: [NSString stringWithFormat:@"%f", self.dataObject.accelY]];
     [url appendString: @"&arz="];
     [url appendString: [NSString stringWithFormat:@"%f", self.dataObject.accelZ]];
     // linear acceleration
     [url appendString: @"&lax="];
     [url appendString: [NSString stringWithFormat:@"%f", self.dataObject.linAccelX]];
     [url appendString: @"&lay="];
     [url appendString: [NSString stringWithFormat:@"%f", self.dataObject.linAccelY]];
     [url appendString: @"&laz="];
     [url appendString: [NSString stringWithFormat:@"%f", self.dataObject.linAccelZ]];
     // rotational vector
     [url appendString: @"&rvx="];
     [url appendString: [NSString stringWithFormat:@"%f", self.dataObject.rotationX]];
     [url appendString: @"&rvy="];
     [url appendString: [NSString stringWithFormat:@"%f", self.dataObject.rotationY]];
     [url appendString: @"&rvz="];
     [url appendString: [NSString stringWithFormat:@"%f", self.dataObject.rotationZ]];
     // gyro
     
     myDate = [[NSDate alloc] init];
     NSString *dateString = [dateFormat stringFromDate: myDate];
     NSDate *startdate = [dateFormat dateFromString: dateString];
     [url appendString: @"&ts="];
     [url appendString: [NSString stringWithFormat:@"%0.0f",[startdate timeIntervalSince1970]*1000]];
     // tesla
     [url appendString: @"&mfx="];
     [url appendString: [NSString stringWithFormat:@"%f", self.dataObject.teslaX]];
     [url appendString: @"&mfy="];
     [url appendString: [NSString stringWithFormat:@"%f", self.dataObject.teslaY]];
     [url appendString: @"&mfz="];
     [url appendString: [NSString stringWithFormat:@"%f", self.dataObject.teslaZ]];
     [url appendString: @"&up="];
     [url appendString: [NSString stringWithFormat:@"%d", uploads]];
     
     //https://developer.apple.com/library/mac/DOCUMENTATION/Cocoa/Conceptual/URLLoadingSystem/Tasks/UsingNSURLConnection.html
     // https://developer.apple.com/library/prerelease/ios/technotes/App-Transport-Security-Technote/index.html
     NSURLRequest *theRequest=[NSURLRequest requestWithURL:[NSURL URLWithString: url ]
                    cachePolicy:NSURLRequestUseProtocolCachePolicy
                    timeoutInterval:60.0];
     
     // Create the NSMutableData to hold the received data.
     self.receivedData = [NSMutableData dataWithCapacity: 0];
     
     NSURLConnection *theConnection=[[NSURLConnection alloc] initWithRequest:theRequest delegate:self];
     if (!theConnection) {
          // Release the receivedData object.
          self.receivedData = nil;
          
          // Inform the user that the connection failed.
          self.uploadConterTextField.text = @"No connection";
     } else {
          uploads++;
          NSString *uploadsString = [NSString stringWithFormat:@"%i", uploads];
          self.uploadConterTextField.text = uploadsString;
          // todo: parse return string for OK
          
     }
}

-(void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data{
     [self.receivedData appendData:data];
     NSString *stringData = [[NSString alloc] initWithData: data encoding: NSUTF8StringEncoding];
     NSLog(@"data: %d: %@", [data length], stringData);
     //NSString *serverRecordIdString = [NSString stringWithFormat:@"%i", uploads];
     //NSString *pattern = @"OK:Record.([^,]*),(.*)";
     //NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:pattern options:0 error:NULL];
     // Record(2081441,20141106,17,92,null,null,45.343885,-75.940397,155,105.814392,1415318456373,1415318336304,null)
     NSTextCheckingResult *idMatch = [[NSRegularExpression regularExpressionWithPattern: @"OK:([^:]*):Record.([^,]*),([^,]*),([^,]*),([^,]*),(.*)" options: 0 error: NULL] firstMatchInString: stringData options:0 range: NSMakeRange(0, [stringData length])];
     NSString *serverRecordIdString = [stringData substringWithRange: [idMatch rangeAtIndex: 2]];
     NSLog(@"id: %@", serverRecordIdString);
     
     NSString *serverRecordInSeqString = [stringData substringWithRange: [idMatch rangeAtIndex: 4]];
     NSLog(@"in: %@", serverRecordInSeqString);
     
     NSString *serverRecordOutSeqString = [stringData substringWithRange: [idMatch rangeAtIndex: 5]];
     NSLog(@"out: %@", serverRecordOutSeqString);
     
     NSString *uploadsString = [NSString stringWithFormat:@"%i,%@,%@", uploads, serverRecordInSeqString, serverRecordOutSeqString];
     self.uploadConterTextField.text = uploadsString;

     NSString *geohashString = [stringData substringWithRange: [idMatch rangeAtIndex: 1]];
     self.geohashTextField.text = geohashString;
}


- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response {
     // This method is called when the server has determined that it
     // has enough information to create the NSURLResponse object.
     
     // It can be called multiple times, for example in the case of a
     // redirect, so each time we reset the data.
     
     // receivedData is an instance variable declared elsewhere.
     NSHTTPURLResponse* httpResponse = (NSHTTPURLResponse*)response;
     int code = [httpResponse statusCode];
     NSLog(@"Code: %d", code);
     [self.receivedData setLength:0];
     
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
- (void)viewDidDisappear:(BOOL)animated {
     [super viewDidDisappear:animated];
     [self.motionManager stopAccelerometerUpdates];
}

// https://developer.apple.com/library/ios/documentation/Cocoa/Conceptual/UserDefaults/AccessingPreferenceValues/AccessingPreferenceValues.html#//apple_ref/doc/uid/10000059i-CH3-SW1




// COMPUTE geohash
- (void) computeGeoHashFromLatitude: (double) latitude longitude: (double) longitude {
     //self.geohashTextField.text = @"+f244mk0zj"; // cira 45.4187 -75.7055
     //int x = 0;
     //NSArray longBits;
     //NSArray latBits;
     NSLog(@"geohash: %.3f,",self.dataObject.gravityZ);
     double divisor = 180.0;
     for(int x=0;x<15;x++) {
          
     }
}

@end
