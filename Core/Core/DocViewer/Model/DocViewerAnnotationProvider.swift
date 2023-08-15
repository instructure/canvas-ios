//
// This file is part of Canvas.
// Copyright (C) 2018-present  Instructure, Inc.
//
// This program is free software: you can redistribute it and/or modify
// it under the terms of the GNU Affero General Public License as
// published by the Free Software Foundation, either version 3 of the
// License, or (at your option) any later version.
//
// This program is distributed in the hope that it will be useful,
// but WITHOUT ANY WARRANTY; without even the implied warranty of
// MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
// GNU Affero General Public License for more details.
//
// You should have received a copy of the GNU Affero General Public License
// along with this program.  If not, see <https://www.gnu.org/licenses/>.
//

import Foundation
import PSPDFKit

protocol DocViewerAnnotationProviderDelegate: AnyObject {
    func annotationDidExceedLimit(annotation: APIDocViewerAnnotation)
    func annotationDidFailToSave(error: Error)
    func annotationSaveStateChanges(saving: Bool)
}

class DocViewerAnnotationProvider: PDFContainerAnnotationProvider {
    public weak var docViewerDelegate: DocViewerAnnotationProviderDelegate? {
        didSet {
            uploader.docViewerDelegate = docViewerDelegate
        }
    }

    private let uploader: DocViewerAnnotationUploader
    private let fileAnnotationProvider: PDFFileAnnotationProvider
    private let isAnnotationEditingDisabled: Bool

    public init(documentProvider: PDFDocumentProvider!,
                fileAnnotationProvider: PDFFileAnnotationProvider,
                metadata: APIDocViewerMetadata,
                apiAnnotations: [APIDocViewerAnnotation],
                api: API,
                sessionID: String,
                isAnnotationEditingDisabled: Bool) {
        self.uploader = DocViewerAnnotationUploader(api: api, sessionID: sessionID)
        self.fileAnnotationProvider = fileAnnotationProvider
        self.isAnnotationEditingDisabled = isAnnotationEditingDisabled

        super.init(documentProvider: documentProvider)

        guard let annotationsMetadata = metadata.annotations, annotationsMetadata.enabled else { return }
        var hasReplies: Set<String> = []
        let allAnnotations = apiAnnotations.compactMap { (apiAnnotation: APIDocViewerAnnotation) -> Annotation? in
            if let id = apiAnnotation.inreplyto { hasReplies.insert(id) }

            let pspdfAnnotation = Annotation.from(apiAnnotation, metadata: annotationsMetadata)

            if isAnnotationEditingDisabled {
                pspdfAnnotation?.flags.update(with: .readOnly)
            }

            return pspdfAnnotation
        }
        for annotation in allAnnotations {
            annotation.hasReplies = hasReplies.contains(annotation.name ?? "")
        }
        for (pageKey, rawRotation) in metadata.rotations ?? [:] {
            if let pageIndex = PageIndex(pageKey), let rotation = Rotation(rawValue: rawRotation) {
                documentProvider.setRotationOffset(rotation, forPageAt: pageIndex)
            }
        }

        setAnnotations(allAnnotations, append: false)
    }

    public func getReplies(to: Annotation) -> [DocViewerCommentReplyAnnotation] {
        allAnnotations
            .compactMap { $0 as? DocViewerCommentReplyAnnotation }
            .filter { $0.inReplyToName == to.name }
            .sorted { a, b in
                let aCreated = a.creationDate ?? Date()
                let bCreated = b.creationDate ?? Date()
                return aCreated.compare(bCreated) == ComparisonResult.orderedAscending
            }
    }

    public func isFileAnnotation(_ annotation: Annotation) -> Bool {
        fileAnnotationProvider.allAnnotations.contains(annotation)
    }

    public override func annotationsForPage(at pageIndex: PageIndex) -> [Annotation]? {
        // First, fetch the annotations from the file annotation provider.
        let fileAnnotations = performRead {
            fileAnnotationProvider.annotationsForPage(at: pageIndex) ?? []
        }

        // Editing of annotations stored in the pdf file are always disabled
        fileAnnotations.forEach { $0.isEditable = false }

        // Then ask `super` to retrieve the API annotations from cache.
        let docViewerAnnotations = performRead {
            super.annotationsForPage(at: pageIndex) ?? []
        }

        // Merge annotations loaded from the file annotation provider with the API ones.
        return fileAnnotations + docViewerAnnotations
    }

    // MARK: - Annotation Change Callbacks From PSPDFKit

    public override func add(_ annotations: [Annotation], options: [AnnotationManager.ChangeBehaviorKey: Any]? = nil) -> [Annotation]? {
        super.add(annotations, options: options)
        var added: [Annotation] = []
        for annotation in annotations {
            guard let apiAnnotation = annotation.apiAnnotation() else { continue }
            added.append(annotation)
            if annotation.isEmpty {
                continue // don't save to network if empty comment reply or free text
            }
            uploader.save(apiAnnotation)
        }
        return added
    }

    public override func remove(_ annotations: [Annotation], options: [AnnotationManager.ChangeBehaviorKey: Any]? = nil) -> [Annotation]? {
        super.remove(annotations, options: options)
        var removed: [Annotation] = []
        for annotation in annotations {
            guard let id = annotation.name else { continue }
            removed.append(annotation)
            uploader.delete(annotationID: id)
        }
        let hasReplies = Set(allAnnotations.compactMap {
            ($0 as? DocViewerCommentReplyAnnotation)?.inReplyToName
        })
        for annotation in allAnnotations {
            annotation.hasReplies = hasReplies.contains(annotation.name ?? "")
        }
        return removed
    }

    public override func didChange(_ annotation: Annotation, keyPaths: [String], options: [String: Any]? = nil) {
        guard !annotation.isEmpty, let apiAnnotation = annotation.apiAnnotation() else { return }
        uploader.save(apiAnnotation)
    }

    // MARK: - User Triggered Events

    public func retryFailedRequest() {
        uploader.retryFailedRequest()
    }
}
