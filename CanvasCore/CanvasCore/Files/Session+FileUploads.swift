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

import ReactiveSwift
import Marshal

import CoreData

struct UploadTarget {
    let url: URL
    let parameters: JSONObject
    
    static func parse(json: JSONObject) -> SignalProducer<UploadTarget, NSError> {
        return attemptProducer {
            if let attachments: [JSONObject] = try json <| "attachments", let attachment = attachments.first {
                return try parse(json: attachment)
            }
            return try parse(json: json)
        }
    }

    private static func parse(json: JSONObject) throws -> UploadTarget {
        return UploadTarget(
            url: try json <| "upload_url",
            parameters: try json <| "upload_params"
        )
    }
}

private let FileUploadErrorTitle = NSLocalizedString("File Upload Error", tableName: "Localizable", bundle: .core, value: "", comment: "title for file upload errors")

private let MultipartBoundary = "---------------------------3klfenalksjflkjoi9auf89eshajsnl3kjnwal"

extension Session {

    public enum UploadProgress {
        case Progress(sent: Int64, total: Int64)
        case Completed(File)
        
        static func fromInternalProgress(p: InternalUploadProgress) -> SignalProducer<UploadProgress, NSError> {
            switch p {
            case let .BytesSent(sent: sent, total: total):
                return SignalProducer(value: .Progress(sent: sent, total: total))
            case .Completed(let file):
                return SignalProducer(value: .Completed(file))
            default:
                return SignalProducer.empty
            }
        }
    }

    enum InternalUploadProgress {
        case BytesSent(sent: Int64, total: Int64)
        case DataCompleted(NSURL)
        case Completed(File)
    }
    
    @objc func requestPostUploadTarget(path: String, fileName: String, size: Int, contentType: String?, folderPath: String?, overwrite: Bool) throws -> URLRequest {
        var parameters: [String: Any] = [
            "name": fileName,
            "size": size,
        ]
        
        if let c = contentType { parameters["content_type"] = c }
        if let f = folderPath { parameters["folder"] = f }
        if !overwrite { parameters["on_duplicate"] = "rename" }
        
        return try POST(path, parameters: parameters, encoding: .url)
    }
    
    func encodeMultipartBody(data: Data, parameters: [String: Any]) -> SignalProducer<Data, NSError> {
        return attemptProducer {
            let delim = try "--\(MultipartBoundary)\r\n".UTF8Data()
            
            var body = Data()
            body += delim
            for (key, value) in parameters {
                body += try "Content-Disposition: form-data; name=\"\(key)\"\r\n\r\n\(value)\r\n".UTF8Data()
                body += delim
            }

            let filename = parameters["filename"] as? String ?? ""
            body += try "Content-Disposition: form-data; name=\"file\"; filename=\"\(filename)\"\r\n\r\n".UTF8Data()
            body += data
            body += try "\r\n--\(MultipartBoundary)--\r\n".UTF8Data()
            
            return body
        }
    }

    func writeDataToFile(identifier: String) -> (Data) -> SignalProducer<URL, NSError> {
        return { data in
            let documentsPath = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0]
            let documentsURL = NSURL(fileURLWithPath: documentsPath, isDirectory: true)

            let fileName = identifier + ".tmp"

            let url = documentsURL.appendingPathComponent(fileName)

            return attemptProducer {
                try data.write(to: url!, options: .atomic)
            }.map { url! }
        }
    }

    func requestUploadFile(data: Data) -> (UploadTarget) -> SignalProducer<(URLRequest, URL), NSError> {
        return { target in
            let identifier = String(NSDate().timeIntervalSince1970)

            var request = URLRequest(url: target.url, cachePolicy: .reloadIgnoringLocalAndRemoteCacheData, timeoutInterval: 60)
            request.httpMethod = "POST"
            
            let contentType = "multipart/form-data; boundary=\"\(MultipartBoundary)\""
            request.addValue(contentType, forHTTPHeaderField: "Content-Type")
            
            let sessionID = self.sessionID
            
            return self.encodeMultipartBody(data: data, parameters: target.parameters)
                .mapError { (e: NSError)->NSError in
                    let description = NSLocalizedString("There was a problem preparing the file for upload", tableName: "Localizable", bundle: .core, value: "", comment: "File upload error message")
                    return NSError(subdomain: "FileKit", code: 0, sessionID: sessionID, apiURL: target.url, title: FileUploadErrorTitle, description: description, failureReason: e.localizedDescription)
                }
                .flatMap(.concat, self.writeDataToFile(identifier: identifier))
                .map { (request, $0) }
        }
    }
}

