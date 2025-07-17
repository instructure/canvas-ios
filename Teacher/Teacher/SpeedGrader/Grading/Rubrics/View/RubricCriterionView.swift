//
// This file is part of Canvas.
// Copyright (C) 2025-present  Instructure, Inc.
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

import Core
import SwiftUI

struct RubricCriterionView: View {
    @Environment(\.viewController) var controller
    private let containerFrameInGlobal: CGRect
    @ObservedObject var viewModel: RubricCriterionViewModel
    @State private var isExpanded: Bool = false

    init(
        containerFrameInGlobal: CGRect,
        viewModel: RubricCriterionViewModel
    ) {
        self.containerFrameInGlobal = containerFrameInGlobal
        self.viewModel = viewModel
    }

    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: RubricSizes.rectangleCornerRadius)
                .fill(Color.backgroundLightest)
            mainView
                .padding(.vertical, RubricPadding.vertical)
        }
    }

    private var mainView: some View {
        VStack(alignment: .leading, spacing: RubricSpacing.vertical) {
            descriptionLine
            if viewModel.shouldShowRubricNotUsedForScoringMessage {
                notUsedForScoringLine
            }
            RubricRatingsView(viewModel: viewModel, isExpanded: isExpanded)
            if let comment = viewModel.userComment {
                freeFormRubricCommentBubbleWithEditButton(comment, criteriaID: viewModel.criterionId)
            }
            InstUI.Divider()
            scoreLine
            InstUI.Divider()
            noteLine
        }
    }

    private var descriptionLine: some View {
        HStack {
            Text(viewModel.description)
                .font(.semibold16).foregroundColor(.textDarkest)
            Spacer()
            expandButton
        }
        .padding(.horizontal, RubricPadding.horizontal)
    }

    private var expandButton: some View {
        Button {
            isExpanded.toggle()
        } label: {
            Image(systemName: "chevron.down")
                .frame(width: 24, height: 24)
        }
    }

    private var notUsedForScoringLine: some View {
        Text("This criterion will not impact the score.", bundle: .teacher)
            .font(.regular12).foregroundColor(.textDark)
            .padding(.top, 2)
            .padding(.horizontal, RubricPadding.horizontal)
    }

    private var scoreLine: some View {
        HStack {
            Text("Score")
                .font(.semibold16)
                .foregroundStyle(Color.textDarkest)
            Spacer()
            Text("Write score here")
                .font(.regular16)
                .foregroundStyle(Color.textDark)
            Text("/ \(viewModel.points) pts")
                .font(.regular16)
                .foregroundStyle(Color.textDark)
        }
        .padding(.horizontal, RubricPadding.horizontal)
    }

    private var noteLine: some View {
        Text("Rubric Note")
            .font(.regular14)
            .foregroundStyle(Color.textDark)
            .padding(.horizontal, RubricPadding.horizontal)
    }

    private func freeFormRubricCommentBubbleWithEditButton(_ comment: String, criteriaID: String) -> some View {
        HStack {
            Text(comment)
                .font(.regular14)
                .foregroundColor(.textDarkest)
                .padding(.horizontal, 12)
                .padding(.vertical, 8)
                .background(CommentBackground()
                    .fill(Color.backgroundLight)
                )
            Spacer()
            Button(action: { withAnimation(.default) {
                viewModel.rubricComment = comment
                viewModel.rubricCommentID = criteriaID
            } }, label: {
                Text("Edit", bundle: .teacher)
                    .font(.medium14).foregroundColor(.accentColor)
            })
        }
        .padding(.top, 8)
    }
}

private struct CommentBackground: Shape {
    func path(in rect: CGRect) -> Path { Path { path in
        let r: CGFloat = 12
        path.move(to: CGPoint(x: 0, y: -5))
        path.addLine(to: CGPoint(x: 0, y: rect.maxY - r))
        path.addArc(tangent1End: CGPoint(x: 0, y: rect.maxY), tangent2End: CGPoint(x: r, y: rect.maxY), radius: r)
        path.addLine(to: CGPoint(x: rect.maxX - r, y: rect.maxY))
        path.addArc(tangent1End: CGPoint(x: rect.maxX, y: rect.maxY), tangent2End: CGPoint(x: rect.maxX, y: rect.maxY - r), radius: r)
        path.addLine(to: CGPoint(x: rect.maxX, y: r))
        path.addArc(tangent1End: CGPoint(x: rect.maxX, y: 0), tangent2End: CGPoint(x: rect.maxX - r, y: 0), radius: r)
        path.addLine(to: CGPoint(x: 20, y: 0))
        path.addRelativeArc(center: CGPoint(x: 20, y: -24), radius: 24, startAngle: .radians(0.5 * .pi), delta: .degrees(56))
    } }
}
