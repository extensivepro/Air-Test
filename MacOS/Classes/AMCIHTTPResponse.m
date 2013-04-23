//
//  AMCIHTTPResponse.m
//  AirTest
//
//  Created by Puttin Wong on 04/23/2013.
//
//

#import "AMCIHTTPResponse.h"

@implementation AMCIHTTPResponse
-(id)initWithErrorCode:(int)httpErrorCode
{
    if ((self = [super initWithData:nil]))
    {
        _status = httpErrorCode;
//        dict = [NSMutableDictionary dictionary];
    }
    
    return self;
}

//- (void)setHeader:(NSString *)value forKey:(NSString *)key {
//    [dict setObject:value forKey:key];
//}
//
//- (NSDictionary *)httpHeaders
//{	
//	return dict;
//}

- (NSInteger)status
{
	return _status;
}

- (void)setStatus:(int)status {
    _status = status;
}

@end
