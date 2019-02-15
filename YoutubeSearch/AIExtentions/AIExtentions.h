//  Created by An on 9/6/16.
//  Copyright © 2016 Mac. All rights reserved.
//   ⁰ ¹ ² ³ ⁴ ⁵ ⁶ ⁷ ⁸ ⁹ ₀ ₁ ₂ ₃ ₄ ₅ ₆ ₇ ₈ ₉


#import <UIKit/UIKit.h>

#define IOS_VERSION_EQUAL_TO(v)                  ([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] == NSOrderedSame)
#define IOS_VERSION_GREATER_THAN(v)              ([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] == NSOrderedDescending)
#define IOS_VERSION_GREATER_THAN_OR_EQUAL_TO(v)  ([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] != NSOrderedAscending)
#define IOS_VERSION_LESS_THAN(v)                 ([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] == NSOrderedAscending)
#define IOS_VERSION_LESS_THAN_OR_EQUAL_TO(v)     ([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] != NSOrderedDescending)


@interface AIExtentions :NSObject
+ (CGFloat)ai_degreeToRadian:(CGFloat)degree;
+ (CGFloat)ai_radianToDegree:(CGFloat)radian;
+ (NSInteger)ai_randomIntFrom:(NSInteger)from to:(NSInteger)to;
+ (NSString*)ai_filePath:(NSString*)fileName;
+ (void)ai_dismissKeyboard;
+ (UIViewController*)veryTopViewController;
@end


#pragma mark - UIView
@interface UIView (AIExtentions)


@property (nonatomic, readonly) UIView *firstResponseView;
@property (nonatomic, readonly) CGRect frameWorld;


@property (nonatomic) CGFloat degree;
#pragma mark - Property

@property (nonatomic) CGFloat x;
@property (nonatomic) CGFloat y;
@property (nonatomic) CGFloat width;
@property (nonatomic) CGFloat height;
@property (nonatomic) CGFloat rotation;


- (UIActivityIndicatorView*)showIndicatorView;
- (UIActivityIndicatorView*)showIndicatorViewCenter;
- (void)removeIndicatorView;

#pragma mark - Animation

- (void)flash;
- (void)animationAlpha:(CGFloat)alpha duration:(CGFloat)duration needRemove:(BOOL)needRemove byX:(CGFloat)byX byY:(CGFloat)byY needRestore:(BOOL)needRestore;
- (void)anmationAlpha:(CGFloat)alpha;
- (void)alphaHide:(BOOL)isHide isRemove:(BOOL)isRemove;
- (void)alphaHide:(BOOL)isHide;
- (void)removeFromSuperviewAlpha;
- (void)animationSpringScale:(CGFloat)scale;
- (void)animationFlash;
- (void)animationLayerBlindFlashRepeat:(NSInteger)repeat;
- (void)animationLayerBlindFlashReverseRepeat:(NSInteger)repeat;
- (void)animationLayerPulsingRatio:(CGFloat)ratio repeat:(NSInteger)repeat;
- (void)animationLayerStop;
- (void)animationPreY:(CGFloat)y duration:(CGFloat)duration;
- (void)animationBackY:(CGFloat)y duration:(CGFloat)duration;
- (void)animationX:(CGFloat)x duration:(CGFloat)duration;

- (void)animationByY:(CGFloat)byY endY:(CGFloat)endY duration:(CGFloat)duration;
- (void)animationRotationDegree:(CGFloat)degree;
- (void)animationRotate:(CGFloat)toValue;

#pragma mark - AddSubview

- (void)addSubviewInCenter:(UIView *)view;
- (void)centerInSuperView;

#pragma mark - AutoLayout

- (void)pinEdgesToSuperviewEdges;
- (NSLayoutConstraint*)pinTrailingToSuperview:(CGFloat)cst multi:(CGFloat)multi;
- (NSLayoutConstraint*)pinLeadingToSuperview:(CGFloat)cst multi:(CGFloat)multi;
- (NSLayoutConstraint*)pinTopToSuperview:(CGFloat)cst multi:(CGFloat)multi;
- (NSLayoutConstraint*)pinBottomToSuperview:(CGFloat)cst multi:(CGFloat)multi;
- (NSLayoutConstraint*)pinLeadingToTrailingView:(UIView*)view constraint:(CGFloat)cst multi:(CGFloat)multi;
- (NSLayoutConstraint*)pinTopToBottomView:(UIView*)view constraint:(CGFloat)cst multi:(CGFloat)multi;
- (NSLayoutConstraint*)pinWidthToWidthParentView:(UIView*)parentView constraint:(CGFloat)cst multi:(CGFloat)multi;
- (NSLayoutConstraint*)pinHeightToWidthParentView:(UIView*)parentView constraint:(CGFloat)cst multi:(CGFloat)multi;
- (NSLayoutConstraint*)pinWidthToWidthView:(UIView*)view constraint:(CGFloat)cst multi:(CGFloat)multi;
- (NSLayoutConstraint*)pinHeightToWidthView:(UIView*)view constraint:(CGFloat)cst multi:(CGFloat)multi;
- (NSLayoutConstraint*)pinWidthToConstrant:(CGFloat)cst;
- (NSLayoutConstraint*)pinWidthLessEqualToConstrant:(CGFloat)cst;
- (NSLayoutConstraint*)pinHeightToConstrant:(CGFloat)cst;

- (NSLayoutConstraint*)pinTrailingToView:(UIView*)view constraint:(CGFloat)cst multi:(CGFloat)multi;
- (NSLayoutConstraint*)pinLeadingToView:(UIView*)view constraint:(CGFloat)cst multi:(CGFloat)multi;
- (NSLayoutConstraint*)pinTopToView:(UIView*)view constraint:(CGFloat)cst multi:(CGFloat)multi;
- (NSLayoutConstraint*)pinBottomToView:(UIView*)view constraint:(CGFloat)cst multi:(CGFloat)multi;



#pragma mark

- (void)removeAllSubviews;


#pragma mark - Creator

+ (UIView *)loadWithNibNamed:(NSString *)nibNamed owner:(id)ownerOrNil;
+ (UIView *)loadWithNibNamed:(NSString *)nibNamed;
@end


//    if ([[UIDevice currentDevice].systemVersion intValue] >= 8) {

//typedef NS_ENUM(NSInteger, Something) {
//    /** The width of the view. */
//    ALDimensionWidth = NSLayoutAttributeWidth,
//    /** The height of the view. */
//    ALDimensionHeight = NSLayoutAttributeHeight
//};


#pragma mark - Alert
typedef void(^UIAlertViewHandler)(BOOL isYes);

@interface UIAlertView (AIExtentions)
- (void)showWithHandler:(UIAlertViewHandler)handler;
+ (void)showMessage:(NSString*)msg;
+ (void)showYesNo:(NSString*)msg callback:(UIAlertViewHandler)callback;
+ (void)showComfirm:(NSString*)msg yesButton:(NSString*)yesButton callback:(UIAlertViewHandler)callback;
@end


#pragma mark - Label

@interface UILabel (AIExtentions)
- (void)textAnimation:(NSString*)text;
@end

#pragma mark - Color

@interface UIColor (AIExtentions)
+ (UIColor*)randomColor;
+ (UIColor*)colorWithHexString:(NSString*)hex;

@end


#pragma mark - Button

@interface UIButton (AIExtentions)
- (void)moveImageToRight;
@end

@interface UIImageView (AIExtentions)
- (void)animationChangeImageNamed:(NSString*)imageNamed;
- (void)animationChangeImage:(UIImage*)image;
@end

@interface NSObject (AIExtentions)

+ (BOOL)ai_isNil:(NSObject*)obj;
- (void)performBlock:(void (^)())block afterDelay:(NSTimeInterval)delay;
- (void)performInBackgroundBlock:(void (^)())block;

@end

#pragma mark - String

@interface NSString (AIExtentions)
+ (NSString*)ai_shortNumberwithSuffix:(NSNumber*)number;
+ (NSString*)shortNumberwithSuffix:(NSNumber*)number;
+ (NSString*)stringFromInt:(NSInteger)num;
- (NSString*)ai_concat:(NSString*)string;
+ (BOOL)ai_isEmpty:(NSString*)string;
+ (BOOL)ai_isEmail:(NSString*)string;
+ (BOOL)ai_isPhoneNumber:(NSString*)string;
- (NSString*)trimBlank;
- (NSString*)ai_stringNumberWithCommas;
- (NSString*)ai_stringNumberWithoutCommas;
+ (NSString*)ai_stringNumberWithCommasFromFloat:(CGFloat)number;
+ (NSString*)ai_stringNumberWithCommasFromInt:(NSInteger)number;


@end

@interface NSError (AIExtentions)
+ (NSError*)ai_createFromString:(NSString*)string;
@end

@interface NSMutableArray (AIExtentions)
- (void)ai_shuffle;
@end



@interface NSDate (AIExtentions)
+ (NSDate*)dateWithYear:(NSInteger)year month:(NSInteger)month day:(NSInteger)day;
- (NSDate*)dateWithClearTime;

@end
