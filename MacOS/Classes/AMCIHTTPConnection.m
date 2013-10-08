//
//  AMCIHTTPConnection.m
//  AirTest
//
//  Created by Puttin Wong on 04/22/2013.
//
//

#import "AMCIHTTPConnection.h"
#import "HTTPLogging.h"
#import "HTTPMessage.h"
#import "AirTestAppDelegate.h"
#import "AMCIHTTPResponse.h"

#ifdef CONFIGURATION_DEBUG
static const int httpLogLevel = HTTP_LOG_LEVEL_VERBOSE; // | HTTP_LOG_FLAG_TRACE;
#else
static const int httpLogLevel = HTTP_LOG_LEVEL_INFO; // | HTTP_LOG_FLAG_TRACE;
#endif

#define IPA_CMD @"ipa"
@implementation AMCIHTTPConnection

- (BOOL)supportsMethod:(NSString *)method atPath:(NSString *)path {
	HTTPLogTrace();
	
	// Only support for POST
	if ([method isEqualToString:@"POST"])
	{
        NSArray *args = [[path substringFromIndex:1] pathComponents];
        
        if ([args count] < 1) return NO;
        
        NSString *cmd = args[0];
        if ( [cmd isEqualToString:IPA_CMD] ) {
            return YES;
        }
	}
	return NO;
}

- (BOOL)expectsRequestBodyFromMethod:(NSString *)method atPath:(NSString *)path {
    HTTPLogTrace();
    if ([method isEqualToString:@"POST"]) {
        return YES;
    }
	return NO;
}

- (NSObject<HTTPResponse> *)httpResponseForMethod:(NSString *)method URI:(NSString *)path {
    HTTPLogTrace();
    
    NSString *host = [request headerField:@"Host"];
    
	DDLogCVerbose(@"httpResponseForURI: host:%@, method:%@, path:%@", host, method, path);
    
    NSArray *args = [[path substringFromIndex:1] pathComponents];
    
    if ([args count] < 1) return nil;
    
    NSString *cmd = args[0];
    
//    NSLog(@"request header:%@",[request allHeaderFields]);
//    NSData *postData = [request body];
//    if (postData)
//    {
//        NSLog(@"request body:%@",[[[NSString alloc] initWithData:postData encoding:NSUTF8StringEncoding] autorelease]);
//    }
    
    NSMutableDictionary *results = nil;
    if ([cmd isEqualToString:IPA_CMD]) {
        NSData *postData = [request body];
        NSError *error = nil;
        NSDictionary *dict = [NSJSONSerialization JSONObjectWithData:postData options:NSJSONReadingMutableContainers error:&error];
        NSArray *files = dict[@"data"];
        results = [NSMutableDictionary dictionaryWithCapacity:[files count]];
        for (NSDictionary *file in files) {
            if ([file[@"type"] isEqualToString:@"local"]) {
                AirTestAppDelegate *app = (AirTestAppDelegate *)[[NSApplication sharedApplication] delegate];
//                NSLog(@"before height:%f",app.dropView.window.frame.size.height);
                NSNumber *number = @([app.dropView openFile:file[@"file"] WithAlert:NO]);
                results[file[@"name"]] = number;
//                NSLog(@"after height:%f",app.dropView.window.frame.size.height);
//                [app.dropView display];
            } else if ([file[@"type"] isEqualToString:@"upload"]) {
                //todo
            } else {
                //error
            }
        }
    }
    NSLog(@"%@",results);
    int successCount = 0;
    for (NSString *key in results) {
        if ([results[key] boolValue]) {
            ++successCount;
        }
    }
    unsigned int status= 0;
    if (successCount == [results count]) {
        //all success
        status = 200;
    } else if (successCount == 0) {
        //all failed
        status = 400;
    } else {
        //some successed,some failed
        status = 207;
    }
    NSDictionary *jsonDict = @{@"result": results};
    
    NSError *error;
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:jsonDict
                                                       options:NSJSONWritingPrettyPrinted // Pass 0 if you don't care about the readability of the generated string
                                                         error:&error];
    
    AMCIHTTPResponse *r = [[[AMCIHTTPResponse alloc] initWithData:jsonData] autorelease];
    [r setStatus:status];
//    [r setHeader:@"application/json" forKey:@"Content-type"];
//    NSLog(@"%@",[r httpHeaders]);
    return r;
	return nil;
}

- (void)prepareForBodyWithSize:(UInt64)contentLength
{
	HTTPLogTrace();
    
	// If we supported large uploads,
	// we might use this method to create/open files, allocate memory, etc.
}

- (void)processDataChunk:(NSData *)postDataChunk
{
	HTTPLogTrace();
    
	// Remember: In order to support LARGE POST uploads, the data is read in chunks.
	// This prevents a 50 MB upload from being stored in RAM.
	// The size of the chunks are limited by the POST_CHUNKSIZE definition.
	// Therefore, this method may be called multiple times for the same POST request.
	BOOL result = [request appendData:postDataChunk];
	if (!result)
	{
		HTTPLogError(@"%@[%p]: %@ - Couldn't append bytes!", THIS_FILE, self, THIS_METHOD);
	}
}

@end
