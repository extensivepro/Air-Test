//
//  AMCIHTTPResponse.h
//  AirTest
//
//  Created by Puttin Wong on 04/23/2013.
//
//

#import "HTTPDataResponse.h"

@interface AMCIHTTPResponse : HTTPDataResponse {
    NSInteger _status;
//    NSMutableDictionary *dict;
}

- (id)initWithErrorCode:(int)httpErrorCode;
- (void)setStatus:(int)status;
- (void)setHeader:(NSString *)value forKey:(NSString *)key;
@end
