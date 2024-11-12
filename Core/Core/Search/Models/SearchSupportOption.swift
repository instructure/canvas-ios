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

import SwiftUI

public struct SearchSupportOption<Action: SearchSupportAction> {
    let action: Action
    let icon: SearchSupportIcon

    public init(action: Action, icon: SearchSupportIcon = .help) {
        self.action = action
        self.icon = icon
    }
}

// MARK: - Icon

public struct SearchSupportIcon {
    public static var help = SearchSupportIcon(image: .questionLine, uiImage: .questionLine)

    let image: () -> Image
    let uiImage: () -> UIImage?

    public init(image: @autoclosure @escaping () -> Image, uiImage: @autoclosure @escaping () -> UIImage?) {
        self.image = image
        self.uiImage = uiImage
    }
}

// MARK: - Actions

public protocol SearchSupportAction {
    func trigger<Info: SearchContextInfo>(
        for searchContext: CoreSearchContext<Info>,
        with router: Router,
        from controller: UIViewController
    )
}

public struct NoSearchSupportAction: SearchSupportAction {
    public func trigger<Info>(
        for searchContext: CoreSearchContext<Info>,
        with router: Router,
        from controller: UIViewController
    ) where Info : SearchContextInfo {}
}

public struct SearchSupportTrigger: SearchSupportAction {

    let action: () -> Void
    public init(_ action: @escaping () -> Void) {
        self.action = action
    }

    public func trigger<Info>(
        for searchContext: CoreSearchContext<Info>,
        with router: Router,
        from controller: UIViewController
    ) where Info: SearchContextInfo {
        action()
    }
}

public struct SearchSupportSheet<Content: View>: SearchSupportAction {
    let content: () -> Content
    public init(content: @autoclosure @escaping () -> Content) {
        self.content = content
    }

    public func trigger<Info>(
        for searchContext: CoreSearchContext<Info>,
        with router: Router,
        from controller: UIViewController
    ) where Info: SearchContextInfo {
        router.show(
            CoreHostingController(
                SearchHostingBaseView(content: content(), searchContext: searchContext)
            ),
            from: controller,
            options: .modal(.formSheet, embedInNav: true)
        )
    }
}
