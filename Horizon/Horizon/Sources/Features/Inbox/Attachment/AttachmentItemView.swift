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

import HorizonUI
import SwiftUI

struct AttachmentItemView: View {
    var viewModel: AttachmentItemViewModel

    var body: some View {
        HStack {
            ZStack {
                spinner
                checkbox
            }
            title
            Spacer()
            ZStack {
                cancelButton
                deleteButton
            }
        }
        .frame(height: 48)
        .frame(maxWidth: .infinity)
        .padding(.horizontal, HorizonUI.spaces.space16)
        .padding(.vertical, HorizonUI.spaces.space8)
        .background(Color.huiColors.surface.pageSecondary)
        .cornerRadius(HorizonUI.spaces.space16)
        .overlay(
            RoundedRectangle(cornerRadius: HorizonUI.spaces.space16)
                .stroke(Color.huiColors.lineAndBorders.lineStroke, lineWidth: 1)
        )
        .padding(1)
    }

    private var cancelButton: some View {
        HorizonUI.IconButton(
            HorizonUI.icons.close,
            type: .white,
            isSmall: true
        ) {
            viewModel.cancel()
        }
        .opacity(viewModel.cancelOpacity)
    }

    private var checkbox: some View {
        HorizonUI.icons.checkCircleFull
            .foregroundStyle(Color.huiColors.icon.success)
            .opacity(viewModel.checkmarkOpacity)
    }

    private var deleteButton: some View {
        HorizonUI.IconButton(
            HorizonUI.icons.delete,
            type: .white,
            isSmall: true
        ) {
            viewModel.delete()
        }
        .opacity(viewModel.deleteOpacity)
    }

    private var spinner: some View {
        HorizonUI.Spinner(size: .xSmall)
            .opacity(viewModel.spinnerOpacity)
            .frame(width: 24, height: 24)
    }

    private var title: some View {
        Text(viewModel.filename)
            .huiTypography(.p1)
    }
}
