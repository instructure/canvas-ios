//
// This file is part of Canvas.
// Copyright (C) 2026-present  Instructure, Inc.
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

import Core
import SwiftUI

struct DashboardThumbnailCard<Thumbnail: View, Labels: View, Accessory: View>: View {

    private let thumbnail: Thumbnail
    private let labels: Labels
    private let accessory: Accessory
    @Binding var isAvailable: Bool
    private let action: () -> Void

    public init(
        @ViewBuilder thumbnail: () -> Thumbnail,
        @ViewBuilder labels: () -> Labels,
        @ViewBuilder accessory: () -> Accessory = { SwiftUI.EmptyView() },
        isAvailable: Binding<Bool>,
        action: @escaping () -> Void
    ) {
        self.thumbnail = thumbnail()
        self.labels = labels()
        self.accessory = accessory()
        self._isAvailable = isAvailable
        self.action = action
    }

    var body: some View {
        PrimaryButton(isAvailable: $isAvailable, action: action) {
            HStack(alignment: .center, spacing: 0) {
                thumbnail
                    .clipShape(RoundedRectangle(cornerRadius: 22))
                    .frame(maxHeight: .infinity, alignment: .top)
                    .padding(EdgeInsets(top: 2, leading: 2, bottom: 2, trailing: 8))

                VStack(alignment: .leading, spacing: 2) {
                    labels
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .paddingStyle(.top, .cellTop)
                .paddingStyle(.bottom, .cellBottom)

                accessory
                    .paddingStyle(.leading, .cellAccessoryPadding)
            }
            .paddingStyle(.trailing, .standard)
            .fixedSize(horizontal: false, vertical: true)
            .contentShape(Rectangle())
            .elevation(.cardLarge, background: .backgroundLightest)
        }
        .buttonStyle(.plain)
    }
}
