//
//  CSGSettingsSwitchView.h
//  SpeedGrader
//
//  Created by Brandon Pluim on 7/21/14.
//  Copyright (c) 2014 Instructure. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface CSGSettingsSwitchView : UIView

@property (nonatomic, weak) IBOutlet UILabel *textLabel;
@property (nonatomic, weak) IBOutlet UISwitch *settingsSwitch;
@property (nonatomic, weak) IBOutlet UIView *separator;

- (void)setUserPrefKey:(NSString*)userPrefKey andGenericKey:(NSString*) genericKey;

@end
