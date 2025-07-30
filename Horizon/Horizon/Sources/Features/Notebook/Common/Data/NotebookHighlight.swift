//
// This file is part of Canvas.
// Copyright (C) 2025-present  Instructure, Inc.
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

public struct NotebookHighlight: Codable, Equatable {
    public let selectedText: String
    public let textPosition: TextPosition
    public let range: Range
    public let iconSVG: String

    public init(
        selectedText: String,
        textPosition: TextPosition,
        range: Range,
        iconSVG: String
    ) {
        self.selectedText = selectedText
        self.textPosition = textPosition
        self.range = range
        self.iconSVG = iconSVG
    }

    public struct TextPosition: Codable, Equatable {
        public let start: Int
        public let end: Int
    }

    public struct Range: Codable, Equatable {
        public let startContainer: String
        public let startOffset: Int
        public let endContainer: String
        public let endOffset: Int
    }
}
