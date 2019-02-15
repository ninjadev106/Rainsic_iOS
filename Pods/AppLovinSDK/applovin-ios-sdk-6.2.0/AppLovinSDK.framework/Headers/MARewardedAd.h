//
//  MARewardedAd.h
//  sdk
//
//  Created by Thomas So on 8/9/18.
//  Copyright © 2018 AppLovin Corporation. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ALSdk.h"
#import "MARewardedAdDelegate.h"

NS_ASSUME_NONNULL_BEGIN

/**
 * This class represents a full screen rewarded ad.
 */
@interface MARewardedAd : NSObject

/**
 * Get an instance of rewarded ad.
 *
 * @param adUnitIdentifier Ad unit id for which to get the instance.
 *
 * @return An instance of rewarded ad tied to the specified ad unit ID.
 */
+ (instancetype)sharedWithAdUnitIdentifier:(NSString *)adUnitIdentifier;

/**
 * Get an instance of rewarded ad.
 *
 * @param adUnitIdentifier Ad unit id for which to get the instance. Must not be null.
 * @param sdk              SDK  to use. Must not be null.
 *
 * @return An instance of rewarded ad tied to the specified ad unit ID.
 */
+ (instancetype)sharedWithAdUnitIdentifier:(NSString *)adUnitIdentifier sdk:(ALSdk *)sdk;
- (instancetype)init NS_UNAVAILABLE;

/**
 * Set a delegate that will be notified about ad events.
 */
@property (nonatomic, weak, nullable) id<MARewardedAdDelegate> delegate;

/**
 * Set an extra parameter to pass to the server.
 *
 * @param key   Parameter key.
 * @param value Parameter value.
 */
- (void)setExtraParameterForKey:(NSString *)key value:(nullable NSString *)value;

/**
 * Load ad for the current rewarded ad. Use {@link MARewardedAd:delegate} to assign a delegate that should be
 * notified about ad load state.
 */
- (void)loadAd;

/**
 * Show the loaded rewarded ad. Use {@link MARewardedAd:delegate} to assign a delegate that should be
 * notified about display events.
 * <p>
 * If no ad was loaded, display delegate will be notified about the display failure. Use `isReady` to check if an ad was
 * successfully loaded.
 * </p>
 */
- (void)showAd;

/**
 * Check if this ad is ready to be shown.
 */
@property (nonatomic, assign, readonly, getter=isReady) BOOL ready;

@end

NS_ASSUME_NONNULL_END
