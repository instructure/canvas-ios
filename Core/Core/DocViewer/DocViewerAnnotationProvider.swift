//
// Copyright (C) 2018-present Instructure, Inc.
//
// This program is free software: you can redistribute it and/or modify
// it under the terms of the GNU General Public License as published by
// the Free Software Foundation, version 3 of the License.
//
// This program is distributed in the hope that it will be useful,
// but WITHOUT ANY WARRANTY; without even the implied warranty of
// MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
// GNU General Public License for more details.
//
// You should have received a copy of the GNU General Public License
// along with this program.  If not, see <http://www.gnu.org/licenses/>.
//

import Foundation
import PSPDFKit

protocol DocViewerAnnotationProviderDelegate: class {
    func annotationDidExceedLimit(annotation: APIDocViewerAnnotation)
    func annotationDidFailToSave(error: Error)
    func annotationSaveStateChanges(saving: Bool)
}

class DocViewerAnnotationProvider: PSPDFContainerAnnotationProvider {
    let api: API
    var apiAnnotations: [String: APIDocViewerAnnotation] = [:]
    weak var docViewerDelegate: DocViewerAnnotationProviderDelegate?
    let sessionID: String

    var requestsInFlight = 0 {
        didSet {
            self.docViewerDelegate?.annotationSaveStateChanges(saving: requestsInFlight != 0)
        }
    }

    init(documentProvider: PSPDFDocumentProvider!, metadata: APIDocViewerAnnotationsMetadata, annotations: [APIDocViewerAnnotation], api: API, sessionID: String) {
        self.api = api
        self.sessionID = sessionID

        super.init(documentProvider: documentProvider)

        guard metadata.enabled else { return }
        let allAnnotations = annotations.compactMap { (apiAnnotation: APIDocViewerAnnotation) -> PSPDFAnnotation? in
            apiAnnotations[apiAnnotation.id] = apiAnnotation
            return PSPDFAnnotation.from(apiAnnotation, metadata: metadata)
        }
        setAnnotations(allAnnotations, append: false)
    }

    func getReplies (to: PSPDFAnnotation) -> [DocViewerCommentReplyAnnotation] {
        return allAnnotations
            .compactMap { $0 as? DocViewerCommentReplyAnnotation }
            .filter { $0.inReplyToName == to.name }
            .sorted { a, b in
                let aCreated = a.creationDate ?? Date()
                let bCreated = b.creationDate ?? Date()
                return aCreated.compare(bCreated) == ComparisonResult.orderedAscending
            }
    }

    override func add(_ annotations: [PSPDFAnnotation], options: [String: Any]? = nil) -> [PSPDFAnnotation]? {
        super.add(annotations, options: options)
        var added: [PSPDFAnnotation] = []
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

    override func remove(_ annotations: [PSPDFAnnotation], options: [String: Any]? = nil) -> [PSPDFAnnotation]? {
        super.remove(annotations, options: options)
        var removed: [PSPDFAnnotation] = []
        for annotation in annotations {
            guard let id = annotation.name, apiAnnotations.removeValue(forKey: id) != nil else { continue }
            removed.append(annotation)
            delete(id)
        }
        return removed
    }

    private func put(_ body: APIDocViewerAnnotation) {
        requestsInFlight += 1
        api.makeRequest(PutDocViewerAnnotationRequest(body: body, sessionID: sessionID)) { [weak self] updated, _, error in
            self?.requestsInFlight -= 1
            if let updated = updated {
                self?.apiAnnotations[updated.id] = updated
            } else if let error = error as? APIDocViewerError, error == APIDocViewerError.tooBig {
                self?.docViewerDelegate?.annotationDidExceedLimit(annotation: body)
            } else {
                self?.docViewerDelegate?.annotationDidFailToSave(error: error ?? APIDocViewerError.noData)
            }
        }
    }

    private func delete(_ id: String) {
        requestsInFlight += 1
        api.makeRequest(DeleteDocViewerAnnotationRequest(annotationID: id, sessionID: sessionID)) { [weak self] _, _, error in
            self?.requestsInFlight -= 1
            if let error = error {
                self?.docViewerDelegate?.annotationDidFailToSave(error: error)
            }
        }
    }

    override func didChange(_ annotation: PSPDFAnnotation, keyPaths: [String], options: [String: Any]? = nil) {
        syncAnnotation(annotation)
    }

    func syncAnnotation(_ annotation: PSPDFAnnotation) {
        guard let apiAnnotation = annotation.apiAnnotation() else { return }

        if let inkAnnotation = annotation as? PSPDFInkAnnotation, inkAnnotation.lines.count > 120 {
            documentProvider?.document?.undoController?.undo()
            docViewerDelegate?.annotationDidExceedLimit(annotation: apiAnnotation)
            return
        }

        apiAnnotations[apiAnnotation.id] = apiAnnotation // update internal list with changes

        if annotation.isEmpty {
            return // don't save to network if empty comment reply or free text
        }
        put(apiAnnotation)
    }

    func syncAllAnnotations() {
        if allAnnotations.count == 0 {
            requestsInFlight = 0
        }
        allAnnotations.forEach(syncAnnotation)
    }
}
