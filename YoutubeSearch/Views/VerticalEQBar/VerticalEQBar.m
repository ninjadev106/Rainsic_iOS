//
//  VerticalEQBar.m
//  YoutubeSearch
//
//  Created by An Nguyen on 3/16/18.
//  Copyright © 2018 An Nguyen. All rights reserved.
//

#import "VerticalEQBar.h"

@interface VerticalEQBar()
@property (strong, nonatomic) IBOutletCollection(UIButton) NSArray *optionButtons;
@property (strong, nonatomic) IBOutletCollection(UIView) NSArray *ButtonsView;
@property (strong, nonatomic) IBOutletCollection(UIImageView) NSArray *ratioImg;


@end

@implementation VerticalEQBar

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


- (void)setIndex:(NSInteger)index{
    if (index < 0 || index >= self.optionButtons.count) {
        for (UIButton* obj in self.optionButtons) {
            obj.selected = false;
        }
        return;
    }
    UIButton* button = [self.optionButtons objectAtIndex:index];
    [self setButtonIndex:button];
}

- (NSInteger)index{
    for (NSInteger i = 0; i<self.optionButtons.count; i++) {
        UIButton* button = [self.optionButtons objectAtIndex:i];
        if (button.selected) {
            return i;
        }
    }
    return  -1;
}

- (void)setButtonIndex:(UIButton*)button{
    button.selected = !button.selected;
    for (UIButton* obj in self.optionButtons) {
        if (obj == button && button.selected) {
            obj.selected = true;
           
        }else{
            obj.selected = false;
            
        }
    }
}

- (IBAction)onSelectTouched:(UIButton *)sender {
    _Viewindex = [self.optionButtons indexOfObject:sender];
    [self setButtonIndex:sender];
    NSInteger index = [self.optionButtons indexOfObject:sender];
    if (!sender.selected) {
        index = -1;
    }
    [self.delegate dlgVerticalEQBarChangeIndex:index];
    sender.selected = YES;
    [sender setTitleColor:[UIColor whiteColor] forState:UIControlStateSelected];
    if (sender.selected){
        for (NSInteger i = 0; i<self.ButtonsView.count; i++) {
            UIView* view = [self.ButtonsView objectAtIndex:i];
            if (i == _Viewindex){
                [view setBackgroundColor: [UIColor colorWithRed:253.0/255.0 green:190.0/255.0 blue:1.0/255.0 alpha:1.0]];
                UIImageView * ratio = [self.ratioImg objectAtIndex:i];
                [ratio setImage: [UIImage imageNamed:@"ic-radio-inactive"]];
              //  [view setBackgroundColor: [UIColor yellowColor]];
                
            }else{
                [view setBackgroundColor: [UIColor whiteColor]];
                UIImageView * ratio = [self.ratioImg objectAtIndex:i];
                [ratio setImage: [UIImage imageNamed:@"ic-radio-active"]];
            }
           
        }
     
    }
}

@end
