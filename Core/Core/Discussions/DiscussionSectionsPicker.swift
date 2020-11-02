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

    @State var isLoaded = false

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
                    if #available(iOS 14, *) {
                        LazyVStack(alignment: .leading, spacing: 0) { list }
                    } else {
                        VStack(alignment: .leading, spacing: 0) { list }
                    }
                case .loading:
                    ZStack { CircleProgress() }
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
    }

    @ViewBuilder
    var list: some View {
        Divider().padding(.top, -1)
        ForEach(sections.all, id: \.id) { section in
            ButtonRow(action: {
                if selection.contains(section) {
                    selection = selection.subtracting([ section ])
                } else {
                    selection = selection.union([ section ])
                }
            }, content: {
                Text(section.name)
                Spacer()
                Icon.checkSolid.foregroundColor(.accentColor)
                    .opacity(selection.contains(section) ? 1 : 0)
            })
                .accessibility(addTraits: selection.contains(section) ? .isSelected : [])
            Divider()
        }
    }

    func load() {
        guard !isLoaded else { return }
        isLoaded = true
        sections.exhaust()
    }
}
