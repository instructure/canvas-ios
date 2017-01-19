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
    
    func XFDFFormatOfAnnotation(_ annotation: PSPDFAnnotation) -> XFDFAnnotation? {
        let outputSteam = OutputStream.toMemory()
        outputSteam.open()
        defer {
            outputSteam.close()
        }
        
        let writer = PSPDFXFDFWriter()
        do {
            try writer.write([annotation], to: outputSteam, documentProvider: annotation.documentProvider)
        } catch let error as NSError {
            // TODO: do something with this error
            print("Error writing annotations: \(error)")
        }
        
        if let contents: Data = outputSteam.property(forKey: Stream.PropertyKey.dataWrittenToMemoryStreamKey) as? Data, let xfdf = NSString(data: contents, encoding: String.Encoding.utf8.rawValue) {
            outputSteam.close()
            let stripped = stripXFDFHeadersFromXFDFAnnotation(xfdf as String)
            
            // If it's a comment annotation, and it's a reply, add that to the xml before sending
            if let commentAnnotation = annotation as? CanvadocsCommentReplyAnnotation, let inReplyTo = commentAnnotation.inReplyTo {
                if inReplyTo != "" {
                    do {
                        let doc = try GDataXMLDocument(xmlString: (stripped as String), options: 0)
                        doc.rootElement().addAttribute(GDataXMLNode.attribute(withName: "inreplyto", stringValue: inReplyTo) as! GDataXMLNode)
                        return doc.rootElement().xmlString()
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
    
    fileprivate func stripXFDFHeadersFromXFDFAnnotation(_ xfdfAnnotation: String) -> String {
        do {
            let doc = try GDataXMLDocument(xmlString: xfdfAnnotation, options: 0)
            var str = ""
            if let annots = (doc.rootElement().elements(forName: "annots").first as AnyObject).children() {
                for child in annots {
                    if let annot = child as? GDataXMLNode {
                        str += annot.xmlString()
                    }
                }
            }
            return str
        } catch let error as NSError {
            print("Error stripping xfdf headers: \(error)")
            return ""
        }
    }
    
    func commentThreadMappingsFromXFDF(_ data: Data, limitPage: Int? = nil) -> (parentToChildren: Dictionary<String, Array<String>>, childToParent: Dictionary<String, String>) {
        var parentToChildrenMap = Dictionary<String, Array<String>>()
        var childToParentMap = Dictionary<String, String>()
        
        do {
            let doc = try GDataXMLDocument(data: data, options: 0)
            if let annots = doc.rootElement().elements(forName: "annots").first as? GDataXMLElement, let textAnnots = annots.children() {
                for textAnnot in textAnnots {
                    if let textAnnotElement = textAnnot as? GDataXMLElement {
                        let id = textAnnotElement.attribute(forName: "name")?.stringValue() ?? ""
                        let inReplyTo = textAnnotElement.attribute(forName: "inreplyto")?.stringValue() ?? ""
                        let annotPageStr = textAnnotElement.attribute(forName: "page")?.stringValue() ?? ""
                        if let limitPage = limitPage, let annotPage = Int(annotPageStr) {
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
    
    func updateXFDFActionsXML(_ adding: Array<XFDFAnnotation> = [], modifying: Array<XFDFAnnotation> = [], deleting: Array<String> = []) -> String {
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
