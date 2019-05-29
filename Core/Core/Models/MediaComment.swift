//
// Copyright (C) 2019-present Instructure, Inc.
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
import CoreData

final public class MediaComment: NSManagedObject {
    @NSManaged public var contentType: String
    @NSManaged public var displayName: String?
    @NSManaged public var mediaID: String
    @NSManaged public var mediaTypeRaw: String
    @NSManaged public var url: URL

    public var mediaType: MediaCommentType {
        get { return MediaCommentType(rawValue: mediaTypeRaw) ?? .video }
        set { mediaTypeRaw = newValue.rawValue }
    }
}

extension MediaComment: WriteableModel {
    public typealias JSON = APIMediaComment

    @discardableResult
    public static func save(_ item: APIMediaComment, in context: NSManagedObjectContext) -> MediaComment {
        let model: MediaComment = context.insert()
        model.contentType = item.content_type
        model.displayName = item.display_name
        model.mediaID = item.media_id
        model.mediaType = item.media_type
        model.url = item.url
        return model
    }
}
