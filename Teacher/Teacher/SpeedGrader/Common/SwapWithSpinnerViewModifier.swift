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

import Combine
import Core
import Foundation
import SwiftUI

extension View {
    func swapWithSpinner(
        onSaving isLoadingSubject: CurrentValueSubject<Bool, Never>,
        alignment: Alignment
    ) -> some View {
        modifier(SwapWithSpinnerViewModifier(
            isLoadingSubject: isLoadingSubject,
            accessibilityValue: String(localized: "Saving", bundle: .teacher),
            alignment: alignment
        ))
    }

    func swapWithSpinner(
        onLoading isLoadingSubject: CurrentValueSubject<Bool, Never>,
        alignment: Alignment
    ) -> some View {
        modifier(SwapWithSpinnerViewModifier(
            isLoadingSubject: isLoadingSubject,
            accessibilityValue: String(localized: "Loading", bundle: .teacher),
            alignment: alignment
        ))
    }
}

private struct SwapWithSpinnerViewModifier: ViewModifier {
    private let isLoadingSubject: CurrentValueSubject<Bool, Never>
    private let accessibilityValue: String
    private let alignment: Alignment

    @State private var isLoading: Bool = false

    init(
        isLoadingSubject: CurrentValueSubject<Bool, Never>,
        accessibilityValue: String,
        alignment: Alignment
    ) {
        self.isLoadingSubject = isLoadingSubject
        self.accessibilityValue = ["", accessibilityValue].accessibilityJoined()
        self.alignment = alignment
    }

    func body(content: Content) -> some View {
        // The loading and the data state have different heights, so we use a ZStack to
        // keep both of them on screen ensuring the cell's constant height.
        ZStack(alignment: alignment) {
            ProgressView()
                .tint(nil)
                .opacity(isLoading ? 1 : 0)
                .accessibilityValue(optional: isLoading ? accessibilityValue : nil)
            content
                .opacity(isLoading ? 0 : 1)
        }
        .animation(.none, value: isLoading)
        .onReceive(isLoadingSubject) {
            isLoading = $0
        }
    }
}
