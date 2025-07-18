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

extension InstUI {

    public struct SectionDisclosureStyle: DisclosureGroupStyle {

        public struct HeaderConfiguration {
            let paddingSet: InstUI.Styles.PaddingSet
            let accessoryIconSize: CGFloat
            let hasDividerBelowHeader: Bool
        }

        @Environment(\.dynamicTypeSize) private var dynamicTypeSize

        private let headerConfig: HeaderConfiguration

        public init(headerConfig: HeaderConfiguration) {
            self.headerConfig = headerConfig
        }

        public func makeBody(configuration: Configuration) -> some View {
            VStack(alignment: .leading, spacing: 0) {
                Button(
                    action: {
                        withAnimation(.smooth(duration: 0.3)) {
                            configuration.isExpanded.toggle()
                        }
                    },
                    label: {
                        header(configuration: configuration)
                            .paddingStyle(set: headerConfig.paddingSet)
                            .contentShape(Rectangle())
                            .background(.backgroundLightest) // to stop collapsing views above showing through
                    }
                )
                .buttonStyle(.plain)

                if headerConfig.hasDividerBelowHeader {
                    InstUI.Divider()
                }

                if configuration.isExpanded {
                    configuration.content
                        .background(.backgroundLightest) // to stop collapsing views above showing through
                }
            }
        }

        private func header(configuration: Configuration) -> some View {
            HStack(alignment: .center, spacing: 0) {
                configuration.label
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .accessibilityAddTraits([.isHeader])

                Image.chevronDown
                    .scaledIcon(size: headerConfig.accessoryIconSize)
                    .foregroundStyle(.textDark)
                    .rotationEffect(.degrees(configuration.isExpanded ? 180 : 0))
                    .paddingStyle(.leading, .cellAccessoryPadding)
            }
        }
    }
}
