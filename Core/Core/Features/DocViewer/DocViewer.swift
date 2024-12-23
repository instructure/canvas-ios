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

public struct DocViewer: UIViewControllerRepresentable {
    @Environment(\.appEnvironment) private var env

    public let filename: String
    public let previewURL: URL?
    public let fallbackURL: URL

    public init(filename: String, previewURL: URL?, fallbackURL: URL) {
        self.filename = filename
        self.previewURL = previewURL
        self.fallbackURL = fallbackURL
    }

    public func makeUIViewController(context: Self.Context) -> UIViewController { UIViewController() }

    public func updateUIViewController(_ uiViewController: UIViewController, context: Self.Context) {
        let prev = uiViewController.children.first as? DocViewerViewController
        if prev?.filename != filename || prev?.previewURL != previewURL || prev?.fallbackURL != fallbackURL {
            prev?.unembed()
            let next = DocViewerViewController.create(
                env: env,
                filename: filename,
                previewURL: previewURL,
                fallbackURL: fallbackURL
            )
            next.isAnnotatable = true
            uiViewController.embed(next, in: uiViewController.view)
        }
    }
}
