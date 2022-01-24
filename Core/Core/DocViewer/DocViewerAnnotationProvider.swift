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
    public weak var docViewerDelegate: DocViewerAnnotationProviderDelegate?

    var apiAnnotations: [String: APIDocViewerAnnotation] = [:]
    var requestsInFlight = 0 {
        didSet {
            // If we have a failed upload don't communicate success even if subsequent upload succeed.
            guard uploadDidFail == false else { return }
            docViewerDelegate?.annotationSaveStateChanges(saving: requestsInFlight != 0)
        }
    }

    private let api: API
    private let sessionID: String
    private let fileAnnotationProvider: PDFFileAnnotationProvider
    private var uploadDidFail = false
    private let isAnnotationEditingDisabled: Bool

    public init(documentProvider: PDFDocumentProvider!,
                fileAnnotationProvider: PDFFileAnnotationProvider,
                metadata: APIDocViewerMetadata,
                annotations: [APIDocViewerAnnotation],
                api: API,
                sessionID: String,
                isAnnotationEditingDisabled: Bool) {
        self.api = api
        self.sessionID = sessionID
        self.fileAnnotationProvider = fileAnnotationProvider
        self.isAnnotationEditingDisabled = isAnnotationEditingDisabled

        super.init(documentProvider: documentProvider)

        guard let annotationsMetadata = metadata.annotations, annotationsMetadata.enabled else { return }
        var hasReplies: Set<String> = []
        let allAnnotations = annotations.compactMap { (apiAnnotation: APIDocViewerAnnotation) -> Annotation? in
            apiAnnotations[apiAnnotation.id] = apiAnnotation
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

    public func getReplies (to: Annotation) -> [DocViewerCommentReplyAnnotation] {
        return allAnnotations
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
        let fileAnnotations = fileAnnotationProvider.annotationsForPage(at: pageIndex) ?? []
        // Editing of annotations stored in the pdf file are always disabled
        fileAnnotations.forEach {
            $0.flags.update(with: .readOnly)
        }
        // Then ask `super` to retrieve the custom annotations from cache.
        let docViewerAnnotations = super.annotationsForPage(at: pageIndex) ?? []
        // Merge annotations loaded from the file annotation provider with our custom ones.
        return fileAnnotations + docViewerAnnotations
    }

    // MARK: - Annotation Change Callbacks From PSPDFKit

    public override func add(_ annotations: [Annotation], options: [AnnotationManager.ChangeBehaviorKey: Any]? = nil) -> [Annotation]? {
        super.add(annotations, options: options)
        var added: [Annotation] = []
        for annotation in annotations {
            guard let apiAnnotation = annotation.apiAnnotation() else { continue }
            added.append(annotation)
            apiAnnotations[apiAnnotation.id] = apiAnnotation
            if annotation.isEmpty {
                continue // don't save to network if empty comment reply or free text
            }
            put(apiAnnotation)
        }
        return added
    }

    public override func remove(_ annotations: [Annotation], options: [AnnotationManager.ChangeBehaviorKey: Any]? = nil) -> [Annotation]? {
        super.remove(annotations, options: options)
        var removed: [Annotation] = []
        for annotation in annotations {
            guard let id = annotation.name, apiAnnotations.removeValue(forKey: id) != nil else { continue }
            removed.append(annotation)
            delete(id)
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
        syncAnnotation(annotation)
    }

    // MARK: - API Sync

    private func put(_ body: APIDocViewerAnnotation) {
        requestsInFlight += 1
        api.makeRequest(PutDocViewerAnnotationRequest(body: body, sessionID: sessionID)) { [weak self] updated, _, error in performUIUpdate {
            self?.requestsInFlight -= 1
            if let updated = updated {
                self?.apiAnnotations[updated.id] = updated
            } else if let error = error as? APIDocViewerError, error == APIDocViewerError.tooBig {
                self?.docViewerDelegate?.annotationDidExceedLimit(annotation: body)
            } else {
                self?.uploadDidFail = true
                self?.docViewerDelegate?.annotationDidFailToSave(error: error ?? APIDocViewerError.noData)
            }
        } }
    }

    private func delete(_ id: String) {
        requestsInFlight += 1
        api.makeRequest(DeleteDocViewerAnnotationRequest(annotationID: id, sessionID: sessionID)) { [weak self] _, _, error in performUIUpdate {
            self?.requestsInFlight -= 1
            if let error = error {
                self?.docViewerDelegate?.annotationDidFailToSave(error: error)
            }
        } }
    }

    // MARK: - User Triggered Events

    public func syncAllAnnotations() {
        uploadDidFail = false

        if allAnnotations.count == 0 {
            requestsInFlight = 0
        }
        allAnnotations.forEach(syncAnnotation)
    }

    // MARK: - Private Methods

    private func syncAnnotation(_ annotation: Annotation) {
        guard let apiAnnotation = annotation.apiAnnotation() else { return }

        if let inkAnnotation = annotation as? InkAnnotation, (inkAnnotation.lines?.count ??  0) > 120 {
            documentProvider?.document?.undoController.undoManager.undo()
            docViewerDelegate?.annotationDidExceedLimit(annotation: apiAnnotation)
            return
        }

        apiAnnotations[apiAnnotation.id] = apiAnnotation // update internal list with changes

        if annotation.isEmpty {
            return // don't save to network if empty comment reply or free text
        }
        put(apiAnnotation)
    }
}
