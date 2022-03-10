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

public struct CourseDetailsCellView: View {

    @Environment(\.appEnvironment) private var env
    @Environment(\.viewController) private var controller

    @ObservedObject private var viewModel: CourseDetailsCellViewModel

    public init(viewModel: CourseDetailsCellViewModel) {
        self.viewModel = viewModel
    }

    public var body: some View {
        Button(action: {
            viewModel.selected(router: env.router, viewController: controller)
        }, label: {
            HStack(spacing: 12) {
                Image(uiImage: viewModel.iconImage)
                    .frame(width: 20, height: 20)
                    .foregroundColor(Color(viewModel.courseColor))
                    .frame(maxHeight: .infinity, alignment: .top)
                VStack(alignment: .leading) {
                    Text(viewModel.label)
                        .font(.semibold16)
                        .foregroundColor(.textDarkest)

                    if let subTitle = viewModel.subtitle {
                        Text(subTitle)
                            .font(.regular14)
                            .foregroundColor(.textDark)
                    }
                }
                Spacer()
                if let specialIndicator = viewModel.specialIndicatorIcon {
                    Image(uiImage: specialIndicator)
                        .resizable()
                        .scaledToFit()
                        .frame(width: 20, height: 20)
                        .foregroundColor(.ash)
                } else {
                    InstDisclosureIndicator()
                }
            }
            .padding(.vertical, 13)
            .padding(.horizontal, 16)
            .fixedSize(horizontal: false, vertical: true)
            .contentShape(Rectangle())
            .frame(height: 54)
        })
        .buttonStyle(ContextButton(contextColor: viewModel.courseColor))
        .accessibility(identifier: viewModel.a11yIdentifier)
    }
}

struct CourseDetailsCellView_Previews: PreviewProvider {
    private static let env = AppEnvironment.shared
    private static let context = env.globalDatabase.viewContext

    static var previews: some View {
        let course = Course.save(.make(), in: context)
        let tab: Tab = Tab(context: context)
        tab.save(.make(), in: context, context: .course("1"))
        let viewModel = CourseDetailsCellViewModel(tab: tab, course: course, attendanceToolID: "123")
        return CourseDetailsCellView(viewModel: viewModel)
            .previewLayout(.sizeThatFits)
    }
}
