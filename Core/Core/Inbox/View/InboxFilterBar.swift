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

public struct InboxFilterBar: View {
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
            if !model.courses.isEmpty {
                model.isShowingCourseSelector = true
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
    }

    private var scopeFilterButton: some View {
        Button {
            model.isShowingScopeSelector = true
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
            }
            .foregroundColor(Color(Brand.shared.linkColor))
        }
        .actionSheet(isPresented: $model.isShowingScopeSelector) {
            ActionSheet(title: Text("Filter by", bundle: .core), buttons: scopeFilterButtons)
        }
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
            },
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
        ForEach(ColorScheme.allCases, id: \.self) {
            let interactor = InboxMessageInteractorPreview(environment: env, messages: .make(count: 5, in: context))
            let viewModel = InboxViewModel(interactor: interactor, router: AppEnvironment.shared.router)
            InboxFilterBar(model: viewModel)
                .preferredColorScheme($0)
                .previewLayout(.sizeThatFits)
        }
    }
}

#endif
