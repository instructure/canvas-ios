//
//  PSPDFAnnotation.h
//  PSPDFKit
//
//  Copyright © 2011-2017 PSPDFKit GmbH. All rights reserved.
//
//  THIS SOURCE CODE AND ANY ACCOMPANYING DOCUMENTATION ARE PROTECTED BY INTERNATIONAL COPYRIGHT LAW
//  AND MAY NOT BE RESOLD OR REDISTRIBUTED. USAGE IS BOUND TO THE PSPDFKIT LICENSE AGREEMENT.
//  UNAUTHORIZED REPRODUCTION OR DISTRIBUTION IS SUBJECT TO CIVIL AND CRIMINAL PENALTIES.
//  This notice may not be removed from this file.
//

#import "PSPDFAction.h"
#import "PSPDFEnvironment.h"
#import "PSPDFJSONAdapter.h"
#import "PSPDFModel.h"
#import "PSPDFUndoProtocol.h"

NS_ASSUME_NONNULL_BEGIN

/// List of available annotation types. Set in the `editableAnnotationTypes` set of `PSPDFDocument`.
typedef NSString *PSPDFAnnotationString NS_EXTENSIBLE_STRING_ENUM;

PSPDF_EXPORT PSPDFAnnotationString const PSPDFAnnotationStringLink;
PSPDF_EXPORT PSPDFAnnotationString const PSPDFAnnotationStringHighlight;
PSPDF_EXPORT PSPDFAnnotationString const PSPDFAnnotationStringUnderline;
PSPDF_EXPORT PSPDFAnnotationString const PSPDFAnnotationStringStrikeOut;
PSPDF_EXPORT PSPDFAnnotationString const PSPDFAnnotationStringSquiggly;
PSPDF_EXPORT PSPDFAnnotationString const PSPDFAnnotationStringNote;
PSPDF_EXPORT PSPDFAnnotationString const PSPDFAnnotationStringFreeText;
PSPDF_EXPORT PSPDFAnnotationString const PSPDFAnnotationStringInk;
PSPDF_EXPORT PSPDFAnnotationString const PSPDFAnnotationStringSquare;
PSPDF_EXPORT PSPDFAnnotationString const PSPDFAnnotationStringCircle;
PSPDF_EXPORT PSPDFAnnotationString const PSPDFAnnotationStringLine;
PSPDF_EXPORT PSPDFAnnotationString const PSPDFAnnotationStringPolygon;
PSPDF_EXPORT PSPDFAnnotationString const PSPDFAnnotationStringPolyLine;
PSPDF_EXPORT PSPDFAnnotationString const PSPDFAnnotationStringSignature; /// Signature is a `PSPDFAnnotationStringInk` annotation.
PSPDF_EXPORT PSPDFAnnotationString const PSPDFAnnotationStringStamp;

/// Special type of "annotation" that will add an eraser feature to the toolbar.
PSPDF_EXPORT PSPDFAnnotationString const PSPDFAnnotationStringEraser;

/// Sound annotations can be played back and recorded by default, but playback and recording will not work when the host app is in the background. If you want to enable background playback and recording, you'll need to add the "audio" entry to the `UIBackgroundModes` array in the app's Info.plist. If you do not add this, then recording will be stopped and playback will be silenced when your app is sent into the background.
PSPDF_EXPORT PSPDFAnnotationString const PSPDFAnnotationStringSound;

/// `UIImagePickerController` used in the image add feature will throw a `UIApplicationInvalidInterfaceOrientation` exception if your app does not include portrait in `UISupportedInterfaceOrientations` (Info.plist). For landscape only apps, we suggest enabling portrait orientation(s) in your Info.plist and rejecting these in `UIViewController`’s auto-rotation methods. This way, you can be landscape only for your view controllers and still be able to use `UIImagePickerController`.
PSPDF_EXPORT PSPDFAnnotationString const PSPDFAnnotationStringImage; // Image is a `PSPDFAnnotationStringStamp` annotation.

/// Non-writable annotation types.
PSPDF_EXPORT PSPDFAnnotationString const PSPDFAnnotationStringWidget;
PSPDF_EXPORT PSPDFAnnotationString const PSPDFAnnotationStringFile;
PSPDF_EXPORT PSPDFAnnotationString const PSPDFAnnotationStringRichMedia;
PSPDF_EXPORT PSPDFAnnotationString const PSPDFAnnotationStringScreen;
PSPDF_EXPORT PSPDFAnnotationString const PSPDFAnnotationStringCaret;

/// Placeholders. Not yet supported.
PSPDF_EXPORT PSPDFAnnotationString const PSPDFAnnotationStringPopup;
PSPDF_EXPORT PSPDFAnnotationString const PSPDFAnnotationStringWatermark;
PSPDF_EXPORT PSPDFAnnotationString const PSPDFAnnotationStringTrapNet;
PSPDF_EXPORT PSPDFAnnotationString const PSPDFAnnotationString3D;
PSPDF_EXPORT PSPDFAnnotationString const PSPDFAnnotationStringRedact;

/// PDF Annotations types.
typedef NS_OPTIONS(NSUInteger, PSPDFAnnotationType) {
    PSPDFAnnotationTypeNone = 0,
    /// Any annotation whose type couldn't be recognized.
    PSPDFAnnotationTypeUndefined = 1 << 0,
    /// Links and PSPDFKit multimedia extensions.
    PSPDFAnnotationTypeLink = 1 << 1,
    PSPDFAnnotationTypeHighlight = 1 << 2,
    PSPDFAnnotationTypeStrikeOut = 1 << 17,
    PSPDFAnnotationTypeUnderline = 1 << 18,
    PSPDFAnnotationTypeSquiggly = 1 << 19,
    PSPDFAnnotationTypeFreeText = 1 << 3,
    /// Ink (includes Signatures)
    PSPDFAnnotationTypeInk = 1 << 4,
    PSPDFAnnotationTypeSquare = 1 << 5,
    PSPDFAnnotationTypeCircle = 1 << 20,
    PSPDFAnnotationTypeLine = 1 << 6,
    PSPDFAnnotationTypeNote = 1 << 7,
    /// A stamp can be an image as well.
    PSPDFAnnotationTypeStamp = 1 << 8,
    PSPDFAnnotationTypeCaret = 1 << 9,
    /// Embedded PDF video
    PSPDFAnnotationTypeRichMedia = 1 << 10,
    /// Embedded PDF video
    PSPDFAnnotationTypeScreen = 1 << 11,
    /// Widget (includes PDF Forms)
    PSPDFAnnotationTypeWidget = 1 << 12,
    /// FileAttachment
    PSPDFAnnotationTypeFile = 1 << 13,
    PSPDFAnnotationTypeSound = 1 << 14,
    PSPDFAnnotationTypePolygon = 1 << 15,
    PSPDFAnnotationTypePolyLine = 1 << 16,
    /// Popup annotations are not yet supported.
    PSPDFAnnotationTypePopup = 1 << 21,
    /// Not supported.
    PSPDFAnnotationTypeWatermark = 1 << 22,
    /// Not supported.
    PSPDFAnnotationTypeTrapNet = 1 << 23,
    /// Not supported.
    PSPDFAnnotationTypeThreeDimensional = 1 << 24,
    /// Not supported.
    PSPDFAnnotationTypeRedact = 1 << 25,
    PSPDFAnnotationTypeAll = NSUIntegerMax,
} PSPDF_ENUM_AVAILABLE;

/// Converts an annotation type into the string representation.
PSPDF_EXPORT PSPDFAnnotationString _Nullable PSPDFStringFromAnnotationType(PSPDFAnnotationType annotationType);

/// Converts the annotation type string representation to an annotation type.
PSPDF_EXPORT PSPDFAnnotationType PSPDFAnnotationTypeFromString(PSPDFAnnotationString _Nullable string);

/// Annotation border style types.
typedef NS_ENUM(NSUInteger, PSPDFAnnotationBorderStyle) {
    PSPDFAnnotationBorderStyleNone,
    PSPDFAnnotationBorderStyleSolid,
    PSPDFAnnotationBorderStyleDashed,
    PSPDFAnnotationBorderStyleBeveled,
    PSPDFAnnotationBorderStyleInset,
    PSPDFAnnotationBorderStyleUnderline,
    PSPDFAnnotationBorderStyleUnknown,
} PSPDF_ENUM_AVAILABLE;

/// Border effect names. See PDF Reference 1.5, 1.6. (Table 167).
typedef NS_ENUM(NSInteger, PSPDFAnnotationBorderEffect) {
    PSPDFAnnotationBorderEffectNoEffect = 0,
    PSPDFAnnotationBorderEffectCloudy,
} PSPDF_ENUM_AVAILABLE;

/// `NSValueTransformer` to convert between `PSPDFAnnotationBorderStyle` enum and string value.
PSPDF_EXPORT NSString *const PSPDFBorderStyleTransformerName;

/// `NSValueTransformer` to convert between `PSPDFAnnotationBorderEffect` enum and string value.
PSPDF_EXPORT NSString *const PSPDFBorderEffectTransformerName;

/**
 A set of flags specifying various characteristics of the annotation.
 PSPDFKit doesn't support all of those flag settings.
 */
typedef NS_OPTIONS(NSUInteger, PSPDFAnnotationFlags) {
    /// If set, ignore annotation AP stream if there is no handler available.
    PSPDFAnnotationFlagInvisible = 1 << 0,
    /// If set, do not display or print the annotation or allow it to interact with the user.
    PSPDFAnnotationFlagHidden = 1 << 1,
    /// If set, print the annotation when the page is printed.
    PSPDFAnnotationFlagPrint = 1 << 2,
    /// [IGNORED] If set, don't scale the annotation’s appearance to match the magnification of the page.
    PSPDFAnnotationFlagNoZoom = 1 << 3,
    /// [IGNORED] If set, don't rotate the annotation’s appearance to match the rotation of the page.
    PSPDFAnnotationFlagNoRotate = 1 << 4,
    /// If set, don't display the annotation on the screen. (But printing might be allowed)
    PSPDFAnnotationFlagNoView = 1 << 5,
    /// If set, don't allow the annotation to interact with the user. Ignored for Widget.
    PSPDFAnnotationFlagReadOnly = 1 << 6,
    /// If set, don't allow the annotation to be deleted or properties modified, including contents.
    /// This does not apply to changes to a form field's contents, however.
    PSPDFAnnotationFlagLocked = 1 << 7,
    /// [IGNORED] If set, invert the interpretation of the NoView flag for certain events.
    PSPDFAnnotationFlagToggleNoView = 1 << 8,
    /// If set, don't allow the contents of the annotation to be modified by the user.
    PSPDFAnnotationFlagLockedContents = 1 << 9
} PSPDF_ENUM_AVAILABLE;

/// Trigger events for certain viewer actions. See PDF Reference 1.7, 423ff.
typedef NS_ENUM(UInt8, PSPDFAnnotationTriggerEvent) {
    /// Cursor Enters. (Unsupported) E (0)
    PSPDFAnnotationTriggerEventCursorEnters,
    /// Cursor Exits. (Unsupported) X  (1)
    PSPDFAnnotationTriggerEventCursorExits,
    /// Triggered on `touchesBegan:` D  (2)
    PSPDFAnnotationTriggerEventMouseDown,
    /// Triggered on `touchesEnded:` U  (3)
    PSPDFAnnotationTriggerEventMouseUp,
    /// Triggers when the annotation is tapped. Fo (4)
    PSPDFAnnotationTriggerEventReceiveFocus,
    /// Triggers when the annotation is tapped. Bl (5)
    PSPDFAnnotationTriggerEventLooseFocus,
    /// Page opens. (Unsupported) PO (6)
    PSPDFAnnotationTriggerEventPageOpened,
    /// Page closes. (Unsupported) PC (7)
    PSPDFAnnotationTriggerEventPageClosed,
    /// Page becomes visible. (Unsupported) PV (8)
    PSPDFAnnotationTriggerEventPageVisible,

    /// Form extensions

    /// Form value changes. K  (9)
    PSPDFAnnotationTriggerEventFormChanged,
    /// Form is formatted. F (10)
    PSPDFAnnotationTriggerEventFieldFormat,
    /// Form is validated. V (11)
    PSPDFAnnotationTriggerEventFormValidate,
    /// Form is calculated. C (12)
    PSPDFAnnotationTriggerEventFormCalculate
} PSPDF_ENUM_AVAILABLE;

/// `NSValueTransformer` to convert between `PSPDFAnnotationTriggerEvent` enum and string value.
PSPDF_EXPORT NSString *const PSPDFAnnotationTriggerEventTransformerName;

@class PSPDFDocument, PSPDFDocumentProvider;

/**
 `PSPDFAnnotation` is the base class for all PDF annotations and forms.

 Don't directly make an instance of this class, use subclasses like `PSPDFNoteAnnotation` or `PSPDFLinkAnnotation`.
 This class will return `nil` if initialized directly, unless with the type `PSPDFAnnotationTypeUndefined`.

 `PSPDFAnnotationManager` searches the runtime for subclasses of `PSPDFAnnotation` and builds up a dictionary using `supportedTypes`.

 @note Thread safety:
 Annotation objects should only ever be edited on the main thread. Modify properties on the main thread only if they are already active
 (for creation, it doesn't matter which thread creates them). Before rendering, obtain a copy of the annotation to ensure it's not mutated while properties are read.
 Once the `documentProvider` is set, modifying properties on a background thread will throw an exception.

 Annotations contain internal state once they are attached to a document. Don't take them and add them to another document.
 Instead, create a new annotation and set the properties relevant for you, and add this annotation.

 Annotations contain internal state once they are attached to a document. Don't take them and add them to another document.
 Instead, create a new annotation and set the properties relevant for you, and add this annotation.

 @warning Annotations are mutable objects. Do not store them into NSSet or other objects that require a hash-value that does not change.
 */
PSPDF_CLASS_AVAILABLE @interface PSPDFAnnotation : PSPDFModel<PSPDFUndoProtocol, PSPDFJSONSerializing>

/**
 Converts JSON representation back into `PSPDFAnnotation` subclasses.
 Will return nil for invalid JSON or not recognized types.
 `documentProvider` is optional and if given the override dictionary will be honored (to return your custom `PSPDFAnnotation*` subclasses)
 */
+ (nullable PSPDFAnnotation *)annotationFromJSONDictionary:(NSDictionary<NSString *, id> *)JSONDictionary documentProvider:(nullable PSPDFDocumentProvider *)documentProvider error:(NSError **)error;

/// Returns YES if PSPDFKit has support to write this annotation type back into the PDF.
+ (BOOL)isWriteable;

/// Returns YES if PSPDFKit has support to delete this annotation type back into the PDF.
+ (BOOL)isDeletable;

/// Returns YES if this annotation type has a fixed size, no matter the internal bounding box.
+ (BOOL)isFixedSize;

/// The size of a fixed-size annotation. Only valid when isFixedSize is set to YES.
+ (CGSize)fixedSize;

/// Returns YES if the annotation wants a selection border. Defaults to YES.
@property (nonatomic, readonly) BOOL wantsSelectionBorder;

/// Returns YES if this annotation requires an implicit popup annotation.
@property (nonatomic, readonly) BOOL requiresPopupAnnotation;

/// Returns YES if the annotation is read only.
@property (nonatomic, getter=isReadOnly, readonly) BOOL readOnly;

/**
 Returns YES if this annotation is locked. Checks `annotationFlags` for `PSPDFAnnotationFlagLocked`.
 @note Even a locked `PSPDFAnnotation` object may have some properties modified, but this is the property that the UI layer should use to allow modifications to an annotation (selection/resizing).
 */
@property (nonatomic, getter=isLocked, readonly) BOOL locked;

/// Returns YES if this annotation's contents are locked. Checks `annotationFlags` for `PSPDFAnnotationFlagLockedContents`.
@property (nonatomic, readonly, getter=isContentsLocked) BOOL contentsLocked;

/// Returns YES if this annotation type is moveable.
@property (nonatomic, getter=isMovable, readonly) BOOL movable;

/// Returns YES if this annotation type is resizable (all but note annotations usually are).
@property (nonatomic, getter=isResizable, readonly) BOOL resizable;

/**
 Returns YES if the annotation should maintain its aspect ratio when resized.
 Defaults to NO for most annotations, except for the `PSPDFStampAnnotation`.
 */
@property (nonatomic, readonly) BOOL shouldMaintainAspectRatio;

/// Returns the minimum size that an annotation can properly display. Defaults to (32.f, 32.f).
@property (nonatomic, readonly) CGSize minimumSize;

/**
 Check if `point` is inside the annotation area, while making sure that the hit area is at least `minDiameter` wide.
 The default implementation performs hit testing based on the annotation bounding box, but concrete subclasses can (and do)
 override this behavior in order to perform custom checks (e.g., path-based hit testing).
 @note The usage of `minDiameter` is annotation specific.
 */
- (BOOL)hitTest:(CGPoint)point minDiameter:(CGFloat)minDiameter;

/// Calculates the exact annotation position in the current page.
- (CGRect)boundingBoxForPageRect:(CGRect)pageRect;

/// The annotation type.
@property (nonatomic, readonly) PSPDFAnnotationType type;

/**
 Page index for current annotation. Page is relative to `documentProvider`.
 @warning Only set the page at creation time and don't change it later on. This would break internal caching. If you want to move an annotations to a different page, copy an annotation, add it again and then delete the original.
 @note When an annotation is serialized as JSON using `PSPDFJSONAdapter` the value of this property is written with the key `page` for backwards compatibility.
 */
@property (nonatomic) NSUInteger pageIndex;

/**
 Page index relative to the document.
 @note Will be calculated each time from `pageIndex` and the current `documentProvider` and will change `pageIndex` if set.
 */
@property (nonatomic) NSUInteger absolutePageIndex;

/// Corresponding `PSPDFDocumentProvider`.
@property (nonatomic, weak) PSPDFDocumentProvider *documentProvider;

/// Document is inferred from the `documentProvider` (Convenience method)
@property (nonatomic, weak, readonly) PSPDFDocument *document;

/**
 If this annotation isn't backed by the PDF, it's dirty by default.
 After the annotation has been written to the file, this will be reset until the annotation has been changed.
 */
@property (nonatomic, getter=isDirty) BOOL dirty;

/**
 If YES, the annotation will be rendered as a overlay. If NO, it will be statically rendered within the PDF content image.
 Rendering as overlay is more performant if you frequently change it, but might delay page display a bit.
 @note `PSPDFAnnotationTypeLink` and `PSPDFAnnotationTypeNote` currently are rendered as overlay.
 If `overlay` is set to YES, you must also register the corresponding *annotationView class to render (override `PSPDFAnnotationManager`’s `defaultAnnotationViewClassForAnnotation:`)
 */
@property (nonatomic, getter=isOverlay) BOOL overlay;

/**
 Per default, annotations are editable when `isWriteable` returns YES.
 Override this to lock certain annotations. (menu won't be shown)
 */
@property (nonatomic, getter=isEditable) BOOL editable;

/**
 Indicator if annotation has been soft-deleted (Annotation may already be deleted locally, but not written back.)
 @note Doesn't check for the `isDeletable` property. Use `removeAnnotations:` on `PSPDFDocument` to delete annotations.
 */
@property (nonatomic, getter=isDeleted) BOOL deleted;

/**
 Annotation type string as defined in the PDF.
 Usually read from the annotDict. Don't change this unless you know what you're doing.
 */
@property (nonatomic, copy) PSPDFAnnotationString typeString;

/// Alpha value of the annotation color.
@property (nonatomic) CGFloat alpha;

/**
 Color associated with the annotation or `nil` if there is no color.
 This is the text color for `PSPDFFreeTextAnnotation`, `PSPDFTextFieldFormElement`, and `PSPDFChoiceFormElement`.
 @note Color will *share* the alpha value set in the .alpha property, and will ignore any custom alpha value set here. Setting `UIColor.clearColor` is equivalent to setting `nil`.
 */
@property (nonatomic, nullable) UIColor *color;

/**
 Border Color usually redirects to color, unless overridden to have a real backing ivar.
 (`PSPDFWidgetAnnotation` has such a backing store)
 */
@property (nonatomic, nullable) UIColor *borderColor;

/**
 Fill color. Only used for certain annotation types. ("IC" key, e.g. Shape Annotations)
 Fill color might be nil - treat like clearColor in that case.
 @note Fill color will *share* the alpha value set in the .alpha property, and will ignore any custom alpha value set here.Setting `UIColor.clearColor` is equivalent to setting `nil`.
 Apple Preview.app will not show you transparency in the `fillColor`.
 */
@property (nonatomic, nullable) UIColor *fillColor;

/// Various annotation types may contain text. Optional. This may be changed even if `isContentsLocked` is `YES`.
@property (nonatomic, copy, nullable) NSString *contents;

/// Subject property (corresponding to "Subj" key).
@property (nonatomic, copy, nullable) NSString *subject;

/**
 Dictionary for additional action types.
 The key is of type `PSPDFAnnotationTriggerEvent`.
 */
@property (nonatomic, copy, nullable) NSDictionary<NSNumber *, __kindof PSPDFAction *> *additionalActions;

/// (Optional; inheritable) The field’s value, whose format varies depending on the field type. See the descriptions of individual field types for further information.
@property (nonatomic, copy, nullable) id value;

/// Annotation flags. Defaults to `PSPDFAnnotationFlagPrint`.
@property (nonatomic) PSPDFAnnotationFlags flags;

/// Shortcut that checks for `PSPDFAnnotationFlagHidden` in `flags`.
@property (nonatomic, getter=isHidden) BOOL hidden;

/**
 The annotation name, a text string uniquely identifying it among all the annotations on its page.
 (Optional; PDF1.4, "NM" key)
 */
@property (nonatomic, copy, nullable) NSString *name;

/// User (title) flag. ("T" property)
@property (nonatomic, copy, nullable) NSString *user;

/**
 Annotation group key. Allows to have multiple annotations that behave as single one, if their `group` string is equal. Only works within one page.
 This is a proprietary extension and saved into the PDF as "PSPDF:GROUP" key.
 */
@property (nonatomic, copy, nullable) NSString *group;

/**
 Date when the annotation was created. Might be nil.
 PSPDFKit will set this for newly created annotations.
 @note Due to PDF standard limitations, the sub-second precision of NSDate is lost,
 if the annotation is saved and subsequently re-read from a PDF. This also impacts annotation equality checks.
 */
@property (nonatomic, nullable) NSDate *creationDate;

/**
 Date when the annotation was last modified. Might be nil.
 Saved into the PDF as the "M" property (Optional, since PDF 1.1)
 @note This property is updated anytime a different property is modified.
 Due to PDF standard limitations, the sub-second precision of NSDate is lost,
 if the annotation is saved and subsequently re-read from a PDF.
 */
@property (atomic, nullable) NSDate *lastModified;

/// Border Line Width (only used in certain annotations)
@property (nonatomic) CGFloat lineWidth;

/// Annotation border style.
@property (nonatomic) PSPDFAnnotationBorderStyle borderStyle;

/**
 (Optional; valid only if the value of `borderStyle` is `PSPDFAnnotationBorderStyleDashed`)
 Array of boxed integer-values defining the dash style.
 */
@property (nonatomic, copy, nullable) NSArray<NSNumber *> *dashArray;

/**
 Border effect. Currently supports No Effect or Cloudy.
 @note `borderEffectIntensity` should be set to non-zero (e.g. 1.0) for Cloudy border to be displayed.
 */
@property (nonatomic) PSPDFAnnotationBorderEffect borderEffect;

/**
 (Optional; valid only if the value of `borderEffect` is `PSPDFAnnotationBorderEffectCloudy`)
 A number describing the intensity of the effect. The value is suggested to be between 0 and 2 but other values are valid as well. Default value: 0.
 */
@property (nonatomic) CGFloat borderEffectIntensity;

/**
 Rectangle of specific annotation. (PDF coordinates)
 @note Other properties might be adjusted, depending what `shouldTransformOnBoundingBoxChange` returns.
 */
@property (nonatomic) CGRect boundingBox;

/**
 Rotation property (should be a multiple of 90,
 but there are exceptions, e.g. for stamp annotations)
 Defaults to 0. Allowed values are between 0 and 360.
 */
@property (nonatomic) NSUInteger rotation;

/// Certain annotation types like highlight can have multiple rects.
@property (nonatomic, copy, nullable) NSArray<NSValue *> *rects;

/**
 Line, Polyline and Polygon annotations have points.
 Contains `NSValue` objects that box a `CGPoint`.
 @note These values are generated on the fly from an internal, optimized representation.
 */
@property (nonatomic, copy, nullable) NSArray<NSValue *> *points;

/**
 If `indexOnPage` is set, it's a native PDF annotation.
 If this is -1, it's not yet saved in the PDF or saved externally.
 */
@property (nonatomic, readonly) NSInteger indexOnPage PSPDF_DEPRECATED(6.0, "This property will go away in the near future. You should not rely on an annotation having a certain index on the page it belongs to.");

/**
 The PDF object number.
 If this is -1, the object is not reference in the PDF yet.
 */
@property (nonatomic, readonly) NSInteger objectNumber;

/// Returns `self.contents` or something appropriate per annotation type to describe the object.
@property (nonatomic, readonly) NSString *localizedDescription;

/// Return icon for the annotation, if there's one defined.
@property (nonatomic, readonly, nullable) UIImage *annotationIcon;

/// Compare.
- (BOOL)isEqualToAnnotation:(PSPDFAnnotation *)otherAnnotation;

@end

@interface PSPDFAnnotation (AppearanceStream)

/**
 Returns YES if a custom appearance stream is attached to this annotation.
 @note An appearance stream is a custom representation for annotations, much like a PDF within a PDF.
 */
@property (nonatomic, readonly) BOOL hasAppearanceStream;

/**
 Extracts and returns an image from the AP stream. If an error occurs or if the annotation
 has no appearance stream, this method returns `nil` and reports the error through the `error` out
 parameter. If an image is found, the `transform` out parameter will be set.
 */
- (nullable UIImage *)extractImageFromAppearanceStreamWithTransform:(out CGAffineTransform *_Nullable)transform error:(NSError **)error;

@end

@interface PSPDFAnnotation (Drawing)

/// Options to use for `drawInContext:withOptions:`
PSPDF_EXPORT NSString *const PSPDFAnnotationDrawFlattenedKey;

/// Set to YES to not render the small note indicator for objects that contain text.
PSPDF_EXPORT NSString *const PSPDFAnnotationIgnoreNoteIndicatorIconKey;

/// Set to `@YES` to specify that the annotation is being drawn for printing.
PSPDF_EXPORT NSString *const PSPDFAnnotationDrawForPrintingKey;

/**
 Draw current annotation in context. Coordinates here are in PDF coordinate space.
 Use `PSPDFConvertViewRectToPDFRect:` to convert your coordinates accordingly.
 (For performance considerations, you want to do this once, not every time `drawInContext:` is called)
 `options is currently used to allow different annotation drawings during the annotation flattening process.
 `options can be `PSPDFAnnotationDrawAppearanceStreamKey`, `PSPDFAnnotationDrawFlattenedKey`, `PSPDFAnnotationIgnoreNoteIndicatorIconKey` and other render-related keys.
 */
- (void)drawInContext:(CGContextRef)context withOptions:(nullable NSDictionary<NSString *, id> *)options;

PSPDF_EXPORT NSString *const PSPDFAnnotationDrawCenteredKey; // CGFloat, draw in the middle of the image, if size has a different aspect ratio.
PSPDF_EXPORT NSString *const PSPDFAnnotationMarginKey; // `UIEdgeInsets`.

/// Renders annotation into an image.
- (UIImage *)imageWithSize:(CGSize)size withOptions:(nullable NSDictionary<NSString *, id> *)options;

/// Point for the note icon. Override to customize.
@property (nonatomic, readonly) CGPoint noteIconPoint;

@end

@interface PSPDFAnnotation (Advanced)

/**
 Some annotations might change their points/lines/size when the bounding box changes.
 This returns NO by default.
 */
@property (nonatomic, readonly) BOOL shouldUpdatePropertiesOnBoundsChange;
@property (nonatomic, readonly) BOOL shouldUpdateOptionalPropertiesOnBoundsChange;

- (void)updatePropertiesWithTransform:(CGAffineTransform)transform isSizeChange:(BOOL)isSizeChange meanScale:(CGFloat)meanScale;
- (void)updateOptionalPropertiesWithTransform:(CGAffineTransform)transform isSizeChange:(BOOL)isSizeChange meanScale:(CGFloat)meanScale;

/// Manually controls if with setting the `boundingBox` it should be transformed as well.
- (void)setBoundingBox:(CGRect)boundingBox transform:(BOOL)transform includeOptional:(BOOL)optionalProperties;

/// Copy annotation object to `UIPasteboard` (multiple formats).
- (void)copyToClipboard;

/// Ask if we may remove an annotation. Only called if `+isDeletable` returns YES.
@property (nonatomic, readonly) BOOL shouldDeleteAnnotation;

@end

/// Key for attributed string attribute that contains the font size - this is set if the font size is defined.
PSPDF_EXPORT NSString *const PSPDFFontSizeName;

/// Key for vertical text alignment in `fontAttributes`.
PSPDF_EXPORT NSString *const PSPDFVerticalAlignmentName;

typedef NS_ENUM(NSUInteger, PSPDFVerticalAlignment) {
    PSPDFVerticalAlignmentTop = 0,
    PSPDFVerticalAlignmentCenter = 1,
    PSPDFVerticalAlignmentBottom = 2,
} PSPDF_ENUM_AVAILABLE;

/// Constant to convert `PSPDFVerticalAlignment` into `NSString` and back.
PSPDF_EXPORT NSString *const PSPDFVerticalAlignmentTransformerName;

/**
 This defines properties for annotations with styled text.
 Valid for `PSPDFFreeTextAnnotation`, `PSPDFTextFieldFormElement`, and `PSPDFChoiceFormElement`.
 Several of the properties here are shortcuts for accessing data in the `fontAttributes` dictionary.
 */
@interface PSPDFAnnotation (Fonts)

/**
 Supports attributes for the text rendering, similar to the attributes in `NSAttributedString`.
 @note Supported keys are:
 `NSUnderlineStyleAttributeName` and `NSStrikethroughStyleAttributeName`, valid values `NSUnderlineStyleNone` and `NSUnderlineStyleSingle`.
 A font can either be underline or strikethrough, not both.
 `UIFontDescriptorTraitsAttribute` takes a boxed value of `UIFontDescriptorSymbolicTraits`, valid options are `UIFontDescriptorTraitItalic` and `UIFontDescriptorTraitBold`.
 Setting `NSForegroundColorAttributeName` will also update the `color` property.
 Several other properties on this class are shortcuts for accesesing data in this dictionary.
 Further attributes might be rendered and saved, but are not persisted in the PDF.
 */
@property (nonatomic, copy, nullable) NSDictionary<NSString *, id> *fontAttributes;

/**
 The font name, if defined.
 @note Shortcut for `[self.fontAttributes[NSFontAttributeName] familyName]`.
 */
@property (nonatomic, copy, nullable) NSString *fontName;

/**
 Font size, if defined. Setting this to 0 will use the default size or (for forms) attempt auto-sizing the text.
 @note Shortcut for `self.fontAttributes[PSPDFFontSizeName]`.
 */
@property (nonatomic) CGFloat fontSize;

/**
 Text justification. Allows `NSTextAlignmentLeft`, `NSTextAlignmentCenter` and `NSTextAlignmentRight`.
 @note This is a shortcut for the data saved in `fontAttributes` (`NSParagraphStyleAttributeName`) and will modify `fontAttributes`.
 */
@property (nonatomic) NSTextAlignment textAlignment;

/**
 Vertical text alignment. Defaults to `PSPDFVerticalAlignmentTop`.
 @note Shortcut for `self.fontAttributes[PSPDFVerticalAlignmentName]`.
 @warning This is not defined in the PDF spec. (PSPDFKit extension)
 */
@property (nonatomic) PSPDFVerticalAlignment verticalTextAlignment;

/// Return a default font size if not defined in the annotation.
- (CGFloat)defaultFontSize;

/// Return a default font name (Helvetica) if not defined in the annotation.
- (NSString *)defaultFontName;

/// Returns the currently set font (calculated from defaultFontSize)
- (UIFont *)defaultFont;

/// Attributed string, used for free text, and text and choice form elements.
@property (nonatomic, readonly, nullable) NSAttributedString *attributedString;

/**
 This helper creates the attribute string.
 There are multiple events that can lead to a re-creation of the attributed string (such as background copies).
 Override this to fine-customize the properties for rendering.
 @note Rendering uses CoreText, so certain UIKit-only attributes such as `NSBackgroundColorAttributeName` will not be rendered.
 */
- (nullable NSAttributedString *)attributedStringWithContents:(nullable NSString *)contents;

@end

PSPDF_EXPORT void PSPDFAnnotationRegisterOverrideClasses(NSKeyedUnarchiver *unarchiver, PSPDFDocument *document);

NS_ASSUME_NONNULL_END
