#import <UIKit/UIKit.h>

//! Project version number for SoAutomated.
FOUNDATION_EXPORT double SoAutomatedVersionNumber;

//! Project version string for SoAutomated.
FOUNDATION_EXPORT const unsigned char SoAutomatedVersionString[];

// In this header, you should import all the public headers of your framework using statements like #import <SoAutomated/PublicHeader.h>

// Private XCTest methods
#import <XCTest/XCTest.h>

@interface XCUIElement (SoAutomated)
@property (readonly) BOOL hasKeyboardFocus;
@end

// Facebook doesn't have headers for XCTWebDriverAgentLib.
@interface FBElementCommands: NSObject
+ (BOOL)typeText:(NSString *)text error:(NSError **)error;
@end
