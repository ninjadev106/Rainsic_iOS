//
//  RootTabBarController.h
//  YoutubeSearch
//
//  Created by An Nguyen on 10/31/17.
//  Copyright © 2017 An Nguyen. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "AudioEQController.h"
#import "ChildTabViewController.h"
#import "AudioPlayerController.h"
#import "UITabBar+TabBar.h"

@interface RootTabBarController : UITabBarController
@property (nonatomic) AudioPlayerController* audioController;
@property (nonatomic, weak) ChildTabViewController *childTab;
//@property (nonatomic) AIAudioMixerManager* mixerManager;
@end
