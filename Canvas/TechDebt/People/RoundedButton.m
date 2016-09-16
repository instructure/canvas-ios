//
//  RoundedButton.m
//  
//
//  Created by Nathan Perry on 7/2/15.
//
//

#import "RoundedButton.h"

@implementation RoundedButton

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

-(void)layoutSubviews{
    [super layoutSubviews];
    [self layoutIfNeeded];
    self.layer.cornerRadius = self.frame.size.width/2.0;
}

@end
