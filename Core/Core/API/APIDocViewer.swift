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

struct APIDocViewerMetadata: Codable {
    let annotations: APIDocViewerAnnotationsMetadata
    let panda_push: APIDocViewerPandaPushMetadata?
    let rotations: [String: UInt]?
    let urls: APIDocViewerURLsMetadata
}

struct APIDocViewerAnnotationsMetadata: Codable {
    let enabled: Bool
    let user_id: String?
    let user_name: String?
    let permissions: APIDocViewerPermissions
}

// https://canvadocs.instructure.com/docs/docs/sessionModes.html
enum APIDocViewerPermissions: String, Codable {
    case none, read, readwrite, readwritemanage
}

struct APIDocViewerPandaPushMetadata: Codable {
    let host: String
    let annotations_channel: String
    let annotations_token: String
}

struct APIDocViewerURLsMetadata: Codable {
    let pdf_download: URL
}

// https://canvadocs.instructure.com/docs/docs/annotationsApi.html#responses
struct APIDocViewerAnnotations: Codable {
    let data: [APIDocViewerAnnotation]
}

// https://canvadocs.instructure.com/docs/docs/annotationsApi.html#
struct APIDocViewerAnnotation: Codable, Equatable {
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
    let icon: String?
    let contents: String?
    let inreplyto: String?
    let coords: [[[Double]]]?
    let rect: [[Double]]?
    let font: String?
    let inklist: APIDocViewerInklist?
    let width: Double?
}

enum APIDocViewerAnnotationType: String, Codable {
    case commentReply, freetext, highlight, ink, square, strikeout, text
}

struct APIDocViewerInklist: Codable, Equatable {
    let gestures: [[APIDocViewerInkPoint]]
}

struct APIDocViewerInkPoint: Codable, Equatable {
    let x: Double
    let y: Double
    let width: Double?
    let opacity: Double?
}

enum APIDocViewerError: Error, Equatable {
    case tooBig
    case noData
    case badDateFormat(String)
}
