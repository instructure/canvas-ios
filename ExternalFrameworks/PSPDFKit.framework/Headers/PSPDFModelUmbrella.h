//
//  PSPDFModelUmbrella.h
//  PSPDFModel
//
//  Copyright © 2015-2017 PSPDFKit GmbH. All rights reserved.
//
//  THIS SOURCE CODE AND ANY ACCOMPANYING DOCUMENTATION ARE PROTECTED BY INTERNATIONAL COPYRIGHT LAW
//  AND MAY NOT BE RESOLD OR REDISTRIBUTED. USAGE IS BOUND TO THE PSPDFKIT LICENSE AGREEMENT.
//  UNAUTHORIZED REPRODUCTION OR DISTRIBUTION IS SUBJECT TO CIVIL AND CRIMINAL PENALTIES.
//  This notice may not be removed from this file.
//

// @category: Common
#import "PSPDFBaseConfiguration.h"
#import "PSPDFDocument+DataDetection.h"
#import "PSPDFDocument.h"
#import "PSPDFDocumentDelegate.h"
#import "PSPDFDocumentProvider.h"
#import "PSPDFDocumentProviderDelegate.h"
#import "PSPDFEnvironment.h"
#import "PSPDFError.h"
#import "PSPDFFileManager.h"
#import "PSPDFFilePresenterCoordinator.h"
#import "PSPDFFoundationExport.h"
#import "PSPDFKitObject.h"
#import "PSPDFLocalization.h"
#import "PSPDFLogging.h"
#import "PSPDFMacros.h"
#import "PSPDFModel+NSCoding.h"
#import "PSPDFModel.h"
#import "PSPDFNamespace.h"
#import "PSPDFOverridable.h"
#import "PSPDFPageBinding.h"
#import "PSPDFPageInfo.h"
#import "PSPDFRenderManager.h"
#import "PSPDFRenderQueue.h"
#import "PSPDFRenderRequest.h"
#import "PSPDFRenderTask.h"
#import "PSPDFVersion.h"

// @category Networking
#import "PSPDFDownloadManager.h"
#import "PSPDFDownloadManagerPolicy.h"
#import "PSPDFReachability.h"
#import "PSPDFRemoteContentObject.h"
#import "PSPDFRemoteFileObject.h"

// @category Processor
#import "PSPDFProcessor.h"
#import "PSPDFProcessorConfiguration.h"
#import "PSPDFProcessorItem.h"
#import "PSPDFProcessorItemBuilder.h"
#import "PSPDFProcessorSaveOptions.h"

// @category: Data Provider
#import "PSPDFCoordinatedFileDataProvider.h"
#import "PSPDFDataContainerProvider.h"
#import "PSPDFDataContainerSink.h"
#import "PSPDFDataProvider.h"
#import "PSPDFDataSink.h"
#import "PSPDFFile.h"
#import "PSPDFFileDataProvider.h"
#import "PSPDFFileDataSink.h"
#import "PSPDFileCoordinationDelegate.h"

// @category: Annotations
#import "PSPDFAbstractLineAnnotation.h"
#import "PSPDFAbstractShapeAnnotation.h"
#import "PSPDFAbstractTextOverlayAnnotation.h"
#import "PSPDFAnnotation.h"
#import "PSPDFAnnotationManager.h"
#import "PSPDFAnnotationProvider.h"
#import "PSPDFAnnotationSet.h"
#import "PSPDFAnnotationStyle.h"
#import "PSPDFAnnotationStyleManager.h"
#import "PSPDFAnnotationSummarizer.h"
#import "PSPDFAssetAnnotation.h"
#import "PSPDFCaretAnnotation.h"
#import "PSPDFCircleAnnotation.h"
#import "PSPDFContainerAnnotationProvider.h"
#import "PSPDFDrawingPoint.h"
#import "PSPDFFileAnnotation.h"
#import "PSPDFFileAnnotationProvider.h"
#import "PSPDFFreeTextAnnotation.h"
#import "PSPDFHighlightAnnotation.h"
#import "PSPDFInkAnnotation.h"
#import "PSPDFLineAnnotation.h"
#import "PSPDFLinkAnnotation.h"
#import "PSPDFNoteAnnotation.h"
#import "PSPDFPolyLineAnnotation.h"
#import "PSPDFPolygonAnnotation.h"
#import "PSPDFPopupAnnotation.h"
#import "PSPDFRichMediaAnnotation.h"
#import "PSPDFScreenAnnotation.h"
#import "PSPDFSoundAnnotation.h"
#import "PSPDFSoundAnnotationController.h"
#import "PSPDFSquareAnnotation.h"
#import "PSPDFSquigglyAnnotation.h"
#import "PSPDFStampAnnotation.h"
#import "PSPDFStrikeOutAnnotation.h"
#import "PSPDFUnderlineAnnotation.h"
#import "PSPDFWidgetAnnotation.h"

// @category: Forms
#import "PSPDFButtonFormElement.h"
#import "PSPDFButtonFormField.h"
#import "PSPDFChoiceFormElement.h"
#import "PSPDFChoiceFormField.h"
#import "PSPDFFormElement.h"
#import "PSPDFFormField.h"
#import "PSPDFFormOption.h"
#import "PSPDFFormParser.h"
#import "PSPDFSignatureFormElement.h"
#import "PSPDFTextFieldFormElement.h"
#import "PSPDFTextFormField.h"

// @category: Actions
#import "PSPDFAbstractFormAction.h"
#import "PSPDFAction.h"
#import "PSPDFBackForwardActionList.h"
#import "PSPDFEmbeddedGoToAction.h"
#import "PSPDFGoToAction.h"
#import "PSPDFHideAction.h"
#import "PSPDFJavaScriptAction.h"
#import "PSPDFNamedAction.h"
#import "PSPDFRemoteGoToAction.h"
#import "PSPDFRenditionAction.h"
#import "PSPDFResetFormAction.h"
#import "PSPDFRichMediaExecuteAction.h"
#import "PSPDFSubmitFormAction.h"
#import "PSPDFURLAction.h"

// @category: Digital Signatures
#import "PSPDFDigitalSignatureReference.h"
#import "PSPDFPKCS12.h"
#import "PSPDFPKCS12Signer.h"
#import "PSPDFPrivateKey.h"
#import "PSPDFRSAKey.h"
#import "PSPDFSignatureInfo.h"
#import "PSPDFSignatureManager.h"
#import "PSPDFSignaturePropBuild.h"
#import "PSPDFSignaturePropBuildEntry.h"
#import "PSPDFSignatureStatus.h"
#import "PSPDFSignatureValidator.h"
#import "PSPDFSigner.h"
#import "PSPDFX509.h"

// @category: Search
#import "PSPDFGlyph.h"
#import "PSPDFImageInfo.h"
#import "PSPDFSearchResult.h"
#import "PSPDFTextBlock.h"
#import "PSPDFTextParser.h"
#import "PSPDFTextSearch.h"
#import "PSPDFWord.h"

// @category: Full-Text Search
#import "PSPDFDatabaseEncryptionProvider.h"
#import "PSPDFDocument+Library.h"
#import "PSPDFFileIndexItemDescriptor.h"
#import "PSPDFLibrary.h"
#import "PSPDFLibraryFileSystemDataSource.h"
#import "PSPDFLibraryPreviewResult.h"

// @category: Outline
#import "PSPDFOutlineElement.h"
#import "PSPDFOutlineParser.h"

// @category: Bookmarks
#import "PSPDFBookmark.h"
#import "PSPDFBookmarkManager.h"
#import "PSPDFBookmarkProvider.h"

// @category: Metadata
#import "PSPDFDocumentPDFMetadata.h"
#import "PSPDFDocumentXMPMetadata.h"

// @category: Embedded Files
#import "PSPDFEmbeddedFile.h"

// @category: Labels
#import "PSPDFLabelParser.h"

// @category: Cache
#import "PSPDFCache.h"
#import "PSPDFDiskCache.h"
#import "PSPDFMemoryCache.h"

// @category: Plugin
#import "PSPDFApplicationPolicy.h"

// @category: XFDF
#import "PSPDFXFDFAnnotationProvider.h"
#import "PSPDFXFDFParser.h"
#import "PSPDFXFDFWriter.h"

// @category JavaScript
#import "PSPDFApplicationJSExport.h"

// @category: View Model
#import "PSPDFAnnotationGroup.h"
#import "PSPDFAnnotationGroupItem.h"
#import "PSPDFAnnotationToolbarConfiguration.h"
#import "PSPDFColorPreset.h"

// @category: Encryption
#import "PSPDFAESCryptoDataProvider.h"
#import "PSPDFAESCryptoInputStream.h"
#import "PSPDFAESCryptoOutputStream.h"
#import "PSPDFCryptoInputStream.h"
#import "PSPDFCryptoOutputStream.h"
#import "PSPDFCryptor.h"

// @category: Undo/Redo
#import "PSPDFUndoController.h"
#import "PSPDFUndoProtocol.h"

// @category: JSON
#import "PSPDFJSONAdapter.h"

// @category: Editing
#import "PSPDFDocumentEditorConfiguration.h"
#import "PSPDFNewPageConfiguration.h"
#import "PSPDFNewPageConfigurationBuilder.h"
#import "PSPDFRectAlignment.h"
