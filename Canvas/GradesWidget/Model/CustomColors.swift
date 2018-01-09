//
//  CustomColors.swift
//  GradesWidget
//
//  Created by Nathan Armstrong on 1/10/18.
//  Copyright © 2018 Instructure. All rights reserved.
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
