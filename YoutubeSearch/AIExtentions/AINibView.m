//
//  AINibView.m
//  AIFramework
//
//  Created by An Nguyen on 9/25/17.
//  Copyright © 2017 An Nguyen. All rights reserved.
//

#import "AINibView.h"

@implementation AINibView

- (instancetype)init{
    self = [super init];
    if (self) {
        [self initNib];
    }
    return self;
}

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        
        [self initNib];
    }
    return self;
}

- (instancetype)initWithCoder:(NSCoder *)aDecoder{
    self = [super initWithCoder:aDecoder];
    if (self) {
        [self initNib];
    }
    
    return self;
}

- (void)initNib{
    NSArray* arr =  [[NSBundle mainBundle]loadNibNamed:NSStringFromClass([self class]) owner:self options:nil];
    UIView *view = arr[0];
    view.frame = [self bounds];
    view.backgroundColor = [UIColor clearColor];
    view.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    [self addSubview:view];
    self.backgroundColor = UIColor.clearColor;
    [self initCustom];
}
- (void)initCustom{
    
}

@end
