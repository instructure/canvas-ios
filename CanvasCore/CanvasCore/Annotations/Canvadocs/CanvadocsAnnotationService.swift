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
import Result

struct CanvadocsFileMetadata {
    let pdfDownloadURL: URL
    let annotationMetadata: CanvadocsAnnotationMetadata
    let pandaPush: PandaPushMetadata?
}

struct CanvadocsAnnotationMetadata {
    enum Permissions: String {
        case Read = "read"
        case ReadWrite = "readwrite"
    }
    
    let enabled: Bool
    let userName: String?
    let permissions: Permissions?
    let xfdfURL: URL?
}

struct PandaPushMetadata {
    let host: String
    let annotationsChannel: String
    let annotationsToken: String
}

enum CanvadocsAnnotationError: Error {
    case tooBig
    case nsError(NSError)
}

let CanvadocsServerAnnotationSizeLimit = 102_400 // Bytes

typealias MetadataResult = Result<CanvadocsFileMetadata, NSError>
typealias DocumentResult = Result<URL, NSError>
typealias AnnotationsResult = Result<[CanvadocsAnnotation], NSError>
typealias UpdateAnnotationsResult = Result<Bool, NSError>
typealias DeleteAnnotationResult = Result<Bool, NSError>


class CanvadocsAnnotationService: NSObject {

    let sessionURL: URL
    fileprivate let baseURLString: String
    
    var metadata: CanvadocsFileMetadata? = nil
    
    fileprivate let clientId: String
    
    static let ISO8601MillisecondFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "en_US_POSIX")
        formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSZ";
        let tz = TimeZone(abbreviation:"GMT")
        formatter.timeZone = tz
        return formatter
    }()
    
    init(sessionURL: URL) {
        self.sessionURL = sessionURL
        if let components = URLComponents(url: sessionURL, resolvingAgainstBaseURL: false), let scheme = components.scheme, let host = components.host {
            // Strip it down to just this
            var baseURLComponents = URLComponents()
            baseURLComponents.scheme = scheme
            baseURLComponents.host = host
            baseURLComponents.path = "/"
            baseURLString = baseURLComponents.url?.absoluteString ?? ""
        } else {
            baseURLString = ""
        }
        
        self.clientId = UUID().uuidString
        URLSession.shared.configuration.httpAdditionalHeaders = ["X-Client-Id": self.clientId]
    }
    
    fileprivate func removeLeadingSlash(_ path: String) -> String {
        if path.substring(to: path.characters.index(path.startIndex, offsetBy: 1)) == "/" {
            return path.substring(from: path.characters.index(path.startIndex, offsetBy: 1))
        }
        return path
    }
    
    func getMetadata(_ completed: @escaping (MetadataResult)->()) {
        let request = URLRequest(url: sessionURL)
        let completion: (Data?, URLResponse?, Error?) -> Void = { (data, response, error) in
            if let error = error {
                completed(.failure(error as NSError))
                return
            } else {
                if let data = data {
                    do {
                        let json = try JSONSerialization.jsonObject(with: data, options: JSONSerialization.ReadingOptions())
                        if let json = json as? [String: AnyObject], let urls = json["urls"] as? [String: AnyObject] {
                            var annotationMetadata: CanvadocsAnnotationMetadata?
                            if let annotationSettings = json["annotations"] as? [String: AnyObject], let enabled = annotationSettings["enabled"] as? Bool, let userName = annotationSettings["user_name"] as? String, let permissionsStr = annotationSettings["permissions"] as? String, let permissions = CanvadocsAnnotationMetadata.Permissions(rawValue: permissionsStr), let xfdfURLStr = annotationSettings["xfdf_url"] as? String {
                                let xfdfURL = URL(string: (self.baseURLString+self.removeLeadingSlash(xfdfURLStr)))!
                                annotationMetadata = CanvadocsAnnotationMetadata(enabled: enabled, userName: userName, permissions: permissions, xfdfURL: xfdfURL)
                            } else {
                                annotationMetadata = CanvadocsAnnotationMetadata(enabled: false, userName: nil, permissions: nil, xfdfURL: nil)
                            }
                            
                            var pandaPushMetadata: PandaPushMetadata?
                            if let pandaPush = json["panda_push"] as? [String: AnyObject] {
                                if let host = pandaPush["host"] as? String,
                                    let annotationsChannel = pandaPush["annotations_channel"] as? String,
                                    let annotationsToken = pandaPush["annotations_token"] as? String {
                                    pandaPushMetadata = PandaPushMetadata(host: host, annotationsChannel: annotationsChannel, annotationsToken: annotationsToken)
                                }
                            }
                            
                            if let pdfDownloadURLStr = urls["pdf_download"] as? String, let pdfDownloadURL = URL(string: (self.baseURLString+self.removeLeadingSlash(pdfDownloadURLStr))), let annotationMetadata = annotationMetadata {
                                let metadata = CanvadocsFileMetadata(pdfDownloadURL: pdfDownloadURL, annotationMetadata: annotationMetadata, pandaPush: pandaPushMetadata)
                                completed(.success(metadata))
                            } else {
                                completed(.failure(NSError(domain: "com.instructure.ios-annotations", code: -1, userInfo: nil)))
                            }
                        } else {
                            completed(.failure(NSError(domain: "com.instructure.ios-annotations", code: -1, userInfo: nil)))
                        }
                    } catch let error as NSError {
                        completed(.failure(error))
                    }
                }
            }
        }
        let dataTask = URLSession.shared.dataTask(with: request, completionHandler: completion)
        dataTask.resume()
    }
    
    func getDocument(_ completed: @escaping (DocumentResult)->()) {
        if let metadata = metadata {
            let downloadTask = URLSession.shared.downloadTask(with: metadata.pdfDownloadURL, completionHandler: { (temporaryURL, response, error) in
                if let error = error {
                    print("SO SAD - failed downloading pdf: \(error)")
                    completed(Result.failure(error as NSError))
                    return
                } else {
                    print("YAY - downloaed pdf doc")
                    // Move the doc to a permanent location
                    let fileManager = FileManager.default
                    let directoryURL = fileManager.urls(for: .documentDirectory, in: .userDomainMask)[0]
                    // TODO: unify the places we do this sorta thing
                    let filename = "\(self.sessionURL.absoluteString.substring(from: self.sessionURL.absoluteString.characters.index(self.sessionURL.absoluteString.endIndex, offsetBy: -12)))_doc.pdf"
                    let copyURL = directoryURL.appendingPathComponent(filename)
                    
                    if fileManager.fileExists(atPath: copyURL.path) {
                        do {
                            try fileManager.removeItem(at: copyURL)
                        } catch let error {
                            print("Couldn't remove old doc: \(error)")
                        }
                    }
                    
                    do {
                        if let temporaryURL = temporaryURL {
                            try fileManager.copyItem(at: temporaryURL, to: copyURL)
                        }
                    } catch let error {
                        print("Couldn't copy new doc file: \(error)")
                    }
                    
                    completed(.success(copyURL))
                }
            }) 
            downloadTask.resume()
        }
    }
    
    
    
    func getAnnotations(_ completed: @escaping (AnnotationsResult)->()) {
        let url = sessionURL.appendingPathComponent("annotations")
        let request = URLRequest(url: url)
        let completion: (Data?, URLResponse?, Error?) -> Void = { (data, response, error) in
            if let error = error {
                print("SO SAD - failed fetching annotations: \(error)")
                completed(Result.failure(error as NSError))
                return
            } else {
                if let data = data {
                    do {
                        let decoder = JSONDecoder()
                        decoder.dateDecodingStrategy = .custom { decoder in
                            let dateStr = try decoder.singleValueContainer().decode(String.self)
                            guard let date = CanvadocsAnnotationService.ISO8601MillisecondFormatter.date(from: dateStr) else {
                                throw NSError(domain: "com.instructure.annotations", code: -1, userInfo: [NSLocalizedFailureReasonErrorKey: "Invalid date received from API"])
                            }
                            return date
                        }
                        let data = try decoder.decode(CanvadocsAnnotationList.self, from: data)
                        completed(.success(data.data))
                    } catch let error as NSError {
                        completed(.failure(error))
                    }
                } else if let error = error{
                    completed(.failure(error as NSError))
                }
            }
        }
        let dataTask = URLSession.shared.dataTask(with: request, completionHandler: completion)
        dataTask.resume()
    }
    
    func upsertAnnotation(_ annotation: CanvadocsAnnotation, completed: @escaping (Result<CanvadocsAnnotation, CanvadocsAnnotationError>) ->()) {
        guard let annotationID = annotation.id else { return }
        let url = sessionURL.appendingPathComponent("annotations").appendingPathComponent(annotationID)
        var request = URLRequest(url: url)
        request.httpMethod = "PUT"
        request.setValue("application/json", forHTTPHeaderField: "Accept")
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        let encoder = JSONEncoder()
        do {
            let json = try encoder.encode(annotation)
            guard json.count < CanvadocsServerAnnotationSizeLimit else {
                completed(.failure(CanvadocsAnnotationError.tooBig))
                return
            }
            request.httpBody = json
        } catch {
            completed(.failure(.nsError(error as NSError)))
            return
        }
        
        let dataTask = URLSession.shared.dataTask(with: request) { (data, response, error) in
            if let data = data {
                do {
                    let decoder = JSONDecoder()
                    decoder.dateDecodingStrategy = .custom { decoder in
                        let dateStr = try decoder.singleValueContainer().decode(String.self)
                        guard let date = CanvadocsAnnotationService.ISO8601MillisecondFormatter.date(from: dateStr) else {
                            throw NSError(domain: "com.instructure.annotations", code: -1, userInfo: [NSLocalizedFailureReasonErrorKey: "Invalid date received from API"])
                        }
                        return date
                    }
                    let annotation = try decoder.decode(CanvadocsAnnotation.self, from: data)
                    completed(.success(annotation))
                } catch let error as NSError {
                    completed(.failure(.nsError(error)))
                }
            } else if let error = error {
                completed(.failure(.nsError(error as NSError)))
            }
        }
        dataTask.resume()
    }
    
    func deleteAnnotation(_ annotation: CanvadocsAnnotation, completed: @escaping (Result<Bool, NSError>)->()) {
        guard let annotationID = annotation.id else { return }
        let url = sessionURL.appendingPathComponent("annotations").appendingPathComponent(annotationID)
        var request = URLRequest(url: url)
        request.httpMethod = "DELETE"
        
        let dataTask = URLSession.shared.dataTask(with: request) { (data, response, error) in
            if let error = error {
                completed(.failure(error as NSError))
            } else {
                completed(.success(true))
            }
        }
        dataTask.resume()
    }
}

