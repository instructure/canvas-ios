//
//  NSAttributedString+RegexHighlight.m
//  SpeedGrader
//
//  Created by Brandon Pluim on 11/26/14.
//  Copyright (c) 2014 Instructure. All rights reserved.
//

#import "NSAttributedString+RegexHighlight.h"

NSString *const kRegexHighlightViewTypeText = @"text";
NSString *const kRegexHighlightViewTypeBackground = @"background";
NSString *const kRegexHighlightViewTypeComment = @"comment";
NSString *const kRegexHighlightViewTypeDocumentationComment = @"documentation_comment";
NSString *const kRegexHighlightViewTypeDocumentationCommentKeyword = @"documentation_comment_keyword";
NSString *const kRegexHighlightViewTypeString = @"string";
NSString *const kRegexHighlightViewTypeCharacter = @"character";
NSString *const kRegexHighlightViewTypeNumber = @"number";
NSString *const kRegexHighlightViewTypeKeyword = @"keyword";
NSString *const kRegexHighlightViewTypePreprocessor = @"preprocessor";
NSString *const kRegexHighlightViewTypeURL = @"url";
NSString *const kRegexHighlightViewTypeAttribute = @"attribute";
NSString *const kRegexHighlightViewTypeProject = @"project";
NSString *const kRegexHighlightViewTypeOther = @"other";

@implementation NSAttributedString (RegexHighlight)

+ (NSAttributedString *)highlightText:(NSString *)text font:(UIFont *)font defaultColor:(UIColor *)defaultColor hightlightDefinition:(NSDictionary *)hightlightDefinition theme:(NSDictionary *)theme {
    if (!text.length) {
        return nil;
    }
    
    if (!font) {
        font = [NSAttributedString defaultHighlightFont];
    }
    
    if (!defaultColor) {
        defaultColor = [NSAttributedString defaultHighlightColor];
    }
    
    //Setup Defaults
    if (!hightlightDefinition) {
        hightlightDefinition = [NSAttributedString defaultHighlightDefinition];
    }
    
    if (!theme) {
        theme = [NSAttributedString defaultTheme];
    }
    
    
    NSRange fullRange = NSMakeRange(0, text.length);
    
    NSMutableAttributedString *attributedText = [[NSMutableAttributedString alloc] initWithString:text];
    [attributedText addAttribute:NSFontAttributeName value:font range:fullRange];
    [attributedText addAttribute:NSForegroundColorAttributeName value:defaultColor range:fullRange];
    
    //Create a mutable attribute string to set the highlighting
    NSString *string = attributedText.string;
    NSRange range = NSMakeRange(0,[string length]);
    
    //For each definition entry apply the highlighting to matched ranges
    for(NSString *key in hightlightDefinition) {
        NSString *expression = hightlightDefinition[key];
        if(!expression.length) {
            continue;
        }
        
        NSArray* matches = [[NSRegularExpression regularExpressionWithPattern:expression options:NSRegularExpressionDotMatchesLineSeparators error:nil] matchesInString:string options:0 range:range];
        for(NSTextCheckingResult *match in matches) {
            // Get the text color from the theme or default to the default color
            UIColor *textColor = theme[key] ? theme[key] : defaultColor;
            [attributedText addAttribute:NSForegroundColorAttributeName value:textColor range:[match rangeAtIndex:0]];
        }
    }
    
    return [attributedText copy];
}

#pragma mark - Defaults

+ (NSDictionary *)defaultHighlightDefinition {
    //It is recommended to use an ordered dictionary, because the highlighting will take place in the same order the dictionary enumerator returns the definitions
    NSMutableDictionary* definition = [NSMutableDictionary dictionary];
    [definition setObject:@"(?<!\\w)(and|or|xor|for|do|while|foreach|as|return|die|exit|if|then|else|elseif|new|delete|try|throw|catch|finally|class|function|string|array|object|resource|var|bool|boolean|int|integer|float|double|real|string|array|global|const|static|public|private|protected|published|extends|switch|true|false|null|void|this|self|struct|char|signed|unsigned|short|long|print)(?!\\w)" forKey:kRegexHighlightViewTypeKeyword];
    [definition setObject:@"((https?|mailto|ftp|file)://([-\\w\\.]+)+(:\\d+)?(/([\\w/_\\.]*(\\?\\S+)?)?)?)" forKey:kRegexHighlightViewTypeURL];
    [definition setObject:@"\\b((NS|UI|CG)\\w+?)" forKey:kRegexHighlightViewTypeProject];
    [definition setObject:@"(\\.[^\\d]\\w+)" forKey:kRegexHighlightViewTypeAttribute];
    [definition setObject:@"(?<!\\w)(((0x[0-9a-fA-F]+)|(([0-9]+\\.?[0-9]*|\\.[0-9]+)([eE][-+]?[0-9]+)?))[fFlLuU]{0,2})(?!\\w)" forKey:kRegexHighlightViewTypeNumber];
    [definition setObject:@"('.')" forKey:kRegexHighlightViewTypeCharacter];
    [definition setObject:@"(@?\"(?:[^\"\\\\]|\\\\.)*\")" forKey:kRegexHighlightViewTypeString];
    [definition setObject:@"//[^\"\\n\\r]*(?:\"[^\"\\n\\r]*\"[^\"\\n\\r]*)*[\\r\\n]" forKey:kRegexHighlightViewTypeComment];
    [definition setObject:@"(/\\*|\\*/)" forKey:kRegexHighlightViewTypeDocumentationCommentKeyword];
    [definition setObject:@"/\\*(.*?)\\*/" forKey:kRegexHighlightViewTypeDocumentationComment];
    [definition setObject:@"(#.*?)[\r\n]" forKey:kRegexHighlightViewTypePreprocessor];
    [definition setObject:@"(Kristian|Kraljic)" forKey:kRegexHighlightViewTypeOther];
    return definition;
}

+ (NSDictionary *)defaultTheme {
    return [self highlightTheme:RegexHighlightThemeDefault];
}

+ (UIFont *)defaultHighlightFont {
    return [UIFont systemFontOfSize:17.0f];
}

+ (UIColor *)defaultHighlightColor {
    return [UIColor blackColor];
}

#pragma mark - Defaults

+ (NSDictionary *)highlightDefinitionWithContentsOfFile:(NSString*)newPath {
    return [NSDictionary dictionaryWithContentsOfFile:newPath];
}

+ (NSDictionary*)highlightTheme:(RegexHighlightTheme)theme {
    //Check if the highlight theme has already been defined
    NSDictionary* themeColor = nil;
    
    //If not define the theme and return it
    switch(theme) {
        case RegexHighlightThemeBasic:
            themeColor = [NSDictionary dictionaryWithObjectsAndKeys:
                          [UIColor colorWithRed:0.0/255 green:0.0/255 blue:0.0/255 alpha:1],kRegexHighlightViewTypeText,
                          [UIColor colorWithRed:255.0/255 green:255.0/255 blue:255.0/255 alpha:1],kRegexHighlightViewTypeBackground,
                          [UIColor colorWithRed:0.0/255 green:142.0/255 blue:43.0/255 alpha:1],kRegexHighlightViewTypeComment,
                          [UIColor colorWithRed:0.0/255 green:142.0/255 blue:43.0/255 alpha:1],kRegexHighlightViewTypeDocumentationComment,
                          [UIColor colorWithRed:0.0/255 green:142.0/255 blue:43.0/255 alpha:1],kRegexHighlightViewTypeDocumentationCommentKeyword,
                          [UIColor colorWithRed:181.0/255 green:37.0/255 blue:34.0/255 alpha:1],kRegexHighlightViewTypeString,
                          [UIColor colorWithRed:0.0/255 green:0.0/255 blue:0.0/255 alpha:1],kRegexHighlightViewTypeCharacter,
                          [UIColor colorWithRed:0.0/255 green:0.0/255 blue:0.0/255 alpha:1],kRegexHighlightViewTypeNumber,
                          [UIColor colorWithRed:6.0/255 green:63.0/255 blue:244.0/255 alpha:1],kRegexHighlightViewTypeKeyword,
                          [UIColor colorWithRed:6.0/255 green:63.0/255 blue:244.0/255 alpha:1],kRegexHighlightViewTypePreprocessor,
                          [UIColor colorWithRed:6.0/255 green:63.0/255 blue:244.0/255 alpha:1],kRegexHighlightViewTypeURL,
                          [UIColor colorWithRed:0.0/255 green:0.0/255 blue:0.0/255 alpha:1],kRegexHighlightViewTypeAttribute,
                          [UIColor colorWithRed:49.0/255 green:149.0/255 blue:172.0/255 alpha:1],kRegexHighlightViewTypeProject,
                          [UIColor colorWithRed:49.0/255 green:149.0/255 blue:172.0/255 alpha:1],kRegexHighlightViewTypeOther,nil];
            break;
        case RegexHighlightThemeDefault:
            themeColor = [NSDictionary dictionaryWithObjectsAndKeys:
                          [UIColor colorWithRed:0.0/255 green:0.0/255 blue:0.0/255 alpha:1],kRegexHighlightViewTypeText,
                          [UIColor colorWithRed:255.0/255 green:255.0/255 blue:255.0/255 alpha:1],kRegexHighlightViewTypeBackground,
                          [UIColor colorWithRed:0.0/255 green:131.0/255 blue:39.0/255 alpha:1],kRegexHighlightViewTypeComment,
                          [UIColor colorWithRed:0.0/255 green:131.0/255 blue:39.0/255 alpha:1],kRegexHighlightViewTypeDocumentationComment,
                          [UIColor colorWithRed:0.0/255 green:76.0/255 blue:29.0/255 alpha:1],kRegexHighlightViewTypeDocumentationCommentKeyword,
                          [UIColor colorWithRed:211.0/255 green:45.0/255 blue:38.0/255 alpha:1],kRegexHighlightViewTypeString,
                          [UIColor colorWithRed:40.0/255 green:52.0/255 blue:206.0/255 alpha:1],kRegexHighlightViewTypeCharacter,
                          [UIColor colorWithRed:40.0/255 green:52.0/255 blue:206.0/255 alpha:1],kRegexHighlightViewTypeNumber,
                          [UIColor colorWithRed:188.0/255 green:49.0/255 blue:156.0/255 alpha:1],kRegexHighlightViewTypeKeyword,
                          [UIColor colorWithRed:120.0/255 green:72.0/255 blue:48.0/255 alpha:1],kRegexHighlightViewTypePreprocessor,
                          [UIColor colorWithRed:21.0/255 green:67.0/255 blue:244.0/255 alpha:1],kRegexHighlightViewTypeURL,
                          [UIColor colorWithRed:150.0/255 green:125.0/255 blue:65.0/255 alpha:1],kRegexHighlightViewTypeAttribute,
                          [UIColor colorWithRed:77.0/255 green:129.0/255 blue:134.0/255 alpha:1],kRegexHighlightViewTypeProject,
                          [UIColor colorWithRed:113.0/255 green:65.0/255 blue:163.0/255 alpha:1],kRegexHighlightViewTypeOther,nil];
            break;
        case RegexHighlightThemeDusk:
            themeColor = [NSDictionary dictionaryWithObjectsAndKeys:
                          [UIColor colorWithRed:255.0/255 green:255.0/255 blue:255.0/255 alpha:1],kRegexHighlightViewTypeText,
                          [UIColor colorWithRed:40.0/255 green:43.0/255 blue:52.0/255 alpha:1],kRegexHighlightViewTypeBackground,
                          [UIColor colorWithRed:72.0/255 green:190.0/255 blue:102.0/255 alpha:1],kRegexHighlightViewTypeComment,
                          [UIColor colorWithRed:72.0/255 green:190.0/255 blue:102.0/255 alpha:1],kRegexHighlightViewTypeDocumentationComment,
                          [UIColor colorWithRed:72.0/255 green:190.0/255 blue:102.0/255 alpha:1],kRegexHighlightViewTypeDocumentationCommentKeyword,
                          [UIColor colorWithRed:230.0/255 green:66.0/255 blue:75.0/255 alpha:1],kRegexHighlightViewTypeString,
                          [UIColor colorWithRed:139.0/255 green:134.0/255 blue:201.0/255 alpha:1],kRegexHighlightViewTypeCharacter,
                          [UIColor colorWithRed:139.0/255 green:134.0/255 blue:201.0/255 alpha:1],kRegexHighlightViewTypeNumber,
                          [UIColor colorWithRed:195.0/255 green:55.0/255 blue:149.0/255 alpha:1],kRegexHighlightViewTypeKeyword,
                          [UIColor colorWithRed:211.0/255 green:142.0/255 blue:99.0/255 alpha:1],kRegexHighlightViewTypePreprocessor,
                          [UIColor colorWithRed:35.0/255 green:63.0/255 blue:208.0/255 alpha:1],kRegexHighlightViewTypeURL,
                          [UIColor colorWithRed:103.0/255 green:135.0/255 blue:142.0/255 alpha:1],kRegexHighlightViewTypeAttribute,
                          [UIColor colorWithRed:146.0/255 green:199.0/255 blue:119.0/255 alpha:1],kRegexHighlightViewTypeProject,
                          [UIColor colorWithRed:0.0/255 green:175.0/255 blue:199.0/255 alpha:1],kRegexHighlightViewTypeOther,nil];
            break;
        case RegexHighlightThemeLowKey:
            themeColor = [NSDictionary dictionaryWithObjectsAndKeys:
                          [UIColor colorWithRed:0.0/255 green:0.0/255 blue:0.0/255 alpha:1],kRegexHighlightViewTypeText,
                          [UIColor colorWithRed:255.0/255 green:255.0/255 blue:255.0/255 alpha:1],kRegexHighlightViewTypeBackground,
                          [UIColor colorWithRed:84.0/255 green:99.0/255 blue:75.0/255 alpha:1],kRegexHighlightViewTypeComment,
                          [UIColor colorWithRed:84.0/255 green:99.0/255 blue:75.0/255 alpha:1],kRegexHighlightViewTypeDocumentationComment,
                          [UIColor colorWithRed:84.0/255 green:99.0/255 blue:75.0/255 alpha:1],kRegexHighlightViewTypeDocumentationCommentKeyword,
                          [UIColor colorWithRed:133.0/255 green:63.0/255 blue:98.0/255 alpha:1],kRegexHighlightViewTypeString,
                          [UIColor colorWithRed:50.0/255 green:64.0/255 blue:121.0/255 alpha:1],kRegexHighlightViewTypeCharacter,
                          [UIColor colorWithRed:50.0/255 green:64.0/255 blue:121.0/255 alpha:1],kRegexHighlightViewTypeNumber,
                          [UIColor colorWithRed:50.0/255 green:64.0/255 blue:121.0/255 alpha:1],kRegexHighlightViewTypeKeyword,
                          [UIColor colorWithRed:0.0/255 green:0.0/255 blue:0.0/255 alpha:1],kRegexHighlightViewTypePreprocessor,
                          [UIColor colorWithRed:24.0/255 green:49.0/255 blue:168.0/255 alpha:1],kRegexHighlightViewTypeURL,
                          [UIColor colorWithRed:35.0/255 green:93.0/255 blue:43.0/255 alpha:1],kRegexHighlightViewTypeAttribute,
                          [UIColor colorWithRed:87.0/255 green:127.0/255 blue:164.0/255 alpha:1],kRegexHighlightViewTypeProject,
                          [UIColor colorWithRed:87.0/255 green:127.0/255 blue:164.0/255 alpha:1],kRegexHighlightViewTypeOther,nil];
            break;
        case RegexHighlightThemeMidnight:
            themeColor = [NSDictionary dictionaryWithObjectsAndKeys:
                          [UIColor colorWithRed:255.0/255 green:255.0/255 blue:255.0/255 alpha:1],kRegexHighlightViewTypeText,
                          [UIColor colorWithRed:0.0/255 green:0.0/255 blue:0.0/255 alpha:1],kRegexHighlightViewTypeBackground,
                          [UIColor colorWithRed:69.0/255 green:208.0/255 blue:106.0/255 alpha:1],kRegexHighlightViewTypeComment,
                          [UIColor colorWithRed:69.0/255 green:208.0/255 blue:106.0/255 alpha:1],kRegexHighlightViewTypeDocumentationComment,
                          [UIColor colorWithRed:69.0/255 green:208.0/255 blue:106.0/255 alpha:1],kRegexHighlightViewTypeDocumentationCommentKeyword,
                          [UIColor colorWithRed:255.0/255 green:68.0/255 blue:77.0/255 alpha:1],kRegexHighlightViewTypeString,
                          [UIColor colorWithRed:139.0/255 green:138.0/255 blue:247.0/255 alpha:1],kRegexHighlightViewTypeCharacter,
                          [UIColor colorWithRed:139.0/255 green:138.0/255     blue:247.0/255 alpha:1],kRegexHighlightViewTypeNumber,
                          [UIColor colorWithRed:224.0/255 green:59.0/255 blue:160.0/255 alpha:1],kRegexHighlightViewTypeKeyword,
                          [UIColor colorWithRed:237.0/255 green:143.0/255 blue:100.0/255 alpha:1],kRegexHighlightViewTypePreprocessor,
                          [UIColor colorWithRed:36.0/255 green:72.0/255 blue:244.0/255 alpha:1],kRegexHighlightViewTypeURL,
                          [UIColor colorWithRed:79.0/255 green:108.0/255 blue:132.0/255 alpha:1],kRegexHighlightViewTypeAttribute,
                          [UIColor colorWithRed:0.0/255 green:249.0/255 blue:161.0/255 alpha:1],kRegexHighlightViewTypeProject,
                          [UIColor colorWithRed:0.0/255 green:179.0/255 blue:248.0/255 alpha:1],kRegexHighlightViewTypeOther,nil];
            break;
        case RegexHighlightThemePresentation:
            themeColor = [NSDictionary dictionaryWithObjectsAndKeys:
                          [UIColor colorWithRed:0.0/255 green:0.0/255 blue:0.0/255 alpha:1],kRegexHighlightViewTypeText,
                          [UIColor colorWithRed:255.0/255 green:255.0/255 blue:255.0/255 alpha:1],kRegexHighlightViewTypeBackground,
                          [UIColor colorWithRed:38.0/255 green:126.0/255 blue:61.0/255 alpha:1],kRegexHighlightViewTypeComment,
                          [UIColor colorWithRed:38.0/255 green:126.0/255 blue:61.0/255 alpha:1],kRegexHighlightViewTypeDocumentationComment,
                          [UIColor colorWithRed:38.0/255 green:126.0/255 blue:61.0/255 alpha:1],kRegexHighlightViewTypeDocumentationCommentKeyword,
                          [UIColor colorWithRed:158.0/255 green:32.0/255 blue:32.0/255 alpha:1],kRegexHighlightViewTypeString,
                          [UIColor colorWithRed:6.0/255 green:63.0/255 blue:244.0/255 alpha:1],kRegexHighlightViewTypeCharacter,
                          [UIColor colorWithRed:6.0/255 green:63.0/255 blue:244.0/255 alpha:1],kRegexHighlightViewTypeNumber,
                          [UIColor colorWithRed:140.0/255 green:34.0/255 blue:96.0/255 alpha:1],kRegexHighlightViewTypeKeyword,
                          [UIColor colorWithRed:125.0/255 green:72.0/255 blue:49.0/255 alpha:1],kRegexHighlightViewTypePreprocessor,
                          [UIColor colorWithRed:21.0/255 green:67.0/255 blue:244.0/255 alpha:1],kRegexHighlightViewTypeURL,
                          [UIColor colorWithRed:150.0/255 green:125.0/255 blue:65.0/255 alpha:1],kRegexHighlightViewTypeAttribute,
                          [UIColor colorWithRed:77.0/255 green:129.0/255 blue:134.0/255 alpha:1],kRegexHighlightViewTypeProject,
                          [UIColor colorWithRed:113.0/255 green:65.0/255 blue:163.0/255 alpha:1],kRegexHighlightViewTypeOther,nil];
            break;
        case RegexHighlightThemePrinting:
            themeColor = [NSDictionary dictionaryWithObjectsAndKeys:
                          [UIColor colorWithRed:0.0/255 green:0.0/255 blue:0.0/255 alpha:1],kRegexHighlightViewTypeText,
                          [UIColor colorWithRed:255.0/255 green:255.0/255 blue:255.0/255 alpha:1],kRegexHighlightViewTypeBackground,
                          [UIColor colorWithRed:113.0/255 green:113.0/255 blue:113.0/255 alpha:1],kRegexHighlightViewTypeComment,
                          [UIColor colorWithRed:113.0/255 green:113.0/255 blue:113.0/255 alpha:1],kRegexHighlightViewTypeDocumentationComment,
                          [UIColor colorWithRed:64.0/255 green:64.0/255 blue:64.0/255 alpha:1],kRegexHighlightViewTypeDocumentationCommentKeyword,
                          [UIColor colorWithRed:112.0/255 green:112.0/255 blue:112.0/255 alpha:1],kRegexHighlightViewTypeString,
                          [UIColor colorWithRed:71.0/255 green:71.0/255 blue:71.0/255 alpha:1],kRegexHighlightViewTypeCharacter,
                          [UIColor colorWithRed:71.0/255 green:71.0/255 blue:71.0/255 alpha:1],kRegexHighlightViewTypeNumber,
                          [UIColor colorWithRed:108.0/255 green:108.0/255 blue:108.0/255 alpha:1],kRegexHighlightViewTypeKeyword,
                          [UIColor colorWithRed:85.0/255 green:85.0/255 blue:85.0/255 alpha:1],kRegexHighlightViewTypePreprocessor,
                          [UIColor colorWithRed:84.0/255 green:84.0/255 blue:84.0/255 alpha:1],kRegexHighlightViewTypeURL,
                          [UIColor colorWithRed:129.0/255 green:129.0/255 blue:129.0/255 alpha:1],kRegexHighlightViewTypeAttribute,
                          [UIColor colorWithRed:120.0/255 green:120.0/255 blue:120.0/255 alpha:1],kRegexHighlightViewTypeProject,
                          [UIColor colorWithRed:86.0/255 green:86.0/255 blue:86.0/255 alpha:1],kRegexHighlightViewTypeOther,nil];
            break;
        case RegexHighlightThemeSunset:
            themeColor = [NSDictionary dictionaryWithObjectsAndKeys:
                          [UIColor colorWithRed:0.0/255 green:0.0/255 blue:0.0/255 alpha:1],kRegexHighlightViewTypeText,
                          [UIColor colorWithRed:255.0/255 green:252.0/255 blue:236.0/255 alpha:1],kRegexHighlightViewTypeBackground,
                          [UIColor colorWithRed:208.0/255 green:134.0/255 blue:59.0/255 alpha:1],kRegexHighlightViewTypeComment,
                          [UIColor colorWithRed:208.0/255 green:134.0/255 blue:59.0/255 alpha:1],kRegexHighlightViewTypeDocumentationComment,
                          [UIColor colorWithRed:190.0/255 green:116.0/255 blue:55.0/255 alpha:1],kRegexHighlightViewTypeDocumentationCommentKeyword,
                          [UIColor colorWithRed:234.0/255 green:32.0/255 blue:24.0/255 alpha:1],kRegexHighlightViewTypeString,
                          [UIColor colorWithRed:53.0/255 green:87.0/255 blue:134.0/255 alpha:1],kRegexHighlightViewTypeCharacter,
                          [UIColor colorWithRed:53.0/255 green:87.0/255 blue:134.0/255 alpha:1],kRegexHighlightViewTypeNumber,
                          [UIColor colorWithRed:53.0/255 green:87.0/255 blue:134.0/255 alpha:1],kRegexHighlightViewTypeKeyword,
                          [UIColor colorWithRed:119.0/255 green:121.0/255 blue:148.0/255 alpha:1],kRegexHighlightViewTypePreprocessor,
                          [UIColor colorWithRed:85.0/255 green:99.0/255 blue:179.0/255 alpha:1],kRegexHighlightViewTypeURL,
                          [UIColor colorWithRed:58.0/255 green:76.0/255 blue:166.0/255 alpha:1],kRegexHighlightViewTypeAttribute,
                          [UIColor colorWithRed:196.0/255 green:88.0/255 blue:31.0/255 alpha:1],kRegexHighlightViewTypeProject,
                          [UIColor colorWithRed:196.0/255 green:88.0/255 blue:31.0/255 alpha:1],kRegexHighlightViewTypeOther,nil];
            break;
        default:
            themeColor = [NSDictionary dictionaryWithObjectsAndKeys:
                          [UIColor colorWithRed:0.0/255 green:0.0/255 blue:0.0/255 alpha:1],kRegexHighlightViewTypeText,
                          [UIColor colorWithRed:255.0/255 green:255.0/255 blue:255.0/255 alpha:1],kRegexHighlightViewTypeBackground,
                          [UIColor colorWithRed:0.0/255 green:131.0/255 blue:39.0/255 alpha:1],kRegexHighlightViewTypeComment,
                          [UIColor colorWithRed:0.0/255 green:131.0/255 blue:39.0/255 alpha:1],kRegexHighlightViewTypeDocumentationComment,
                          [UIColor colorWithRed:0.0/255 green:76.0/255 blue:29.0/255 alpha:1],kRegexHighlightViewTypeDocumentationCommentKeyword,
                          [UIColor colorWithRed:211.0/255 green:45.0/255 blue:38.0/255 alpha:1],kRegexHighlightViewTypeString,
                          [UIColor colorWithRed:40.0/255 green:52.0/255 blue:206.0/255 alpha:1],kRegexHighlightViewTypeCharacter,
                          [UIColor colorWithRed:40.0/255 green:52.0/255 blue:206.0/255 alpha:1],kRegexHighlightViewTypeNumber,
                          [UIColor colorWithRed:188.0/255 green:49.0/255 blue:156.0/255 alpha:1],kRegexHighlightViewTypeKeyword,
                          [UIColor colorWithRed:120.0/255 green:72.0/255 blue:48.0/255 alpha:1],kRegexHighlightViewTypePreprocessor,
                          [UIColor colorWithRed:21.0/255 green:67.0/255 blue:244.0/255 alpha:1],kRegexHighlightViewTypeURL,
                          [UIColor colorWithRed:150.0/255 green:125.0/255 blue:65.0/255 alpha:1],kRegexHighlightViewTypeAttribute,
                          [UIColor colorWithRed:77.0/255 green:129.0/255 blue:134.0/255 alpha:1],kRegexHighlightViewTypeProject,
                          [UIColor colorWithRed:113.0/255 green:65.0/255 blue:163.0/255 alpha:1],kRegexHighlightViewTypeOther,nil];
            break;
    }

    return themeColor;
}

+ (NSString *)plistMappingForFileExtension:(NSString *)fileExtension {
    NSDictionary *mappingFile = [self fileExtensionToPlistNameMapping];
    return mappingFile[fileExtension];
}

+ (NSDictionary *)fileExtensionToPlistNameMapping {
    static NSDictionary *fileExtensionToPlistNameMapping = nil;
    static dispatch_once_t once;
    dispatch_once(&once, ^{
        fileExtensionToPlistNameMapping = @{
                                @"as"              : @"actionscript",
                                @"actionscript"    : @"actionscript",
                                @"a4l"             : @"active4d",
                                @"ada"             : @"ada",
                                @"ampl"            : @"ampl",
                                @"apache"          : @"apache",
                                @"scpt"            : @"applescript",
                                @"applescript"     : @"applescript",
                                @"mdmx"            : @"asm-mips",
                                @"mips-3d"         : @"asm-mips",
                                @"asm"             : @"asm-mips",
                                @"asm-x86"         : @"asm-x86",
                                @"asm-js"          : @"asm-js",
                                @"asm-vb"          : @"asm-vb",
                                @"awk"             : @"awk",
                                @"aspx.cs"         : @"aspdotnet-cs",
                                @"aspx"            : @"aspdotnet-vb",
                                @"batch"           : @"batch",
                                @"c"               : @"c",
                                @"cbl"             : @"cobol",
                                @"cob"             : @"cobol",
                                @"cpy"             : @"cobol",
                                @"cfm"             : @"coldfusion",
                                @"cfml"            : @"coldfusion",
                                @"cc"              : @"cpp",
                                @"c++"             : @"c++",
                                @"cpp"             : @"cpp",
                                @"cs"              : @"csharp",
                                @"csound"          : @"csound",
                                @"css"             : @"css",
                                @"d"               : @"d",
                                @"dylan"           : @"dylan",
                                @"e"               : @"eiffel",
                                @"epr"             : @"eiffel",
                                @"erl"             : @"erl",
                                @"ezt"             : @"eztpl",
                                @"f90"             : @"fortran",
                                @"f03"             : @"fortran",
                                @"f95"             : @"fortran",
                                @"edp"             : @"freefem",
                                @"gedcom"          : @"gedcom",
                                @"h"               : @"objectivec",
                                @"m"               : @"objectivec",
                                @"java"            : @"java",
                                @"rb"              : @"ruby",
                                @"ruby"            : @"ruby",
                                @"sql"             : @"sql",
                                @"vb"              : @"vb",
                                @"html"            : @"html",
                                @"html"            : @"htm",
                                @"xhtml"           : @"html",
                                @"js"              : @"js",
                                @"perl"            : @"perl",
                                @"php"             : @"php",
                                @"php3"            : @"php",
                                @"php4"            : @"php",
                                @"php5"            : @"php",
                                @"pas"             : @"pascal",
                                @"plist"           : @"plist",
                                @"python"          : @"python",
                                @"xml"             : @"xml",
                                };
    });
    
    return fileExtensionToPlistNameMapping;
}

+ (NSArray *)supportedSyntaxHighlightFileExtensions {
    static NSArray *supportedFileExtensions = nil;
    static dispatch_once_t once;
    dispatch_once(&once, ^{
        supportedFileExtensions = @[
                                    @"as",
                                    @"actionscript",
                                    @"a4l",
                                    @"ada",
                                    @"ampl",
                                    @"apache",
                                    @"scpt",
                                    @"applescript",
                                    @"mdmx",
                                    @"mips-3d",
                                    @"asm",
                                    @"asm-x86",
                                    @"asm-js",
                                    @"asm-vb",
                                    @"awk",
                                    @"aspx.cs",
                                    @"aspx",
                                    @"batch",
                                    @"c",
                                    @"cbl",
                                    @"cob",
                                    @"cpy",
                                    @"cfm",
                                    @"cfml",
                                    @"cc",
                                    @"c++",
                                    @"cpp",
                                    @"cs",
                                    @"csound",
                                    @"css",
                                    @"d",
                                    @"dylan",
                                    @"e",
                                    @"epr",
                                    @"erl",
                                    @"ezt",
                                    @"f90",
                                    @"f03",
                                    @"f95",
                                    @"edp",
                                    @"gedcom",
                                    @"h",
                                    @"m",
                                    @"java",
                                    @"rb",
                                    @"ruby",
                                    @"sql",
                                    @"vb",
                                    @"html",
                                    @"htmm",
                                    @"xhtml",
                                    @"js",
                                    @"perl",
                                    @"php",
                                    @"php3",
                                    @"php4",
                                    @"php5",
                                    @"pas",
                                    @"plist",
                                    @"python",
                                    @"xml",
                                    ];
    });
    
    return supportedFileExtensions;
}

@end
