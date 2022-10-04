//
// This file is part of Canvas.
// Copyright (C) 2020-present  Instructure, Inc.
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

struct DiscussionSectionsPicker: View {
    let courseID: String
    @Binding var selection: Set<CourseSection>

    @ObservedObject var sections: Store<GetCourseSections>

    @Environment(\.viewController) private var viewController

    init(courseID: String, selection: Binding<Set<CourseSection>>) {
        self.courseID = courseID
        sections = AppEnvironment.shared.subscribe(GetCourseSections(courseID: courseID))
        _selection = selection
    }

    var body: some View {
        GeometryReader { geometry in
            ScrollView {
                switch sections.state {
                case .data:
                    LazyVStack(alignment: .leading, spacing: 0) { list }
                case .loading:
                    ZStack {
                        ProgressView()
                            .progressViewStyle(.indeterminateCircle())
                    }
                    .frame(minWidth: geometry.size.width, minHeight: geometry.size.height)
                case .empty:
                    EmptyPanda(.NoRubric,
                        title: Text("No Sections", bundle: .core),
                        message: Text("This course does not have any sections.", bundle: .core)
                    )
                        .frame(minWidth: geometry.size.width, minHeight: geometry.size.height)
                case .error:
                    ZStack {
                        Text(sections.error?.localizedDescription ?? "")
                            .font(.regular16).foregroundColor(.textDanger)
                            .multilineTextAlignment(.center)
                    }
                        .frame(minWidth: geometry.size.width, minHeight: geometry.size.height)
                }
            }
        }
            .background(Color.backgroundLightest.edgesIgnoringSafeArea(.all))
            .navigationBarTitle(Text("Sections", bundle: .core))
            .navigationBarBackButtonHidden(true)
            .navigationBarItems(leading:
                                    Button(action: {
                                        viewController.value.navigationController?.popViewController(animated: true)
                                    }, label: {
                                        HStack(spacing: 2) {
                                            Image.arrowOpenLeftSolid.padding(.leading, -14)
                                            Text("Back", bundle: .core).font(.regular17)
                                        }
                                    }))

            .onAppear(perform: load)
    }

    @ViewBuilder
    var list: some View {
        Divider().padding(.top, -1)
        ForEach(sections.all, id: \.id) { section in
            let isSelected = selection.contains { $0.id == section.id }
            ButtonRow(action: {
                if isSelected {
                    selection = selection.filter { $0.id != section.id }
                } else {
                    selection = selection.union([ section ])
                }
            }, content: {
                Text(section.name)
                Spacer()
                Image.checkSolid.foregroundColor(.accentColor)
                    .opacity(isSelected ? 1 : 0)
            })
                .accessibility(addTraits: isSelected ? .isSelected : [])
            Divider()
        }
    }

    func load() {
        guard !sections.requested else { return }
        sections.exhaust()
    }
}
