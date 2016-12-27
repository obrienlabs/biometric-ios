//
//  BMViewController.h
//  Biometric
//
//  Created by Michael O'Brien on 2013-09-22.
//  Copyright (c) 2013 Michael O'Brien. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreBluetooth/CoreBluetooth.h>

//@interface BMViewController : UIViewController
@interface BMViewController : UIViewController <CBCentralManagerDelegate, CBPeripheralDelegate>
//@property (nonatomic, strong) CBPeripheralManager *peripheralManager;
////@property (nonatomic, strong) CBPeripheralDelegate *peripheralDelegate;
//@property (nonatomic, strong) CBMutableCharacteristic *customCharacteristic;
@property (weak, nonatomic) IBOutlet UITextField *deviceTextField;
//@property (nonatomic, strong) CBMutableService *customService;
@property (weak, nonatomic) IBOutlet UITextView *statusTextView;
//@property (weak, nonatomic) IBOutlet UITextField *cloudField;
//@property (weak, nonatomic) IBOutlet UITextField *uuidField;
@property (weak, nonatomic) IBOutlet UIButton *readButton;

- (IBAction)readTouchDown:(id)sender;
//@property (weak, nonatomic) IBOutlet UILabel *uuidLabel;

@property (nonatomic, strong) CBPeripheral *peripheral;
@property (nonatomic, strong) CBCharacteristic *aCharacteristic;
@property (nonatomic, strong) CBCentralManager *manager;
@property (nonatomic, strong) NSMutableData *data;
@property (assign) uint16_t heartRate;
@property (assign) uint16_t heartRateMax;
@property (assign) uint16_t heartRateMin;

//-(IBACTION)DISmissKeyboardOnTap:(id)sender;
@end
