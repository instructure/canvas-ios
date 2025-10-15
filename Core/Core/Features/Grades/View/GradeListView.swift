//
// This file is part of Canvas.
// Copyright (C) 2024-present  Instructure, Inc.
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

import Combine
import SwiftUI

public struct GradeListView: View, ScreenViewTrackable {
    private enum AccessibilityFocusArea: Hashable, Equatable {
        case list, editor
    }

    // MARK: - Dependencies
    @ObservedObject private var viewModel: GradeListViewModel
    @ObservedObject private var offlineModeViewModel: OfflineModeViewModel
    @Environment(\.viewController) private var viewController
    @Environment(\.verticalSizeClass) private var verticalSizeClass
    public let screenViewTrackingParameters: ScreenViewTrackingParameters

    // MARK: - Private properties
    @State private var offsets = CGSize.zero
    @State private var isScoreEditorPresented = false

    @State private var originalScrollOffset: CGFloat = 0
    @State private var scrollOffset: CGFloat?
    @State private var collapsableHeaderHeight: CGFloat = 0

    @Environment(\.horizontalSizeClass) private var horizontalSizeClass

    private var toggleViewIsVisible: Bool {
        scrollOffset ?? 0 > originalScrollOffset - collapsableHeaderHeight
    }

    @AccessibilityFocusState private var accessibilityFocus: AccessibilityFocusArea?
    private var subscriptions = Set<AnyCancellable>()

    // MARK: - Init

    public init(
        viewModel: GradeListViewModel,
        offlineViewModel: OfflineModeViewModel = OfflineModeViewModel(interactor: OfflineModeAssembly.make())
    ) {
        self.viewModel = viewModel
        offlineModeViewModel = offlineViewModel
        screenViewTrackingParameters = ScreenViewTrackingParameters(
            eventName: "/courses/\(viewModel.courseID)/grades"
        )
    }

    // MARK: - Components

    public var body: some View {
		if #available(iOS 26, *) {
			ZStack {
				ScrollView(showsIndicators: false) {
					contentView
				}
				.background(Color.backgroundLight)
				.accessibilityHidden(isScoreEditorPresented)
				.refreshable {
					await withCheckedContinuation { continuation in
						viewModel.pullToRefreshDidTrigger.accept {
							continuation.resume()
						}
					}
				}

				whatIfScoreEditorView
			}
			.animation(.smooth, value: isScoreEditorPresented)
			.safeAreaInset(edge: .top, spacing: 0) {
				switch viewModel.state {
				case .data, .empty: GradeListHeaderView(
					viewModel: viewModel,
					toggleViewIsVisible: toggleViewIsVisible
				)
				default: SwiftUI.EmptyView()
				}
			}
			.background(Color.backgroundLightest)
			.navigationTitle(.init("Grades", bundle: .core))
			.optionalNavigationSubtitle(viewModel.courseName)
			.toolbar {
				RevertWhatIfScoreButton(isWhatIfScoreModeOn: viewModel.isWhatIfScoreModeOn) {
					viewModel.isShowingRevertDialog = true
				}
				ToolbarItem(placement: .primaryAction) {
					GradeListFilterButton(viewModel: viewModel)
				}
			}
			.navigationBarStyle(.color(nil))
			.confirmationAlert(
				isPresented: $viewModel.isShowingRevertDialog,
				presenting: viewModel.confirmRevertAlertViewModel
			)
		} else {
			ZStack {
				ScrollView(showsIndicators: false) {
					contentView
				}
				.background(Color.backgroundLight)
				.accessibilityHidden(isScoreEditorPresented)
				.refreshable {
					await withCheckedContinuation { continuation in
						viewModel.pullToRefreshDidTrigger.accept {
							continuation.resume()
						}
					}
				}

				whatIfScoreEditorView
			}
			.animation(.smooth, value: isScoreEditorPresented)
			.safeAreaInset(edge: .top, spacing: 0) {
				switch viewModel.state {
				case .data, .empty: GradeListHeaderView(
					viewModel: viewModel,
					toggleViewIsVisible: toggleViewIsVisible
				)
				default: SwiftUI.EmptyView()
				}
			}
			.background(Color.backgroundLightest)
			.navigationBarTitleView(
				title: String(localized: "Grades", bundle: .core),
				subtitle: viewModel.courseName
			)
			.toolbar {
				RevertWhatIfScoreButton(isWhatIfScoreModeOn: viewModel.isWhatIfScoreModeOn) {
					viewModel.isShowingRevertDialog = true
				}
				ToolbarItem(placement: .primaryAction) {
					LegacyGradeListFilterButton(viewModel: viewModel)
				}
			}
			.navigationBarStyle(.color(nil))
			.confirmationAlert(
				isPresented: $viewModel.isShowingRevertDialog,
				presenting: viewModel.confirmRevertAlertViewModel
			)
		}
    }

    @ViewBuilder
    private var contentView: some View {
        VStack(spacing: 0) {
            switch viewModel.state {
            case .data, .empty:
                GradeListTogglesView(viewModel: viewModel)
                    .bindTopPosition(id: "collapsableHeader", coordinateSpace: .global, to: $scrollOffset)
                    .readingFrame { frame in
                        if collapsableHeaderHeight != frame.height {
                            collapsableHeaderHeight = frame.height
                        }
                    }
                    .onFirstAppear {
                        originalScrollOffset = scrollOffset ?? 0
                    }
            default:
                SwiftUI.EmptyView()
            }

            switch viewModel.state {
            case .initialLoading: loadingView
            case .data(let data): dataView(data)
            case .empty: emptyView
            case .error: errorView
            }
            Spacer()
        }
        .background(Color.backgroundLightest)
    }

    @ViewBuilder
    private var loadingView: some View {
        ProgressView()
            .progressViewStyle(.indeterminateCircle())
            .containerRelativeFrame([.vertical, .horizontal])
    }

    @ViewBuilder
    private func dataView(_ gradeListData: GradeListData) -> some View {
        assignmentListView(
            courseColor: gradeListData.courseColor,
            assignmentSections: gradeListData.assignmentSections,
            userID: gradeListData.userID ?? ""
        )
        .accessibilityFocused($accessibilityFocus, equals: .list)
    }

    @ViewBuilder
    private var emptyView: some View {
        InteractivePanda(
            scene: SpacePanda(),
            title: String(localized: "No Assignments", bundle: .core),
            subtitle: String(localized: "It looks like assignments haven’t been created in this space yet.", bundle: .core)
        )
        .padding(.horizontal, 16)
        .containerRelativeFrame([.horizontal, .vertical])
        .accessibilityIdentifier("GradeList.emptyView")
    }

    @ViewBuilder
    private var errorView: some View {
        InteractivePanda(
            scene: NoResultsPanda(),
            title: String(localized: "Something Went Wrong", bundle: .core),
            subtitle: String(localized: "Pull to refresh to try again.", bundle: .core)
        )
        .padding(.horizontal, 16)
        .listSectionSeparator(.hidden)
        .listSectionSeparatorTint(Color.clear)
        .listRowBackground(Color.clear)
        .containerRelativeFrame([.horizontal, .vertical])
    }

    @ViewBuilder
    private func totalGradeText(_ totalGrade: String) -> some View {
        Text(totalGrade)
            .foregroundStyle(Color.textDarkest)
            .font(.semibold22)
            .multilineTextAlignment(.center)
            .accessibilityLabel(Text("Total grade is \(totalGrade)", bundle: .core))
            .accessibilityIdentifier("CourseTotalGrade")
    }

    @ViewBuilder
    private func assignmentListView(
        courseColor: UIColor?,
        assignmentSections: [GradeListData.AssignmentSections],
        userID: String
    ) -> some View {
        LazyVStack(spacing: 0, pinnedViews: .sectionHeaders) {
            ForEach(assignmentSections, id: \.id) { section in
                AssignmentSection(
                    title: section.title,
                    titleA11yLabel: section.accessibilityLabel
                ) {
                    ForEach(section.assignments, id: \.id) { entry in
                        VStack(alignment: .leading, spacing: 0) {
                            listRowView(
                                assignment: entry,
                                userID: userID,
                                courseColor: courseColor
                            )

                            if entry.id != section.assignments.last?.id {
                                InstUI.Divider()
                                    .paddingStyle(.horizontal, .standard)
                                    .accessibilityHidden(true)
                            }
                        }.id(entry.id)
                    }
                }
            }
        }

        Color.backgroundLightest
            .frame(height: 30)
    }

    @ViewBuilder
    private func listRowView(
        assignment: GradeListAssignment,
        userID: String,
        courseColor _: UIColor?
    ) -> some View {
        Button {
            viewModel.didSelectAssignment.accept((viewController, assignment.id))
        } label: {
            GradeRowView(
                assignment: assignment,
                isWhatIfScoreModeOn: viewModel.isWhatIfScoreModeOn
            ) {
                isScoreEditorPresented.toggle()
            }
            .onSwipe(trailing: revertWhatIfScoreSwipeButton(id: assignment.id))
            .contentShape(Rectangle())
        }
        .background(Color.backgroundLightest)
        .buttonStyle(ContextButton(contextColor: viewModel.courseColor))
        .accessibilityAction(named: Text("Edit What-if score", bundle: .core)) {
            isScoreEditorPresented.toggle()
        }
        .accessibilityAction(named: Text("Revert to official score", bundle: .core)) {
            viewModel.isShowingRevertDialog = true
        }
    }

    @ViewBuilder
    private var whatIfScoreEditorView: some View {
        if isScoreEditorPresented {
            WhatIfScoreEditorView(isPresented: $isScoreEditorPresented) {}
                .accessibilitySortPriority(1)
                .accessibilityFocused($accessibilityFocus, equals: .editor)
                .onAppear {
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.25) {
                        accessibilityFocus = .editor
                    }
                }
                .onDisappear {
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.25) {
                        accessibilityFocus = .list
                    }
                }
        }
    }

    private func revertWhatIfScoreSwipeButton(id: String) -> [SwipeModel] {
        guard viewModel.isWhatIfScoreModeOn else {
            return []
        }

        let slot = SwipeModel(id: id,
                              image: { Image(uiImage: .replyLine)},
                              action: { viewModel.isShowingRevertDialog = true },
                              style: .init(background: Color.backgroundDark))
        return [slot]
    }
}

// This is workaround, because .toolbar doesn't allow optional `ToolBarContent`.
private struct RevertWhatIfScoreButton: ToolbarContent {
    let isWhatIfScoreModeOn: Bool
    let buttonDidTap: () -> Void

    var body: some ToolbarContent {
        ToolbarItemGroup(placement: .navigationBarTrailing) {
            if isWhatIfScoreModeOn {
                Button(action: {
                    buttonDidTap()
                }) {
                    Image(uiImage: .replyLine)
                        .resizable()
                        .foregroundColor(.textLightest.variantForLightMode)
                }
                .frame(alignment: .leading)
                .accessibilityLabel(Text("Revert", bundle: .core))
                .accessibilityHint(Text("Double tap to revert to official score.", bundle: .core))
            }
        }
    }
}

extension Assignment: Identifiable {}
extension GradingPeriod: Identifiable {}

#if DEBUG
struct GradeListViewPreview: PreviewProvider {
    static var previews: some View {
        GradeListView(
            viewModel: .init(
                interactor: GradeListInteractorPreview(),
                gradeFilterInteractor: GradeFilterInteractorLive(
                    appEnvironment: .shared,
                    courseId: "courseId"
                ),
                env: PreviewEnvironment.shared
            )
        )
    }
}

#endif
