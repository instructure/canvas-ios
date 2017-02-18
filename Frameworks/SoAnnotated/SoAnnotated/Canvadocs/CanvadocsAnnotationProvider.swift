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
import SoPretty

class CanvadocsAnnotationProvider: PSPDFXFDFAnnotationProvider {
    
    let service: CanvadocsAnnotationService
    let xfdfParser = CanvadocsXFDFParser()
    var childrenMapping: [String:[CanvadocsCommentReplyAnnotation]] = [:]
    
    init(documentProvider: PSPDFDocumentProvider!, fileURL XFDFFileURL: URL, service: CanvadocsAnnotationService) {
        self.service = service
        super.init(documentProvider: documentProvider, fileURL: XFDFFileURL)
        
        let parser = PSPDFXFDFParser(inputStream: InputStream(url: fileURL!)!, documentProvider: documentProvider)
        var pspdfAnnotations: [PSPDFAnnotation] = []
        do {
            pspdfAnnotations = try parser.parse()
        } catch {
            print("Error parsing annotations: \(error)")
        }
        let (parentToChildrenMap, childToParentMap) = xfdfParser.commentThreadMappingsFromXFDF(try! Data(contentsOf: fileURL!))
        
        var commentAnnotations = Dictionary<String, CanvadocsCommentReplyAnnotation>()
        for annotation in pspdfAnnotations {
            if let noteAnnotation = annotation as? PSPDFNoteAnnotation, let id = noteAnnotation.name, let inReplyTo = childToParentMap[id] {
                let contents = noteAnnotation.contents?.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines) ?? ""
                let commentAnnotation = CanvadocsCommentReplyAnnotation(contents: contents)
                commentAnnotation.name = id
                commentAnnotation.user = noteAnnotation.user
                commentAnnotation.page = noteAnnotation.page
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
    
    override func annotations(forPage page: UInt) -> [PSPDFAnnotation]? {
        var mut_annotations = super.annotations(forPage: page)
        
        if let annotations = mut_annotations {
            // Find and remove any lone note annotations, and send back that filtered list, plus our own comment annotations

            for index in stride(from: (annotations.count - 1), through: 0, by: -1) {
                let annotation = annotations[index]
                if let noteAnnotation = annotation as? PSPDFNoteAnnotation {
                    // the call to super should be limiting these annots by the page for us
                    for (_, value) in childrenMapping {
                        for annot in value {
                            if annot.name == annotation.name {
                                mut_annotations?.remove(at: index)
                                break
                            }
                        }
                    }
                    
                    // Don't ask me why, but somehow some notes were going black, this fixes it ¯\_(ツ)_/¯
                    DispatchQueue.main.async(execute: {
                        if noteAnnotation.color?.hex != "#F2DD47" {
                            noteAnnotation.color = UIColor(rgba: "#F2DD47")
                            NotificationCenter.default.post(name: NSNotification.Name.PSPDFAnnotationChanged, object: noteAnnotation, userInfo: [PSPDFAnnotationChangedNotificationKeyPathKey: ["color"]])
                        }
                    })
                } else {
                    if let metadata = service.metadata {
                        if annotation.user != metadata.annotationMetadata.userName || metadata.annotationMetadata.permissions == .Read {
                            annotation.isEditable = false
                        }
                    }
                }
            }
        }
        
        return (mut_annotations ?? [])
    }
    override func add(_ annotations: [PSPDFAnnotation], options: [String : Any]? = nil) -> [PSPDFAnnotation]? {
        // I tried doing this without the verbose if statement, trust me. IT DIDN'T WORK so here I lay...
        let filtered = annotations.filter {
            if let noteAnnotation = $0 as? PSPDFNoteAnnotation {
                if noteAnnotation.contents == nil || noteAnnotation.contents == "" {
                    return false
                }
            }
            if type(of: $0) === CanvadocsCommentReplyAnnotation.self {
                return false
            } else {
                return true
            }
        }
        let _ = super.add(filtered, options: options) ?? []
        
        // Doing it this way instead of sending the xfdf because at this point in time, the xfdf hasn't been written out to disk
        var xfdfAnnotations: [XFDFAnnotation] = []
        for annotation in annotations {
            if let noteAnnotation = annotation as? PSPDFNoteAnnotation {
                if noteAnnotation.contents == nil || noteAnnotation.contents == "" {
                    continue
                }
            }
            
            if let canvasCommentAnnotation = annotation as? CanvadocsCommentReplyAnnotation, let inReplyTo = canvasCommentAnnotation.inReplyTo {
                for (parentID, _) in childrenMapping {
                    if parentID == inReplyTo {
                        childrenMapping[parentID]!.append(canvasCommentAnnotation)
                    }
                }
            }
            
            if let annotationID = annotation.name {
                if childrenMapping[annotationID] == nil {
                    childrenMapping[annotationID] = []
                }
            }
           
            if let xfdf = xfdfParser.XFDFFormatOfAnnotation(annotation) {
                xfdfAnnotations.append(xfdf)
            }
        }
        service.addAnnotations(xfdfAnnotations)
        
        return annotations
    }
    
    override func remove(_ annotations: [PSPDFAnnotation], options: [String : Any]? = nil) -> [PSPDFAnnotation]? {
        let annotations = super.remove(annotations, options: options) ?? []
        
        for annotation in annotations {
            if let annotationID = annotation.name {
                childrenMapping[annotationID] = []
                service.deleteAnnotation(annotationID)
            }
        }
        
        return annotations
    }
    
    override func didChange(_ annotation: PSPDFAnnotation, keyPaths: [String], options: [String : Any]? = nil) {
        if let xfdf = xfdfParser.XFDFFormatOfAnnotation(annotation) {
            service.modifyAnnotations([xfdf])
        }
    }
}
