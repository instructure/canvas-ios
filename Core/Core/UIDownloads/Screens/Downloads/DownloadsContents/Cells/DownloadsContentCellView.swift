//
// This file is part of Canvas.
// Copyright (C) 2023-present  Instructure, Inc.
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

public struct DownloadsContentCellView: View {

    // MARK: - Properties -

    let viewModel: DownloadsModuleCellViewModel
    var color: Color = .oxford
    var onTap: (() -> Void)?
    var onDelete: (() -> Void)?

    // MARK: - Views -

    public var body: some View {
        HStack(spacing: 15) {
            HStack(spacing: 15) {
                Image(uiImage: viewModel.uiImage ?? .documentLine)
                    .frame(width: 20, height: 20)
                    .foregroundColor(color)
                VStack(alignment: .leading) {
                    Text(viewModel.title)
                        .lineLimit(2)
                        .font(.semibold16)
                        .foregroundColor(.textDarkest)
                    viewModel.lastUpdated.flatMap(dateText)
                }
                Spacer()
            }
            .contentShape(Rectangle())
            .onTapGesture {
                onTap?()
            }
            DownloadButtonRepresentable(
                progress: .constant(0),
                currentState: .constant(.downloaded),
                mainTintColor: Brand.shared.linkColor,
                onState: { state in
                    debugLog(state)
                },
                onTap: { _ in
                    onDelete?()
                }
            )
            .frame(width: 35, height: 35)
        }
        .fixedSize(horizontal: false, vertical: true)
        .frame(height: 60)
        .padding(.horizontal, 15)
        .contentShape(Rectangle())
        .background(Color.backgroundLightest)
    }

    private func dateText(date: Date) -> some View {
        Text(
            DateFormatter.localizedString(
                from: date,
                dateStyle: .medium,
                timeStyle: .short
            )
        )
        .font(.regular14)
        .foregroundColor(.oxford)
    }
}
