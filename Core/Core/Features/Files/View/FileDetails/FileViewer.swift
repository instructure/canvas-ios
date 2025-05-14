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

public struct FileViewer: UIViewControllerRepresentable {
    @Environment(\.appEnvironment) private var env

    public let fileID: String

    public init(fileID: String) {
        self.fileID = fileID
    }

    public func makeUIViewController(context: Self.Context) -> UIViewController { UIViewController() }

    public func updateUIViewController(_ uiViewController: UIViewController, context: Self.Context) {
        let prev = uiViewController.children.first as? FileDetailsViewController
        if prev?.fileID != fileID {
            prev?.unembed()
            let next = FileDetailsViewController.create(context: nil, fileID: fileID, environment: env)
            uiViewController.embed(next, in: uiViewController.view)
        }
    }
}
