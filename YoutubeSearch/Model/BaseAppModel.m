//
//  BaseAppModel.m
//  YoutubeSearch
//
//  Created by An Nguyen on 10/31/17.
//  Copyright © 2017 An Nguyen. All rights reserved.
//

#import "BaseAppModel.h"
#import "YYModel.h"

@implementation BaseAppModel
- (void)encodeWithCoder:(NSCoder *)aCoder {
    [self yy_modelEncodeWithCoder:aCoder];
}
- (id)initWithCoder:(NSCoder *)aDecoder {
    self = [self init];
    return [self yy_modelInitWithCoder:aDecoder];
}
- (id)copyWithZone:(NSZone *)zone {
    return [self yy_modelCopy];
}
- (NSUInteger)hash {
    return [self yy_modelHash];
}
- (BOOL)isEqual:(id)object {
    return [self yy_modelIsEqual:object];
}
- (NSString *)description {
    return [self yy_modelDescription];
}

+ (instancetype)createWithDictionary:(NSDictionary *)dictionary{
    if ([dictionary isKindOfClass:[NSNull class]]) {
        return nil;
    }
    return [self yy_modelWithDictionary:dictionary];
}

+ (NSMutableArray*)createWithArray:(NSArray *)array{
    if ([array isKindOfClass:[NSNull class]]) {
        return nil;
    }
    NSMutableArray *datas = [NSMutableArray new];
    for(NSDictionary *dic in array){
        [datas addObject:[self createWithDictionary:dic]];
    }
    return datas;
}

+ (NSDictionary*)modelCustomPropertyMapper{
    return @{};
    //    return @{@"idx" : @"ix"};
}
+ (NSDictionary*)modelContainerPropertyGenericClass{
    return @{};
    //    return @{@"imageList" : [ListingImage class]};
}

@end
