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

import Combine
import UIKit
import SwiftUI

/**
 A utility entity which can be passed to a `HorizontalPager` in order to change pages programatically.
 */
public struct HorizontalPagerProxy {
    public let scrollToNextPageSubject = PassthroughSubject<Void, Never>()
    public let scrollToPreviousPageSubject = PassthroughSubject<Void, Never>()

    public func scrollToNextPage() {
        scrollToNextPageSubject.send()
    }

    public func scrollToPreviousPage() {
        scrollToPreviousPageSubject.send()
    }
}

// MARK: - UICollectionView Wrapping

public struct HorizontalPager<Page: View>: UIViewRepresentable {
    private let pageCount: Int
    private let initialPageIndex: Int
    @Binding private var currentPageIndex: Int
    private let pagerProxy: HorizontalPagerProxy?
    private let pageFactory: (_ pageIndex: Int) -> Page
    @State private var nextPageEventListener: AnyCancellable?
    @State private var previousPageEventListener: AnyCancellable?

    /**
     - parameters:
        - currentPageIndex: The actual page's index is written into this binding by this view. Modifying it from outside has no effect, use `pagerProxy` to control scrolling.
     */
    public init(pageCount: Int,
                initialPageIndex: Int = 0,
                currentPageIndex: Binding<Int>,
                pagerProxy: HorizontalPagerProxy? = nil,
                _ cellFactory: @escaping (_ pageIndex: Int) -> Page) {
        self.pageCount = pageCount
        self.initialPageIndex = initialPageIndex
        self._currentPageIndex = currentPageIndex
        self.pagerProxy = pagerProxy
        self.pageFactory = cellFactory
    }

    public func makeUIView(context: Self.Context) -> UICollectionView {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .horizontal
        layout.minimumLineSpacing = 0

        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.isPrefetchingEnabled = false
        collectionView.isPagingEnabled = true
        collectionView.showsHorizontalScrollIndicator = false
        collectionView.register(UICollectionViewCell.self, forCellWithReuseIdentifier: "cell")
        collectionView.backgroundColor = .clear
        // Delegate has to be set before datasource, otherwise UICollectionViewDelegateFlowLayout methods won't be called.
        collectionView.delegate = context.coordinator
        collectionView.dataSource = context.coordinator

        context.coordinator.observeFrameChange(on: collectionView)

        // async to avoid "Modifying state during view update, this will cause undefined behavior." error
        DispatchQueue.main.async {
            previousPageEventListener = pagerProxy?.scrollToPreviousPageSubject.sink {
                let safeIndex = min(max(0, currentPageIndex - 1), pageCount - 1)
                collectionView.scrollToItem(at: IndexPath(row: safeIndex, section: 0), at: .centeredHorizontally, animated: true)
            }
            nextPageEventListener = pagerProxy?.scrollToNextPageSubject.sink {
                let safeIndex = min(max(0, currentPageIndex + 1), pageCount - 1)
                collectionView.scrollToItem(at: IndexPath(row: safeIndex, section: 0), at: .centeredHorizontally, animated: true)
            }
        }

        return collectionView
    }

    public func makeCoordinator() -> Coordinator {
        HorizontalPager.Coordinator(pageCount: pageCount, initialPageIndex: initialPageIndex, currentPageIndex: $currentPageIndex, pageFactory)
    }

    public func updateUIView(_ collectionView: UICollectionView, context: HorizontalPager.Context) {
    }
}

// MARK: - UICollectionView DataSource

extension HorizontalPager {
    public class Coordinator: NSObject, UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {
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
            let pageIndex = Int(scrollView.contentOffset.x / scrollView.frame.size.width)

            if pageIndex != currentPageIndex {
                currentPageIndex = pageIndex
            }
        }
    }
}

// MARK: - Preview

#if DEBUG

struct HorizontalPager_Previews: PreviewProvider {
    private static let colors = [
        Color.red,
        Color.blue,
        Color.green,
        Color.black,
    ]

    static var previews: some View {
        HorizontalPager(pageCount: colors.count, initialPageIndex: 1, currentPageIndex: .constant(0)) { pageIndex in
            ZStack {
                colors[pageIndex]
                Text(verbatim: "\(pageIndex)")
                    .foregroundColor(.white)
            }
        }
        .previewDevice(PreviewDevice(stringLiteral: "iPhone 12"))
    }
}

#endif
