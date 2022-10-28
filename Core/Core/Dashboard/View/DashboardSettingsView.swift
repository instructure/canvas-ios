//
// This file is part of Canvas.
// Copyright (C) 2022-present  Instructure, Inc.
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

struct DashboardSettingsView: View {
    @ObservedObject private var viewModel: DashboardLayoutViewModel

    init(viewModel: DashboardLayoutViewModel) {
        self.viewModel = viewModel
    }

    var body: some View {
        VStack(spacing: 0) {
            SideMenuSubHeaderView(title: Text("LAYOUT", bundle: .core))
                .accessibility(addTraits: .isHeader)
                .padding(.top, 10)
            HStack(spacing: 0) {
                Spacer()
                gridButton
                Spacer()
                listButton
                Spacer()
            }
            .padding(.top, 20)
            .padding(.bottom, 20)
            .padding(.horizontal, 20)
            SideMenuOptionsSection(enrollment: .student)
            SideMenuSubHeaderView(title: Text("HINT", bundle: .core))
                .accessibility(addTraits: .isHeader)
                .padding(.top, 5)
            HStack(alignment: .top, spacing: 20) {
                Image.infoLine
                    .foregroundColor(.textDarkest)
                Text("To re-order your courses tap and hold on a card then drag to its new position.")
                    .font(.regular16)
                    .foregroundColor(.textDarkest)
                    .frame(maxWidth: .infinity, alignment: .leading)
            }
            .padding(.horizontal, 20)
            .padding(.top, 15)
            .padding(.bottom, 10)
        }
        .background(Color.backgroundLightest)
        .navigationBarStyle(.modal)
        .navigationTitle(Text("Dashboard Settings", bundle: .core))
    }

    private var gridButton: some View {
        Button(action: viewModel.setCardLayout) {
            VStack(spacing: 3) {
                cardLayoutPhone
                    .frame(width: 100)
                Text("Card", bundle: .core)
                    .foregroundColor(.textDarkest)
                    .padding(.top, 2)
                    .padding(.bottom, 8)
                    .font(.regular16)
                (viewModel.isCardLayout ? Image.publishSolid : Image.emptyLine)
                    .foregroundColor(Color(Brand.shared.primary))
            }
        }
    }

    private var listButton: some View {
        Button(action: viewModel.setListLayout) {
            VStack(spacing: 3) {
                listLayoutPhone
                    .frame(width: 100)
                Text("List", bundle: .core)
                    .foregroundColor(.textDarkest)
                    .padding(.top, 2)
                    .padding(.bottom, 8)
                    .font(.regular16)
                (viewModel.isListLayout ? Image.publishSolid : Image.emptyLine)
                    .foregroundColor(Color(Brand.shared.primary))
            }
        }
    }

    private var cardLayoutPhone: some View {
        VStack {
            ForEach(0..<5) { _ in
                HStack {
                    Rectangle()
                    Rectangle()
                }
            }
        }
        .padding(20)
        .background(Color.backgroundLight)
        .foregroundColor(.borderMedium)
        .aspectRatio(0.6, contentMode: .fit)
        .overlay(
            RoundedRectangle(cornerRadius: 15)
                .stroke(Color.textDark, lineWidth: 3)
        )
    }

    private var listLayoutPhone: some View {
        VStack {
            ForEach(0..<5) { _ in
                Rectangle()
            }
        }
        .padding(20)
        .background(Color.backgroundLight.cornerRadius(15))
        .foregroundColor(.borderMedium)
        .aspectRatio(0.6, contentMode: .fit)
        .overlay(
            RoundedRectangle(cornerRadius: 15)
                .stroke(Color.textDark, lineWidth: 3)
        )
    }

}

#if DEBUG

struct DashboardSettingsView_Previews: PreviewProvider {
    static var previews: some View {
        DashboardSettingsView(viewModel: DashboardLayoutViewModel())
            .frame(width: 400)
            .previewLayout(.sizeThatFits)
    }
}

#endif
