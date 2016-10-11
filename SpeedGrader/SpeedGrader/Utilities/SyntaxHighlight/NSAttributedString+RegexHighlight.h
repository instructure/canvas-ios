//
//  NSAttributedString+RegexHighlight.h
//  SpeedGrader
//
//  Created by Brandon Pluim on 11/26/14.
//  Copyright (c) 2014 Instructure. All rights reserved.
//

#import <Foundation/Foundation.h>

FOUNDATION_EXPORT NSString *const kRegexHighlightViewTypeText;
FOUNDATION_EXPORT NSString *const kRegexHighlightViewTypeBackground;
FOUNDATION_EXPORT NSString *const kRegexHighlightViewTypeComment;
FOUNDATION_EXPORT NSString *const kRegexHighlightViewTypeDocumentationComment;
FOUNDATION_EXPORT NSString *const kRegexHighlightViewTypeString;
FOUNDATION_EXPORT NSString *const kRegexHighlightViewTypeCharacter;
FOUNDATION_EXPORT NSString *const kRegexHighlightViewTypeNumber;
FOUNDATION_EXPORT NSString *const kRegexHighlightViewTypeKeyword;
FOUNDATION_EXPORT NSString *const kRegexHighlightViewTypePreprocessor;
FOUNDATION_EXPORT NSString *const kRegexHighlightViewTypeURL;
FOUNDATION_EXPORT NSString *const kRegexHighlightViewTypeAttribute;
FOUNDATION_EXPORT NSString *const kRegexHighlightViewTypeProject;
FOUNDATION_EXPORT NSString *const kRegexHighlightViewTypeOther;

typedef enum {
    RegexHighlightThemeBasic,
    RegexHighlightThemeDefault,
    RegexHighlightThemeDusk,
    RegexHighlightThemeLowKey,
    RegexHighlightThemeMidnight,
    RegexHighlightThemePresentation,
    RegexHighlightThemePrinting,
    RegexHighlightThemeSunset
} RegexHighlightTheme;

@interface NSAttributedString (RegexHighlight)

+ (NSDictionary *)highlightDefinitionWithContentsOfFile:(NSString*)newPath;
+ (NSDictionary*)highlightTheme:(RegexHighlightTheme)theme;
+ (NSAttributedString *)highlightText:(NSString *)text font:(UIFont *)font defaultColor:(UIColor *)defaultColor hightlightDefinition:(NSDictionary *)hightlightDefinition theme:(NSDictionary *)theme;

+ (NSString *)plistMappingForFileExtension:(NSString *)fileExtension;
+ (NSDictionary *)fileExtensionToPlistNameMapping;
+ (NSArray *)supportedSyntaxHighlightFileExtensions;

@end
