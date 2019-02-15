//
//  VerticalEQBar.h
//  YoutubeSearch
//
//  Created by An Nguyen on 3/16/18.
//  Copyright © 2018 An Nguyen. All rights reserved.
//

#import "AINibView.h"

@protocol VerticalEQBarDelegate <NSObject>
- (void)dlgVerticalEQBarChangeIndex:(NSInteger)index;
@end

@interface VerticalEQBar : AINibView
@property (nonatomic, weak) id<VerticalEQBarDelegate> delegate;
@property (nonatomic) NSInteger index;
@property (nonatomic) NSInteger Viewindex;
@end
