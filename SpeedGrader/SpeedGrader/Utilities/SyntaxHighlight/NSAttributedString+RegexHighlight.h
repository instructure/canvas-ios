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
