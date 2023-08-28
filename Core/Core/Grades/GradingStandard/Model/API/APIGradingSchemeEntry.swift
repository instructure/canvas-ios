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

import Foundation

public struct APIGradingSchemeEntry: Codable, Equatable {
    public let name: String
    public let value: Double

    public init(name: String, value: Double) {
        self.name = name
        self.value = value
    }

    /**
     This initializer is used when constructing grading scheme from a Course API response
     which has a different format compared to the grading scheme API.
     */
    public init?(courseGradingScheme: [TypeSafeCodable<String, Double>]) {
        guard courseGradingScheme.count == 2,
              let name = courseGradingScheme[0].value1,
              let value = courseGradingScheme[1].value2
        else { return nil }
        self.init(name: name, value: value)
    }
}
