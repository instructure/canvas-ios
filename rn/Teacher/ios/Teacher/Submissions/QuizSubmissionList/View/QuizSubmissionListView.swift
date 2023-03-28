//
// This file is part of Canvas.
// Copyright (C) 2023-present  Instructure, Inc.
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

public struct QuizSubmissionListView: View {
    @ObservedObject private var model: QuizSubmissionListViewModel
    @Environment(\.viewController) private var controller

    init(model: QuizSubmissionListViewModel) {
        self.model = model
    }

    public var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            filterBarView
            Color.borderMedium
                .frame(height: 0.5)
            if model.state == .loading {
                loadingIndicator
            } else {
                List {
                    switch model.state {
                    case .data:
                        submissionList
                    case .empty:
                        InteractivePanda(scene: ConferencesPanda(),
                            title: Text("No Submissions"),
                            subtitle: Text("It seems there aren't any valid submissions to grade."))
                    case .error:
                        Text("There was an error loading submissions. Pull to refresh to try again.")
                    case .loading:
                        SwiftUI.EmptyView()
                    }
                }
                .refreshable {
                    await withCheckedContinuation { continuation in
                        model.refreshDidTrigger.send {
                            continuation.resume()
                        }
                    }
                }
                .listStyle(PlainListStyle())
                .animation(.default, value: model.submissions)
                }
            }
            .background(Color.backgroundLightest)
            .navigationTitle(model.title, subtitle: model.subTitle)
            .navigationBarItems(trailing: messageUsersButton)
            .alert(isPresented: $model.showError) {
                Alert(title: Text("Practice quizzes & surveys do not have detail views."))
            }
    }

    private var filterBarView: some View {
        Button {
            model.isShowingFilterSelector.toggle()
        } label: {
            HStack(spacing: 6) {
                Text(model.filter.localizedName)
                    .lineLimit(1)
                    .font(.semibold22)
                    .foregroundColor(.textDarkest)
                Image
                    .arrowOpenDownSolid
                    .resizable()
                    .scaledToFit()
                    .frame(width: 17)
            }
            .foregroundColor(.textDarkest)
        }
        .actionSheet(isPresented: $model.isShowingFilterSelector) {
            ActionSheet(title: Text("Filter by"), buttons: filterButtons)
        }
        .frame(height: 81)
        .padding(.leading, 16)
        .padding(.trailing, 19)
        .background(Color.backgroundLightest)
        .accessibilityLabel(Text("Filter submissions"))
        .accessibilityHint(Text(model.filter.localizedName))
    }

    private var filterButtons: [ActionSheet.Button] {
        let filterButtons: [ActionSheet.Button] = model.filters.map { filter in
            .default(Text(filter.localizedName)) {
                model.filterDidChange.send(filter)
            }
        }
        let cancelButton = ActionSheet.Button.cancel(Text("Cancel"))
        return filterButtons + [cancelButton]
    }

    private var loadingIndicator: some View {
        ProgressView()
            .progressViewStyle(.indeterminateCircle())
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .accentColor(Color(Brand.shared.primary))
            .listRowInsets(EdgeInsets())
            .listRowSeparator(.hidden)
    }

    var submissionList: some View {
        ForEach(model.submissions) { submission in
            VStack(spacing: 0) {
                QuizSubmissionListItemView(model: submission, action: { model.submissionDidTap() })
                Color.borderMedium
                    .frame(height: 0.5)
                    .overlay(Color.backgroundLightest.frame(width: 64), alignment: .leading)
            }
            .listRowInsets(EdgeInsets())
            .listRowSeparator(.hidden)
        }
    }

    private var messageUsersButton: some View {
        Button {
            model.messageUsersDidTap.send(controller)
        } label: {
            Image.emailLine
                .foregroundColor(Color(Brand.shared.navTextColor.ensureContrast(against: Brand.shared.navBackground)))
        }
        .frame(width: 44, height: 44).padding(.leading, -6)
        .accessibility(label: Text("Send message to users"))
    }
}

#if DEBUG

struct QuizSubmissionListView_Previews: PreviewProvider {
    static let env = PreviewEnvironment()
    static let context = env.globalDatabase.viewContext

    static var previews: some View {
        QuizSubmissionListAssembly.makePreview(env: env, submissions: .make(count: 5))
            .previewLayout(.sizeThatFits)

        QuizSubmissionListAssembly.makePreview(env: env, submissions: [])
            .previewLayout(.sizeThatFits)
            .previewDisplayName("Empty State")
    }
}

#endif
