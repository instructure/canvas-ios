//
//  DBChooserResult.h
//  DBChooser
//

#import <Foundation/Foundation.h>

@interface DBChooserResult : NSObject

/** url to the file */
@property (nonatomic, readonly) NSURL *link;

/** name of the file */
@property (nonatomic, readonly) NSString *name;

/** file size in bytes */
@property (nonatomic, readonly) long long size;

/** url to the file icon */
@property (nonatomic, readonly) NSURL *iconURL;

/** available thumbnail URLs of this file. key'ed by sizes
    (e.g. 64x64, 200x200, 640x480). */
@property (nonatomic, readonly) NSDictionary *thumbnails;

@end
