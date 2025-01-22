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

import Foundation

struct HModuleItemLockMessage {
    let html: String

    func generate() -> String {
        if let dueDateMessage = extractDueDate() {
            return "Locked until \(dueDateMessage)"
        }
        let cleanedMessage = html.removeHTMLTags().removingHTMLEntities()
        return cleanedMessage.firstSentence
    }

    private func extractDueDate() -> String? {
        let datePattern = #"(\d{1,2} \w{3} at \d{1,2}:\d{2})"#
        if let dateRange = html.range(of: datePattern, options: .regularExpression) {
            return String(html[dateRange])
        }
        return nil
    }
}

fileprivate extension String {
    func removeHTMLTags() -> String {
        let regex = try? NSRegularExpression(pattern: "<[^>]+>", options: [])
        let range = NSRange(location: 0, length: self.utf16.count)
        let cleanedString = regex?.stringByReplacingMatches(in: self, options: [], range: range, withTemplate: "")
        return cleanedString ?? self
    }

    func removingHTMLEntities() -> String {
        guard let data = self.data(using: .utf8) else { return self }
        do {
            let attributedString = try NSAttributedString(data: data, options: [.documentType: NSAttributedString.DocumentType.html], documentAttributes: nil)
            return attributedString.string
        } catch {
            return self
        }
    }

    var firstSentence: String {
        let sentences = self.split { [".", "!", "?"].contains($0) }
            .map { $0.trimmingCharacters(in: .whitespacesAndNewlines) }
        return sentences.first ?? self
    }
}
