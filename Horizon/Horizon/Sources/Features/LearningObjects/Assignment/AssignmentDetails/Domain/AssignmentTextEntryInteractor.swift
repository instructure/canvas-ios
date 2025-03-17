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

import Core
import Foundation

protocol AssignmentTextEntryInteractor {
    func save(_ text: String)
    func load() -> AssignmentTextEntryModel?
    func delete()
}

final class AssignmentTextEntryInteractorLive: AssignmentTextEntryInteractor {
    // MARK: - Dependencies

    private let courseID: String
    private let assignmentID: String
    private var userDefaults: SessionDefaults?
    private let key: String

    // MARK: - Init

    init(
        courseID: String,
        assignmentID: String,
        userDefaults: SessionDefaults?
    ) {
        self.courseID = courseID
        self.assignmentID = assignmentID
        self.userDefaults = userDefaults
        self.key = "\(courseID)-\(assignmentID)"
    }

    func save(_ text: String) {
        guard text.isNotEmpty else {
            delete()
            return
        }
        let model = AssignmentTextEntryModel(text: text)
        if userDefaults?.assignmentSubmissionTextEntry == nil {
            userDefaults?.assignmentSubmissionTextEntry = [key: model.encode]
        } else {
            userDefaults?.assignmentSubmissionTextEntry?[key] = model.encode
        }
    }

    func load() -> AssignmentTextEntryModel? {
        guard let value = userDefaults?.assignmentSubmissionTextEntry?[key] else {
            return nil
        }
        let model: AssignmentTextEntryModel? = value.decoded()
        return model
    }

    func delete() {
        userDefaults?.assignmentSubmissionTextEntry?[key] = nil
    }
}

struct AssignmentTextEntryModel: Codable {
    let text: String
    let date: Date

    fileprivate init(
        text: String,
        date: Date = Date()
    ) {
        self.text = text
        self.date = date
    }

    var dateFormated: String {
        date.formatted(format: "d/MM, h:mm a")
    }
}

// MARK: - Helpers

private extension String {
    func decoded<T: Decodable>() -> T? {
        let decoder = JSONDecoder()
        if let data = data(using: .utf8) {
            return try? decoder.decode(T.self, from: data)
        }
        return nil
    }
}

private extension Encodable {
    var encode: String {
        let encoder = JSONEncoder()
        if let encode = try? encoder.encode(self) {
            return String(data: encode, encoding: .utf8) ?? ""
        }
        return ""
    }
}
