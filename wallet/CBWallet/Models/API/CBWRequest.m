//
//  CBWRequest.m
//  CBWallet
//
//  Created by Zin on 16/3/28.
//  Copyright © 2016年 Bitmain. All rights reserved.
//

#import "CBWRequest.h"

#import "AFNetworking.h"

NSString *const CBWRequestAPIHost = @"http://123.56.188.103:8079";
NSString *const CBWRequestAPIPath = @"";
NSString *const CBWRequestAPIVersion = @"";

const NSUInteger CBWRequestPageSizeDefault = 20;
const NSUInteger CBWRequestPageSizeMax = 50;

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
    // 3. create request
    NSString *urlString = [[self baseURLString] stringByAppendingPathComponent:path];
    DLog(@"request: %@", urlString);
    NSURLRequest *request = [[AFJSONRequestSerializer serializer] requestWithMethod:method URLString:urlString parameters:parameters error:nil];
    // 4. fetch
    NSURLSessionDataTask *dataTask = [manager dataTaskWithRequest:request completionHandler:^(NSURLResponse *response, id responseObject, NSError *error) {
        [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
        
        NSInteger statusCode = ((NSHTTPURLResponse *)response).statusCode;
        if (error) {
            NSLog(@"request error: %@", error);
            // TODO: handle error
            completion(error, statusCode, nil);
        } else {
//            DLog(@"request response [%ld]: %@", (long)statusCode, responseObject);
            DLog(@"request response [%ld]", (long)statusCode);
            completion(nil, statusCode, [responseObject objectForKey:@"data"]);
        }
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
