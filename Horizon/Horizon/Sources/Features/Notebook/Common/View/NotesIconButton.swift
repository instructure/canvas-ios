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

struct NotesIconButton: View {
    // MARK: - Properties

    private let background: Color?
    private let onTap: () -> Void
    private let systemName: String?
    private let tint: Color?
    private let resource: ImageResource?

    // MARK: - Init

    init(
        systemName: String,
        background: Color = .backgroundLightest,
        tint: Color = .backgroundDark,
        onTap: @escaping () -> Void
    ) {
        self.background = background
        self.onTap = onTap
        self.systemName = systemName
        self.tint = tint

        resource = nil
    }

    init(
        resource: ImageResource,
        onTap: @escaping () -> Void
    ) {
        self.resource = resource
        self.onTap = onTap

        background = nil
        systemName = nil
        tint = nil
    }

    var body: some View {
        Button {
            onTap()
        } label: {
            if let resource = resource {
                Image(resource)
                    .frame(width: 40, height: 40)
                    .buttonStyles()
            } else if let systemName = systemName,
                      let background = background,
                      let tint = tint {
                Image(systemName: systemName)
                    .frame(width: 40, height: 40)
                    .tint(tint)
                    .background(background)
                    .buttonStyles()
            }
        }
    }
}

fileprivate extension View {
    func buttonStyles() -> some View {
        self
            .clipShape(.circle)
            .shadow(
                color: Color(red: 66 / 100, green: 54 / 100, blue: 36 / 100)
                    .opacity(0.12),
                radius: 2,
                x: 1,
                y: 2
            )
    }
}
