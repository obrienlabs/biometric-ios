//
//  BMViewController.h
//  Biometric
//
//  Created by Michael O'Brien on 2013-09-22.
//  Copyright (c) 2013 Michael O'Brien. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreBluetooth/CoreBluetooth.h>
#import <CoreLocation/CoreLocation.h>

//@interface BMViewController : UIViewController
@interface BMViewController : UIViewController <CBCentralManagerDelegate, CBPeripheralDelegate>
//@property (nonatomic, strong) CBPeripheralManager *peripheralManager;
////@property (nonatomic, strong) CBPeripheralDelegate *peripheralDelegate;
//@property (nonatomic, strong) CBMutableCharacteristic *customCharacteristic;
@property (weak, nonatomic) IBOutlet UITextField *deviceTextField;
//@property (nonatomic, strong) CBMutableService *customService;
//@property (weak, nonatomic) IBOutlet UITextView *statusTextView;
//@property (weak, nonatomic) IBOutlet UITextField *cloudField;
//@property (weak, nonatomic) IBOutlet UITextField *uuidField;
@property (weak, nonatomic) IBOutlet UIButton *readButton;
@property (weak, nonatomic) IBOutlet UITextField *maxRate2TextField;
@property (weak, nonatomic) IBOutlet UITextField *minRate2TextField;
@property (weak, nonatomic) IBOutlet UITextField *device2TextField;
@property (weak, nonatomic) IBOutlet UISwitch *uploadUISwitch;
@property (weak, nonatomic) IBOutlet UITextField *uploadConterTextField;

@property (weak, nonatomic) IBOutlet UITextField *rate2TextView;

//@property (weak, nonatomic) IBOutlet UITextView *uploadsTextView;

// Core Location
@property (weak, nonatomic) IBOutlet UITextField *longTextField;
@property (weak, nonatomic) IBOutlet UITextField *latTextField;
@property (weak, nonatomic) IBOutlet UITextField *altTextField;


- (IBAction)readTouchDown:(id)sender;
//@property (weak, nonatomic) IBOutlet UILabel *uuidLabel;

@property (nonatomic, strong) CBPeripheral *peripheral1;
@property (nonatomic, strong) CBPeripheral *peripheral12;
@property (nonatomic, strong) CBCharacteristic *aCharacteristic;
@property (nonatomic, strong) CBCentralManager *manager;
//@property (nonatomic, strong) CLLocationManager *locationManager;
@property (weak, nonatomic) IBOutlet UITextField *bearingTextField;

@property (nonatomic, strong) NSMutableData *data1;
@property (nonatomic, strong) NSMutableData *data2;
@property (assign) uint16_t heartRate1;
@property (assign) uint16_t lastHeartRate1;
@property (assign) uint16_t lastHeartRate2;
@property (assign) uint16_t heartRateMax1;
@property (assign) uint16_t heartRateMin1;
@property (assign) uint16_t heartRate2;
@property (assign) uint16_t heartRateMax2;
@property (assign) uint16_t heartRateMin2;

@property (assign) double lastHeading;
@property (assign) double currHeading;
@property (weak, nonatomic) IBOutlet UITextField *headingXTextField;
@property (weak, nonatomic) IBOutlet UITextField *headingYTextField;
@property (weak, nonatomic) IBOutlet UITextField *headingZTextField;


@property (weak, nonatomic) IBOutlet UITextField *accelXtextField;
@property (weak, nonatomic) IBOutlet UITextField *accelYtextField;
@property (weak, nonatomic) IBOutlet UITextField *accelZtextField;
@property (weak, nonatomic) IBOutlet UITextField *maxAccelXtextField;
@property (weak, nonatomic) IBOutlet UITextField *maxAccelYtextField;
@property (weak, nonatomic) IBOutlet UITextField *maxAccelZtextField;
@property (weak, nonatomic) IBOutlet UITextField *rotXtextField;
@property (weak, nonatomic) IBOutlet UITextField *rotYtextField;
@property (weak, nonatomic) IBOutlet UITextField *rotZtextField;
@property (weak, nonatomic) IBOutlet UITextField *maxRotXtextField;
@property (weak, nonatomic) IBOutlet UITextField *maxRotYtextField;
@property (weak, nonatomic) IBOutlet UITextField *maxRotZtextField;
// http://conecode.com/news/2012/06/ios-how-to-using-the-proximity-sensor/
@property (weak, nonatomic) IBOutlet UITextField *proximityTextField;

// http://nscookbook.com/2013/03/ios-programming-recipe-19-using-core-motion-to-access-gyro-and-accelerometer/




- (IBAction)resetMaxValues:(id)sender;

//-(IBACTION)DISmissKeyboardOnTap:(id)sender;
@end
