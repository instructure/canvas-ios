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

public protocol SearchSupportAction {
    func trigger<Attrs: SearchViewAttributes>(
        for searchContext: SearchViewContext<Attrs>,
        with router: Router,
        from controller: UIViewController
    )
}

public struct SearchSupportVoidAction: SearchSupportAction {
    public func trigger<Attrs>(
        for searchContext: SearchViewContext<Attrs>,
        with router: Router,
        from controller: UIViewController
    ) where Attrs: SearchViewAttributes {}
}

public struct SearchSupportClosureAction: SearchSupportAction {

    let action: () -> Void
    public init(_ action: @escaping () -> Void) {
        self.action = action
    }

    public func trigger<Attrs>(
        for searchContext: SearchViewContext<Attrs>,
        with router: Router,
        from controller: UIViewController
    ) where Attrs: SearchViewAttributes {
        action()
    }
}

public struct SearchSupportSheetAction<Content: View>: SearchSupportAction {
    let content: () -> Content
    public init(content: @autoclosure @escaping () -> Content) {
        self.content = content
    }

    public func trigger<Attrs>(
        for searchContext: SearchViewContext<Attrs>,
        with router: Router,
        from controller: UIViewController
    ) where Attrs: SearchViewAttributes {
        router.show(
            CoreHostingController(
                SearchHostingBaseView(content: content(), searchContext: searchContext)
            ),
            from: controller,
            options: .modal(.formSheet, embedInNav: true)
        )
    }
}
