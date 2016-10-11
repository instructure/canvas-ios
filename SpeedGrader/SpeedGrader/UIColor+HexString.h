//
//  UIColor+HexString.h
//  Class to convert hex string to UIColor
//  Support #RGB # ARGB #RRGGBB #AARRGGBB
//  Usage: [UIColor colorWithHexString:@"#f5e6a1"];
//  Created by Zhu Yuzhou on 1/20/13.
//

#import <UIKit/UIKit.h>

@interface UIColor (HexString)

+ (UIColor *) colorWithHexString: (NSString *) hexString;

@end