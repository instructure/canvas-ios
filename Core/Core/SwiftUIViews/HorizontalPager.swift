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

import UIKit
import SwiftUI

// MARK: - UICollectionView Wrapping

public struct HorizontalPager<Page: View>: UIViewRepresentable {
    private let pageCount: Int
    private let size: CGSize
    private let initialPageIndex: Int
    private let proxy: WeakObject<UICollectionView>?
    private let pageFactory: (_ pageIndex: Int) -> Page

    public init(pageCount: Int, size: CGSize, initialPageIndex: Int = 0, proxy: WeakObject<UICollectionView>? = nil, _ cellFactory: @escaping (_ pageIndex: Int) -> Page) {
        self.pageCount = pageCount
        self.size = size
        self.initialPageIndex = initialPageIndex
        self.proxy = proxy
        self.pageFactory = cellFactory
    }

    public func makeUIView(context: Self.Context) -> UICollectionView {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .horizontal
        layout.itemSize = size
        layout.minimumLineSpacing = 0

        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.isPagingEnabled = true
        collectionView.showsHorizontalScrollIndicator = false
        collectionView.register(UICollectionViewCell.self, forCellWithReuseIdentifier: "cell")
        collectionView.backgroundColor = .clear
        collectionView.dataSource = context.coordinator
        collectionView.delegate = context.coordinator
        proxy?.object = collectionView

        return collectionView
    }

    public func makeCoordinator() -> Coordinator {
        HorizontalPager.Coordinator(pageCount: pageCount, initialPageIndex: initialPageIndex, pageFactory)
    }

    public func updateUIView(_ collectionView: UICollectionView, context: Self.Context) {
        // TODO: Fix rotation
    }
}

// MARK: - UICollectionView DataSource

extension HorizontalPager {
    public class Coordinator: NSObject, UICollectionViewDataSource, UICollectionViewDelegate {
        private let pageCount: Int
        private let initialPageIndex: Int
        private let pageFactory: (_ pageIndex: Int) -> Page
        private var scrolledToInitialPage = false

        public init(pageCount: Int, initialPageIndex: Int, _ pageFactory: @escaping (_ pageIndex: Int) -> Page) {
            self.pageCount = pageCount
            self.initialPageIndex = initialPageIndex
            self.pageFactory = pageFactory
        }

        public func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
            pageCount
        }

        public func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
            let wrapperView = UIHostingController(rootView: pageFactory(indexPath.row)).view!
            wrapperView.translatesAutoresizingMaskIntoConstraints = false

            let cell = collectionView.dequeue(withReuseIdentifier: "cell", for: indexPath)
            cell.addSubview(wrapperView)
            cell.translatesAutoresizingMaskIntoConstraints = false

            let constraints = [
                wrapperView.widthAnchor.constraint(equalToConstant: collectionView.frame.size.width),
                wrapperView.heightAnchor.constraint(equalToConstant: collectionView.frame.size.height),
             ]
             NSLayoutConstraint.activate(constraints)

            return cell
        }

        public func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
            if scrolledToInitialPage { return }

            scrolledToInitialPage = true
            collectionView.scrollToItem(at: IndexPath(row: initialPageIndex, section: 0), at: .centeredHorizontally, animated: false)
        }
    }
}

// MARK: - UICollectionView Proxy To SwiftUI

public class WeakObject<T: AnyObject> {
    public weak var object: T?
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
    private static let collectionViewProxy = WeakObject<UICollectionView>()

    static var previews: some View {
        GeometryReader { geometry in
            HorizontalPager(pageCount: colors.count, size: geometry.size, initialPageIndex: 1, proxy: collectionViewProxy) { pageIndex in
                ZStack {
                    colors[pageIndex]
                    Text(verbatim: "\(pageIndex)")
                        .foregroundColor(.white)
                }
            }
        }
        .previewDevice(PreviewDevice(stringLiteral: "iPhone 12"))
    }
}

#endif
