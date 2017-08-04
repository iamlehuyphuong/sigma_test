//
//  MyData.m
//  ThreadTesting
//
//  Created by HuyPhuong on 8/2/17.
//  Copyright © 2017 HuyPhuong. All rights reserved.
//

#import "MyData.h"

@implementation MyData
@synthesize type;
@synthesize content;

- (instancetype)init
{
    self = [super init];
    if (self) {

    }
    return self;
}

-(instancetype) initWith:(MyDataType) _type andContent:(NSString*) _content {
    self = [super init];
    type=_type;
    content=_content;
    return self;
}

@end
