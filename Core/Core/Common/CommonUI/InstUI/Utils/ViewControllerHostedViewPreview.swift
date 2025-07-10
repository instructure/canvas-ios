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

#if DEBUG

import SwiftUI
import UIKit

/// This wrapper can be used to preview SwiftUI views that interact with their host UIViewController (like presenting an alert on it).
public struct ViewControllerHostedViewPreview<Content: View>: UIViewControllerRepresentable {
    private let content: () -> Content

    public init(@ViewBuilder content: @escaping () -> Content) {
        self.content = content
    }

    public func makeUIViewController(context: Self.Context) -> UIViewController {
        CoreHostingController(content())
    }

    public func updateUIViewController(
        _ uiViewController: UIViewController,
        context: Self.Context
    ) {}
}

#endif
