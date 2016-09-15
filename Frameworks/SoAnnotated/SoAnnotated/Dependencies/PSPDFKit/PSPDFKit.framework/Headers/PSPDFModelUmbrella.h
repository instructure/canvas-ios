//
//  PSPDFModelUmbrella.h
//  PSPDFModel
//
//  Copyright (c) 2015-2016 PSPDFKit GmbH. All rights reserved.
//
//  THIS SOURCE CODE AND ANY ACCOMPANYING DOCUMENTATION ARE PROTECTED BY INTERNATIONAL COPYRIGHT LAW
//  AND MAY NOT BE RESOLD OR REDISTRIBUTED. USAGE IS BOUND TO THE PSPDFKIT LICENSE AGREEMENT.
//  UNAUTHORIZED REPRODUCTION OR DISTRIBUTION IS SUBJECT TO CIVIL AND CRIMINAL PENALTIES.
//  This notice may not be removed from this file.
//

// @category: Common
#import "PSPDFEnvironment.h"
#import "PSPDFMacros.h"
#import "PSPDFVersion.h"
#import "PSPDFOverridable.h"
#import "PSPDFKitObject.h"
#import "PSPDFLogging.h"
#import "PSPDFLocalization.h"
#import "PSPDFError.h"
#import "PSPDFDocument.h"
#import "PSPDFDocument+DataDetection.h"
#import "PSPDFDocumentDelegate.h"
#import "PSPDFDocumentProvider.h"
#import "PSPDFDocumentProviderDelegate.h"
#import "PSPDFRenderManager.h"
#import "PSPDFPageInfo.h"
#import "PSPDFRenderQueue.h"
#import "PSPDFRenderJob.h"
#import "PSPDFModel.h"
#import "PSPDFModel+NSCoding.h"
#import "PSPDFFileManager.h"

// @category Networking
#import "PSPDFReachability.h"
#import "PSPDFDownloadManager.h"
#import "PSPDFDownloadManagerPolicy.h"
#import "PSPDFRemoteContentObject.h"
#import "PSPDFRemoteFileObject.h"

// @category Processor
#import "PSPDFProcessor.h"
#import "PSPDFProcessorConfiguration.h"
#import "PSPDFProcessorItem.h"
#import "PSPDFProcessorItemBuilder.h"
#import "PSPDFProcessorSaveOptions.h"

// @category: Data Provider
#import "PSPDFDataProvider.h"
#import "PSPDFDataContainerProvider.h"
#import "PSPDFDataSink.h"
#import "PSPDFFile.h"
#import "PSPDFDataContainerSink.h"
#import "PSPDFFileDataProvider.h"
#import "PSPDFFileDataSink.h"

// @category: Annotations
#import "PSPDFAnnotationManager.h"
#import "PSPDFAnnotation.h"
#import "PSPDFAnnotationSet.h"
#import "PSPDFAnnotationProvider.h"
#import "PSPDFContainerAnnotationProvider.h"
#import "PSPDFFileAnnotationProvider.h"
#import "PSPDFHighlightAnnotation.h"
#import "PSPDFUnderlineAnnotation.h"
#import "PSPDFStrikeOutAnnotation.h"
#import "PSPDFSquigglyAnnotation.h"
#import "PSPDFFreeTextAnnotation.h"
#import "PSPDFNoteAnnotation.h"
#import "PSPDFInkAnnotation.h"
#import "PSPDFLineAnnotation.h"
#import "PSPDFLinkAnnotation.h"
#import "PSPDFSquareAnnotation.h"
#import "PSPDFCircleAnnotation.h"
#import "PSPDFStampAnnotation.h"
#import "PSPDFCaretAnnotation.h"
#import "PSPDFPopupAnnotation.h"
#import "PSPDFWidgetAnnotation.h"
#import "PSPDFScreenAnnotation.h"
#import "PSPDFRichMediaAnnotation.h"
#import "PSPDFFileAnnotation.h"
#import "PSPDFSoundAnnotation.h"
#import "PSPDFPolygonAnnotation.h"
#import "PSPDFPolyLineAnnotation.h"
#import "PSPDFAppearanceCharacteristics.h"
#import "PSPDFIconFit.h"
#import "PSPDFAnnotationSummarizer.h"
#import "PSPDFAnnotationStyleManager.h"
#import "PSPDFAnnotationStyle.h"
#import "PSPDFSoundAnnotationController.h"
#import "PSPDFAbstractShapeAnnotation.h"
#import "PSPDFDrawingPoint.h"
#import "PSPDFAbstractLineAnnotation.h"
#import "PSPDFAbstractTextOverlayAnnotation.h"
#import "PSPDFAssetAnnotation.h"

// @category: Forms
#import "PSPDFFormParser.h"
#import "PSPDFFormElement.h"
#import "PSPDFButtonFormElement.h"
#import "PSPDFChoiceFormElement.h"
#import "PSPDFSignatureFormElement.h"
#import "PSPDFTextFieldFormElement.h"

// @category: Actions
#import "PSPDFAction.h"
#import "PSPDFGoToAction.h"
#import "PSPDFRemoteGoToAction.h"
#import "PSPDFEmbeddedGoToAction.h"
#import "PSPDFURLAction.h"
#import "PSPDFNamedAction.h"
#import "PSPDFJavaScriptAction.h"
#import "PSPDFRenditionAction.h"
#import "PSPDFRichMediaExecuteAction.h"
#import "PSPDFAbstractFormAction.h"
#import "PSPDFSubmitFormAction.h"
#import "PSPDFResetFormAction.h"
#import "PSPDFHideAction.h"
#import "PSPDFBackForwardActionList.h"

// @category: Digital Signatures
#import "PSPDFPKCS12.h"
#import "PSPDFPKCS12Signer.h"
#import "PSPDFRSAKey.h"
#import "PSPDFSignatureDigest.h"
#import "PSPDFSignatureManager.h"
#import "PSPDFSigner.h"
#import "PSPDFX509.h"
#import "PSPDFSignatureStatus.h"
#import "PSPDFDigitalSignatureReference.h"
#import "PSPDFSignatureValidator.h"

// @category: Search
#import "PSPDFSearchResult.h"
#import "PSPDFTextSearch.h"
#import "PSPDFTextParser.h"
#import "PSPDFGlyph.h"
#import "PSPDFWord.h"
#import "PSPDFTextBlock.h"
#import "PSPDFImageInfo.h"

// @category: Full-text Search
#import "PSPDFDatabaseEncryptionProvider.h"
#import "PSPDFLibrary.h"
#import "PSPDFDocument+Library.h"

// @category: Outline
#import "PSPDFOutlineParser.h"
#import "PSPDFOutlineElement.h"

// @category: Bookmarks
#import "PSPDFBookmark.h"
#import "PSPDFBookmarkParser.h"

// @category: Embedded files
#import "PSPDFEmbeddedFile.h"
#import "PSPDFEmbeddedFilesParser.h"

// @category: Labels
#import "PSPDFLabelParser.h"

// @category: Cache
#import "PSPDFCache.h"
#import "PSPDFMemoryCache.h"
#import "PSPDFDiskCache.h"

// @category: Plugin
#import "PSPDFPlugin.h"
#import "PSPDFApplicationPolicy.h"

// @category: XFDF
#import "PSPDFXFDFParser.h"
#import "PSPDFXFDFWriter.h"
#import "PSPDFXFDFAnnotationProvider.h"

// @category JavaScript
#import "PSPDFApplicationJSExport.h"

// @category: View Model
#import "PSPDFAnnotationGroup.h"
#import "PSPDFAnnotationGroupItem.h"
#import "PSPDFAnnotationToolbarConfiguration.h"
#import "PSPDFColorPreset.h"

// @category: Encryption
#import "PSPDFCryptor.h"
#import "PSPDFCryptoInputStream.h"
#import "PSPDFCryptoOutputStream.h"
#import "PSPDFAESCryptoDataProvider.h"
#import "PSPDFAESCryptoInputStream.h"
#import "PSPDFAESCryptoOutputStream.h"

// @category: Undo/Redo
#import "PSPDFUndoController.h"
#import "PSPDFUndoProtocol.h"

// @category: JSON
#import "PSPDFJSONAdapter.h"

// @category: Editing
#import "PSPDFNewPageConfiguration.h"
#import "PSPDFNewPageConfigurationBuilder.h"
#import "PSPDFRectAlignment.h"
#import "PSPDFDocumentEditorConfiguration.h"
