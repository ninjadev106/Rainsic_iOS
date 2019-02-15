//
//  ReverbOptionsView.h
//  YoutubeSearch
//
//  Created by An Nguyen on 3/28/18.
//  Copyright © 2018 An Nguyen. All rights reserved.
//

#import "AINibView.h"

@protocol ReverbOptionsViewDelegate <NSObject>
- (void)dlgReverbOptionsViewChangeIndex:(NSInteger)index;
@end

@interface ReverbOptionsView : AINibView
@property (nonatomic, weak) id<ReverbOptionsViewDelegate> delegate;
@property (nonatomic) NSInteger reverbCode;
@property (nonatomic) NSString* reverbName;
@property (nonatomic) NSInteger Viewindex;
@end
