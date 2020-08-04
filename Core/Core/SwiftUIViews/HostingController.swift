//
// This file is part of Canvas.
// Copyright (C) 2020-present  Instructure, Inc.
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

@available(iOSApplicationExtension 13.0.0, *)
public class CoreHostingController<InnerContent: View>: UIHostingController<CoreHostingBaseView<InnerContent>> {

    public init(_ rootView: InnerContent, env: AppEnvironment = .shared) {
        let selfBox = Box()
        super.init(rootView: CoreHostingBaseView(rootView: rootView, env: env) {
            selfBox.value
        })
        selfBox.value = self
    }

    @objc required dynamic init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }

    private class Box {
        weak var value: UIViewController?
        init() { }
    }
}

@available(iOSApplicationExtension 13.0.0, *)
public struct CoreHostingBaseView<Content: View>: View {
    var rootView: Content
    let env: AppEnvironment
    let controller: () -> UIViewController?

    public var body: some View {
        rootView
            .environment(\.appEnvironment, env)
            .environment(\.viewController, controller)
    }
}
