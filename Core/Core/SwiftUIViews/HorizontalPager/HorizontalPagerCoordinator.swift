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

public class HorizontalPagerCoordinator<Page: View>: NSObject, UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {
    private let pageCount: Int
    private let initialPageIndex: Int
    @Binding private var currentPageIndex: Int
    private let pageFactory: (_ pageIndex: Int) -> Page
    private var scrolledToInitialPage = false
    private var observation: NSKeyValueObservation?

    public init(pageCount: Int,
                initialPageIndex: Int,
                currentPageIndex: Binding<Int>,
                _ pageFactory: @escaping (_ pageIndex: Int) -> Page) {
        self.pageCount = pageCount
        self.initialPageIndex = initialPageIndex
        self._currentPageIndex = currentPageIndex
        self.pageFactory = pageFactory
    }

    public func observeFrameChange(on collectionView: UICollectionView) {
        observation = collectionView.observe(\.frame) { collectionView, _ in
            // Force a layout update so cells always match the actual size of the UICollectionView
            collectionView.collectionViewLayout.invalidateLayout()
        }
    }

    // MARK: UICollectionViewDataSource

    public func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        pageCount
    }

    public func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let embeddedViewTag = 382576

        let cell = collectionView.dequeue(withReuseIdentifier: "cell", for: indexPath)
        cell.backgroundColor = .backgroundLightest
        cell.viewWithTag(embeddedViewTag)?.removeFromSuperview()

        let wrapperView = UIHostingController(rootView: pageFactory(indexPath.row)).view!
        wrapperView.tag = embeddedViewTag
        wrapperView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        wrapperView.frame = CGRect(origin: .zero, size: cell.frame.size)
        cell.addSubview(wrapperView)

        return cell
    }

    // MARK: UICollectionViewDelegate

    public func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        if scrolledToInitialPage { return }

        scrolledToInitialPage = true
        collectionView.scrollToItem(at: IndexPath(row: initialPageIndex, section: 0), at: .centeredHorizontally, animated: false)
    }

    /**
     This method keeps the collectionview's scroll focused on the same cell (page) after the device is rotated.
     */
    public func collectionView(_ collectionView: UICollectionView, targetContentOffsetForProposedContentOffset proposedContentOffset: CGPoint) -> CGPoint {
        guard let currentCellIndex = collectionView.indexPathsForVisibleItems.first else { return collectionView.contentOffset }
        return CGPoint(x: collectionView.frame.size.width * CGFloat(currentCellIndex.row), y: 0)
    }

    // MARK: UICollectionViewDelegateFlowLayout

    public func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        collectionView.frame.size
    }

    // MARK: UIScrollViewDelegate

    public func scrollViewDidScroll(_ scrollView: UIScrollView) {
        // When the collectionview receives VoiceOver focus from above, it will scroll to the first cell.
        // If the focus moves from below to the collectionview then it scrolls to the last cell.
        // We try to catch these scrolling events and restore the scroll position to its original state.
        if UIAccessibility.isVoiceOverRunning {
            let isJumpingToFirstPage = scrollView.contentOffset == .zero && currentPageIndex != 1
            let lastPageContentOffset = scrollView.contentSize.width - scrollView.frame.size.width
            let isJumpingToLastPage = scrollView.contentOffset.x == lastPageContentOffset && currentPageIndex != pageCount - 2

            if isJumpingToFirstPage || isJumpingToLastPage {
                scrollView.scrollRectToVisible(CGRect(origin: CGPoint(x: currentPageIndex * Int(scrollView.frame.size.width), y: 0), size: scrollView.frame.size), animated: false)
                return
            }
        }

        let pageIndex = Int(scrollView.contentOffset.x / scrollView.frame.size.width)

        if pageIndex != currentPageIndex {
            currentPageIndex = pageIndex
        }
    }
}
