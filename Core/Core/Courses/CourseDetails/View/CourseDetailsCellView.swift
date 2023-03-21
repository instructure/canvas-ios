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
    @ScaledMetric private var uiScale: CGFloat = 1

    @ObservedObject private var viewModel: CourseDetailsCellViewModel

    public init(viewModel: CourseDetailsCellViewModel) {
        self.viewModel = viewModel
    }

    public var body: some View {
        Button {
            viewModel.selected(router: env.router, viewController: controller)
        } label: {
            HStack(spacing: 12) {
                Image(uiImage: viewModel.iconImage)
                    .resizable()
                    .frame(width: uiScale.iconScale * 20,
                           height: uiScale.iconScale * 20)
                    .foregroundColor(Color(viewModel.courseColor))
                VStack(alignment: .leading) {
                    Text(viewModel.label)
                        .font(.semibold16)
                        .foregroundColor(.textDarkest)
                        .lineLimit(1)

                    if let subTitle = viewModel.subtitle {
                        Text(subTitle)
                            .font(.regular14)
                            .foregroundColor(.textDark)
                            .lineLimit(1)
                    }
                }
                .frame(maxWidth: .infinity, alignment: .leading)

                accessoryIcon
            }
            .padding(.vertical, 13)
            .padding(.horizontal, 16)
            .fixedSize(horizontal: false, vertical: true)
            .contentShape(Rectangle())
            .frame(minHeight: 54)
        }
        .buttonStyle(ContextButton(contextColor: viewModel.courseColor, isHighlighted: viewModel.isHighlighted))
        .accessibility(identifier: viewModel.a11yIdentifier)
        .accessibility(addTraits: viewModel.isHighlighted ? .isSelected : [])
        .alert(isPresented: $viewModel.showGenericError) {
            Alert(title: Text("Something went wrong", bundle: .core), message: Text("There was an error while communicating with the server", bundle: .core))
        }
    }

    @ViewBuilder
    private var accessoryIcon: some View {
        switch viewModel.accessoryIconType {
        case .disclosure:
            InstDisclosureIndicator()
        case .externalLink:
            Image.externalLinkLine
                .resizable()
                .scaledToFit()
                .frame(width: uiScale.iconScale * 20,
                       height: uiScale.iconScale * 20)
                .foregroundColor(.textDarkest)
        case .loading:
            ProgressView()
                .progressViewStyle(
                    .indeterminateCircle(
                        size: uiScale.iconScale * 20,
                        lineWidth: uiScale.iconScale * 2
                    )
                )
        }
    }
}

#if DEBUG

struct CourseDetailsCellView_Previews: PreviewProvider {
    private static let env = AppEnvironment.shared
    private static let context = env.globalDatabase.viewContext
    private static var defaultButtonViewModel: CourseDetailsCellViewModel {
        let course = Course.save(.make(), in: context)
        let tab: Tab = Tab(context: context)
        tab.save(.make(), in: context, context: .course("1"))
        return GenericCellViewModel(tab: tab, course: course, selectedCallback: {})
    }
    private static var attendanceButtonViewModel: CourseDetailsCellViewModel {
        let course = Course.save(.make(id: "2"), in: context)
        let tab: Tab = Tab(context: context)
        tab.save(.make(id: "attendance"), in: context, context: .course("2"))
        return AttendanceCellViewModel(tab: tab, course: course, attendanceToolID: "123", selectedCallback: {})
    }
    private static var loadingButtonViewModel: CourseDetailsCellViewModel {
        let course = Course.save(.make(id: "3"), in: context)
        let tab: Tab = Tab(context: context)
        tab.save(.make(id: "3"), in: context, context: .course("3"))
        let viewModel = GenericCellViewModel(tab: tab, course: course, selectedCallback: {})
        viewModel.accessoryIconType = .loading
        return viewModel
    }

    static var previews: some View {
        VStack(spacing: 0) {
            Divider()
            CourseDetailsCellView(viewModel: StudentViewCellViewModel(course: Course.save(.make(), in: context)))
            Divider()
            CourseDetailsCellView(viewModel: defaultButtonViewModel)
            Divider()
            CourseDetailsCellView(viewModel: attendanceButtonViewModel)
            Divider()
            CourseDetailsCellView(viewModel: loadingButtonViewModel)
            Divider()
        }
        .previewLayout(.sizeThatFits)
    }
}

#endif
