//
// This file is part of Canvas.
// Copyright (C) 2021-present  Instructure, Inc.
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

public struct K5HomeroomView: View {
    @ObservedObject private var viewModel: K5HomeroomViewModel
    private let containerHorizontalMargin: CGFloat

    public init(viewModel: K5HomeroomViewModel, containerHorizontalMargin: CGFloat) {
        self.viewModel = viewModel
        self.containerHorizontalMargin = containerHorizontalMargin
    }

    public var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            Text(viewModel.welcomeText)
                .foregroundColor(.licorice)
                .font(.bold34)
                .padding(.top)
            ForEach(viewModel.announcements) {
                K5HomeroomAnnouncementView(viewModel: $0)
                    .padding(.vertical, 23)
                Divider()
                    .padding(.horizontal, -containerHorizontalMargin) // make sure the divider fills the parent view horizontally
            }

            K5HomeroomMySubjectsView(subjectCards: viewModel.subjectCards)
                .padding(.top, 23)
        }
    }
}

struct K5HomeroomView_Previews: PreviewProvider {
    static var previews: some View {
        K5HomeroomView(viewModel: K5HomeroomViewModel(), containerHorizontalMargin: 0).previewLayout(.sizeThatFits)
    }
}
