//
//  UITabBar+TabBar.m
//  YoutubeSearch
//
//  Created by mobile on 12/12/18.
//  Copyright © 2018 An Nguyen. All rights reserved.
//

#import "UITabBar+TabBar.h"

@implementation UITabBar (TabBar)

-(CGSize)sizeThatFits:(CGSize)size {
    return CGSizeMake(size.width + self.frame.size.width, size.height + 60);
}

@end
