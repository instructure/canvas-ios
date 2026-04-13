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
import HorizonUI
import SwiftUI

struct OfflineConfirmationView: View {
    // MARK: - Private variables

    @Environment(\.viewController) private var viewController
    @Environment(\.dismiss) private var dismiss

    // MARK: - Dependencies

    private let type: ConfirmationType
    private let onTapConfirmation: () -> Void

    // MARK: - Init

    init(
        type: ConfirmationType,
        onTapConfirmation: @escaping () -> Void
    ) {
        self.type = type
        self.onTapConfirmation = onTapConfirmation
    }

    var body: some View {
        VStack(spacing: .zero) {
            headerView
            Text(type.subtitle)
                .frame(maxWidth: .infinity, alignment: .leading)
                .multilineTextAlignment(.leading)
                .huiTypography(.p1)
                .foregroundStyle(Color.huiColors.text.body)
                .padding(.huiSpaces.space24)
            Spacer()
            footerView
        }
    }

    private var headerView: some View {
        VStack(spacing: .huiSpaces.space16) {
            HStack {
                Text(type.title)
                    .huiTypography(.h3)
                    .foregroundStyle(Color.huiColors.text.title)
                Spacer()
                HorizonUI.IconButton(Image.huiIcons.close, type: .white) {
                    dismiss()
                }
                .padding(.trailing, .huiSpaces.space8)
            }
            .padding(.leading, .huiSpaces.space16)
            .padding(.top, .huiSpaces.space24)
            lineView
        }
    }

    private var footerView: some View {
       VStack {
           lineView
            HStack {
                HorizonUI.PrimaryButton(
                    String(localized: "Cancel"),
                    type: .white,
                    fillsWidth: false
                ) {
                    dismiss()
                }
                .padding(.horizontal, .huiSpaces.space16)
                .padding(.top, .huiSpaces.space12)

                Spacer()
                HorizonUI.PrimaryButton(type.buttonTitle,
                                        type: type.isRemove ? .danger : .black,
                                        fillsWidth: false
                ) {
                    onTapConfirmation()
                    dismiss()
                }
                .padding(.horizontal, .huiSpaces.space16)
                .padding(.top, .huiSpaces.space12)
                .padding(.horizontal, .huiSpaces.space16)
                .padding(.top, .huiSpaces.space12)
            }
        }
    }

    private var lineView: some View {
        Rectangle()
            .fill(Color.huiColors.lineAndBorders.lineDivider)
            .frame(height: 1)
    }
}

extension OfflineConfirmationView {
    enum ConfirmationType {
        case remove
        case download(size: String)

        var title: String {
            switch self {
            case .remove:
                return String(localized: "Remove synced content")
            case .download:
                return String(localized: "Sync")
            }
        }

        var subtitle: String {
            switch self {
            case .remove:
                return String(localized: "This will remove all previously synced content from your device.")
            case .download(size: let size):
                return String(format: String(localized: "This will sync ~%@ content while you are connected to a Wi-Fi network"), size)
            }
        }

        var buttonTitle: String {
            switch self {
            case .remove: String(localized: "Remove")
            case .download: String(localized: "Sync")
            }
        }

        var isRemove: Bool {
            if case .remove = self { true } else { false }
        }

    }
}

#Preview {
    OfflineConfirmationView(type: .remove) {}
}
