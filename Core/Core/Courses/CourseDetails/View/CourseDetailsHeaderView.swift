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

struct CourseDetailsHeaderView: View {
    @ObservedObject private var viewModel: CourseDetailsHeaderViewModel
    private let width: CGFloat

    public init(viewModel: CourseDetailsHeaderViewModel, width: CGFloat) {
        self.viewModel = viewModel
        self.width = width
    }

    public var body: some View {
        ZStack {
            Color(viewModel.courseColor.resolvedColor(with: .light).darkenToEnsureContrast(against: .textLightest)).frame(width: width, height: viewModel.height)
            if let url = viewModel.imageURL {
                RemoteImage(url, width: width, height: viewModel.height)
                    .opacity(viewModel.imageOpacity)
                    .accessibility(hidden: true)
            }
            VStack(spacing: 3) {
                Text(viewModel.courseName)
                    .font(.semibold23)
                    .accessibility(identifier: "course-details.title-lbl")
                Text(viewModel.termName)
                    .font(.semibold14)
                    .accessibility(identifier: "course-details.subtitle-lbl")
            }
            .padding()
            .multilineTextAlignment(.center)
            .foregroundColor(.textLightest)
            .opacity(viewModel.titleOpacity)
        }
        .frame(height: viewModel.height)
        .clipped()
        .offset(x: 0, y: viewModel.verticalOffset)
    }
}

#if DEBUG

struct CourseDetailsHeaderView_Previews: PreviewProvider {
    private static let env = AppEnvironment.shared
    private static let context = env.globalDatabase.viewContext

    static var previews: some View {
        let course = Course.save(.make(term: .make()), in: context)
        let viewModel = CourseDetailsHeaderViewModel()
        viewModel.courseUpdated(course)
        return CourseDetailsHeaderView(viewModel: viewModel, width: 400)
    }
}

#endif
