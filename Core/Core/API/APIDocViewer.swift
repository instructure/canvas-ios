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
    let bgColor: String?
    let icon: String?
    let contents: String?
    let inreplyto: String?
    let coords: [[[Double]]]?
    let rect: [[Double]]?
    let font: String?
    let inklist: APIDocViewerInklist?
    let width: Double?
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
