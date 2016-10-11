//
// CSGKeymasterDelegate.m
// Created by Jason Larsen on 4/28/14.
//

#import "CSGKeymasterDelegate.h"

@interface CSGKeymasterDelegate ()

@end

@implementation CSGKeymasterDelegate

@synthesize logFilePath;

- (NSString *)appNameForMobileVerify
{
    return @"SpeedGrader";
}

- (UIView *)backgroundViewForDomainPicker
{
    UIImage *backgroundImage = [UIImage imageNamed:@"domain_picker_bg"];
    UIImageView *backgroundImageView = [[UIImageView alloc] initWithImage:backgroundImage];
    return backgroundImageView;
}

- (UIImage *)logoForDomainPicker
{
    return [UIImage imageNamed:@"logo"];
}


@end