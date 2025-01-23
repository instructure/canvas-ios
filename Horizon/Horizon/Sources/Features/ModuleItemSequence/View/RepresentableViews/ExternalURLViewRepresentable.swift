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

import SwiftUI
import Core

struct ExternalURLViewRepresentable: UIViewControllerRepresentable {
    // MARK: - Dependencies

    private let environment: AppEnvironment
    private let name: String
    private let url: URL
    private let courseID: String?

    init(
        environment: AppEnvironment,
        name: String,
        url: URL,
        courseID: String?
    ) {
        self.environment = environment
        self.name = name
        self.url = url
        self.courseID = courseID
    }

    func makeUIViewController(context: Self.Context) -> ExternalURLViewController {
        ExternalURLViewController.create(
            env: environment,
            name: name,
            url: url,
            courseID: courseID
        )
    }

    func updateUIViewController(
        _ uiViewController: ExternalURLViewController,
        context: Self.Context
    ) { }
}
