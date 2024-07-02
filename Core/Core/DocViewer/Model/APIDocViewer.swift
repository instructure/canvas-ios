//
// This file is part of Canvas.
// Copyright (C) 2018-present  Instructure, Inc.
//
// This program is free software: you can redistribute it and/or modify
// it under the terms of the GNU Affero General Public License as
// published by the Free Software Foundation, either version 3 of the
// License, or (at your option) any later version.
//
// This program is distributed in the hope that it will be useful,
// but WITHOUT ANY WARRANTY; without even the implied warranty of
// MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
// GNU Affero General Public License for more details.
//
// You should have received a copy of the GNU Affero General Public License
// along with this program.  If not, see <https://www.gnu.org/licenses/>.
//

import Foundation

struct APIDocViewerMetadata: Codable, Equatable {
    let annotations: APIDocViewerAnnotationsMetadata?
    let panda_push: APIDocViewerPandaPushMetadata?
    let rotations: [String: UInt]?
    let urls: APIDocViewerURLsMetadata
}

struct APIDocViewerAnnotationsMetadata: Codable, Equatable {
    let enabled: Bool
    let user_id: String?
    let user_name: String?
    let permissions: APIDocViewerPermissions
}

// https://canvadocs.instructure.com/docs/docs/sessionModes.html
public enum APIDocViewerPermissions: String, Codable {
    case none, read, readwrite, readwritemanage
}

struct APIDocViewerPandaPushMetadata: Codable, Equatable {
    let host: String
    let annotations_channel: String?
    let annotations_token: String?
    let document_channel: String?
    let document_token: String?
}

struct APIDocViewerURLsMetadata: Codable, Equatable {
    let pdf_download: URL
}

// https://canvadocs.instructure.com/docs/docs/annotationsApi.html#responses
struct APIDocViewerAnnotations: Codable, Equatable {
    let data: [APIDocViewerAnnotation]
}

// https://canvadocs.instructure.com/docs/docs/annotationsApi.html#
struct APIDocViewerAnnotation: Codable, Equatable, Comparable {
    let id: String
    let document_id: String?
    let user_id: String?
    let user_name: String
    let page: UInt
    let created_at: Date?
    let modified_at: Date?
    let deleted: Bool?
    let deleted_at: Date?
    let deleted_by: String?
    let deleted_by_id: String?
    let type: APIDocViewerAnnotationType
    let color: String?
    let bgColor: String?
    let icon: String?
    let contents: String?
    let inreplyto: String?
    let coords: [[[Double]]]?
    var rect: [[Double]]?
    let font: String?
    let inklist: APIDocViewerInklist?
    var width: Double?

    static func < (lhs: APIDocViewerAnnotation, rhs: APIDocViewerAnnotation) -> Bool {
        guard let lhsCreationDate = lhs.created_at, let rhsCreationDate = rhs.created_at else {
            return false
        }

        return lhsCreationDate < rhsCreationDate
    }
}

public enum APIDocViewerAnnotationType: String, Codable {
    case commentReply, freetext, highlight, ink, square, strikeout, text
}

struct APIDocViewerInklist: Codable, Equatable {
    let gestures: [[APIDocViewerInkPoint]]
}

public struct APIDocViewerInkPoint: Codable, Equatable {
    public let x: Double
    public let y: Double
    public let width: Double?
    public let opacity: Double?

    public init(x: Double, y: Double, width: Double?, opacity: Double?) {
        self.x = x
        self.y = y
        self.width = width
        self.opacity = opacity
    }
}

public enum APIDocViewerError: Error, Equatable {
    case tooBig
    case noData
    case badDateFormat(String)
}

#if DEBUG
extension APIDocViewerAnnotation {
    public static func make(
        id: String = "1",
        document_id: String? = nil,
        user_id: String? = "1",
        user_name: String = "a",
        page: UInt = 0,
        created_at: Date? = nil,
        modified_at: Date? = nil,
        deleted: Bool? = nil,
        deleted_at: Date? = nil,
        deleted_by: String? = nil,
        deleted_by_id: String? = nil,
        type: APIDocViewerAnnotationType = .text,
        color: String? = nil,
        bgColor: String? = nil,
        icon: String? = nil,
        contents: String? = "contents",
        inreplyto: String? = nil,
        coords: [[[Double]]]? = nil,
        rect: [[Double]]? = nil,
        font: String? = nil,
        inklist: APIDocViewerInklist? = nil,
        width: Double? = nil
    ) -> APIDocViewerAnnotation {
        return APIDocViewerAnnotation(
            id: id,
            document_id: document_id,
            user_id: user_id,
            user_name: user_name,
            page: page,
            created_at: created_at,
            modified_at: modified_at,
            deleted: deleted,
            deleted_at: deleted_at,
            deleted_by: deleted_by,
            deleted_by_id: deleted_by_id,
            type: type,
            color: color,
            bgColor: bgColor,
            icon: icon,
            contents: contents,
            inreplyto: inreplyto,
            coords: coords,
            rect: rect,
            font: font,
            inklist: inklist,
            width: width
        )
    }
}

extension APIDocViewerMetadata {
    public static func make(
        annotations: APIDocViewerAnnotationsMetadata? = .make(),
        panda_push: APIDocViewerPandaPushMetadata? = nil,
        rotations: [String: UInt]? = nil,
        urls: APIDocViewerURLsMetadata = .make()
    ) -> APIDocViewerMetadata {
        return APIDocViewerMetadata(
            annotations: annotations,
            panda_push: panda_push,
            rotations: rotations,
            urls: urls
        )
    }
}

extension APIDocViewerAnnotationsMetadata {
    public static func make(
        enabled: Bool = true,
        user_id: String? = "1",
        user_name: String? = "Bob",
        permissions: APIDocViewerPermissions = .readwritemanage
    ) -> APIDocViewerAnnotationsMetadata {
        return APIDocViewerAnnotationsMetadata(
            enabled: enabled,
            user_id: user_id,
            user_name: user_name,
            permissions: permissions
        )
    }
}

extension APIDocViewerURLsMetadata {
    public static func make(
        pdf_download: URL = URL(string: "download")!
    ) -> APIDocViewerURLsMetadata {
        return APIDocViewerURLsMetadata(
            pdf_download: pdf_download
        )
    }
}
#endif

struct GetDocViewerMetadataRequest: APIRequestable {
    typealias Response = APIDocViewerMetadata

    let path: String // DocViewer sessionURL

    let headers: [String: String?] = [
        HttpHeader.accept: "application/json",
        HttpHeader.authorization: nil
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
        HttpHeader.authorization: nil
    ]

    static var decoder: JSONDecoder = {
        let decoder = JSONDecoder()
        let formatter1 = ISO8601DateFormatter()
        formatter1.formatOptions = [ .withInternetDateTime, .withFractionalSeconds ]
        // This is mainly to support mocking because when the mock encodes APIDocViewerAnnotations it doesn't add franctions so response parsing fails.
        let formatter2 = ISO8601DateFormatter()
        formatter2.formatOptions = [ .withInternetDateTime]
        decoder.dateDecodingStrategy = .custom { decoder in
            let dateStr = try decoder.singleValueContainer().decode(String.self)
            guard let date = (formatter1.date(from: dateStr) ?? formatter2.date(from: dateStr)) else {
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
        HttpHeader.authorization: nil
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
        HttpHeader.authorization: nil
    ]
}

public struct CanvaDocsSessionRequest: APIRequestable {
    public static let DraftAttempt = "draft"
    public struct RequestBody: Encodable, Equatable {
        let submission_attempt: String
        let submission_id: String
    }
    public struct ResponseBody: Codable {
        public let annotation_context_launch_id: String?
        public let canvadocs_session_url: APIURL?
    }
    public typealias Response = ResponseBody
    public typealias Body = RequestBody

    public let body: Body?
    public let method = APIMethod.post
    public let path = "canvadoc_session"

    /**
     - parameters:
        - attempt: Use `CanvaDocsSessionRequest.DraftAttempt` to create a new annotation context for a new submission, otherwise use the index of the submission attempt: "1", "2", ... to retrieve the context for that particular attempt.
     */
    public init(submissionId: String, attempt: String = DraftAttempt) {
        self.body = RequestBody(submission_attempt: attempt, submission_id: submissionId)
    }
}
