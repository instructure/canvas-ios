//
//  CKIBrand.h
//  CanvasKit
//
//  Created by Garrett Richards on 3/9/17.
//  Copyright © 2017 Instructure. All rights reserved.
//

#import <CanvasKit/CanvasKit.h>

@interface CKIBrand : CKIModel

@property(nonatomic, copy) NSString *primaryColor;
@property(nonatomic, copy) NSString *fontColorDark;
@property(nonatomic, copy) NSString *fontColorLight;
@property(nonatomic, copy) NSString *linkColor;
@property(nonatomic, copy) NSString *primaryButtonBackgroundColor;
@property(nonatomic, copy) NSString *primaryButtonTextColor;
@property(nonatomic, copy) NSString *secondaryButtonBackgroundColor;
@property(nonatomic, copy) NSString *secondaryButtonTextColor;
@property(nonatomic, copy) NSString *navigationBackground;
@property(nonatomic, copy) NSString *headerImageURL;

@end


