//
//  AppDelegate.m
//  YoutubeSearch
//
//  Created by An Nguyen on 10/27/17.
//  Copyright © 2017 An Nguyen. All rights reserved.
//

#import "AppDelegate.h"
#import <AVFoundation/AVFoundation.h>
#import <AudioToolbox/AudioToolbox.h>
#import <IQKeyboardManager.h>
#import <AppLovinSDK/AppLovinSDK.h>

@interface AppDelegate ()

@end

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    [NSThread sleepForTimeInterval:2.0];
    
  //  [[UITabBar appearance] setTintColor:[UIColor blueColor]];
    
    [[UITabBarItem appearance] setTitleTextAttributes:@{NSFontAttributeName: [UIFont systemFontOfSize: 11.0]} forState:UIControlStateNormal];
    
//    [[UITabBarItem appearance] setTitleTextAttributes:@{ NSForegroundColorAttributeName :[UIColor colorWithRed:(72.0 / 255.0) green:(232.0 / 255.0) blue:(1.0 / 255.0) alpha: 1] }forState:UIControlStateSelected];

    
    UITabBarController *tabBarController = (UITabBarController *)self.window.rootViewController;
    UITabBar *tabBar = tabBarController.tabBar;
    UITabBarItem *tabBarItem1 = [tabBar.items objectAtIndex:0];
    UITabBarItem *tabBarItem2 = [tabBar.items objectAtIndex:1];
    UITabBarItem *tabBarItem3 = [tabBar.items objectAtIndex:2];
   
//    [tabBarItem1 setFinishedSelectedImage:[UIImage imageNamed:@"library"] withFinishedUnselectedImage:[UIImage imageNamed:@"library"]];
//    [tabBarItem2 setFinishedSelectedImage:[UIImage imageNamed:@"favorite"] withFinishedUnselectedImage:[UIImage imageNamed:@"favorite"]];
//    [tabBarItem3 setFinishedSelectedImage:[UIImage imageNamed:@"playlist"] withFinishedUnselectedImage:[UIImage imageNamed:@"playlist"]];
  

//    NSError *sessionError = nil;
   // com.anng.YoutubeSearch
//    [[AVAudioSession sharedInstance] setDelegate:self];
//    [[AVAudioSession sharedInstance] setCategory:AVAudioSessionCategoryPlayAndRecord error:&sessionError];
//    UInt32 doChangeDefaultRoute = 1;
//    AudioSessionSetProperty( kAudioSessionProperty_OverrideCategoryDefaultToSpeaker, sizeof(doChangeDefaultRoute), &doChangeDefaultRoute);
    // Override point for customization after application launch.
//    AVAudioSession*session = [AVAudioSession sharedInstance];
//    [session setCategory:AVAudioSessionCategoryPlayback error:nil];
//    [session overrideOutputAudioPort:AVAudioSessionPortOverrideSpeaker error:nil];
//    [session setActive:true withOptions:(AVAudioSessionSetActiveOptionNotifyOthersOnDeactivation) error:nil];
    
    [IQKeyboardManager sharedManager].enable = true;
    [IQKeyboardManager sharedManager].toolbarDoneBarButtonItemText = @"Close keyboard";
    
    [ALSdk initializeSdk];
    return YES;
}


- (void)applicationWillResignActive:(UIApplication *)application {
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
}


- (void)applicationDidEnterBackground:(UIApplication *)application {
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}


- (void)applicationWillEnterForeground:(UIApplication *)application {
    // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
}


- (void)applicationDidBecomeActive:(UIApplication *)application {
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}


- (void)applicationWillTerminate:(UIApplication *)application {
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}


@end
