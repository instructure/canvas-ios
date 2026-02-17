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

import Observation
import SwiftUI

public extension HorizonUI {
    struct LoadingButton: View {
        private let title: String
        private let fillsWidth: Bool
        private let isSmall: Bool
        private let type: HorizonUI.ButtonStyles.ButtonType
        private let isLoading: Bool
        @Binding private var isDisabled: Bool
        private let onSave: () -> Void

        public init(
            title: String,
            type: HorizonUI.ButtonStyles.ButtonType = .black,
            isSmall: Bool = false,
            fillsWidth: Bool = true,
            isLoading: Bool,
            isDisabled: Binding<Bool>? = nil,
            onSave: @escaping () -> Void
        ) {
            self.title = title
            self.fillsWidth = fillsWidth
            self.type = type
            self.isSmall = isSmall
            self.isLoading = isLoading
            _isDisabled = isDisabled ?? .constant(false)
            self.onSave = onSave
        }

        public var body: some View {
            ZStack {
                HorizonUI.PrimaryButton(
                    title,
                    type: type,
                    isSmall: isSmall,
                    fillsWidth: fillsWidth
                ) {
                    onSave()
                }
                .opacity(isLoading ? 0.25 : 1.0)
                .animation(.easeInOut, value: isLoading)
                .disabled(isDisabled)

                HorizonUI.Spinner(size: .xSmall)
                    .opacity(isLoading ? 1.0 : 0.0)
                    .animation(.easeInOut, value: isLoading)
            }
            .frame(maxWidth: fillsWidth ? .infinity : nil)
        }
    }
}

#Preview {
    HorizonUI.LoadingButton(
        title: "Enrolle",
        type: .institution,
        fillsWidth: false,
        isLoading: true,
        isDisabled: nil
    ) {}
}
