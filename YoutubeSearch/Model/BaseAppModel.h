//
//  BaseAppModel.h
//  YoutubeSearch
//
//  Created by An Nguyen on 10/31/17.
//  Copyright © 2017 An Nguyen. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface BaseAppModel : NSObject
+ (instancetype)createWithDictionary:(NSDictionary *)dictionary;
+ (NSMutableArray*)createWithArray:(NSArray *)array;
+ (NSDictionary*)modelCustomPropertyMapper;
+ (NSDictionary*)modelContainerPropertyGenericClass;
@end
