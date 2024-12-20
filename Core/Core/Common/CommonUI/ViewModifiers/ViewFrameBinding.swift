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

public extension View {

    func bindFrame(
        id: String,
        coordinateSpace: CoordinateSpace,
        to binding: Binding<CGRect?>
    ) -> some View {
        self
            .saveFrame(
                id: id,
                coordinateSpace: coordinateSpace
            )
            .onPreferenceChange(ViewFrameByID.self) { framesByIDs in
                binding.wrappedValue = framesByIDs[id]
            }
    }

    func bindFrame(
        id: String,
        coordinateSpaceName: String,
        to binding: Binding<CGRect?>
    ) -> some View {
        self
            .bindFrame(
                id: id,
                coordinateSpace: .named(coordinateSpaceName),
                to: binding
            )
    }

    func bindTopPosition(
        id: String,
        coordinateSpace: CoordinateSpace,
        to binding: Binding<CGFloat?>
    ) -> some View {
        self
            .saveFrame(id: id, coordinateSpace: coordinateSpace)
            .onPreferenceChange(ViewFrameByID.self) { framesByIDs in
                binding.wrappedValue = framesByIDs[id]?.minY
            }
    }

    func bindTopPosition(
        id: String,
        coordinateSpaceName: String,
        to binding: Binding<CGFloat?>
    ) -> some View {
        self
            .bindTopPosition(
                id: id,
                coordinateSpace: .named(coordinateSpaceName),
                to: binding
            )
    }

    func onFrameChange(
        id: String,
        coordinateSpace: CoordinateSpace,
        _ callback: @escaping (CGRect) -> Void
    ) -> some View {
        self
            .saveFrame(id: id, coordinateSpace: coordinateSpace)
            .onPreferenceChange(ViewFrameByID.self) { framesByIDs in
                if let frame = framesByIDs[id] {
                    callback(frame)
                }
            }
    }

    private func saveFrame(
        id: String,
        coordinateSpace: CoordinateSpace
    ) -> some View {
        self
            .background(GeometryReader { geometry in
                Color.clear.preference(
                    key: ViewFrameByID.self,
                    value: [id: geometry.frame(in: coordinateSpace)]
                )
            })
    }
}
