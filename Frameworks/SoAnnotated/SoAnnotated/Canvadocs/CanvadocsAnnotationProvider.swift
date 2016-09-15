//
//  CanvadocsAnnotationProvider.swift
//  SoAnnotated
//
//  Created by Ben Kraus on 4/7/15.
//  Copyright (c) 2015 Instructure. All rights reserved.
//

import Foundation
import PSPDFKit

class CanvadocsAnnotationProvider: PSPDFXFDFAnnotationProvider {
    
    let service: CanvadocsAnnotationService
    let xfdfParser = CanvadocsXFDFParser()
    var childrenMapping: [String:[CanvadocsCommentReplyAnnotation]] = [:]
    
    init!(documentProvider: PSPDFDocumentProvider!, fileURL XFDFFileURL: NSURL!, service: CanvadocsAnnotationService) {
        self.service = service
        super.init(documentProvider: documentProvider, fileURL: XFDFFileURL)
        
        let parser = PSPDFXFDFParser(inputStream: NSInputStream(URL: fileURL!)!, documentProvider: documentProvider)
        var pspdfAnnotations: [PSPDFAnnotation] = []
        do {
            pspdfAnnotations = try parser.parse()
        } catch {
            print("Error parsing annotations: \(error)")
        }
        let (parentToChildrenMap, childToParentMap) = xfdfParser.commentThreadMappingsFromXFDF(NSData(contentsOfURL: fileURL!)!)
        
        var commentAnnotations = Dictionary<String, CanvadocsCommentReplyAnnotation>()
        for annotation in pspdfAnnotations {
            if let noteAnnotation = annotation as? PSPDFNoteAnnotation, id = noteAnnotation.name, inReplyTo = childToParentMap[id] {
                let contents = noteAnnotation.contents?.stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceAndNewlineCharacterSet()) ?? ""
                let commentAnnotation = CanvadocsCommentReplyAnnotation(contents: contents)
                commentAnnotation.name = id
                commentAnnotation.user = noteAnnotation.user
                commentAnnotation.page = noteAnnotation.page
                commentAnnotation.boundingBox = noteAnnotation.boundingBox
                commentAnnotation.inReplyTo = inReplyTo
                commentAnnotation.creationDate = noteAnnotation.creationDate
                if let metadata = service.metadata {
                    if commentAnnotation.user != metadata.annotationMetadata.userName || metadata.annotationMetadata.permissions == .Read {
                        commentAnnotation.editable = false
                    }
                }
                commentAnnotations[id] = commentAnnotation
            }
        }
        
        for (parent, children) in parentToChildrenMap {
            let childAnnots = children.filter({ commentAnnotations[$0] != nil }).map({ commentAnnotations[$0]! }).sort { comment1, comment2 in
                let date1 = comment1.creationDate ?? NSDate()
                let date2 = comment2.creationDate ?? NSDate()
                return date1.compare(date2) == NSComparisonResult.OrderedAscending
            }
            childrenMapping[parent] = childAnnots
        }
    }
    
    override func annotationsForPage(page: UInt) -> [PSPDFAnnotation]? {
        var mut_annotations = super.annotationsForPage(page)
        
        if let annotations = mut_annotations {
            // Find and remove any lone note annotations, and send back that filtered list, plus our own comment annotations

            for index in (annotations.count - 1).stride(through: 0, by: -1) {
                let annotation = annotations[index]
                if let noteAnnotation = annotation as? PSPDFNoteAnnotation {
                    // the call to super should be limiting these annots by the page for us
                    for (_, value) in childrenMapping {
                        for annot in value {
                            if annot.name == annotation.name {
                                mut_annotations?.removeAtIndex(index)
                                break
                            }
                        }
                    }
                    
                    // Don't ask me why, but somehow some notes were going black, this fixes it ¯\_(ツ)_/¯
                    dispatch_async(dispatch_get_main_queue(), {
                        if noteAnnotation.color?.hexStringRepresentation() != "#F2DD47" {
                            noteAnnotation.color = UIColor(rgba: "#F2DD47")
                            NSNotificationCenter.defaultCenter().postNotificationName(PSPDFAnnotationChangedNotification, object: noteAnnotation, userInfo: [PSPDFAnnotationChangedNotificationKeyPathKey: ["color"]])
                        }
                    })
                } else {
                    if let metadata = service.metadata {
                        if annotation.user != metadata.annotationMetadata.userName || metadata.annotationMetadata.permissions == .Read {
                            annotation.editable = false
                        }
                    }
                }
            }
        }
        
        return (mut_annotations ?? [])
    }
    
    override func addAnnotations(annotations: [PSPDFAnnotation], options: [String: AnyObject]?) -> [PSPDFAnnotation]? {
        // I tried doing this without the verbose if statement, trust me. IT DIDN'T WORK so here I lay...
        let filtered = annotations.filter {
            if let noteAnnotation = $0 as? PSPDFNoteAnnotation {
                if noteAnnotation.contents == nil || noteAnnotation.contents == "" {
                    return false
                }
            }
            if $0.dynamicType === CanvadocsCommentReplyAnnotation.self {
                return false
            } else {
                return true
            }
        }
        let _ = super.addAnnotations(filtered, options: options) ?? []
        
        // Doing it this way instead of sending the xfdf because at this point in time, the xfdf hasn't been written out to disk
        var xfdfAnnotations: [XFDFAnnotation] = []
        for annotation in annotations {
            if let noteAnnotation = annotation as? PSPDFNoteAnnotation {
                if noteAnnotation.contents == nil || noteAnnotation.contents == "" {
                    continue
                }
            }
            
            if let canvasCommentAnnotation = annotation as? CanvadocsCommentReplyAnnotation, inReplyTo = canvasCommentAnnotation.inReplyTo {
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
    
    override func removeAnnotations(annotations: [PSPDFAnnotation], options: [String: AnyObject]?) -> [PSPDFAnnotation]? {
        let annotations = super.removeAnnotations(annotations, options: options) ?? []
        
        for annotation in annotations {
            if let annotationID = annotation.name {
                childrenMapping[annotationID] = []
                service.deleteAnnotation(annotationID)
            }
        }
        
        return annotations
    }
    
    override func didChangeAnnotation(annotation: PSPDFAnnotation, keyPaths: [String], options: [String : AnyObject]?) {
        if let xfdf = xfdfParser.XFDFFormatOfAnnotation(annotation) {
            service.modifyAnnotations([xfdf])
        }
    }
}