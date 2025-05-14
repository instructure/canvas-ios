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

public extension InteractivePanda {
    struct Config: Equatable {
        public let scene: PandaScene
        public let title: String?
        public let subtitle: String?

        public init(
            scene: PandaScene,
            title: String? = nil,
            subtitle: String? = nil
        ) {
            self.scene = scene
            self.title = title
            self.subtitle = subtitle
        }

        public static func == (lhs: InteractivePanda.Config, rhs: InteractivePanda.Config) -> Bool {
            lhs.title == rhs.title && lhs.subtitle == rhs.subtitle
        }
    }
}

public extension InteractivePanda.Config {

    static func error(
        scene: PandaScene = (NoResultsPanda() as PandaScene),
        title: String = String(localized: "Something Went Wrong", bundle: .core),
        subtitle: String = String(localized: "Pull to refresh to try again", bundle: .core)
    ) -> Self {
        .init(
            scene: scene,
            title: title,
            subtitle: subtitle
        )
    }

    static func empty(
        scene: PandaScene = (SpacePanda() as PandaScene),
        title: String = String(localized: "This screen is empty", bundle: .core),
        subtitle: String = String(localized: "Pull to refresh to reload", bundle: .core)
    ) -> Self {
        .init(
            scene: scene,
            title: title,
            subtitle: subtitle
        )
    }
}
