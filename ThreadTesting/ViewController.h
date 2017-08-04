//
//  ViewController.h
//  ThreadTesting
//
//  Created by HuyPhuong on 8/2/17.
//  Copyright © 2017 HuyPhuong. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MyData.h"
#import "ALSystem.h"
#import "AFNetworking.h"

#import <CoreLocation/CoreLocation.h>

@interface ViewController : UIViewController <CLLocationManagerDelegate>


@property (weak, nonatomic) IBOutlet UILabel *label_lat;
@property (weak, nonatomic) IBOutlet UILabel *label_long;
@property (weak, nonatomic) IBOutlet UITextView *address;
@property (weak, nonatomic) IBOutlet UILabel *label_status;
@property (weak, nonatomic) IBOutlet UIButton *button_control;
@property (weak, nonatomic) IBOutlet UILabel *label_battery;

@property (nonatomic, strong) NSThread* thread_1;
@property (nonatomic, strong) NSThread* thread_2;
@property (nonatomic, strong) NSThread* thread_3;

@end


