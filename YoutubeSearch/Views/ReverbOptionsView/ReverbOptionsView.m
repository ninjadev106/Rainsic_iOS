//
//  ReverbOptionsView.m
//  YoutubeSearch
//
//  Created by An Nguyen on 3/28/18.
//  Copyright © 2018 An Nguyen. All rights reserved.
//

#import "ReverbOptionsView.h"

@interface ReverbOptionsView()

@property (strong, nonatomic) IBOutletCollection(UIButton) NSArray *buttonOptions;
@property (strong, nonatomic) IBOutletCollection(UIView) NSArray *ButtonsView;
@property (strong, nonatomic) IBOutletCollection(UIImageView) NSArray *ratioImg;
@end

@implementation ReverbOptionsView

- (void)initCustom{
    [super initCustom];
}


-(void)drawRect:(CGRect)rect{
    [super drawRect:rect];
    
    for (NSInteger i = 0; i<self.ButtonsView.count; i++) {
        UIView* roundView = [self.ButtonsView objectAtIndex:i];
        roundView.layer.cornerRadius = roundView.frame.size.width / 2;
        roundView.clipsToBounds = YES;
        roundView.hidden = YES;
        UIImageView* ratio = [self.ratioImg objectAtIndex:i];
        ratio.layer.cornerRadius = ratio.frame.size.width / 2;
        ratio.clipsToBounds = YES;
    }
}

- (void)setReverbCode:(NSInteger)reverbCode{
    _reverbCode = reverbCode;
    
    for (NSInteger count = 0; count < self.buttonOptions.count; count++) {
        UIButton* button = [self.buttonOptions objectAtIndex:count];
        if (count == _reverbCode) {
            button.selected = true;
        }else{
            button.selected = false;
        }
    }
}

- (NSString *)reverbName{
    for (UIButton* button in self.buttonOptions) {
        if (button.selected) {
            return [button titleForState:(UIControlStateNormal)];
        }
    }
    return @"None";
}

- (IBAction)onChangedTouched:(UIButton *)sender {
    _Viewindex = [self.buttonOptions indexOfObject:sender];
    self.reverbCode = [self.buttonOptions indexOfObject:sender];
    [self.delegate dlgReverbOptionsViewChangeIndex:[self.buttonOptions indexOfObject:sender]];
    [sender setTitleColor:[UIColor whiteColor] forState:UIControlStateSelected];
    if (sender.selected){
        for (NSInteger i = 0; i<self.ButtonsView.count; i++) {
            UIView* view = [self.ButtonsView objectAtIndex:i];
            if (i == _Viewindex){
                UIImageView * ratio = [self.ratioImg objectAtIndex:i];
                [ratio setImage: [UIImage imageNamed:@"ic-radio-inactive"]];
                [view setBackgroundColor: [UIColor colorWithRed:253.0/255.0 green:190.0/255.0 blue:1.0/255.0 alpha:1.0]];
                
            }else{
                [view setBackgroundColor: [UIColor whiteColor]];
                UIImageView * ratio = [self.ratioImg objectAtIndex:i];
                [ratio setImage: [UIImage imageNamed:@"ic-radio-active"]];
            }
            
        }
        
    }
    
}

@end
