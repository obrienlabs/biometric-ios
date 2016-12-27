//
//  BMModelEvent.h
//  Biometric
//
//  Created by Michael O'Brien on 11/18/2013.
//  Copyright (c) 2013 Michael O'Brien. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface BMModelEvent : NSObject
// no private properties - all encapsulation is public
@property (assign) double heading;
@property (assign) uint16_t heartRate1;
@property (assign) uint16_t heartRate2;
@property (assign) double rotationX;
@property (assign) double rotationY;
@property (assign) double rotationZ;
@property (assign) double accelX;
@property (assign) double accelY;
@property (assign) double accelZ;
@property (assign) double bearing;
@property (assign) double longitude;
@property (assign) double latitude;
@property (assign) double altitude;
@property (assign) double accuracyHorizontal;
@property (assign) double accuracyVertical;
@property (assign) double gravityX;
@property (assign) double gravityY;
@property (assign) double gravityZ;
@property (assign) double speed;
@property (assign) double teslaX;
@property (assign) double teslaY;
@property (assign) double teslaZ;

@end
