//
// This file is part of Canvas.
// Copyright (C) 2023-present  Instructure, Inc.
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

@testable import Core
import XCTest

class GradingSchemeTestCase: CoreTestCase {

    func scoreConversionEntries() -> [GradingSchemeEntry] {
        [
            makeEntry(name: "A", value: 0.9),
            makeEntry(name: "B", value: 0.3),
            makeEntry(name: "F", value: 0)
        ]
    }

    func invalidConversionEntries() -> [GradingSchemeEntry] {
        [makeEntry(name: "A", value: 90)]
    }

    func makeEntry(name: String = "", value: Double = 0) -> GradingSchemeEntry {
        let entry: GradingSchemeEntry = databaseClient.insert()
        entry.name = name
        entry.value = value
        return entry
    }
}
