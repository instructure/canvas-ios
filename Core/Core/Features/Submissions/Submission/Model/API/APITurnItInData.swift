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

public struct APITurnItInData: Codable, Equatable {
    let rawValue: [String: Item]

    struct DynamicCodingKeys: CodingKey {
        var stringValue: String
        init?(stringValue: String) {
            self.stringValue = stringValue
        }

        var intValue: Int?
        init?(intValue: Int) {
            return nil
        }
    }

    init(rawValue: [String: Item]) {
        self.rawValue = rawValue
    }

    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: DynamicCodingKeys.self)
        var data: [String: Item] = [:]
        for key in container.allKeys {
            if let codingKey = DynamicCodingKeys(stringValue: key.stringValue),
               let turnItIn = try? container.decode(Item.self, forKey: codingKey) {
                data[key.stringValue] = turnItIn
            }
        }
        self.rawValue = data
    }
}

extension APITurnItInData {
    public struct Item: Codable, Equatable {
        let status: String
        let similarity_score: Double?
        let outcome_response: Outcome?

        public struct Outcome: Codable, Equatable {
            let outcomes_tool_placement_url: APIURL?
        }
    }
}

#if DEBUG

extension APITurnItInData.Item {
    public static func make(
        status: String = "scored",
        similarity_score: Double? = 86,
        outcome_response: Outcome? = .make()
    ) -> Self {
        .init(
            status: status,
            similarity_score: similarity_score,
            outcome_response: outcome_response
        )
    }
}

extension APITurnItInData.Item.Outcome {
    public static func make(outcomes_tool_placement_url: URL? = nil) -> Self {
        .init(outcomes_tool_placement_url: APIURL(rawValue: outcomes_tool_placement_url))
    }
}

#endif
