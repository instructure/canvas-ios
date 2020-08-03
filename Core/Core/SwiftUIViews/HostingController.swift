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
public class HostingController<InnerContent: View>: UIHostingController<HostingControllerBaseView<InnerContent>> {
    public init(rootView: InnerContent) {
        let selfBox = Box()
        super.init(rootView: HostingControllerBaseView(rootView: rootView, controller: { selfBox.value }))
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
public struct HostingControllerBaseView<Content: View>: View {
    public let rootView: Content
    let controller: () -> UIViewController?

    public var body: some View {
        rootView.environment(\.viewController, controller)
    }
}
