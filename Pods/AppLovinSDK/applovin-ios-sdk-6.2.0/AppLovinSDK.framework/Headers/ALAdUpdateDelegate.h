//
//  ALAdUpdateDelegate.h
//  sdk
//
//
//  Copyright © 2018 AppLovin Corporation. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@protocol ALAdUpdateObserver <NSObject>

- (void)adService:(ALAdService *)adService didUpdateAd:(nullable ALAd *)ad;

- (BOOL)canAcceptUpdate;

@end

NS_ASSUME_NONNULL_END
