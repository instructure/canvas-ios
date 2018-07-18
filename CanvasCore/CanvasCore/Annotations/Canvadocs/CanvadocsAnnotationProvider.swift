//
// Copyright (C) 2016-present Instructure, Inc.
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

protocol CanvadocsAnnotationProviderDelegate: class {
    func annotationDidExceedLimit(annotation: CanvadocsAnnotation)
}

class CanvadocsAnnotationProvider: PSPDFContainerAnnotationProvider {
    
    let service: CanvadocsAnnotationService

    private var canvadocsAnnotations: [CanvadocsAnnotation] = []

    weak var limitDelegate: CanvadocsAnnotationProviderDelegate?
    
    init(documentProvider: PSPDFDocumentProvider!, annotations: [CanvadocsAnnotation], service: CanvadocsAnnotationService) {
        self.service = service
        self.canvadocsAnnotations = annotations

        super.init(documentProvider: documentProvider)

        guard let metadata = service.metadata?.annotationMetadata, metadata.enabled else { return }

        if let doc = documentProvider.document {
            var allAnnotations: [PSPDFAnnotation] = []
            for canvadocsAnnotation in annotations {
                if let annotation = canvadocsAnnotation.pspdfAnnotation(for: doc) {
                    (annotation as? PSPDFFreeTextAnnotation)?.sizeToFit()
                    annotation.flags.remove(.readOnly) // Always allow user to view and add comments
                    annotation.isEditable = annotation.user == metadata.userID &&
                        (metadata.permissions == .ReadWriteManage || metadata.permissions == .ReadWrite)
                    allAnnotations.append(annotation)
                }
            }
            setAnnotations(allAnnotations, append: false)
        }
    }
    
    func getReplies (to: PSPDFAnnotation) -> [CanvadocsCommentReplyAnnotation] {
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
    
    override func add(_ annotations: [PSPDFAnnotation], options: [String : Any]? = nil) -> [PSPDFAnnotation]? {
        super.add(annotations, options: options)
        guard let doc = self.documentProvider?.document else { return nil }
        
        var added: [PSPDFAnnotation] = []
        for annotation in annotations {
            if let canvadocsAnnotation = CanvadocsAnnotation(pspdfAnnotation: annotation, onDocument: doc) {
                added.append(annotation)
                self.canvadocsAnnotations.append(canvadocsAnnotation)
                if canvadocsAnnotation.isEmpty {
                    continue // don't save to network if empty comment reply or free text
                }
                self.service.upsertAnnotation(canvadocsAnnotation) { [weak self] result in
                    switch result {
                    case .success(let updated):
                        if let index = self?.canvadocsAnnotations.index(where: { $0.id == updated.id }) {
                            self?.canvadocsAnnotations[index] = updated
                        }
                    case .failure(let error):
                        _ = self?.remove([annotation])
                        print(error)
                    }
                }
            }
        }
        return added
    }
    
    override func remove(_ annotations: [PSPDFAnnotation], options: [String : Any]? = nil) -> [PSPDFAnnotation]? {
        super.remove(annotations, options: options)
        
        var removed: [PSPDFAnnotation] = []
        for annotation in annotations {
            if let annotationID = annotation.name {
                print("Deleting annotation \(annotationID)")
                
                for index in stride(from: (self.canvadocsAnnotations.count - 1), through: 0, by: -1) {
                    let canvadocsAnnotation = self.canvadocsAnnotations[index]
                    if canvadocsAnnotation.id == annotationID {
                        removed.append(annotation)
                        self.canvadocsAnnotations.remove(at: index)
                        self.service.deleteAnnotation(canvadocsAnnotation) { [weak self] result in
                            if result.error != nil {
                                // Let's go back and reset so the user can try deleting again
                                self?.canvadocsAnnotations.append(canvadocsAnnotation)
                            }
                        }
                    }
                }
            }
        }
        return removed
    }
    
    override func didChange(_ annotation: PSPDFAnnotation, keyPaths: [String], options: [String : Any]? = nil) {
        guard
            let doc = documentProvider?.document,
            let pspdfAnnotationID = annotation.name,
            let index = canvadocsAnnotations.index(where: { $0.id == pspdfAnnotationID }),
            let canvadocsAnnotation = CanvadocsAnnotation(pspdfAnnotation: annotation, onDocument: doc)
        else { return }

        if let inkAnnotation = annotation as? PSPDFInkAnnotation, inkAnnotation.lines.count > 120 {
            doc.undoController?.undo()
            limitDelegate?.annotationDidExceedLimit(annotation: canvadocsAnnotation)
            return
        }

        canvadocsAnnotations[index] = canvadocsAnnotation // update internal list with changes
        
        if canvadocsAnnotation.isEmpty {
            return // don't save to network if empty comment reply or free text
        }
        service.upsertAnnotation(canvadocsAnnotation) { [weak self] result in
            switch result {
            case .success(let annotation):
                if let id = annotation.id {
                    if let index = self?.canvadocsAnnotations.index(where: { $0.id == id }) {
                        self?.canvadocsAnnotations[index] = canvadocsAnnotation
                    }
                }
            case .failure(let error):
                doc.undoController?.undo()
                switch error {
                case .tooBig:
                    self?.limitDelegate?.annotationDidExceedLimit(annotation: canvadocsAnnotation)
                case .nsError(let e):
                    print(e)
                }
            }
        }
    }

}
