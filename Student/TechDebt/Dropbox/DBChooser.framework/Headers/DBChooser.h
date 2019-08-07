//
//  DBChooser.h
//  DBChooser
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import "DBChooserResult.h"

/** Block type used for handling results from the Chooser. The results may be nil if the user cancelled
    out of the Chooser. Otherwise, this will return an NSArray of DBChooserResults.
 */
typedef void (^DBChooserCompletionBlock)(NSArray *results);

/** Enum type of the possible link types the app can request for */
typedef enum {
	DBChooserLinkTypePreview, // returns a preview link
    DBChooserLinkTypeDirect,  // returns a link for downloading the file directly
} DBChooserLinkType;

/** The DBChooser object is responsible for opening the Chooser interface on the Dropbox app and
    handling the results returned from the app.
 */

@interface DBChooser : NSObject

/** @name Creating a DBChooser */

/** Returns a DBChooser object with your app's app key. Remember to add a URL scheme db-APP_KEY:// to the app's
    Info.plist file. You can register your app or find your key at the [apps](https://www.dropbox.com/developers/apps)
    page.
    NOTE that this class parses your app key from the app's Info.plist's list of URL schemes. If you have multiple
    app keys prefixed by "db-", you should initialize your own instance of DBChooser with `initWithAppKey:`.
 */
+ (DBChooser*)defaultChooser;

/** Initializes an instance of DBChooser with the given app key. Make sure to use the same DBChooser instance to invoke
    `openChooserForLinkType:` and `handleOpenURL:`.
 */
- (id)initWithAppKey:(NSString*)appKey;

/** @name Invoking the chooser */

/** This method opens the Chooser interface.
    @param linkType the linkType specifies the type of link to be returned from the Chooser.
    @param topViewController the topmost view controller in your controller hierarchy.
    @param completion this is the handler that will be invoked when we returned from the Chooser.
 */
- (void)openChooserForLinkType:(DBChooserLinkType)linkType
            fromViewController:(UIViewController *)topViewController
                    completion:(DBChooserCompletionBlock)blk;

/** You must call this method in your app delegate's `-application:openURL:sourceApplication:annotation:`
    method in order to handle responses from the Dropbox app.
    @return YES if the URL is returned from the Dropbox app due to the Chooser flow.
 */
- (BOOL)handleOpenURL:(NSURL *)url;

@end
