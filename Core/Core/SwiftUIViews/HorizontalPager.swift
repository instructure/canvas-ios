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
    private let proxy: WeakObject<UICollectionView>?
    private let pageFactory: (_ pageIndex: Int) -> Page

    public init(pageCount: Int, size: CGSize, proxy: WeakObject<UICollectionView>? = nil, _ cellFactory: @escaping (_ pageIndex: Int) -> Page) {
        self.pageCount = pageCount
        self.size = size
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
        return collectionView
    }

    public func makeCoordinator() -> Coordinator {
        HorizontalPager.Coordinator(pageCount: pageCount, pageFactory)
    }

    public func updateUIView(_ collectionView: UICollectionView, context: Self.Context) {
        collectionView.register(UICollectionViewCell.self, forCellWithReuseIdentifier: "cell")
        collectionView.dataSource = context.coordinator
        collectionView.backgroundColor = .clear
        collectionView.scrollToItem(at: IndexPath(row: 1, section: 0), at: .centeredHorizontally, animated: false)
        proxy?.object = collectionView
    }
}

// MARK: - UICollectionView DataSource

extension HorizontalPager {
    public class Coordinator: NSObject, UICollectionViewDataSource {
        private let pageCount: Int
        private let pageFactory: (_ pageIndex: Int) -> Page

        public init(pageCount: Int, _ pageFactory: @escaping (_ pageIndex: Int) -> Page) {
            self.pageCount = pageCount
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
            HorizontalPager(pageCount: colors.count, size: geometry.size, proxy: collectionViewProxy) { pageIndex in
                ZStack {
                    colors[pageIndex]
                    Text(verbatim: "\(pageIndex)")
                        .foregroundColor(.white)
                }
            }
            .onAppear {
                DispatchQueue.main.async {
                    collectionViewProxy.object?.scrollToItem(at: IndexPath(row: 1, section: 0), at: .centeredHorizontally, animated: false)
                }
            }
        }
        .previewDevice(PreviewDevice(stringLiteral: "iPhone 12"))
    }
}

#endif
