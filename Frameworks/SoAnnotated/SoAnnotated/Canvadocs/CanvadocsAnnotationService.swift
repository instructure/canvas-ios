//
//  CanvadocsAnnotationService.swift
//  SoAnnotated
//
//  Created by Ben Kraus on 4/7/15.
//  Copyright (c) 2015 Instructure. All rights reserved.
//

import Foundation
import Result

struct CanvadocsFileMetadata {
    let pdfDownloadURL: NSURL
    let annotationMetadata: CanvadocsAnnotationMetadata
    let pandaPush: PandaPushMetadata?
}

struct CanvadocsAnnotationMetadata {
    enum Permissions: String {
        case Read = "read"
        case ReadWrite = "readwrite"
    }
    
    let enabled: Bool
    let userName: String
    let permissions: Permissions
    let xfdfURL: NSURL
}

struct PandaPushMetadata {
    let host: String
    let annotationsChannel: String
    let annotationsToken: String
}

typealias MetadataResult = Result<CanvadocsFileMetadata, NSError>
typealias DocumentResult = Result<NSURL, NSError>
typealias AnnotationsResult = Result<NSURL, NSError>
typealias UpdateAnnotationsResult = Result<Bool, NSError>
typealias DeleteAnnotationResult = Result<Bool, NSError>


protocol PandaPushAnnotationUpdateHandler {
    func annotationCreatedOrUpdated(annotation: XFDFAnnotation)
    func annotationDeleted(annotation: XFDFAnnotation)
}


class CanvadocsAnnotationService: NSObject {

    let sessionURL: NSURL
    private let baseURLString: String
    
    var metadata: CanvadocsFileMetadata? = nil
    var pandaPushHandler: PandaPushAnnotationUpdateHandler? = nil
    
    private let clientId: String
    
    private let parser = CanvadocsXFDFParser()
    
    init(sessionURL: NSURL) {
        self.sessionURL = sessionURL
        if let components = NSURLComponents(URL: sessionURL, resolvingAgainstBaseURL: false), scheme = components.scheme, host = components.host {
            // Strip it down to just this
            let baseURLComponents = NSURLComponents()
            baseURLComponents.scheme = scheme
            baseURLComponents.host = host
            baseURLComponents.path = "/"
            baseURLString = baseURLComponents.URL?.absoluteString ?? ""
        } else {
            baseURLString = ""
        }
        
        self.clientId = NSUUID().UUIDString
        NSURLSession.sharedSession().configuration.HTTPAdditionalHeaders = ["X-Client-Id": self.clientId]
    }
    
    private func removeLeadingSlash(path: String) -> String {
        if path.substringToIndex(path.startIndex.advancedBy(1)) == "/" {
            return path.substringFromIndex(path.startIndex.advancedBy(1))
        }
        return path
    }
    
    func getMetadata(completed: MetadataResult->()) {
        let request = NSMutableURLRequest(URL: sessionURL)
        let dataTask = NSURLSession.sharedSession().dataTaskWithRequest(request) { (data, response, error) in
            if let error = error {
                completed(Result.Failure(error))
                return
            } else {
                if let data = data {
                    do {
                        let json = try NSJSONSerialization.JSONObjectWithData(data, options: NSJSONReadingOptions())
                        if let json = json as? [String: AnyObject], urls = json["urls"] as? [String: AnyObject], annotationSettings = json["annotations"] as? [String: AnyObject] {
                            var annotationMetadata: CanvadocsAnnotationMetadata?
                            if let enabled = annotationSettings["enabled"] as? Bool, userName = annotationSettings["user_name"] as? String, permissionsStr = annotationSettings["permissions"] as? String, permissions = CanvadocsAnnotationMetadata.Permissions(rawValue: permissionsStr), xfdfURLStr = annotationSettings["xfdf_url"] as? String {
                                let xfdfURL = NSURL(string: (self.baseURLString+self.removeLeadingSlash(xfdfURLStr)))!
                                annotationMetadata = CanvadocsAnnotationMetadata(enabled: enabled, userName: userName, permissions: permissions, xfdfURL: xfdfURL)
                            }
                            
                            var pandaPushMetadata: PandaPushMetadata?
                            if let pandaPush = json["panda_push"] as? [String: AnyObject] {
                                if let host = pandaPush["host"] as? String,
                                    annotationsChannel = pandaPush["annotations_channel"] as? String,
                                    annotationsToken = pandaPush["annotations_token"] as? String {
                                        pandaPushMetadata = PandaPushMetadata(host: host, annotationsChannel: annotationsChannel, annotationsToken: annotationsToken)
                                }
                            }
                            
                            if let pdfDownloadURLStr = urls["pdf_download"] as? String, pdfDownloadURL = NSURL(string: (self.baseURLString+self.removeLeadingSlash(pdfDownloadURLStr))), annotationMetadata = annotationMetadata {
                                let metadata = CanvadocsFileMetadata(pdfDownloadURL: pdfDownloadURL, annotationMetadata: annotationMetadata, pandaPush: pandaPushMetadata)
                                completed(Result.Success(metadata))
                            } else {
                                completed(Result.Failure(NSError(domain: "com.instructure.ios-annotations", code: -1, userInfo: nil)))
                            }
                        } else {
                            completed(Result.Failure(NSError(domain: "com.instructure.ios-annotations", code: -1, userInfo: nil)))
                        }
                    } catch let error as NSError {
                        completed(Result.Failure(error))
                    }
                }
            }
        }
        dataTask.resume()
    }
    
    func getDocument(completed: DocumentResult->()) {
        if let metadata = metadata {
            let downloadTask = NSURLSession.sharedSession().downloadTaskWithURL(metadata.pdfDownloadURL) { (temporaryURL, response, error) in
                if let error = error {
                    print("SO SAD - failed downloading pdf: \(error)")
                    completed(Result.Failure(error))
                    return
                } else {
                    print("YAY - downloaed pdf doc")
                    // Move the doc to a permanent location
                    let fileManager = NSFileManager.defaultManager()
                    let directoryURL = fileManager.URLsForDirectory(.DocumentDirectory, inDomains: .UserDomainMask)[0]
                    // TODO: unify the places we do this sorta thing
                    let filename = "\(self.sessionURL.absoluteString.substringFromIndex(self.sessionURL.absoluteString.endIndex.advancedBy(-12)))_doc.pdf"
                    let copyURL = directoryURL.URLByAppendingPathComponent(filename)
                    
                    if fileManager.fileExistsAtPath(copyURL.path!) {
                        do {
                            try fileManager.removeItemAtURL(copyURL)
                        } catch let error {
                            print("Couldn't remove old doc: \(error)")
                        }
                    }
                    
                    do {
                        if let temporaryURL = temporaryURL {
                            try fileManager.copyItemAtURL(temporaryURL, toURL: copyURL)
                        }
                    } catch let error {
                        print("Couldn't copy new doc file: \(error)")
                    }
                    
                    completed(Result.Success(copyURL))
                }
            }
            downloadTask.resume()
        }
    }
    
    func getAnnotations(completed: AnnotationsResult->()) {
        if let metadata = metadata {
            let downloadTask = NSURLSession.sharedSession().downloadTaskWithURL(metadata.annotationMetadata.xfdfURL) { (temporaryURL, response, error) in
                if let error = error {
                    print("SO SAD - failed downloading xfdf annotations: \(error)")
                    completed(Result.Failure(error))
                    return
                } else {
                    print("YAY - downloaded xfdf annotations")
                    // Move the doc to a permanent location
                    let fileManager = NSFileManager.defaultManager()
                    let directoryURL = fileManager.URLsForDirectory(.DocumentDirectory, inDomains: .UserDomainMask)[0]
                    // TODO: unify the places we do this sorta thing
                    let filename = "\(self.sessionURL.absoluteString.substringFromIndex(self.sessionURL.absoluteString.endIndex.advancedBy(-12)))_annots.xfdf"
                    let copyURL = directoryURL.URLByAppendingPathComponent(filename)
                    
                    if fileManager.fileExistsAtPath(copyURL.path!) {
                        do {
                            try fileManager.removeItemAtURL(copyURL)
                        } catch let error {
                            print("Couldn't remove old annots file: \(error)")
                        }
                    }
                    
                    do {
                        if let temporaryURL = temporaryURL {
                            try fileManager.copyItemAtURL(temporaryURL, toURL: copyURL)
                        }
                    } catch let error {
                        print("Couldn't copy new annots file: \(error)")
                    }
                    
                    let data = NSData(contentsOfURL: copyURL)
                    let str = NSString(data: data!, encoding: NSUTF8StringEncoding)
                    print("This is the xfdf:\n \(str)")
                    completed(Result.Success(copyURL))
                }
            }
            downloadTask.resume()
        }
    }
    
    func updateAnnotationsFromFile(fileURL: NSURL, completed: UpdateAnnotationsResult->()) {
        if let metadata = metadata {
            let string = try? NSString(contentsOfURL: fileURL, encoding: NSUTF8StringEncoding)
            print("About to upload annots: \(string!)")
            let request = NSMutableURLRequest(URL: metadata.annotationMetadata.xfdfURL)
            request.HTTPMethod = "PUT"
            request.addValue("text/xml", forHTTPHeaderField: "Content-Type")
            let uploadTask = NSURLSession.sharedSession().uploadTaskWithRequest(request, fromFile: fileURL) { _, response, error in
                if let error = error {
                    print("UH OH - Couldn't upload annots: \(error)")
                    print(response)
                }
            }
            uploadTask.resume()
        }
    }
    
    func addAnnotations(annotations: Array<XFDFAnnotation>) {
        for xfdfAnnotation in annotations {
            print("About to send this new annotation: \(xfdfAnnotation)")
        }
        let xfdf = parser.updateXFDFActionsXML(annotations)
        updateXFDFFromActionsFormat(xfdf)
    }
    
    func modifyAnnotations(annotations: Array<XFDFAnnotation>) {
        let xfdf = parser.updateXFDFActionsXML(modifying: annotations)
        updateXFDFFromActionsFormat(xfdf)
    }
    
    func deleteAnnotation(annotationID: String) {
        if let url = NSURL(string: "\(sessionURL.absoluteString)/annotations/\(annotationID)") {
            let request = NSMutableURLRequest(URL: url)
            request.HTTPMethod = "DELETE"
            
            let deleteTask = NSURLSession.sharedSession().dataTaskWithRequest(request) { (_, response, error) in
                if let error = error {
                    print("UH OH - Couldn't delete annotation \(annotationID): \(error)")
                    print(response)
                }
            }
            deleteTask.resume()
        }
    }
    
    func deleteAnnotations(annotationIDs: Array<String>) {
        for annotationID in annotationIDs {
            deleteAnnotation(annotationID)
        }
    }
    
    private func updateXFDFFromActionsFormat(xfdf: String) {
        print("About to update xfdf from actions format: \(xfdf)")
        if let metadata = metadata, data = xfdf.dataUsingEncoding(NSUTF8StringEncoding) {
            let request = NSMutableURLRequest(URL: metadata.annotationMetadata.xfdfURL)
            request.HTTPMethod = "POST"
            request.addValue("text/xml", forHTTPHeaderField: "Content-Type")
            let uploadTask = NSURLSession.sharedSession().uploadTaskWithRequest(request, fromData: data) { _, response, error in
                if let error = error {
                    print("UH OH - Couldn't add annots: \(error)")
                    print(response)
                }
            }
            uploadTask.resume()
        }
    }
}

