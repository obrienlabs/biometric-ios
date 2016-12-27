//
//  BMUIView.h
//  Biometric
//
//  Created by Michael O'Brien on 11/17/2013.
//  Copyright (c) 2013 Michael O'Brien. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BMViewDelegateProtocol.h"
#import "BMViewController.h"

@interface BMUIView : UIView

-(void)update;
@property (assign) CGRect redrawRect;
@property (assign) BMModelEvent *dataObject;
@property (assign) UIViewController *viewController;
// mvc delegate
//property (nonat@omic, assign) BMViewDelegateProtocol delegate;
@property (assign) uint16_t heartRate1;
@property (assign) uint16_t heartRate2;
@property (assign) uint16_t count;


@end
