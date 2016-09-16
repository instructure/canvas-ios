//
//  UITableView+in_fix10550644.m
//  iCanvas
//
//  Created by BJ Homer on 12/9/11.
//  Copyright (c) 2011 Instructure. All rights reserved.
//

#import "UITableView+in_fix10550644.h"


@implementation UITableView (in_fix10550644)

- (id)in_dequeueReusableCellWithIdentifier:(NSString *)identifier {
    UITableViewCell *cell = [self dequeueReusableCellWithIdentifier:identifier];
    
    if (cell == nil) {
        NSDictionary *nibDictionary = [self valueForKey:@"_nibMap"];
        UINib *nib = nibDictionary[identifier];
        
        NSDictionary *externals = [self valueForKey:@"_nibExternalObjectsTables"];
        NSDictionary *externalsForIdentifier = externals[identifier];
        
        NSDictionary *options = nil;
        if (externalsForIdentifier != nil) {
            options = @{UINibExternalObjects: externalsForIdentifier};
            cell = [nib instantiateWithOwner:self options:options][0];
        }
    }
    return cell;
}

@end
