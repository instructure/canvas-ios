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

public struct CoursePickerView: View {
    @Environment(\.presentationMode) private var presentationMode
    @ObservedObject private var viewModel: CoursePickerViewModel

    public init(viewModel: CoursePickerViewModel) {
        self.viewModel = viewModel
    }

    public var body: some View {
        content
            .navigationTitleStyled(Text("Select Course", bundle: .core).font(.semibold17).foregroundColor(.textDarkest))
            .navigationBarTitleDisplayMode(.inline)
    }

    @ViewBuilder
    private var content: some View {
        switch viewModel.state {
        case .loading:
            ProgressView()
                .progressViewStyle(.indeterminateCircle())
        case .error(let message):
            error(message: message)
        case .data(let courses):
            self.courses(courses: courses)
        }
    }

    private func error(message: String) -> some View {
        Text(message)
            .font(.regular17)
            .foregroundColor(.textDarkest)
    }

    private func courses(courses: [CoursePickerViewModel.Course]) -> some View {
        ScrollView {
            VStack(spacing: 0) {
                ForEach(courses) { course in
                    Button(action: {
                        viewModel.courseSelected(course)
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                            presentationMode.wrappedValue.dismiss()
                        }
                    }) {
                        HStack(spacing: 0) {
                            Text(course.name)
                                .font(.regular16)
                                .foregroundColor(.textDarkest)
                                .frame(height: 50)
                                .multilineTextAlignment(.leading)
                            Spacer()

                            if viewModel.selectedCourse == course {
                                Image.checkSolid
                                    .frame(width: 50, height: 50)
                                    .foregroundColor(.electric)
                            }
                        }
                        .padding(.leading, 16)
                        .padding(.trailing, 2)
                    }

                    Divider()
                }
            }
        }
    }
}

#if DEBUG

struct CoursePickerView_Previews: PreviewProvider {

    static var previews: some View {
        let loadingModel = CoursePickerViewModel(state: .loading)
        let errorModel = CoursePickerViewModel(state: .error("Something went wrong"))
        let dataModel = CoursePickerViewModel(state: .data([
            .init(id: "0", name: "American Literature"),
            .init(id: "1", name: "History"),
            .init(id: "2", name: "Math"),
            .init(id: "3", name: "Biology"),
        ]))
        CoursePickerView(viewModel: dataModel)
            .previewLayout(.fixed(width: 500, height: 500))
        CoursePickerView(viewModel: loadingModel)
            .previewLayout(.fixed(width: 500, height: 500))
        CoursePickerView(viewModel: errorModel)
            .previewLayout(.fixed(width: 500, height: 500))
    }
}

#endif
