//
//  MAInterstitial.h
//  sdk
//
//  Created by Thomas So on 8/9/18.
//  Copyright © 2018 AppLovin Corporation. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ALSdk.h"
#import "MAAdDelegate.h"

NS_ASSUME_NONNULL_BEGIN

/**
 * This class represents a full screen interstitial ad.
 */
@interface MAInterstitialAd : NSObject

/**
 * Create a new mediation interstitial.
 *
 * @param adUnitIdentifier Ad unit id to load ads for.
 */
- (instancetype)initWithAdUnitIdentifier:(NSString *)adUnitIdentifier;

/**
 * Create a new mediation interstitial.
 *
 * @param adUnitIdentifier Ad unit id to load ads for.
 * @param sdk              SDK to use. An instance of the SDK may be obtained by calling <code>[ALSdk shared]</code>.
 */
- (instancetype)initWithAdUnitIdentifier:(NSString *)adUnitIdentifier sdk:(ALSdk *)sdk;
- (instancetype)init NS_UNAVAILABLE;

/**
 * Set a delegate that will be notified about ad events.
 */
@property (nonatomic, weak, nullable) id<MAAdDelegate> delegate;

/**
 * Set an extra parameter to pass to the server.
 *
 * @param key   Parameter key.
 * @param value Parameter value.
 */
- (void)setExtraParameterForKey:(NSString *)key value:(nullable NSString *)value;

/**
 * Load ad for the current interstitial. Use {@link MAInterstitialAd:delegate} to assign a delegate that should be
 * notified about ad load state.
 */
- (void)loadAd;

/**
 * Show the loaded interstitial. Use {@link MAInterstitialAd:delegate:} to assign a delegate that should be
 * notified about display events.
 * <p>
 * If no ad was loaded, display delegate will be notified about the display failure. Use {MAInterstitialAd:isReady} to check if an ad was
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
