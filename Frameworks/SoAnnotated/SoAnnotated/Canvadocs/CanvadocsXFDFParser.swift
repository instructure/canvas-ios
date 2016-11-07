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


class CanvadocsCommentReplyAnnotation: PSPDFNoteAnnotation {
    var inReplyTo: String?
}

typealias XFDFAnnotation = String

class CanvadocsXFDFParser: NSObject {
    
    func XFDFFormatOfAnnotation(annotation: PSPDFAnnotation) -> XFDFAnnotation? {
        let outputSteam = NSOutputStream.outputStreamToMemory()
        outputSteam.open()
        defer {
            outputSteam.close()
        }
        
        let writer = PSPDFXFDFWriter()
        do {
            try writer.writeAnnotations([annotation], toOutputStream: outputSteam, documentProvider: annotation.documentProvider)
        } catch let error as NSError {
            // TODO: do something with this error
            print("Error writing annotations: \(error)")
        }
        
        if let contents: NSData = outputSteam.propertyForKey(NSStreamDataWrittenToMemoryStreamKey) as? NSData, xfdf = NSString(data: contents, encoding: NSUTF8StringEncoding) {
            outputSteam.close()
            let stripped = stripXFDFHeadersFromXFDFAnnotation(xfdf as String)
            
            // If it's a comment annotation, and it's a reply, add that to the xml before sending
            if let commentAnnotation = annotation as? CanvadocsCommentReplyAnnotation, inReplyTo = commentAnnotation.inReplyTo {
                if inReplyTo != "" {
                    do {
                        let doc = try GDataXMLDocument(XMLString: (stripped as String), options: 0)
                        doc.rootElement().addAttribute(GDataXMLNode.attributeWithName("inreplyto", stringValue: inReplyTo) as! GDataXMLNode)
                        return doc.rootElement().XMLString()
                    } catch let error as NSError {
                        print("Error writing inreplyto attribute: \(error)")
                        return stripped
                    }
                } else {
                    return stripped
                }
            } else {
                return stripped
            }
        }
        return nil
    }
    
    private func stripXFDFHeadersFromXFDFAnnotation(xfdfAnnotation: String) -> String {
        do {
            let doc = try GDataXMLDocument(XMLString: xfdfAnnotation, options: 0)
            var str = ""
            if let annots = doc.rootElement().elementsForName("annots").first?.children() {
                for child in annots {
                    if let annot = child as? GDataXMLNode {
                        str += annot.XMLString()
                    }
                }
            }
            return str
        } catch let error as NSError {
            print("Error stripping xfdf headers: \(error)")
            return ""
        }
    }
    
    func commentThreadMappingsFromXFDF(data: NSData, limitPage: Int? = nil) -> (parentToChildren: Dictionary<String, Array<String>>, childToParent: Dictionary<String, String>) {
        var parentToChildrenMap = Dictionary<String, Array<String>>()
        var childToParentMap = Dictionary<String, String>()
        
        do {
            let doc = try GDataXMLDocument(data: data, options: 0)
            if let annots = doc.rootElement().elementsForName("annots").first as? GDataXMLElement, textAnnots = annots.children() {
                for textAnnot in textAnnots {
                    if let textAnnotElement = textAnnot as? GDataXMLElement {
                        let id = textAnnotElement.attributeForName("name")?.stringValue() ?? ""
                        let inReplyTo = textAnnotElement.attributeForName("inreplyto")?.stringValue() ?? ""
                        let annotPageStr = textAnnotElement.attributeForName("page")?.stringValue() ?? ""
                        if let limitPage = limitPage, annotPage = Int(annotPageStr) {
                            if limitPage == annotPage {
                                childToParentMap[id] = inReplyTo
                            }
                        } else {
                            childToParentMap[id] = inReplyTo
                        }
                    }
                }
            }
        } catch let error as NSError {
            print("Error mapping comment threads: \(error)")
            return ([:], [:])
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
    
    func updateXFDFActionsXML(adding: Array<XFDFAnnotation> = [], modifying: Array<XFDFAnnotation> = [], deleting: Array<String> = []) -> String {
        // I did this manually because this xml lib I'm using doesn't allow for creation/adding of elements. Another one I tried didn't allow
        // you to construct a raw element from an xml string, only docs. THEY ALL SUCK
        var str = "<xfdf xmlns=\"http://ns.adobe.com/xfdf/\" xml:space=\"preserve\"><fields />"
        
        str += "<add>"
        for annotation in adding {
            str += annotation
        }
        str += "</add>"
        
        str += "<modify>"
        for annotation in modifying {
            str += annotation
        }
        str += "</modify>"
        
        str += "<delete>"
        for id in deleting {
            str += "<id>\(id)</id>"
        }
        str += "</delete>"
        
        str += "</xfdf>"
        
        return str
    }
}