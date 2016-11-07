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
