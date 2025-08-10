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

enum AssistChatDocumentType: String, Codable, CaseIterable {
    case pdf
    case csv
    case docx
    case doc
    case xlsx
    case xls
    case html
    case txt
    case md

    static func from(mimeType: String?) -> AssistChatDocumentType? {
        [
            "text/plain": AssistChatDocumentType.txt,
            "text/html": AssistChatDocumentType.html,
            "text/csv": AssistChatDocumentType.csv,
            "application/pdf": AssistChatDocumentType.pdf,
            "application/msword": AssistChatDocumentType.doc,
            "application/vnd.openxmlformats-officedocument.wordprocessingml.document": AssistChatDocumentType.docx,
            "application/vnd.ms-excel": AssistChatDocumentType.xls,
            "application/vnd.openxmlformats-officedocument.spreadsheetml.sheet": AssistChatDocumentType.xlsx
        ][mimeType ?? ""]
    }
}
