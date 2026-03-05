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

import Combine
import Core
import SwiftUI
import UIKit

struct ToDoWeekPager: UIViewRepresentable {
    typealias UIViewType = UICollectionView
    typealias Coordinator = ToDoWeekPagerCoordinator

    let viewModel: ToDoWidgetViewModel
    let proxy: WeekPagerProxy
    let onWeekOffsetChanged: (Int) -> Void
    let weekDays: (Int) -> [Date]

    @State private var prevSubscription: AnyCancellable?
    @State private var nextSubscription: AnyCancellable?
    @State private var todaySubscription: AnyCancellable?

    func makeCoordinator() -> ToDoWeekPagerCoordinator {
        ToDoWeekPagerCoordinator(
            viewModel: viewModel,
            weekDays: weekDays,
            onWeekOffsetChanged: onWeekOffsetChanged
        )
    }

    func makeUIView(context: UIViewRepresentableContext<ToDoWeekPager>) -> UICollectionView {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .horizontal
        layout.minimumLineSpacing = 0

        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.isPrefetchingEnabled = false
        collectionView.isPagingEnabled = true
        collectionView.showsHorizontalScrollIndicator = false
        collectionView.register(UICollectionViewCell.self, forCellWithReuseIdentifier: "cell")
        collectionView.backgroundColor = .clear
        collectionView.delegate = context.coordinator
        collectionView.dataSource = context.coordinator
        let coordinator = context.coordinator
        coordinator.collectionView = collectionView
        coordinator.observeFrameChange(on: collectionView)

        DispatchQueue.main.async { [weak coordinator] in
            prevSubscription = proxy.scrollToPreviousWeekSubject.sink { [weak coordinator] in
                guard let coordinator, let collectionView = coordinator.collectionView else { return }
                coordinator.scrollToPrevious(collectionView)
            }
            nextSubscription = proxy.scrollToNextWeekSubject.sink { [weak coordinator] in
                guard let coordinator, let collectionView = coordinator.collectionView else { return }
                coordinator.scrollToNext(collectionView)
            }
            todaySubscription = proxy.scrollToTodaySubject.sink { [weak coordinator] in
                guard let coordinator, let collectionView = coordinator.collectionView else { return }
                coordinator.scrollToToday(collectionView)
            }
        }

        return collectionView
    }

    func updateUIView(_ collectionView: UICollectionView, context: UIViewRepresentableContext<ToDoWeekPager>) {
    }
}

final class ToDoWeekPagerCoordinator: NSObject, UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {
    private static let hostedViewTag = 493820

    private let viewModel: ToDoWidgetViewModel
    private let weekDays: (Int) -> [Date]
    private let onWeekOffsetChanged: (Int) -> Void

    private(set) var currentWeekOffset: Int = 0
    private var pendingWeekOffset: Int?
    private var hostingControllers: [UIHostingController<ToDoWeekPageView>]
    private var didScrollToInitialPage = false
    private var observation: NSKeyValueObservation?

    weak var collectionView: UICollectionView?

    init(
        viewModel: ToDoWidgetViewModel,
        weekDays: @escaping (Int) -> [Date],
        onWeekOffsetChanged: @escaping (Int) -> Void
    ) {
        self.viewModel = viewModel
        self.weekDays = weekDays
        self.onWeekOffsetChanged = onWeekOffsetChanged
        self.hostingControllers = (0..<3).map { i in
            UIHostingController(rootView: ToDoWeekPageView(weekDays: weekDays(i - 1), viewModel: viewModel))
        }
        for hc in self.hostingControllers {
            hc.view.backgroundColor = .clear
        }
    }

    func observeFrameChange(on collectionView: UICollectionView) {
        observation = collectionView.observe(\.frame) { collectionView, _ in
            collectionView.collectionViewLayout.invalidateLayout()
        }
    }

    // MARK: - UICollectionViewDataSource

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        3
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "cell", for: indexPath)
        cell.backgroundColor = .clear
        cell.viewWithTag(Self.hostedViewTag)?.removeFromSuperview()

        guard let hcView = hostingControllers[indexPath.row].view else { return cell }
        hcView.tag = Self.hostedViewTag
        hcView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        hcView.frame = CGRect(origin: .zero, size: cell.frame.size)
        cell.addSubview(hcView)

        return cell
    }

    // MARK: - UICollectionViewDelegate

    func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        guard !didScrollToInitialPage else { return }
        didScrollToInitialPage = true
        collectionView.scrollToItem(at: IndexPath(row: 1, section: 0), at: .centeredHorizontally, animated: false)
    }

    func collectionView(_ collectionView: UICollectionView, targetContentOffsetForProposedContentOffset proposedContentOffset: CGPoint) -> CGPoint {
        CGPoint(x: collectionView.frame.size.width, y: 0)
    }

    // MARK: - UICollectionViewDelegateFlowLayout

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        collectionView.frame.size
    }

    // MARK: - UIScrollViewDelegate

    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        guard let collectionView else { return }
        handleScrollEnd(collectionView)
    }

    func scrollViewDidEndScrollingAnimation(_ scrollView: UIScrollView) {
        guard let collectionView else { return }
        handleScrollEnd(collectionView)
    }

    // MARK: - Programmatic Navigation

    func scrollToPrevious(_ collectionView: UICollectionView) {
        collectionView.setContentOffset(CGPoint(x: 0, y: 0), animated: true)
    }

    func scrollToNext(_ collectionView: UICollectionView) {
        collectionView.setContentOffset(CGPoint(x: 2 * collectionView.frame.width, y: 0), animated: true)
    }

    func scrollToToday(_ collectionView: UICollectionView) {
        guard currentWeekOffset != 0 else { return }
        let targetPage = currentWeekOffset > 0 ? 0 : 2
        hostingControllers[targetPage].rootView = makePageView(weekOffset: 0)
        pendingWeekOffset = 0
        collectionView.setContentOffset(
            CGPoint(x: CGFloat(targetPage) * collectionView.frame.width, y: 0),
            animated: true
        )
    }

    // MARK: - Private

    private func handleScrollEnd(_ collectionView: UICollectionView) {
        guard collectionView.frame.width > 0 else { return }
        let page = Int(round(collectionView.contentOffset.x / collectionView.frame.width))
        guard page != 1 else { return }

        if let pending = pendingWeekOffset {
            currentWeekOffset = pending
            pendingWeekOffset = nil
        } else {
            currentWeekOffset += page == 0 ? -1 : 1
        }

        onWeekOffsetChanged(currentWeekOffset)
        updateAllCells()
        collectionView.setContentOffset(
            CGPoint(x: collectionView.frame.width, y: 0),
            animated: false
        )
    }

    private func updateAllCells() {
        for i in 0..<3 {
            hostingControllers[i].rootView = makePageView(weekOffset: currentWeekOffset + i - 1)
        }
    }

    private func makePageView(weekOffset: Int) -> ToDoWeekPageView {
        ToDoWeekPageView(weekDays: weekDays(weekOffset), viewModel: viewModel)
    }
}
