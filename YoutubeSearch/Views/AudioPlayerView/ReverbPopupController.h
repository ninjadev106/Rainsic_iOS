//
//  ReverbPopupController.h
//  YoutubeSearch
//
//  Created by An Nguyen on 3/23/18.
//  Copyright © 2018 An Nguyen. All rights reserved.
//

#import "AIPopupController.h"


@class ReverbPopupController;

@protocol ReverbPopupControllerDelegate <NSObject>
- (void)dlgReverbPopupControllerChanged:(ReverbPopupController*)sender;
@end

@interface ReverbPopupController : AIPopupController
@property (nonatomic) NSInteger reverbCode;
@property (nonatomic) NSString* reverbName;
@property (nonatomic, weak) id<ReverbPopupControllerDelegate> delegate;
@end
