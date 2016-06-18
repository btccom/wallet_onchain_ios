//
//  CBWRequest.m
//  CBWallet
//
//  Created by Zin (noteon.com) on 16/3/28.
//  Copyright © 2016年 Bitmain. All rights reserved.
//
// TODO: request operation queue, cancel request (remove a request queue)

#import "CBWRequest.h"

#import "AFNetworking.h"
NSString *const CBWRequestAPIHost = @"https://chain.api.btc.com";
NSString *const CBWRequestAPIPath = @"";
NSString *const CBWRequestAPIVersion = @"v3";

NSString *const CBWRequestResponseErrorNumberKey = @"err_no";
NSString *const CBWRequestResponseErrorMessageKey = @"err_msg";
NSString *const CBWRequestResponseDataKey = @"data";
NSString *const CBWRequestResponseDataTotalCountKey = @"total_count";
NSString *const CBWRequestResponseDataPageKey = @"page";
NSString *const CBWRequestResponseDataPageSizeKey = @"pagesize";
NSString *const CBWRequestResponseDataListKey = @"list";

@implementation CBWRequest

+ (instancetype)request {
    return [[CBWRequest alloc] init];
}

+ (NSString *)baseURLString {
    return [[CBWRequestAPIHost stringByAppendingPathComponent:CBWRequestAPIPath] stringByAppendingPathComponent:CBWRequestAPIVersion];
}

- (NSString *)baseURLString {
    return [CBWRequest baseURLString];
}

- (void)requestWithPath:(NSString *)path method:(NSString *)method parameters:(NSDictionary *)parameters completion:(CBWRequestCompletion)completion {
    // network indicator
    [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:YES];
    
    // 1. config session
    NSURLSessionConfiguration *configuration = [NSURLSessionConfiguration defaultSessionConfiguration];
    // 2. create manager with configuration
    AFURLSessionManager *manager = [[AFURLSessionManager alloc] initWithSessionConfiguration:configuration];
//    manager.securityPolicy = [AFSecurityPolicy policyWithPinningMode:AFSSLPinningModePublicKey];
    // 3. create request
    NSString *urlString = [[self baseURLString] stringByAppendingPathComponent:path];
    DLog(@"request: %@", urlString);
    NSURLRequest *request = [[AFJSONRequestSerializer serializer] requestWithMethod:method URLString:urlString parameters:parameters error:nil];
    // 4. fetch
    NSURLSessionDataTask *dataTask = [manager dataTaskWithRequest:request completionHandler:^(NSURLResponse *response, id responseObject, NSError *error) {
        [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
        
        NSInteger statusCode = ((NSHTTPURLResponse *)response).statusCode;
        
        DLog(@"request response [%ld]", (long)statusCode);
        
        if (statusCode == 404) {
            completion([NSError errorWithDomain:CBWRequestErrorDomain code:statusCode userInfo:@{NSLocalizedDescriptionKey: @"404: endpoint is not found."}], statusCode, nil);
            NSLog(@"request error, 404");
            return;
        }
        
        if (statusCode / 100 == 5) {
            completion([NSError errorWithDomain:CBWRequestErrorDomain code:500 userInfo:@{NSLocalizedDescriptionKey: @"Server is down."}], statusCode, nil);
            NSLog(@"request error, 5**");
            return;
        }
        
        if (error) {
            NSLog(@"request error: %@", error);
            completion(error, statusCode, nil);
            return;
        }
        
        NSInteger errorNumber = [[responseObject objectForKey:CBWRequestResponseErrorNumberKey] integerValue];
        if (errorNumber > 0) {
            NSString *errorMessage = [responseObject objectForKey:CBWRequestResponseErrorMessageKey];
            if (!errorMessage) {
                errorMessage = [self errorMessageWithCode:errorNumber];
            }
            completion([NSError errorWithDomain:CBWRequestErrorDomain code:errorNumber userInfo:@{NSLocalizedDescriptionKey: [errorMessage stringByAppendingFormat:@"\n(%ld)", (long)errorNumber]}], errorNumber, nil);
            return;
        }
        
        completion(nil, statusCode, [responseObject objectForKey:CBWRequestResponseDataKey]);
    }];
    [dataTask resume];
}

- (void)requestWithPath:(NSString *)path parameters:(NSDictionary *)parameters completion:(CBWRequestCompletion)completion {
    [self requestWithPath:path method:@"GET" parameters:parameters completion:completion];
}

- (void)dealloc {
    DLog(@"request dealloc");
}

@end
