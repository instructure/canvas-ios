//
//  CSGSettingsSwitchView.m
//  SpeedGrader
//
//  Created by Brandon Pluim on 7/21/14.
//  Copyright (c) 2014 Instructure. All rights reserved.
//

#import "CSGSettingsSwitchView.h"

@interface CSGSettingsSwitchView ()
@property (nonatomic, strong) NSString *genericKey;
@property (nonatomic, strong) NSString *userPrefKey;
@end

@implementation CSGSettingsSwitchView

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
}

- (void)awakeFromNib
{
    [super awakeFromNib];
    
    self.backgroundColor = [UIColor clearColor];
    self.textLabel.textColor = [UIColor csg_settingsDarkGreyTextColor];
    self.textLabel.font = [UIFont systemFontOfSize:14.0f];
    
    self.separator.backgroundColor = [UIColor csg_settingsContainerBorderColor];
    
    [self.settingsSwitch addTarget:self action:@selector(toggleSwitch:) forControlEvents:UIControlEventValueChanged];
    
    UITapGestureRecognizer *viewTapped = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(toggleSwitch:)];
    [self addGestureRecognizer:viewTapped];
}

- (void)setUserPrefKey:(NSString*)userPrefKey andGenericKey:(NSString*) genericKey {
    self.genericKey = genericKey;
    self.userPrefKey = userPrefKey;
}

- (void)setUserPrefKey:(NSString *)userPrefKey
{
    if (_userPrefKey == userPrefKey) {
        return;
    }
    
    _userPrefKey = userPrefKey;
    NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
    NSArray *prefsKeys = [[prefs dictionaryRepresentation] allKeys];
    if ([prefsKeys containsObject:_userPrefKey]) {
        self.settingsSwitch.on = [prefs boolForKey:_userPrefKey];
    } else if([prefsKeys containsObject:_genericKey]) {
        [[NSUserDefaults standardUserDefaults] setBool:[prefs boolForKey:self.genericKey] forKey:_userPrefKey];
        self.settingsSwitch.on = [prefs boolForKey:self.genericKey];
    }

}

- (IBAction)toggleSwitch:(id)sender
{
    BOOL currentValue = [[NSUserDefaults standardUserDefaults] boolForKey:self.userPrefKey];
    [[NSUserDefaults standardUserDefaults] setBool:!currentValue forKey:self.userPrefKey];
    
    if (sender != self.settingsSwitch) {
        [self.settingsSwitch setOn:!currentValue animated:YES];
    }
}


@end
