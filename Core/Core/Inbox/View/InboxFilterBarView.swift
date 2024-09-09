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

public struct InboxFilterBarView: View {
    @ObservedObject private var model: InboxViewModel

    public init(model: InboxViewModel) {
        self.model = model
    }

    public var body: some View {
        HStack(spacing: 0) {
            courseFilterButton
            Spacer(minLength: 22)
            scopeFilterButton
                .layoutPriority(1)
        }
        .frame(height: 81)
        .padding(.leading, 16)
        .padding(.trailing, 19)
        .background(Color.backgroundLightest)
    }

    private var courseFilterButton: some View {
        Button {
            if model.isShowingScopeSelector {
                return
            }

            if !model.courses.isEmpty {
                model.isShowingCourseSelector.toggle()
            }
        } label: {
            HStack(spacing: 6) {
                Text(model.course)
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
        .actionSheet(isPresented: $model.isShowingCourseSelector) {
            ActionSheet(title: Text("Filter by", bundle: .core), buttons: courseFilterButtons)
        }
        .accessibilityLabel(Text("Filter messages by course", bundle: .core))
        .accessibilityHint(Text(model.course))
        .accessibilityIdentifier("Inbox.filterByCourse")
    }

    private var scopeFilterButton: some View {
        Button {
            if model.isShowingCourseSelector {
                return
            }

            model.isShowingScopeSelector.toggle()
        } label: {
            HStack(spacing: 5) {
                Text(model.scope.localizedName)
                    .lineLimit(1)
                    .font(.regular16)
                Image
                    .arrowOpenDownSolid
                    .resizable()
                    .scaledToFit()
                    .frame(width: 13)
                    .accessibilityHidden(true)
            }
            .foregroundColor(Color(Brand.shared.linkColor))
        }
        .actionSheet(isPresented: $model.isShowingScopeSelector) {
            ActionSheet(title: Text("Filter by", bundle: .core), buttons: scopeFilterButtons)
        }
        .accessibilityLabel(Text("Filter messages by type", bundle: .core))
        .accessibilityHint(Text(model.scope.localizedName))
        .accessibilityIdentifier("Inbox.filterByType")
    }

    private var scopeFilterButtons: [ActionSheet.Button] {
        let scopeButtons: [ActionSheet.Button] = model.scopes.map { scope in
            .default(Text(scope.localizedName)) {
                model.scopeDidChange.send(scope)
            }
        }
        let cancelButton = ActionSheet.Button.cancel(Text("Cancel", bundle: .core))
        return scopeButtons + [cancelButton]
    }

    private var courseFilterButtons: [ActionSheet.Button] {
        var buttons: [ActionSheet.Button] = [
            .default(Text("All Courses", bundle: .core)) {
                model.courseDidChange.send(nil)
            }
        ]
        buttons.append(contentsOf: model.courses.map { course in
            .default(Text(course.name)) {
                model.courseDidChange.send(course)
            }
        })
        buttons.append(.cancel(Text("Cancel", bundle: .core)))
        return buttons
    }
}

#if DEBUG

struct InboxFilterBar_Previews: PreviewProvider {
    static let env = PreviewEnvironment()
    static let context = env.globalDatabase.viewContext

    static var previews: some View {
        let messageInteractor = InboxMessageInteractorPreview(environment: env, messages: .make(count: 5, in: context))
        let favouriteInteractor = InboxMessageFavouriteInteractorLive()
        let viewModel = InboxViewModel(
            messageInteractor: messageInteractor,
            router: AppEnvironment.shared.router,
            favouriteInteractor: favouriteInteractor
        )
        InboxFilterBarView(model: viewModel)
            .previewLayout(.sizeThatFits)
    }
}

#endif
