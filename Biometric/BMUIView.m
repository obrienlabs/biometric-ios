//
//  BMUIView.m
//  Biometric
//
//  Created by Michael O'Brien on 11/17/2013.
//  Copyright (c) 2013 Michael O'Brien. All rights reserved.
//

#import "BMUIView.h"
#import "BMModelEvent.h"
#import "BMViewController.h"

//BMModelEvent *dataObject2;
@implementation BMUIView

//BMViewController *viewController;
CGContextRef g;
//NSInteger heartRates[400];
uint16_t heartRates[400];
float accel[400];
float rotate[400];
static int warningHeartRate = 156; // merge with viewController
int counter = 10;

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
}

-(void)update {
    //g = UIGraphicsGetCurrentContext();
    
    // fill grey background
    //CGContextSetRGBFillColor(g, (207.0/255.0), (207.0/255.0), 211.0/255.0, 1.0);
    //CGContextFillRect(g, rect);//self.frame);
    // setup graphics p.565
    //CGContextRef context = UIGraphicsGetCurrentContext();
/*    CGContextSetLineWidth(g,3.0);
    CGContextSetStrokeColorWithColor(g, [UIColor redColor].CGColor);
    CGContextMoveToPoint(g, 000.0f,300.0f);//self.dataObject.heading);
    CGContextAddLineToPoint(g, 350.0f,400.0f);
    CGContextStrokePath(g);*/
    //self.currentColor = [UIColor redColor];
    self.redrawRect = CGRectMake (0,280, 400,410);
    [self setNeedsDisplayInRect: self.redrawRect];
    //self.count = self.count + 1;
    //NSLog(@"update %f", self.dataObject.heading);
   
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
*/

- (void)drawRect:(CGRect)rect {
    // get controller
    // https://developer.apple.com/library/ios/documentation/uikit/reference/UIResponder_Class/Reference/Reference.html#//apple_ref/occ/instm/UIResponder/nextResponder
    // https://developer.apple.com/library/ios/featuredarticles/ViewControllerPGforiPhoneOS/BasicViewControllers/BasicViewControllers.html
    //[(BMViewController *)[[self.superView superview] nextResponder] doSomething];
    // grab current graphics context
    g = UIGraphicsGetCurrentContext();

    // fill grey background
    if((warningHeartRate < self.dataObject.heartRate1 || warningHeartRate < self.dataObject.heartRate2) && (counter == 4 || counter == 9))  {
        //CGContextSetStrokeColorWithColor(g, [UIColor colorWithRed: 224.0/255.0f green:224.0/255.0f blue:32.0/255.0f alpha:1.0].CGColor);
        CGContextSetRGBFillColor(g, (224.0/255.0), (240.0/255.0), 32.0/255.0, 1.0);
        CGContextFillRect(g, rect);//self.frame);
        //NSLog(@"Max: %d %d %d", self.warningHeartRate, self.dataObject.heartRate1, self.dataObject.heartRate2);
        
    } else {
        //CGContextSetStrokeColorWithColor(g, [UIColor colorWithRed: 0.0/255.0f green:0.0/255.0f blue:255.0/255.0f alpha:1.0].CGColor);
        //CGContextSetRGBFillColor(g, (0.0/255.0), (0.0/255.0), 0.0/255.0, 1.0);
        //CGContextFillRect(g, rect);//self.frame);
        
    }
    // setup graphics p.565
    //CGContextRef context = UIGraphicsGetCurrentContext();
     CGContextSetLineWidth(g,1.0);
    
    CGFloat yPos;// = 400.0;
    CGFloat xPos;
    if(counter > 0) {
        counter--;
    } else {
        counter = 10;
        // get latest sensor data
        if(self.dataObject.heartRate1 == 0) {
            heartRates[319] = self.dataObject.heartRate2 - 50;
        } else {
            heartRates[319] = self.dataObject.heartRate1 - 50;
        }


    //heartRates[319] = 40;
    //NSLog(@"%d", heartRates[319]);
    }
    for (int i=0; i < 319; i++) {
        // erase
        /*CGContextSetStrokeColorWithColor(g, [UIColor blackColor].CGColor);
         CGContextMoveToPoint(g, xPos,381.0f);
         CGContextAddLineToPoint(g, xPos,410);//yPos);
         CGContextStrokePath(g);*/
        CGContextSetStrokeColorWithColor(g, [UIColor colorWithRed: 192.0/255.0f green:32.0/255.0f blue:224.0/255.0f alpha:1.0].CGColor);
        accel[i] = accel[i+1];
        
        xPos = i;
        yPos = 340.0 - (accel[i]*15);
        CGContextMoveToPoint(g, xPos,340.0);
        CGContextAddLineToPoint(g, xPos,yPos);
        CGContextStrokePath(g);

        //if(0 < self.dataObject.heartRate1 && counter == 4) {
        //    CGContextSetStrokeColorWithColor(g, [UIColor colorWithRed: 224.0/255.0f green:224.0/255.0f blue:32.0/255.0f alpha:1.0].CGColor);
        //} else {
            CGContextSetStrokeColorWithColor(g, [UIColor colorWithRed: 0.0/255.0f green:0.0/255.0f blue:255.0/255.0f alpha:1.0].CGColor);
        //}
        rotate[i] = rotate[i+1];
        yPos = 360.0 - (rotate[i]*15);
        CGContextMoveToPoint(g, xPos,360.0);
        CGContextAddLineToPoint(g, xPos,yPos);
        CGContextStrokePath(g);
    }
    accel[319] = self.dataObject.accelX + self.dataObject.accelY + self.dataObject.accelZ;
    rotate[319] = self.dataObject.rotationX + self.dataObject.rotationY + self.dataObject.rotationZ;

    for (int i=0; i < 319; i++) {
        
        // erase
        /*CGContextSetStrokeColorWithColor(g, [UIColor blackColor].CGColor);
         CGContextMoveToPoint(g, xPos,280.0f);
         CGContextAddLineToPoint(g, xPos,380);//yPos);
         CGContextStrokePath(g);*/
        
        // lower grid
        CGContextSetStrokeColorWithColor(g, [UIColor colorWithRed: 128.0/255.0f green:0.0/255.0f blue:255.0/255.0f alpha:1.0].CGColor);
        CGContextMoveToPoint(g, xPos,379.0f);
        CGContextAddLineToPoint(g, xPos,380);//yPos);
        CGContextStrokePath(g);
        
        if(heartRates[i+1] <= heartRates[i]) {
            CGContextSetStrokeColorWithColor(g, [UIColor colorWithRed: 128.0/255.0f green:255.0/255.0f blue:255.0/255.0f alpha:1.0].CGColor);
        } else {
            CGContextSetStrokeColorWithColor(g, [UIColor colorWithRed: 240.0/255.0f green:240.0/255.0f blue:16.0/255.0f alpha:1.0].CGColor);
            
        }
        // only update every 10th screen
        if(counter == 10) {
            heartRates[i] = heartRates[i+1];
        }
        
        yPos = 380 - (heartRates[i]/2);
        xPos = i;
        CGContextMoveToPoint(g, xPos,yPos - 3);
        CGContextAddLineToPoint(g, xPos,yPos);
        CGContextStrokePath(g);
    }

    
     //NSLog(@"%.1f", sensor[319]);
}
@end
