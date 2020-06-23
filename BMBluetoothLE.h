//
//  BMBluetoothLE.h
//  Biometric
//
//  Created by Michael O'Brien on 2014-05-20.
//  Copyright (c) 2014 Michael O'Brien. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface BMBluetoothLE : NSObject

+(uint16_t) extractHeartRate: (NSData *)hrData ;
@end
