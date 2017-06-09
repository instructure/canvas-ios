//
//  PSPDFDataProvider.h
//  PSPDFFoundation
//
//  Copyright © 2015-2017 PSPDFKit GmbH. All rights reserved.
//
//  THIS SOURCE CODE AND ANY ACCOMPANYING DOCUMENTATION ARE PROTECTED BY INTERNATIONAL COPYRIGHT LAW
//  AND MAY NOT BE RESOLD OR REDISTRIBUTED. USAGE IS BOUND TO THE PSPDFKIT LICENSE AGREEMENT.
//  UNAUTHORIZED REPRODUCTION OR DISTRIBUTION IS SUBJECT TO CIVIL AND CRIMINAL PENALTIES.
//  This notice may not be removed from this file.
//

#import "PSPDFDataSink.h"
#import "PSPDFEnvironment.h"

NS_ASSUME_NONNULL_BEGIN

/**
 Specifies which types of operations the `PSPDFDataProvider` supports.
 Every `PSPDFDataProvider` must support reading.
 */
typedef NS_OPTIONS(NSUInteger, PSPDFDataProviderAdditionalOperations) {
    /// No additional operations are supported.
    PSPDFDataProviderAdditionalOperationNone = 0x00,

    /// Specifies that this `PSPDFDataProvider` does support writing.
    PSPDFDataProviderAdditionalOperationWrite = 0x01
};

/**
 This protocol is to be used by all possible data providers for PDF access.
 E.g. a `PSPDFDataProvider` or `PSPDFAESCryptoDataProvider`.

 @note This replaces the `CGDataProvider` support in earlier versions of the SDK.
 */
PSPDF_AVAILABLE_DECL @protocol PSPDFDataProvider<NSObject, NSSecureCoding>

/**
 Creates a `NSData` object with all the data of the provider. Use with caution - this can take a while if the data provider is
 a remote source and it can quickly exhaust all your memory if it is a big data provider.
 */
@property (nonatomic, readonly, nullable) NSData *data;

/// Returns the size of the data.
@property (nonatomic, readonly) uint64_t size;

/// Returns a UID that enables you to uniquely identify this data provider, even after re-starting the application.
@property (nonatomic, readonly) NSString *UID;

/// Specifies which additional operations are supported, if any.
@property (nonatomic, readonly) PSPDFDataProviderAdditionalOperations additionalOperationsSupported;

/// Reads and returns data read from offset with size. You have to make sure not to read past the end of your data.
- (nullable NSData *)readDataWithSize:(uint64_t)size atOffset:(uint64_t)offset;

@optional

/**
 An optional progress object that indicates that the data backing the data provider is still being generated.
 Be sure to transition into the fully completed progress state only after the data is completely ready for reading.
 */
@property (nonatomic, readonly, nullable) NSProgress *progress;

/// The `fileURL` if the data porvider is backed by a file.
@property (nonatomic, readonly) NSURL *fileURL;

/**
 This method should create a data sink for your data provider with the given options.
 PSPDFKit will write all the appropriate data into it and pass it to `replaceWithDataSink:` when appropriate.
 */
- (nullable id<PSPDFDataSink>)createDataSinkWithOptions:(PSPDFDataSinkOptions)options error:(NSError **)error;

/**
 This method should replace your current data with the one written into `replacementDataSink`.
 `replacementDataSink` is the object instantiated in `createDataSinkWithOptions:`.
 Depending on the `PSPDFDataSinkOptions` used above, you either have to append or replace the data.
 */
- (BOOL)replaceWithDataSink:(id<PSPDFDataSink>)replacementDataSink;

/**
 This method should delete any data that is referenced by this `PSPDFDataProvider`.
 PSPDFKit uses this method to delete temporary data, if necessary.
 Returns YES on successful deletion, NO otherwise.
 */
- (BOOL)deleteDataWithError:(NSError **)error;

/**
 Should reset any cached data and restore the data provider to its original state.
 For file based data providers, this should recreate the file handle in case the underlaying file was replaced.
 */
- (void)clearCache;

@end

NS_ASSUME_NONNULL_END
