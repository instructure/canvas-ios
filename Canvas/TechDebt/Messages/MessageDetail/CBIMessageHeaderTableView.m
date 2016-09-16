//
//  CBIResizableRowTableView.m
//  iCanvas
//
//  Created by derrick on 12/2/13.
//  Copyright (c) 2013 Instructure. All rights reserved.
//

#import "CBIMessageHeaderTableView.h"

@implementation CBIMessageHeaderTableView

- (void)setUserInteractionEnabled:(BOOL)userInteractionEnabled
{
    // this prevents the tableview's subviews from resigning
    // first responder status when the tableview reloads.
    // It is necessary in order to resize the height of the
    // cell while typing without the keyboard disappearing.
    [super setUserInteractionEnabled:YES];
}

@end
