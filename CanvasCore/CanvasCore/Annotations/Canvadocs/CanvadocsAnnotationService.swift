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
import Result

struct CanvadocsFileMetadata {
    let pdfDownloadURL: URL
    let annotationMetadata: CanvadocsAnnotationMetadata
    let pandaPush: PandaPushMetadata?
}

struct CanvadocsAnnotationMetadata {
    enum Permissions: String {
        case None = "none"
        case Read = "read"
        case ReadWrite = "readwrite"
        case ReadWriteManage = "readwritemanage"
    }
    
    let enabled: Bool
    let userID: String?
    let userName: String?
    let permissions: Permissions?
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
    fileprivate let sessionID: String
    
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
        self.sessionID = sessionURL.lastPathComponent
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
        if path.first == "/" {
            return String(path.dropFirst())
        }
        return path
    }
    
    fileprivate func sessionBasedPDFFilename() -> String {
        let url = self.sessionURL.absoluteString
        let endIndex = url.index(url.endIndex, offsetBy: -12)
        let prefix = self.sessionURL.absoluteString.substring(from: endIndex)
        return "\(prefix)_doc.pdf"
    }
    
    fileprivate func genericError() -> NSError {
        let description = NSLocalizedString("An unexpected error has occurred.", tableName: nil, bundle: .core, value: "An unexpected error has occurred.", comment: "")
        return NSError(domain: "com.instructure.annotations", code: -1, userInfo: [NSLocalizedDescriptionKey: description])
    }
    
    func getMetadata(_ completed: @escaping (MetadataResult)->()) {
        let request = URLRequest(url: sessionURL)
        let genericError = self.genericError()
        let completion: (Data?, URLResponse?, Error?) -> Void = { (data, response, error) in
            if let error = error {
                return completed(.failure(error as NSError))
            }
            
            guard let data = data else {
                return completed(.failure(genericError))
            }
            
            do {
                let response = try JSONSerialization.jsonObject(with: data, options: JSONSerialization.ReadingOptions())
                guard let json = response as? [String: AnyObject], let urls = json["urls"] as? [String: AnyObject] else {
                    return completed(.failure(genericError))
                }
                
                var annotationMetadata: CanvadocsAnnotationMetadata?
                if let annotationSettings = json["annotations"] as? [String: AnyObject] {
                    let enabled = annotationSettings["enabled"] as? Bool ?? false
                    let userID = annotationSettings["user_id"] as? String
                    let userName = annotationSettings["user_name"] as? String
                    
                    var permissions: CanvadocsAnnotationMetadata.Permissions = .None
                    if let permissionsStr = annotationSettings["permissions"] as? String, let annotationPermissions = CanvadocsAnnotationMetadata.Permissions(rawValue: permissionsStr) {
                        permissions = annotationPermissions
                    }
                    
                    annotationMetadata = CanvadocsAnnotationMetadata(enabled: enabled, userID: userID, userName: userName, permissions: permissions)
                } else {
                    annotationMetadata = CanvadocsAnnotationMetadata(enabled: false, userID: nil, userName: nil, permissions: nil)
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
                    completed(.failure(genericError))
                }
                
            } catch let error as NSError {
                completed(.failure(error))
            }
        }
        let dataTask = URLSession.shared.dataTask(with: request, completionHandler: completion)
        dataTask.resume()
    }
    
    func getDocument(_ completed: @escaping (DocumentResult)->()) {
        let genericError = self.genericError()
        guard let metadata = metadata else {
            completed(Result.failure(genericError))
            return
        }
        let filename = sessionBasedPDFFilename()
        let downloadTask = URLSession.shared.downloadTask(with: metadata.pdfDownloadURL, completionHandler: { (temporaryURL, response, error) in
            if let error = error {
                return completed(Result.failure(error as NSError))
            }
            
            guard let tempURL = temporaryURL else {
                return completed(Result.failure(genericError))
            }
            
            // Move the doc to a permanent location
            let fileManager = FileManager.default
            let directoryURL = fileManager.urls(for: .documentDirectory, in: .userDomainMask)[0]
            let copyURL = directoryURL.appendingPathComponent(filename)
            
            if fileManager.fileExists(atPath: copyURL.path) {
                do {
                    try fileManager.removeItem(at: copyURL)
                } catch let error {
                    return completed(Result.failure(error as NSError))
                }
            }
            
            do {
                try fileManager.copyItem(at: tempURL, to: copyURL)
            } catch let error {
                return completed(Result.failure(error as NSError))
            }
            
            completed(.success(copyURL))
        })
        downloadTask.resume()
    }
    
    func getAnnotations(_ completed: @escaping (AnnotationsResult)->()) {
        guard let url = URL(string: "/2018-04-06/sessions/\(sessionID)/annotations", relativeTo: sessionURL) else {
            return
        }
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
                                let description = NSLocalizedString("Invalid date received from API.", tableName: nil, bundle: .core, value: "Invalid date received from API.", comment: "")
                                throw NSError(domain: "com.instructure.annotations", code: -1, userInfo: [NSLocalizedDescriptionKey: description])
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
        guard let url = URL(string: "/2018-03-07/sessions/\(sessionID)/annotations/\(annotationID)", relativeTo: sessionURL) else {
            return
        }
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
        guard let url = URL(string: "/1/sessions/\(sessionID)/annotations/\(annotationID)", relativeTo: sessionURL) else {
            return
        }
        var request = URLRequest(url: url)
        request.httpMethod = "DELETE"
        
        let dataTask = URLSession.shared.dataTask(with: request) { (data, response, error) in
            if let error = error {
                completed(.failure(error as NSError))
            } else if let http = response as? HTTPURLResponse, http.statusCode >= 400 {
                completed(.failure(NSError(domain: NSURLErrorDomain, code: http.statusCode, userInfo: [ "data": data as Any ])))
            } else {
                completed(.success(true))
            }
        }
        dataTask.resume()
    }
}

