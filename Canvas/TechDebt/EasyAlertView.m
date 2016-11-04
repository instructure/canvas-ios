
//
// Copyright (C) 2016-present Instructure, Inc.
//   
// This program is free software: you can redistribute it and/or modify
// it under the terms of the GNU General Public License as published by
// the Free Software Foundation, version 3 of the License.
//
// This program is distributed in the hope that it will be useful,
// but WITHOUT ANY WARRANTY; without even the implied warranty of
// MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
// GNU General Public License for more details.
//
// You should have received a copy of the GNU General Public License
// along with this program.  If not, see <http://www.gnu.org/licenses/>.
//
    
    

#import "EasyAlertView.h"
@import Masonry;
#import "ModalPresenter.h"

// global constants
static CGFloat horizontalMarginsForTitleAndMessage = 10;
static CGFloat verticalMarginsBeforeTitleAndBelowMessage = 15;

// title constants
static inline UIFont* titleFont(){return [UIFont boldSystemFontOfSize:18];}

// message contants
static inline UIFont* messageFont(){return [UIFont systemFontOfSize:16];}

// button constants
static inline UIColor* buttonBorderColor(){return [UIColor lightGrayColor];}
static inline UIFont* buttonFont(){return [UIFont systemFontOfSize:16];}
static inline UIColor* buttonColor(){return [UIColor colorWithRed:30/255.0 green:130/255.0 blue:197/255.0 alpha:1.0];}
static CGFloat buttonHeight = 40;


@interface EasyAlertView () <ModalPresentable>

@property (nonatomic, retain) NSArray *buttonBlocks;
@property (nonatomic, retain) NSArray *buttons;

@end

@implementation EasyAlertView

+(void (^)())doNothingBlock{
    return ^void(){};
}

+(EasyAlertView*)presentAlertFromView:(UIView *)presentingView withTitle:(NSString *)title message:(NSString *)message buttonTitles:(NSArray *)titles buttonBlocks:(NSArray *)blocks{
    /////////////////
    // ERROR CHECKING
    if (titles.count != blocks.count) {
        NSLog(@"must have the same number of titles and blocks!");
        return nil;
    }
    
    /////////
    // CREATE
    EasyAlertView *easyAlertView = [EasyAlertView new];
    easyAlertView.view.backgroundColor = [UIColor whiteColor];
    easyAlertView.view.layer.cornerRadius = 10;
    [easyAlertView.view mas_makeConstraints:^(MASConstraintMaker *make) {
        make.width.equalTo(@300);
    }];
    
    //////////////
    // TITLE LABEL
    UILabel *titleLabel = [UILabel new];
    titleLabel.text = title;
    titleLabel.font = titleFont();
    titleLabel.textAlignment = NSTextAlignmentCenter;
    titleLabel.numberOfLines = 0;
    [easyAlertView.view addSubview:titleLabel];
    [titleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(easyAlertView.view.mas_top).with.offset(verticalMarginsBeforeTitleAndBelowMessage);
        make.left.equalTo(easyAlertView.view.mas_left).with.offset(horizontalMarginsForTitleAndMessage);
        make.right.equalTo(easyAlertView.view.mas_right).with.offset(-1*horizontalMarginsForTitleAndMessage);
    }];
    
    ////////////////
    // MESSAGE LABEL
    UILabel *messageLabel;
    if(message.length){
        // MESSAGE LABEL
        messageLabel = [UILabel new];
        messageLabel.text = message;
        messageLabel.font = messageFont();
        messageLabel.textAlignment = NSTextAlignmentCenter;
        messageLabel.numberOfLines = 0;
        [easyAlertView.view addSubview:messageLabel];
        [messageLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(titleLabel.mas_bottom).with.offset(10);
            make.left.equalTo(easyAlertView.view.mas_left).with.offset(horizontalMarginsForTitleAndMessage);
            make.right.equalTo(easyAlertView.view.mas_right).with.offset(-1*horizontalMarginsForTitleAndMessage);
        }];
    }
    
    //////////
    // BUTTONS
    easyAlertView.buttons = @[];
    for (NSInteger i = 0 ; i < titles.count; ++i){
        NSString *title = titles[i];
        UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
        button.tag = i; 
        [button setTitle:title forState:UIControlStateNormal];
        [button setTitleColor:buttonColor() forState:UIControlStateNormal];
        button.titleLabel.font = buttonFont();
        [button addTarget:easyAlertView action:@selector(buttonPressed:) forControlEvents:UIControlEventTouchUpInside];
        
        UIView *topBorder = [UIView new];
        topBorder.backgroundColor = buttonBorderColor();
        [button addSubview:topBorder];
        [topBorder mas_makeConstraints:^(MASConstraintMaker *make) {
            make.height.equalTo(@1);
            make.top.right.and.left.equalTo(button);
        }];
        
        // Figure out what we want to pin this button to
        [easyAlertView.view addSubview:button];
        UIView *pinTopTo;
        CGFloat topMargin;
        if (i == 0){
            pinTopTo = (messageLabel) ? : titleLabel;
            topMargin = verticalMarginsBeforeTitleAndBelowMessage;
        }else{
            pinTopTo = [easyAlertView.buttons lastObject];
            topMargin = 0;
        }
        UIView *pinBottomTo = (i == titles.count-1) ? easyAlertView.view : nil;

        [button mas_makeConstraints:^(MASConstraintMaker *make) {
            make.height.equalTo(@(buttonHeight));
            make.left.and.right.equalTo(easyAlertView.view);
            make.top.equalTo(pinTopTo.mas_bottom).with.offset(topMargin);
            if(pinBottomTo)
                make.bottom.equalTo(pinBottomTo.mas_bottom);
        }];
        
        easyAlertView.buttons = [easyAlertView.buttons arrayByAddingObject:button];
    }
    
    /////////
    // BLOCKS
    easyAlertView.buttonBlocks = blocks;
    
    //////////
    // PRESENT
    [ModalPresenter presentController:easyAlertView fromView:presentingView withCompletion:nil];
    
    return easyAlertView;
}

-(void)buttonPressed:(UIButton*) button{
    [ModalPresenter dismissController];
    void (^buttonBlock)() = self.buttonBlocks[button.tag];
    if (buttonBlock) buttonBlock();
}

@end
