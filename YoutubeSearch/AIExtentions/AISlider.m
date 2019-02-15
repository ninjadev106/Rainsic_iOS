//
//  AISlider.m
//  YoutubeSearch
//
//  Created by An Nguyen on 1/11/18.
//  Copyright © 2018 An Nguyen. All rights reserved.
//

#import "AISlider.h"

@implementation AISlider

- (CGRect)trackRectForBounds:(CGRect)bounds{
    return CGRectMake(bounds.origin.x, (bounds.size.height-8)/2, bounds.size.width, 3);
}
@end
