//
// This file is part of Canvas.
// Copyright (C) 2024-present  Instructure, Inc.
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

public struct APIStudioMediaItem: Codable, Equatable {
    public struct Caption: Codable, Equatable {
        /// Language of the caption
        public let srclang: String
        /// Custom label of the caption
        public let label: String
        /// Caption text in srt file format
        public let data: String
    }

    public let id: ID
    /// The id used when this media is embedded as an LTI tool. There is a 1:1 connection between this and the `id` property.
    public let lti_launch_id: String
    public let title: String
    public let mime_type: String
    public let size: Int
    /// Download URL of the media
    public let url: URL
    public let captions: [Caption]
}
