//
//  MyData.h
//  ThreadTesting
//
//  Created by HuyPhuong on 8/2/17.
//  Copyright © 2017 HuyPhuong. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef NS_ENUM (NSInteger, MyDataType) {
    MyDataTypeBatteryLevel=0,
    MyDataTypeGPSLocation
};

@interface MyData : NSObject
    
@property (nonatomic) MyDataType type;
@property (nonatomic, strong) NSString* content;

-(instancetype) initWith:(MyDataType) _type andContent:(NSString*) _content;
    
@end
