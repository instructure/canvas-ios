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
import Core

struct SubmissionGrader: View {
    let assignment: Assignment
    let submission: Submission

    @Environment(\.appEnvironment) var env
    @Environment(\.horizontalSizeClass) var horizontalSizeClass

    @State var selectedDrawerTab: DrawerTab = .grades
    @State var drawerState: DrawerState = .min

    var bottomInset: CGFloat { env.window?.safeAreaInsets.bottom ?? 0 }

    var body: some View {
        if horizontalSizeClass == .compact {
            graderWithDrawer
        } else {
            graderWithSplit
        }
    }

    var graderWithDrawer: some View {
        GeometryReader { geometry in ZStack(alignment: .bottom) {
            VStack(spacing: 0) {
                SubmissionHeader(assignment: assignment, submission: submission)
                Divider()
                Text(verbatim: "submission placeholder")
                Spacer()
                Spacer().frame(height: bottomInset)
            }
            Drawer(state: $drawerState, minHeight: 56 + bottomInset, maxHeight: geometry.size.height - 64) {
                drawerContent
                Spacer().frame(height: bottomInset)
            }
        } }
            .background(Color.backgroundLightest)
    }

    var graderWithSplit: some View {
        VStack(spacing: 0) {
            SubmissionHeader(assignment: assignment, submission: submission)
            Divider()
            HStack(spacing: 0) {
                VStack {
                    Text(verbatim: "submission placeholder")
                    Spacer()
                }
                Spacer()
                Divider()
                VStack(spacing: 0) {
                    Spacer().frame(height: 16)
                    drawerContent
                }
                    .frame(width: 375)
            }
        }
            .background(Color.backgroundLightest)
    }

    enum DrawerTab: Int, CaseIterable, Identifiable {
        case grades, comments, files
        var id: Int { rawValue }
    }

    @ViewBuilder
    var drawerContent: some View {
        Picker(selection: Binding(get: { selectedDrawerTab }, set: {
            selectedDrawerTab = $0
            if drawerState == .min { drawerState = .mid }
        }), label: Text(verbatim: "")) {
            Text("Grades").tag(DrawerTab.grades)
            Text("Comments").tag(DrawerTab.comments)
            filesTabText.tag(DrawerTab.files)
        }
            .pickerStyle(SegmentedPickerStyle())
            .padding(EdgeInsets(top: 0, leading: 16, bottom: 8, trailing: 16))
        Divider()
        Pages(items: DrawerTab.allCases, currentIndex: Binding(
            get: { selectedDrawerTab.rawValue },
            set: { selectedDrawerTab = DrawerTab.allCases[$0] }
        )) { tab in
            ScrollView {
                switch tab {
                case .grades:
                    Text("Grades")
                case .comments:
                    Text("Comments")
                case .files:
                    Text("Files")
                }
            }
        }
    }

    var filesTabText: Text {
        let selectedSubmission = submission // TODO: which one in history
        if let count = selectedSubmission.attachments?.count, count > 0 {
            return Text("Files (\(count))")
        }
        return Text("Files")
    }
}
