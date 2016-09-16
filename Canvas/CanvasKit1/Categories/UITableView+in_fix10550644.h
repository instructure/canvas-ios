//
//  UITableView+in_fix10550644.h
//  iCanvas
//
//  Created by BJ Homer on 12/9/11.
//  Copyright (c) 2011 Instructure. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UITableView (in_fix10550644)

- (id)in_dequeueReusableCellWithIdentifier:(NSString *)identifier;

@end
