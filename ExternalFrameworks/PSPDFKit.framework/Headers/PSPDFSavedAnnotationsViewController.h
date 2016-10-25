//
//  PSPDFSavedAnnotationsViewController.h
//  PSPDFKit
//
//  Copyright (c) 2013-2016 PSPDFKit GmbH. All rights reserved.
//
//  THIS SOURCE CODE AND ANY ACCOMPANYING DOCUMENTATION ARE PROTECTED BY INTERNATIONAL COPYRIGHT LAW
//  AND MAY NOT BE RESOLD OR REDISTRIBUTED. USAGE IS BOUND TO THE PSPDFKIT LICENSE AGREEMENT.
//  UNAUTHORIZED REPRODUCTION OR DISTRIBUTION IS SUBJECT TO CIVIL AND CRIMINAL PENALTIES.
//  This notice may not be removed from this file.
//

#import "PSPDFAnnotationGridViewController.h"
#import "PSPDFAnnotationSet.h"
#import "PSPDFStyleable.h"

NS_ASSUME_NONNULL_BEGIN

/// Protocol for the annotation store implementation.
PSPDF_AVAILABLE_DECL @protocol PSPDFAnnotationSetStore <NSObject>

/// The annotation set to read/write.
@property (nonatomic, copy) NSArray<PSPDFAnnotationSet *> *annotationSets;

@end

/// A default store that saves annotations into the keychain.
PSPDF_CLASS_AVAILABLE @interface PSPDFKeychainAnnotationSetsStore : NSObject <PSPDFAnnotationSetStore> @end


/// Shows an editable grid of saved annotation sets.
PSPDF_CLASS_AVAILABLE @interface PSPDFSavedAnnotationsViewController : PSPDFAnnotationGridViewController <PSPDFAnnotationGridViewControllerDataSource, PSPDFStyleable>

/// The default `PSPDFKeychainAnnotationSetsStore`, used if no custom store is set.
+ (id <PSPDFAnnotationSetStore>)sharedAnnotationStore;

/// The store object that gets called when annotations are changed. Set to use the controller.
@property (nonatomic) id<PSPDFAnnotationSetStore> annotationStore;

@end

@interface PSPDFSavedAnnotationsViewController (SubclassingHooks)

/// Updates the toolbar.
- (void)updateToolbarAnimated:(BOOL)animated;

@end

NS_ASSUME_NONNULL_END
