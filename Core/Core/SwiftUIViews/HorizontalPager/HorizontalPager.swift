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

// MARK: - UICollectionView Wrapping

public struct HorizontalPager<Page: View>: UIViewRepresentable {
    private let pageCount: Int
    private let initialPageIndex: Int
    @Binding private var currentPageIndex: Int
    private let pagerProxy: HorizontalPagerProxy?
    private let pageFactory: (_ pageIndex: Int) -> Page
    @State private var nextPageEventListener: AnyCancellable?
    @State private var previousPageEventListener: AnyCancellable?
    @State private var scrollToPageEventListener: AnyCancellable?

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

        let safeIndex = { index in
            min(max(0, index), pageCount - 1)
        }

        // async to avoid "Modifying state during view update, this will cause undefined behavior." error
        DispatchQueue.main.async {
            previousPageEventListener = pagerProxy?.scrollToPreviousPageSubject.sink {
                collectionView.scrollToItem(at: IndexPath(row: safeIndex(currentPageIndex - 1), section: 0), at: .centeredHorizontally, animated: true)
            }
            nextPageEventListener = pagerProxy?.scrollToNextPageSubject.sink {
                collectionView.scrollToItem(at: IndexPath(row: safeIndex(currentPageIndex + 1), section: 0), at: .centeredHorizontally, animated: true)
            }
            scrollToPageEventListener = pagerProxy?.scrollToPageSubject.sink { (pageIndex, animated) in
                collectionView.scrollToItem(at: IndexPath(row: safeIndex(pageIndex), section: 0), at: .centeredHorizontally, animated: animated)
            }
        }

        return collectionView
    }

    public func makeCoordinator() -> HorizontalPagerCoordinator<Page> {
        HorizontalPager.Coordinator(pageCount: pageCount, initialPageIndex: initialPageIndex, currentPageIndex: $currentPageIndex, pageFactory)
    }

    public func updateUIView(_ collectionView: UICollectionView, context: HorizontalPager.Context) {
    }
}

// MARK: - Preview

#if DEBUG

struct HorizontalPager_Previews: PreviewProvider {
    private static let colors = [
        Color.red,
        Color.blue,
        Color.green,
        Color.black
    ]

    static var previews: some View {
        HorizontalPager(pageCount: colors.count, initialPageIndex: 1, currentPageIndex: .constant(0)) { pageIndex in
            ZStack {
                colors[pageIndex]
                Text(verbatim: "\(pageIndex)")
                    .foregroundColor(.textLightest.variantForLightMode)
            }
        }
        .previewDevice(PreviewDevice(stringLiteral: "iPhone 12"))
    }
}

#endif
