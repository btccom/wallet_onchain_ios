//
//  CBWRequest.m
//  CBWallet
//
//  Created by Zin on 16/3/28.
//  Copyright © 2016年 Bitmain. All rights reserved.
//

#import "CBWRequest.h"

#import "AFNetworking.h"

NSString *const CBWRequestAPIHost = @"https://chain.btc.com";
NSString *const CBWRequestAPIPath = @"api";
NSString *const CBWRequestAPIVersion = @"v1";

const NSUInteger CBWRequestLimitDefault = 20;

@implementation CBWRequest

+ (NSString *)baseURLString {
    return [NSString stringWithFormat:@"%@/%@/%@", CBWRequestAPIHost, CBWRequestAPIPath, CBWRequestAPIVersion];
}

- (NSString *)baseURLString {
    return [CBWRequest baseURLString];
}

- (void)requestWithPath:(NSString *)path parameters:(NSDictionary *)parameters completion:(CBWRequestCompletion)completion {
    // 1. config session
    NSURLSessionConfiguration *configuration = [NSURLSessionConfiguration defaultSessionConfiguration];
    // 2. create manager with configuration
    AFURLSessionManager *manager = [[AFURLSessionManager alloc] initWithSessionConfiguration:configuration];
    // 3. create request
    NSString *urlString = [[self baseURLString] stringByAppendingPathComponent:path];
    DLog(@"request: %@", urlString);
    NSURLRequest *request = [[AFJSONRequestSerializer serializer] requestWithMethod:@"GET" URLString:urlString parameters:parameters error:nil];
    // 4. fetch
    NSURLSessionDataTask *dataTask = [manager dataTaskWithRequest:request completionHandler:^(NSURLResponse *response, id responseObject, NSError *error) {
        NSInteger statusCode = ((NSHTTPURLResponse *)response).statusCode;
        if (error) {
            NSLog(@"request error: %@", error);
            // TODO: handle error
            completion(error, statusCode, nil);
        } else {
            completion(nil, statusCode, responseObject);
        }
    }];
    [dataTask resume];
}

@end
