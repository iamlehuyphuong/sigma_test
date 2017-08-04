//
//  ViewController.m
//  ThreadTesting
//
//  Created by HuyPhuong on 8/2/17.
//  Copyright © 2017 HuyPhuong. All rights reserved.
//

#import "ViewController.h"

#define time_read_battery 3
#define time_read_location 5
#define time_delay_post 0

#define remove_when_posted NO

#define server_address @"http://sigma-solutions.eu/test"

@interface ViewController ()

@end

@implementation ViewController
{
    CLLocationManager * locationManager;
    CLGeocoder *geocoder;
    CLPlacemark *placemark;
    
    NSMutableArray* L;
    
    BOOL isRunning;
    NSUInteger counter;
    NSUInteger post_index;
    
    BOOL isThread_1_Run;
    BOOL isThread_2_Run;
    BOOL isThread_3_Run;
}

@synthesize label_lat, label_long, label_status, address, button_control;
@synthesize label_battery;
@synthesize thread_1, thread_2, thread_3;

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    L = [[NSMutableArray alloc] init];
    
    counter=0;
    isRunning=NO;
    isThread_1_Run=NO;
    isThread_2_Run=NO;
    isThread_3_Run=NO;
    
    locationManager = [[CLLocationManager alloc] init];
    geocoder = [[CLGeocoder alloc] init];
    
    [locationManager requestWhenInUseAuthorization];
    [locationManager requestAlwaysAuthorization];
    
    [[NSThread mainThread] setName:@"Main Thread"];
}

/**
 *  @brief Start schedule get data.
 *  Change title & background color of button control.
 */
-(void) onStart {
    [button_control setTitle:@"STOP" forState:UIControlStateNormal];
    [button_control setBackgroundColor:[UIColor colorWithRed:246/255.0 green:30/255.0 blue:30/255.0 alpha:1.0]];
    
    isRunning=YES;
    
    if (!isThread_1_Run) {
        isThread_1_Run=YES;
        thread_1 = [[NSThread alloc] initWithTarget:self selector:@selector(onReadBatteryLevel) object:nil];
        [thread_1 setName:@"Battery Thread"];
        [thread_1 start];
    }
    
    if (!isThread_2_Run) {
        isThread_2_Run=YES;
        thread_2 = [[NSThread alloc] initWithTarget:self selector:@selector(onReadGPSLocation) object:nil];
        [thread_2 setName:@"GPS Location Thread"];
        [thread_2 start];
    }
    
    if (!isThread_3_Run) {
        isThread_3_Run=YES;
        thread_3 = [[NSThread alloc] initWithTarget:self selector:@selector(onCountDataStored) object:nil];
        [thread_3 setName:@"Post data Thread"];
        [thread_3 start];
    }

}

/**
 *  @brief Set flag stop all threads.
 *  Change title & background color of button control
 */
-(void) onStop {
    [button_control setTitle:@"START" forState:UIControlStateNormal];
    [button_control setBackgroundColor:[UIColor colorWithRed:23/255.0 green:145/255.0 blue:67/255.0 alpha:1.0]];
    
    isRunning=NO;
}

/**
 *  @brief Schedule get battery level.
 *  This method run on thread T1.
 *  Every time_read_battery seconds, T1 call this method one time.
 *  Get battery level using ALSystem.
 */

-(void) onReadBatteryLevel {
    if (!isRunning) {
        NSLog(@"Stop: %@", [[NSThread currentThread] name]);
        isThread_1_Run=NO;
        [NSThread exit];
    }
    
    NSLog(@"Running on: %@", [[NSThread currentThread] name]);
    
    //TODO: Add battery level
    CGFloat bat_level = [ALBattery batteryLevel];
    
    
    dispatch_async(dispatch_get_main_queue(), ^{
        self.label_battery.text = [NSString stringWithFormat:@"%.1f%@", bat_level, @"%"];
    });
    
    [L addObject:[[MyData alloc] initWith:MyDataTypeBatteryLevel andContent:[NSString stringWithFormat:@"Battery level: %f", bat_level]]];

    sleep(time_read_battery);
    [self onReadBatteryLevel];
}

/**
 *  @brief Schedule get current GPS location.
 *  This method run on thread T2.
 *  Every time_read_location seconds, T2 call this method one time.
 */
-(void) onReadGPSLocation {
    if (!isRunning) {
        NSLog(@"Stop: %@", [[NSThread currentThread] name]);
        isThread_2_Run=NO;
        [NSThread exit];
    }
    
    NSLog(@"Running on: %@", [[NSThread currentThread] name]);
    
    //TODO: request GPS Location
    [self onRequestLocation];
    
    sleep(time_read_location);
    [self onReadGPSLocation];
    
}

/**
 * @brief count number of new items stored in L.
 * When couter == 5, sends data to a HTTP server on thread T3.
 */
-(void) onCountDataStored {
    if (!isRunning) {
        isThread_3_Run=NO;
        [NSThread exit];
    }
    
    if (counter + 5 <= L.count) {
        counter+=5;
        
        NSLog(@"Running on abc: %@ (%d-%d)" , [[NSThread currentThread] name], counter, L.count);

        post_index=counter;
        
        [self onPostData];
    }
    
    sleep(5);
    [self onCountDataStored];
}

/**
 *  @brief schedule post all datas to http server.
 *  This method run on thread T3
 */
-(void) onPostData {
    
    if (remove_when_posted) {
        post_index=5;
        while (post_index>0) {
            MyData* data = [L firstObject];
            [L removeObjectAtIndex:0];
            [self post:data];
            sleep(time_delay_post);

        }
    } else {
        for (NSInteger i=5; i>0; i--) {
            MyData* data = [L objectAtIndex:post_index-i];
            [self post:data];
            sleep(time_delay_post);
        }
    }
}

/**
 *  @brief post an item of datas to http server.
 *  This method run on thread T3
 *  @param data content of item (NSString*)
 */

-(void) post:(MyData*) data {
    NSLog(@"Post on: %@", [[NSThread currentThread] name]);
    
    NSDictionary *body = @{@"type": [NSString stringWithFormat:@"%ld", data.type], @"data": data.content};
    NSError *error;
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:body options:0 error:&error];
    NSString *jsonString = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
    
    AFURLSessionManager *manager = [[AFURLSessionManager alloc] initWithSessionConfiguration:[NSURLSessionConfiguration defaultSessionConfiguration]];
    //manager.completionQueue = [NSThread currentThread];
    
    NSMutableURLRequest *req = [[AFJSONRequestSerializer serializer] requestWithMethod:@"POST" URLString:server_address parameters:nil error:nil];
    req.timeoutInterval= [[[NSUserDefaults standardUserDefaults] valueForKey:@"timeoutInterval"] longValue];
    [req setValue:@"text/xml" forHTTPHeaderField:@"Content-Type"];
    [req setHTTPBody:[jsonString dataUsingEncoding:NSUTF8StringEncoding]];
    
    [[manager dataTaskWithRequest:req completionHandler:^(NSURLResponse * _Nonnull response, id  _Nullable responseObject, NSError * _Nullable error) {
        
        NSLog(@"Post result on: %@ error: %ld", [[NSThread currentThread] name], error.code);
        /*
        if (!error) {
            NSLog(@"Post success");
        } else {
            NSLog(@"Post Error: %ld", error.code);
        }
         */
    }] resume];
}

#pragma mark - CLLocationManagerDelegate
-(void) onRequestLocation {
    NSLog(@"Request location on: %@", [[NSThread currentThread] name]);
    if ([CLLocationManager locationServicesEnabled]) {
        locationManager.delegate = self;
        locationManager.desiredAccuracy = kCLLocationAccuracyBest;
        [locationManager startUpdatingLocation];
        dispatch_async(dispatch_get_main_queue(), ^{
            [label_status setText:@"Loading Your Location..."];
        });
    }
}

- (void)locationManager:(CLLocationManager *)manager didFailWithError:(NSError *)error
{
    NSLog(@"didFailWithError Running on: %@", [[NSThread currentThread] name]);

    [label_status setText:@"Failed to Get Your Location"];
}

-(void) locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray<CLLocation *> *)locations {
    NSLog(@"didUpdateLocations Running on: %@", [[NSThread currentThread] name]);
    
    CLLocation *currentLocation = [locations objectAtIndex:0];
    
    if (currentLocation != nil) {
        label_long.text = [NSString stringWithFormat:@"%.8f", currentLocation.coordinate.longitude];
        label_lat.text = [NSString stringWithFormat:@"%.8f", currentLocation.coordinate.latitude];
        
        MyData* data = [[MyData alloc] initWith:MyDataTypeGPSLocation andContent:[NSString stringWithFormat:@"long: %@ and lat: %@", label_long.text, label_lat.text]];
        [L addObject:data];
        [label_status setText:@"Success to Get Your Location"];
    }
    
    // Reverse Geocoding
    [geocoder reverseGeocodeLocation:currentLocation completionHandler:^(NSArray *placemarks, NSError *error) {
        NSLog(@"Found placemarks");
        if (error == nil && [placemarks count] > 0) {
            placemark = [placemarks lastObject];
            address.text = [NSString stringWithFormat:@"%@ %@\n%@ %@\n%@\n%@",
                            placemark.subThoroughfare, placemark.thoroughfare,
                            placemark.postalCode, placemark.locality,
                            placemark.administrativeArea,
                            placemark.country];
        } else {
            NSLog(@"%@", error.debugDescription);
        }
    } ];
    
    
    // Stop Location Manager
    [locationManager stopUpdatingLocation];
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)buttonClicked:(id)sender {
    if (isRunning) {
        [self onStop];
    } else {
        [self onStart];
    }
}

@end
