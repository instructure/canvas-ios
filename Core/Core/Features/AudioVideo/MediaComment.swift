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
import CoreData

final public class MediaComment: NSManagedObject, WriteableModel {
    public typealias JSON = APIMediaComment

    @NSManaged public var contentType: String
    @NSManaged public var displayName: String?
    @NSManaged public var mediaID: String
    @NSManaged public var mediaTypeRaw: String
    @NSManaged public var url: URL?

    public var mediaType: MediaCommentType {
        get { return MediaCommentType(rawValue: mediaTypeRaw) ?? .video }
        set { mediaTypeRaw = newValue.rawValue }
    }

    @discardableResult
    public static func save(_ item: APIMediaComment, in context: NSManagedObjectContext) -> MediaComment {
        let model: MediaComment = context.insert()
        model.contentType = item.content_type
        model.displayName = item.display_name
        model.mediaID = item.media_id
        model.mediaType = MediaCommentType(rawValue: item.media_type) ?? .video
        model.url = item.url
        return model
    }
}

public enum MediaCommentType: String, Codable {
    case audio, video
}
