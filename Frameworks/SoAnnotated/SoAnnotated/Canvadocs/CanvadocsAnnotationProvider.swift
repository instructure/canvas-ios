//
// Copyright (C) 2016-present Instructure, Inc.
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
// http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.
//
    
    

import Foundation
import PSPDFKit

class CanvadocsAnnotationProvider: PSPDFContainerAnnotationProvider {
    
    let service: CanvadocsAnnotationService

    private var canvadocsAnnotations: [CanvadocsAnnotation] = []

    var childrenMapping: [String:[CanvadocsCommentReplyAnnotation]] = [:]
    
    init(documentProvider: PSPDFDocumentProvider!, annotations: [CanvadocsAnnotation], service: CanvadocsAnnotationService) {
        self.service = service
        self.canvadocsAnnotations = annotations

        super.init(documentProvider: documentProvider)

        if let doc = documentProvider.document {
            setAnnotations(annotations.map { $0.pspdfAnnotation(for: doc) }.filter { $0 != nil }.map { $0! }, append: false)
        }

        let (parentToChildrenMap, childToParentMap) = commentThreadMappings(from: annotations)

        var commentAnnotations = Dictionary<String, CanvadocsCommentReplyAnnotation>()
        for annotation in allAnnotations {
            if let noteAnnotation = annotation as? PSPDFNoteAnnotation, let id = noteAnnotation.name, let inReplyTo = childToParentMap[id] {
                let contents = noteAnnotation.contents?.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines) ?? ""
                let commentAnnotation = CanvadocsCommentReplyAnnotation(contents: contents)
                commentAnnotation.name = id
                commentAnnotation.user = noteAnnotation.user
                commentAnnotation.pageIndex = noteAnnotation.pageIndex
                commentAnnotation.boundingBox = noteAnnotation.boundingBox
                commentAnnotation.inReplyTo = inReplyTo
                commentAnnotation.creationDate = noteAnnotation.creationDate
                if let metadata = service.metadata {
                    if commentAnnotation.user != metadata.annotationMetadata.userName || metadata.annotationMetadata.permissions == .Read {
                        commentAnnotation.isEditable = false
                    }
                }
                commentAnnotations[id] = commentAnnotation
            }
        }

        for (parent, children) in parentToChildrenMap {
            let childAnnots = children.filter({ commentAnnotations[$0] != nil }).map({ commentAnnotations[$0]! }).sorted { comment1, comment2 in
                let date1 = comment1.creationDate ?? Date()
                let date2 = comment2.creationDate ?? Date()
                return date1.compare(date2) == ComparisonResult.orderedAscending
            }
            childrenMapping[parent] = childAnnots
        }
    }
    
    func commentThreadMappings(from annotations: [CanvadocsAnnotation]) -> (parentToChildren: Dictionary<String, Array<String>>, childToParent: Dictionary<String, String>) {
        var parentToChildrenMap = Dictionary<String, Array<String>>()
        var childToParentMap = Dictionary<String, String>()
        
        for annot in annotations {
            if case let .commentReply(parent, _) = annot.type, let annotationID = annot.id {
                childToParentMap[annotationID] = parent
            }
        }
        
        // Now we have something like
        // "A" -> "", "B" -> "A", "C" -> "B", "D" -> "C"
        // where key is the child and value is it's parent
        
        for (childID, parentID) in childToParentMap {
            if parentID != "" {
                var childrenList: Array<String> = parentToChildrenMap[parentID] ?? []
                childrenList.append(childID)
                parentToChildrenMap[parentID] = childrenList
            } else if (parentToChildrenMap[childID] == nil){
                parentToChildrenMap[childID] = []
            }
        }
        
        // Now we have something like
        // "A" -> ["B", "C", "D"] (after sorting by date)
        // where key is the parent and value is all the children
        
        return (parentToChildrenMap, childToParentMap)
    }
    
    override func annotationsForPage(at pageIndex: UInt) -> [PSPDFAnnotation]? {
        let pageAnnotations = super.annotationsForPage(at: pageIndex)
        for annotation in (pageAnnotations ?? []) {
            (annotation as? PSPDFFreeTextAnnotation)?.sizeToFit()
            annotation.flags.remove(.readOnly) // Allows user to view and add comments

            if let metadata = service.metadata {
                if annotation.user != metadata.annotationMetadata.userName || metadata.annotationMetadata.permissions == .Read {
                    annotation.isEditable = false
                }
            }
        }
        return pageAnnotations
    }
    
    override func add(_ annotations: [PSPDFAnnotation], options: [String : Any]? = nil) -> [PSPDFAnnotation]? {
        let filtered = annotations.filter {
            if type(of: $0) === CanvadocsCommentAnnotation.self {
                return false
            }
            return true
        }
        super.add(filtered, options: options)
        
        for annotation in annotations {
            if let noteAnnotation = annotation as? PSPDFNoteAnnotation, (noteAnnotation.contents == nil || noteAnnotation.contents == "") {
                continue
            } else if let freeTextAnnotation = annotation as? PSPDFFreeTextAnnotation, (freeTextAnnotation.contents == nil || freeTextAnnotation.contents == "") {
                continue
            }

            if let canvasCommentAnnotation = annotation as? CanvadocsCommentReplyAnnotation, let inReplyTo = canvasCommentAnnotation.inReplyTo {
                if var children = childrenMapping[inReplyTo] {
                    children.append(canvasCommentAnnotation)
                    childrenMapping[inReplyTo] = children
                } else {
                    childrenMapping[inReplyTo] = [canvasCommentAnnotation]
                }
            }
            
            guard let doc = documentProvider?.document else { continue }
            if let canvadocsAnnotation = CanvadocsAnnotation(pspdfAnnotation: annotation, onDocument: doc) {
                canvadocsAnnotations.append(canvadocsAnnotation)
                service.upsertAnnotation(canvadocsAnnotation) { [weak self] result in
                    switch result {
                    case .success(let annotation):
                        if let id = annotation.id {
                            if let index = self?.canvadocsAnnotations.index(where: { $0.id == id }) {
                                self?.canvadocsAnnotations[index] = canvadocsAnnotation
                            }
                        }
                    case .failure(let error):
                        _ = self?.remove([annotation])
                        print(error)
                    }
                }
            }
        }
        
        return filtered
    }
    
    override func remove(_ annotations: [PSPDFAnnotation], options: [String : Any]? = nil) -> [PSPDFAnnotation]? {
        let annotations = super.remove(annotations, options: options) ?? []
        
        for annotation in annotations {
            if let annotationID = annotation.name {
                print("Deleting annotation \(annotationID)")
                childrenMapping.removeValue(forKey: annotationID)
                
                for index in stride(from: (canvadocsAnnotations.count - 1), through: 0, by: -1) {
                    let canvadocsAnnotation = canvadocsAnnotations[index]
                    if canvadocsAnnotation.id == annotationID {
                        service.deleteAnnotation(canvadocsAnnotation) { [weak self] result in
                            if result.error != nil {
                                // Let's go back and reset so the user can try deleting again
                                self?.canvadocsAnnotations.append(canvadocsAnnotation)
                            }
                        }
                        canvadocsAnnotations.remove(at: index)
                    }
                }
            }
        }
        
        return annotations
    }
    
    override func didChange(_ annotation: PSPDFAnnotation, keyPaths: [String], options: [String : Any]? = nil) {
        guard let doc = documentProvider?.document else { return }
        guard let pspdfAnnotationID = annotation.name else { return }
        guard let canvadocsAnnotation = CanvadocsAnnotation(pspdfAnnotation: annotation, onDocument: doc) else { return }
        
        if let noteAnnotation = annotation as? PSPDFNoteAnnotation, (noteAnnotation.contents == nil || noteAnnotation.contents == "") {
            return
        } else if let freeTextAnnotation = annotation as? PSPDFFreeTextAnnotation, (freeTextAnnotation.contents == nil || freeTextAnnotation.contents == "") {
            return
        }

        if let index = canvadocsAnnotations.index(where: { $0.id == pspdfAnnotationID }) {
            canvadocsAnnotations[index] = canvadocsAnnotation
        } else {
            canvadocsAnnotations.append(canvadocsAnnotation)
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
                print(error)
            }
        }
        
    }
}
