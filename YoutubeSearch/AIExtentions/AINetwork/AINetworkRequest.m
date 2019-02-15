//
//  AINetworkRequest.m
//  afnetworkex
//
//  Created by An Nguyen on 1/2/17.
//  Copyright © 2017 An Nguyen. All rights reserved.
//

#import "AINetworkRequest.h"
@interface AINetworkRequest ()
    @property AFHTTPSessionManager  *manager;
@end

@implementation AINetworkRequest
//- (NSString *)requestHostName {
//    return @"";
//}
//    
//- (NSString *)requestModuleName {
//    return @"";
//}
//    
//- (NSString *)requestApiName {
//    return @"";
//}
//    
//- (NSDictionary *)requestParameters {
//    return @{};
//}
//    
//- (BOOL)isPOSTMethod {
//    return true;
//}
//    
//- (NSInteger)requestTimeoutInterval{
//    return 15;
//}
//    

//- (NSDictionary*) requestHeaderParameters{
//    return nil;
////    return @{@"Apikey":@"wV70mg5h5DLiDMUGQ4OUdOtadjAMqnWT9WDxD/XiI/E=",
////             @"Authorization":@"Basic aG9tZWNhcmF2YW46U3Ryb25nZXIyMDE1IQ=="};
//}

- (void)startRequestWithSuccessHandler:(AINetworkSuccessHandler)successHandler
                        failureHandler:(AINetworkFailureHandler)failureHandler {
    if (!self.manager) {
        self.manager = [AFHTTPSessionManager manager];
        [self.manager.requestSerializer setTimeoutInterval:self.requestTimeout];
//        self.manager.responseSerializer = [[AFJSONResponseSerializer alloc]init];
        self.manager.responseSerializer = [[AFHTTPResponseSerializer alloc]init];//AFHTTPResponseSerializer for data
        if (self.headerParameters) {
            [self.headerParameters enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop) {
                [self.manager.requestSerializer setValue:obj forHTTPHeaderField:key];
            }];
        }
    }
    NSString * urlString = self.fullURL;
    if (!urlString) {
        urlString = [NSString stringWithFormat:@"%@%@%@",self.hostName,self.moduleName,self.apiName];
    }
    NSDictionary *parameters = self.parameters;
    if (!parameters) {
        parameters = @{};
    }
    NSString *encodedURL = [urlString stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    if (self.isPOST) {
        [self.manager POST:encodedURL parameters:parameters progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
            [self responseSuccess:responseObject successHandler:successHandler failureHandler:failureHandler];
        } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
            failureHandler(error);
        }];
    }else{
        
        [self.manager GET:encodedURL parameters:parameters progress:nil success:^(NSURLSessionTask *task, id responseObject) {
            [self responseSuccess:responseObject successHandler:successHandler failureHandler:failureHandler];
        } failure:^(NSURLSessionTask *operation, NSError *error) {
            failureHandler(error);
            
        }];
    }
}
    
- (void)responseSuccess:(id)responseObject successHandler:(AINetworkSuccessHandler)successHandler
         failureHandler:(AINetworkFailureHandler)failureHandler{
    NSError *error = nil;
    NSDictionary *responseData = [NSJSONSerialization JSONObjectWithData:responseObject options:kNilOptions error:&error];
    if (error != nil) {
        failureHandler(error);
    }
    else{
        successHandler(responseData,nil);
    }
}
    

    
@end
