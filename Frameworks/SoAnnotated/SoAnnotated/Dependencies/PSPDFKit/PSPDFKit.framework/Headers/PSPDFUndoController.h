//
//  PSPDFUndoController.h
//  PSPDFKit
//
//  Copyright (c) 2011-2016 PSPDFKit GmbH. All rights reserved.
//
//  THIS SOURCE CODE AND ANY ACCOMPANYING DOCUMENTATION ARE PROTECTED BY INTERNATIONAL COPYRIGHT LAW
//  AND MAY NOT BE RESOLD OR REDISTRIBUTED. USAGE IS BOUND TO THE PSPDFKIT LICENSE AGREEMENT.
//  UNAUTHORIZED REPRODUCTION OR DISTRIBUTION IS SUBJECT TO CIVIL AND CRIMINAL PENALTIES.
//  This notice may not be removed from this file.
//

#import <Foundation/Foundation.h>
#import "PSPDFUndoProtocol.h"
#import "PSPDFMacros.h"

NS_ASSUME_NONNULL_BEGIN

/// Sent once we have new undo operations available.
/// @note Always sent on the main thread.
PSPDF_EXPORT NSString *const PSPDFUndoControllerAddedUndoActionNotification;

/// Sent once we have available undo actions have been changed/removed.
/// @note Always sent on the main thread.
PSPDF_EXPORT NSString *const PSPDFUndoControllerRemovedUndoActionNotification;

/// This is a custom undo manager that can coalesce similar changes within the same group.
/// This class is thread safe.
/// @note Only use a perform/lock block if you're not in any other lock controlled by PSPDFKit.
PSPDF_CLASS_AVAILABLE_SUBCLASSING_RESTRICTED @interface PSPDFUndoController : NSObject

PSPDF_EMPTY_INIT_UNAVAILABLE

/// Returns YES if the undo controller is currently either undoing or redoing.
@property (nonatomic, getter=isWorking, readonly) BOOL working;

/// Returns YES if the undo controller is currently undoing.
@property (nonatomic, getter=isUndoing, readonly) BOOL undoing;

/// Returns YES if the undo controller is currently redoing.
@property (nonatomic, getter=isRedoing, readonly) BOOL redoing;

/// Returns YES if undoable operations have been recorded.
/// @note This is a calculated property and does not support KVO.
/// Listen to NSUndoManagerDid* and PSPDFUndoController* notification events instead.
@property (nonatomic, readonly) BOOL canUndo;

/// Returns YES if recordable operations have been recorded.
/// @note This is a calculated property and does not support KVO.
/// Listen to NSUndoManagerDid* and PSPDFUndoController* notification events instead.
@property (nonatomic, readonly) BOOL canRedo;

/// Performs an undo operation.
- (void)undo;

/// Performs a redo operation.
- (void)redo;

/// Helper that will infer a good name for `changedProperty` of `object`.
- (void)endUndoGroupingWithProperty:(NSString *)changedProperty ofObject:(nullable id)object;

/// Removes all recorded actions.
- (void)removeAllActions;

/// Removes all recorded actions with the provided target.
/// Implement `performUndoAction:` from `PSPDFUndoProtocol` to add support for conditional
/// removal of `PSPDFUndoProtocol` tracked (observed) changes.
- (void)removeAllActionsWithTarget:(id)target;

/// Register/unregister objects.
- (void)registerObjectForUndo:(NSObject <PSPDFUndoProtocol> *)object;
- (void)unregisterObjectForUndo:(NSObject <PSPDFUndoProtocol> *)object;
- (BOOL)isObjectRegisteredForUndo:(NSObject <PSPDFUndoProtocol> *)object;

/// Support for regular invocation based undo.
/// Perform the call you would normally invoke after [undoManager prepareWithInvocationTarget:target]
/// on the proxy passed into the block.
- (void)prepareWithInvocationTarget:(id)target block:(void (^)(id proxy))block;

/// Undo can be disabled globally, set this before any objects are registered on the controller.
@property (nonatomic, getter=isUndoEnabled, readonly) BOOL undoEnabled;

/// Provides access to the underlying `NSUndoManager`. You are strongly encouraged to not use this
/// property since it is not thread safe and `PSPDFUndoController` manages the state of this undo manager.
/// However, since `UIResponders` can provide an undo manager, this property is exposed.
@property (nonatomic, readonly) NSUndoManager *undoManager;

/// Specifies the time interval that is used for `PSPDFUndoCoalescingTimed`. Defaults to 0.5 seconds.
@property (nonatomic) NSTimeInterval timedCoalescingInterval;

/// Specifies the levels of undo we allow. Defaults to 40. More means higher memory usage.
@property (nonatomic) NSUInteger levelsOfUndo;

/// Required for conditional undo removal support using `removeAllActionsWithTarget:`.
/// @see PSPDFUndoProtocol
- (void)performUndoAction:(PSPDFUndoAction *)action;

@end

@interface PSPDFUndoController (TimeCoalescingSupport)

/// Commits all incomplete undo actions. This method is automatically called before undoing or redoing,
/// so there's usually no need to call this method directly.
- (void)commitIncompleteUndoActions;

/// Indicates that there are still incomplete undo actions because of a coalescing policy.
@property (nonatomic, readonly) BOOL hasIncompleteUndoActions;

/// Returns the name of the most recent incomplete action or nil.
@property (nonatomic, readonly) NSString *incompleteUndoActionName;

@end

/// Performs a block and groups all observed changes into one event, if the undo controller is available.
PSPDF_EXPORT void PSPDFPerformBlockAsGroup(PSPDFUndoController *_Nullable undoController, PSPDF_NOESCAPE dispatch_block_t block, NSString *_Nullable name);

/// Performs a block and ignores all observed changes, if the undo controller is available.
PSPDF_EXPORT void PSPDFPerformBlockWithoutUndo(PSPDFUndoController *_Nullable undoController, PSPDF_NOESCAPE dispatch_block_t block);

NS_ASSUME_NONNULL_END
