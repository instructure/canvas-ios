//
// This file is part of Canvas.
// Copyright (C) 2019-present  Instructure, Inc.
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

public struct APIMediaComment: Codable, Equatable {
    let content_type: String
    let display_name: String?
    let media_id: String
    let media_type: String // "audio", "video", "video/*"
    let url: URL

    enum CodingKeys: String, CodingKey {
        case content_type = "content-type"
        case display_name = "display_name"
        case media_id = "media_id"
        case media_type = "media_type"
        case url = "url"
    }
}

// https://canvas.instructure.com/doc/api/services.html#method.services_api.show_kaltura_config
struct APIMediaService: Codable {
    let domain: String
}

// https://canvas.instructure.com/doc/api/services.html#method.services_api.start_kaltura_session
struct APIMediaSession: Codable {
    let ks: String
}

struct APIMediaIDWrapper: Codable {
    let id: String
}

#if DEBUG
extension APIMediaComment {
    public static func make(
        content_type: String = "video/mp4",
        display_name: String? = "Submission",
        media_id: String = "m-1234567890",
        media_type: MediaCommentType = .video,
        url: URL = URL(string: "https://google.com")!
    ) -> APIMediaComment {
        return APIMediaComment(
            content_type: content_type,
            display_name: display_name,
            media_id: media_id,
            media_type: media_type.rawValue,
            url: url
        )
    }
}
#endif

// https://canvas.instructure.com/doc/api/services.html#method.services_api.show_kaltura_config
struct GetMediaServiceRequest: APIRequestable {
    typealias Response = APIMediaService
    let path = "services/kaltura"
}

// https://canvas.instructure.com/doc/api/services.html#method.services_api.start_kaltura_session
struct PostMediaSessionRequest: APIRequestable {
    typealias Response = APIMediaSession
    let method = APIMethod.post
    let path = "services/kaltura_session"
}

struct PostMediaUploadTokenRequest: APIRequestable {
    typealias Response = APIMediaIDWrapper
    struct Body: Encodable {
        let ks: String
    }

    let method = APIMethod.post
    let headers: [String: String?] = [
        HttpHeader.accept: "application/xml"
    ]
    let path = "/api_v3/index.php"
    let query: [APIQueryItem] = [
        .value("service", "uploadtoken"),
        .value("action", "add")
    ]
    let body: Body?

    func decode(_ data: Data) throws -> APIMediaIDWrapper {
        let finder = MediaIDFinder()
        let parser = XMLParser(data: data)
        parser.delegate = finder
        parser.parse()
        return APIMediaIDWrapper(id: finder.id)
    }
}

struct PostMediaUploadRequest: APIRequestable {
    typealias Response = APINoContent

    let fileURL: URL
    let type: MediaCommentType
    let ks: String
    let token: String

    let cachePolicy = URLRequest.CachePolicy.reloadIgnoringLocalAndRemoteCacheData
    let method = APIMethod.post
    let headers: [String: String?] = [
        HttpHeader.accept: nil
    ]
    let path = "/api_v3/index.php"
    var query: [APIQueryItem] {
        return [
            .value("service", "uploadtoken"),
            .value("action", "upload"),
            .value("uploadTokenId", token),
            .value("ks", ks)
        ]
    }
    var form: APIFormData? {
        return [
            (
                key: "fileData",
                value: type == .audio
                    ? APIFormDatum.file(filename: "audiocomment.m4a", type: "audio/x-m4a", at: fileURL)
                    : APIFormDatum.file(filename: "videocomment.mp4", type: "video/mp4", at: fileURL)
            )
        ]
    }
}

struct PostMediaIDRequest: APIRequestable {
    typealias Response = APIMediaIDWrapper
    struct Body: Encodable {
        let name: String = "Media Comment"
        let mediaType: MediaCommentType

        enum CodingKeys: String, CodingKey {
            case name = "mediaEntry:name"
            case mediaType = "mediaEntry:mediaType"
        }

        func encode(to encoder: Encoder) throws {
            var container = encoder.container(keyedBy: CodingKeys.self)
            try container.encode(name, forKey: .name)
            try container.encode(mediaType == .audio ? "5" : "1", forKey: .mediaType)
        }
    }

    let ks: String
    let token: String
    let type: MediaCommentType

    let method = APIMethod.post
    let headers: [String: String?] = [
        HttpHeader.accept: "application/xml"
    ]
    let path = "/api_v3/index.php"
    var query: [APIQueryItem] {
        return [
            .value("service", "media"),
            .value("action", "addFromUploadedFile"),
            .value("uploadTokenId", token),
            .value("ks", ks)
        ]
    }
    var body: Body? {
        return Body(mediaType: type)
    }

    func decode(_ data: Data) throws -> APIMediaIDWrapper {
        let finder = MediaIDFinder()
        let parser = XMLParser(data: data)
        parser.delegate = finder
        parser.parse()
        return APIMediaIDWrapper(id: finder.id)
    }
}

class MediaIDFinder: NSObject, XMLParserDelegate {
    var id = ""
    func parser(_ parser: XMLParser, foundCharacters string: String) {
        if inIDElement { id += string }
    }

    var inIDElement = false
    func parser(_ parser: XMLParser, didStartElement elementName: String, namespaceURI: String?, qualifiedName qName: String?, attributes attributeDict: [String: String] = [:]) {
        inIDElement = elementName == "id"
    }
    func parser(_ parser: XMLParser, didEndElement elementName: String, namespaceURI: String?, qualifiedName qName: String?) {
        inIDElement = false
    }
}

struct PostCompleteMediaUploadRequest: APIRequestable {
    struct Response: Codable {
        struct MediaObject: Codable {
            let media_id: String
        }
        let media_object: MediaObject
    }

    struct Body: Encodable {
        let id: String
        let context_code: String
        let type: MediaCommentType
    }

    let mediaID: String
    let context: Context
    let type: MediaCommentType

    let path = "media_objects"
    var body: Body? {
        return Body(id: mediaID, context_code: context.canvasContextID, type: type)
    }
    let method = APIMethod.post
}
