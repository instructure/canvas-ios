//
// Copyright (C) 2016-present Instructure, Inc.
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

enum Context: String {
    case course
    case group
}

struct CustomColors: Codable {
    enum CodingKeys: String, CodingKey {
        case customColors = "custom_colors"
    }

    struct CustomColorKey: CodingKey {
        var stringValue: String
        init?(stringValue: String) {
            self.stringValue = stringValue
        }

        var intValue: Int? { return nil }
        init?(intValue: Int) { return nil }
    }

    struct CustomColor {
        let context: Context
        let id: String
        let color: String
    }

    let customColors: [CustomColor]

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        let nestedContainer = try container.nestedContainer(keyedBy: CustomColorKey.self, forKey: .customColors)

        var customColors: [CustomColor] = []
        for key in nestedContainer.allKeys {
            let contextID = key.stringValue
            let color = try nestedContainer.decode(String.self, forKey: CustomColorKey(stringValue: contextID)!)
            if let rawContext = contextID.split(separator: "_").first, let context = Context(rawValue: String(rawContext)), let id = contextID.split(separator: "_").last {
                customColors.append(CustomColor(context: context, id: String(id), color: color))
            }
        }

        self.customColors = customColors
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CustomColorKey.self)
        for customColor in customColors {
            let key = CustomColorKey(stringValue: "\(customColor.context)_\(customColor.id)")!
            try container.encode(customColor.color, forKey: key)
        }
    }
}
