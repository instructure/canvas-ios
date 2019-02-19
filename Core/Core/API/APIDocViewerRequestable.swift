//
// Copyright (C) 2018-present Instructure, Inc.
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

struct GetDocViewerMetadataRequest: APIRequestable {
    typealias Response = APIDocViewerMetadata

    let path: String // DocViewer sessionURL

    let headers: [String: String?] = [
        HttpHeader.accept: "application/json",
        HttpHeader.authorization: nil,
    ]
}

// https://canvadocs.instructure.com/docs/docs/annotationsApi.html#get-all-annotations-for-a-document
struct GetDocViewerAnnotationsRequest: APIRequestable {
    typealias Response = APIDocViewerAnnotations

    let sessionID: String

    var path: String {
        return "/2018-04-06/sessions/\(sessionID)/annotations"
    }

    let headers: [String: String?] = [
        HttpHeader.accept: "application/json",
        HttpHeader.authorization: nil,
    ]

    static var decoder: JSONDecoder = {
        let decoder = JSONDecoder()
        let formatter = ISO8601DateFormatter()
        formatter.formatOptions = [ .withInternetDateTime, .withFractionalSeconds ]
        decoder.dateDecodingStrategy = .custom { decoder in
            let dateStr = try decoder.singleValueContainer().decode(String.self)
            guard let date = formatter.date(from: dateStr) else {
                throw APIDocViewerError.badDateFormat(dateStr)
            }
            return date
        }
        return decoder
    }()

    func decode(_ data: Data) throws -> APIDocViewerAnnotations {
        return try GetDocViewerAnnotationsRequest.decoder.decode(APIDocViewerAnnotations.self, from: data)
    }
}

// https://canvadocs.instructure.com/docs/docs/annotationsApi.html#create-or-update-an-annotation
struct PutDocViewerAnnotationRequest: APIRequestable {
    typealias Response = APIDocViewerAnnotation
    typealias Body = APIDocViewerAnnotation

    let body: Body?
    let sessionID: String

    let method = APIMethod.put

    var path: String {
        return "/2018-03-07/sessions/\(sessionID)/annotations/\(body?.id ?? "")"
    }

    let headers: [String: String?] = [
        HttpHeader.accept: "application/json",
        HttpHeader.authorization: nil,
    ]

    func encode(_ body: Body) throws -> Data {
        let encoder = JSONEncoder()
        encoder.dateEncodingStrategy = .iso8601
        let value = try encoder.encode(body)
        guard value.count < PutDocViewerAnnotationRequest.SizeLimit else {
            throw APIDocViewerError.tooBig
        }
        return value
    }

    func decode(_ data: Data) throws -> APIDocViewerAnnotation {
        return try GetDocViewerAnnotationsRequest.decoder.decode(APIDocViewerAnnotation.self, from: data)
    }

    static let SizeLimit = 400_000 // Bytes
}

// https://canvadocs.instructure.com/docs/docs/annotationsApi.html#delete-an-annotation
struct DeleteDocViewerAnnotationRequest: APIRequestable {
    typealias Response = APINoContent

    let annotationID: String
    let sessionID: String

    let method = APIMethod.delete

    var path: String {
        return "/1/sessions/\(sessionID)/annotations/\(annotationID)"
    }

    let headers: [String: String?] = [
        HttpHeader.accept: "application/json",
        HttpHeader.authorization: nil,
    ]
}
