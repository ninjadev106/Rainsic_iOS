//
//  AINetworkRequest.h
//  afnetworkex
//
//  Created by An Nguyen on 1/2/17.
//  Copyright © 2017 An Nguyen. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "AFNetworking.h"

typedef void(^AINetworkSuccessHandler)(NSDictionary* data, NSString * message);
typedef void(^AINetworkFailureHandler)(NSError * error);

@interface AINetworkRequest : NSObject
@property NSString *hostName;
@property NSString *moduleName;
@property NSString *apiName;
@property NSString *fullURL;
@property NSDictionary *parameters;
@property NSDictionary *headerParameters;
@property BOOL isPOST;
@property NSInteger requestTimeout;

- (void)startRequestWithSuccessHandler:(AINetworkSuccessHandler)successHandler
                        failureHandler:(AINetworkFailureHandler)failureHandler;
@end
