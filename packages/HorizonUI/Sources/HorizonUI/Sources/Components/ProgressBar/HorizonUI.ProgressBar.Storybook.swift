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

public extension HorizonUI.ProgressBar {
    struct Storybook: View {
        public var body: some View {
            ScrollView {
                VStack(spacing: 35) {
                    mediumZero
                    mediumSmallValues
                    mediumHalfPercent
                    mediumFull
                    smallBar
                }
                .padding(.horizontal, 16)
                .navigationTitle("ProgressBar")
            }
            .background(Color.black.opacity(0.1))
        }

        private var mediumZero: some View {
            VStack {
                HorizonUI.ProgressBar(
                    progress: 0.0,
                    size: .medium
                )

                HorizonUI.ProgressBar(
                    progress: 0.0,
                    size: .medium,
                    numberPosition: .outside
                )

                HorizonUI.ProgressBar(
                    progress: 0.0,
                    size: .medium,
                    numberPosition: .hidden
                )
            }
        }

        private var mediumSmallValues: some View {
            VStack {
                HorizonUI.ProgressBar(
                    progress: 0.01,
                    size: .medium
                )
                
                HorizonUI.ProgressBar(
                    progress: 0.1,
                    size: .medium,
                    numberPosition: .outside
                )

                HorizonUI.ProgressBar(
                    progress: 0.1,
                    size: .medium,
                    numberPosition: .hidden
                )
            }
        }

        private var mediumHalfPercent: some View {
            VStack {
                HorizonUI.ProgressBar(
                    progress: 0.5343,
                    size: .medium,
                    numberPosition: .inside,
                    progressTextColor: .huiColors.primitives.white10
                )

                HorizonUI.ProgressBar(
                    progress: 0.5,
                    size: .medium,
                    numberPosition: .outside
                )

                HorizonUI.ProgressBar(
                    progress: 0.5,
                    size: .medium,
                    numberPosition: .hidden
                )
            }
        }

        private var mediumFull: some View {
            VStack {
                HorizonUI.ProgressBar(
                    progress: 1,
                    size: .medium,
                    numberPosition: .inside,
                    progressTextColor: .huiColors.primitives.white10
                )

                HorizonUI.ProgressBar(
                    progress: 1,
                    size: .medium,
                    numberPosition: .outside
                )

                HorizonUI.ProgressBar(
                    progress: 1,
                    size: .medium,
                    numberPosition: .hidden
                )
            }
        }

        private var smallBar: some View {
            VStack {
                HorizonUI.ProgressBar(
                    progress: 0,
                    size: .small,
                    numberPosition: .hidden
                )

                HorizonUI.ProgressBar(
                    progress: 0.5,
                    size: .small,
                    numberPosition: .hidden
                )

                HorizonUI.ProgressBar(
                    progress: 1,
                    size: .small,
                    numberPosition: .hidden
                )
            }
        }
    }
}

#Preview {
    HorizonUI.ProgressBar.Storybook()
}
