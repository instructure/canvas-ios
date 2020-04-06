//
// This file is part of Canvas.
// Copyright (C) 2016-present  Instructure, Inc.
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

protocol CanvadocsAnnotationProviderDelegate: class {
    func annotationDidExceedLimit(annotation: CanvadocsAnnotation)
    func annotationDidFailToSave(error: NSError)
    func annotationSaveStateChanges(saving: Bool)
}

class CanvadocsAnnotationProvider: PDFContainerAnnotationProvider {
    
    @objc let service: CanvadocsAnnotationService

    private var canvadocsAnnotations: [CanvadocsAnnotation] = []

    weak var canvasDelegate: CanvadocsAnnotationProviderDelegate?
    
    @objc var requestsInFlight = 0 {
        didSet {
            let saving = requestsInFlight != 0
            self.canvasDelegate?.annotationSaveStateChanges(saving: saving)
        }
    }
    
    init(documentProvider: PDFDocumentProvider!, annotations: [CanvadocsAnnotation], service: CanvadocsAnnotationService) {
        self.service = service
        self.canvadocsAnnotations = annotations

        super.init(documentProvider: documentProvider)

        guard let metadata = service.metadata?.annotationMetadata, metadata.enabled else { return }

        if let doc = documentProvider.document {
            var allAnnotations: [Annotation] = []
            for canvadocsAnnotation in annotations {
                if let annotation = canvadocsAnnotation.pspdfAnnotation(for: doc) {
                    (annotation as? FreeTextAnnotation)?.sizeToFit()
                    annotation.flags.remove(.readOnly) // Always allow user to view and add comments
                    annotation.isEditable = annotation.user == metadata.userID &&
                        (metadata.permissions == .ReadWriteManage || metadata.permissions == .ReadWrite)
                    allAnnotations.append(annotation)
                }
            }
            setAnnotations(allAnnotations, append: false)
        }
    }
    
    @objc func getReplies (to: Annotation) -> [CanvadocsCommentReplyAnnotation] {
        var replies: [CanvadocsCommentReplyAnnotation] = []
        for annotation in allAnnotations {
            if let reply = annotation as? CanvadocsCommentReplyAnnotation, reply.inReplyToName == to.name {
                replies.append(reply)
            }
        }
        return replies.sorted {
            a, b in
            let aCreated = a.creationDate ?? Date()
            let bCreated = b.creationDate ?? Date()
            return aCreated.compare(bCreated) == ComparisonResult.orderedAscending
        }
    }
    
    @objc func incrementRequestsInFlight() {
        requestsInFlight += 1
    }
    
    @objc func decrementRequestsInFlight() {
        requestsInFlight -= 1
    }

    override func add(_ annotations: [Annotation], options: [AnnotationManager.ChangeBehaviorKey : Any]? = nil) -> [Annotation]? {
        super.add(annotations, options: options)
        guard let doc = self.documentProvider?.document else { return nil }
        
        var added: [Annotation] = []
        for annotation in annotations {
            if let canvadocsAnnotation = CanvadocsAnnotation(pspdfAnnotation: annotation, onDocument: doc) {
                added.append(annotation)
                self.canvadocsAnnotations.append(canvadocsAnnotation)
                if canvadocsAnnotation.isEmpty {
                    continue // don't save to network if empty comment reply or free text
                }
                self.incrementRequestsInFlight()
                self.service.upsertAnnotation(canvadocsAnnotation) { [weak self] result in
                    self?.decrementRequestsInFlight()
                    switch result {
                    case .success(let updated):
                        if let index = self?.canvadocsAnnotations.firstIndex(where: { $0.id == updated.id }) {
                            self?.canvadocsAnnotations[index] = updated
                        }
                    case .failure(let error):
                        self?.canvasDelegate?.annotationDidFailToSave(error: error as NSError)
                    }
                }
            }
        }
        return added
    }
    
    override func remove(_ annotations: [Annotation], options: [AnnotationManager.ChangeBehaviorKey : Any]? = nil) -> [Annotation]? {
        super.remove(annotations, options: options)
        
        var removed: [Annotation] = []
        for annotation in annotations {
            if let annotationID = annotation.name {
                print("Deleting annotation \(annotationID)")
                
                for index in stride(from: (self.canvadocsAnnotations.count - 1), through: 0, by: -1) {
                    let canvadocsAnnotation = self.canvadocsAnnotations[index]
                    if canvadocsAnnotation.id == annotationID {
                        removed.append(annotation)
                        self.canvadocsAnnotations.remove(at: index)
                        self.incrementRequestsInFlight()
                        self.service.deleteAnnotation(canvadocsAnnotation) { [weak self] result in
                            self?.decrementRequestsInFlight()
                            if let e = result.error {
                                self?.canvasDelegate?.annotationDidFailToSave(error: e)
                            }
                        }
                    }
                }
            }
        }
        return removed
    }
    
    override func didChange(_ annotation: Annotation, keyPaths: [String], options: [String : Any]? = nil) {
        syncAnnotation(annotation)
    }
    
    @objc func syncAnnotation(_ annotation: Annotation) {
        guard
            let doc = documentProvider?.document,
            let pspdfAnnotationID = annotation.name,
            let index = canvadocsAnnotations.firstIndex(where: { $0.id == pspdfAnnotationID }),
            let canvadocsAnnotation = CanvadocsAnnotation(pspdfAnnotation: annotation, onDocument: doc)
            else { return }
        
        if let inkAnnotation = annotation as? InkAnnotation, (inkAnnotation.lines?.count ?? 0) > 120 {
            doc.undoController?.undo()
            canvasDelegate?.annotationDidExceedLimit(annotation: canvadocsAnnotation)
            return
        }
        
        canvadocsAnnotations[index] = canvadocsAnnotation // update internal list with changes
        
        if canvadocsAnnotation.isEmpty {
            return // don't save to network if empty comment reply or free text
        }
        self.incrementRequestsInFlight()
        service.upsertAnnotation(canvadocsAnnotation) { [weak self] result in
            self?.decrementRequestsInFlight()
            switch result {
            case .success(let annotation):
                if let id = annotation.id {
                    if let index = self?.canvadocsAnnotations.firstIndex(where: { $0.id == id }) {
                        self?.canvadocsAnnotations[index] = canvadocsAnnotation
                    }
                }
            case .failure(let error):
                switch error {
                case .tooBig:
                    self?.canvasDelegate?.annotationDidExceedLimit(annotation: canvadocsAnnotation)
                case .nsError(let e):
                    self?.canvasDelegate?.annotationDidFailToSave(error: e)
                }
            }
        }
    }
    
    @objc func syncAllAnnotations() {
        if self.allAnnotations.count == 0 {
            self.requestsInFlight = 0
        }
        self.allAnnotations.forEach { syncAnnotation($0) }
    }
}

// Needed for setRotationOffset(_:forPageAt:)
extension CanvadocsAnnotationProvider {
    override func prepareForRefresh() {
    }

    override func refreshAnnotationsForPages(at pageIndexes: IndexSet) {
    }
}
