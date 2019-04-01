//
// Copyright (C) 2019-present Instructure, Inc.
//
// This program is free software: you can redistribute it and/or modify
// it under the terms of the GNU General Public License as published by
// the Free Software Foundation, version 3 of the License.
//
// This program is distributed in the hope that it will be useful,
// but WITHOUT ANY WARRANTY; without even the implied warranty of
// MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
// GNU General Public License for more details.
//
// You should have received a copy of the GNU General Public License
// along with this program.  If not, see <http://www.gnu.org/licenses/>.
//

import UIKit

public protocol HorizontalMenuDelegate: class {
    var maxItemWidth: CGFloat { get }
    var measurementFont: UIFont { get }
    var selectedColor: UIColor? { get }
    func menuItemCount() -> Int
    func menuItemTitle(at: IndexPath) -> String
    func didSelectItem(at: IndexPath)
}

public class HorizontalMenuView: UIView {
    @IBOutlet private weak var contentView: UIView!
    @IBOutlet private weak var collectionView: UICollectionView!
    private var selectedIndexPath: IndexPath? // = IndexPath(item: 0, section: 0)
    public weak var delegate: HorizontalMenuDelegate?
    private var cachedTotalWidthOfItems: CGFloat?
    private var cachedSpaceBetweenCells: CGFloat?

    public override init(frame: CGRect) {
        super.init(frame: frame)
        commonInit()
    }

    public required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        commonInit()
    }

    func commonInit() {
        //  TODO: - figure out why this does not work ??
        //  contentView = type(of: self).loadFromXib(nibName: "HorizontalMenuView")

        Bundle.core.loadNibNamed("HorizontalMenuView", owner: self, options: nil)
        addSubview(contentView)
        backgroundColor = UIColor.white.ensureContrast(against: .named(.white))
        contentView.backgroundColor = UIColor.white.ensureContrast(against: .named(.white))
        contentView.frame = CGRect.zero
        contentView.pin(inside: self)
        collectionView.registerCell(HorizontalMenuViewCell.self, bundle: Bundle.core)
        collectionView.dataSource = self
        collectionView.delegate = self
    }

    override public func layoutSubviews() {
        super.layoutSubviews()
        if selectedIndexPath == nil {
            selectedIndexPath = IndexPath(item: 0, section: 0)
            selectMenuItem(at: selectedIndexPath)
        }
        reload()
    }

    public func reload() {
        cachedTotalWidthOfItems = nil
        cachedSpaceBetweenCells = nil
        collectionView.reloadData()
        selectMenuItem(at: selectedIndexPath)
    }

    public func selectMenuItem(at: IndexPath?, animated: Bool = true) {
        guard let at = at else { return }
        collectionView.selectItem(at: at, animated: animated, scrollPosition: UICollectionView.ScrollPosition.centeredHorizontally)
    }
}

extension HorizontalMenuView: UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {

    public func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return delegate?.menuItemCount() ?? 0
    }

    public func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell: HorizontalMenuViewCell = collectionView.dequeue(for: indexPath)
        cell.title = delegate?.menuItemTitle(at: indexPath)
        cell.selectionColor = delegate?.selectedColor
        cell.titleFont = delegate?.measurementFont
        if indexPath == selectedIndexPath {
            cell.isSelected = true
        }
        return cell
    }

    public func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if let selectedIndexPath = selectedIndexPath {
            let cell = collectionView.cellForItem(at: selectedIndexPath)
            cell?.isSelected = false
        }
        selectedIndexPath = indexPath
        delegate?.didSelectItem(at: indexPath)
    }

    public func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return sizeForItem(for: indexPath)
    }

    public func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        let spacing = spaceBetweenCells()
        return UIEdgeInsets(top: 0, left: spacing, bottom: 0, right: spacing)
    }

    public func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return spaceBetweenCells()
    }

    func sizeForItem(for indexPath: IndexPath) -> CGSize {
        guard let font = delegate?.measurementFont,
            let title = delegate?.menuItemTitle(at: indexPath),
            let maxWidth = delegate?.maxItemWidth
            else { return CGSize.zero }
        let maxHeight: CGFloat = 40.0
        let constraintRect = CGSize(width: maxWidth, height: maxHeight)
        let boundingBox = title.boundingRect(with: constraintRect, options: [], attributes: [NSAttributedString.Key.font: font], context: nil)
        return CGSize(width: ceil(boundingBox.width), height: maxHeight)
    }

    func spaceBetweenCells() -> CGFloat {
        if let cachedSpaceBetweenCells = cachedSpaceBetweenCells { return cachedSpaceBetweenCells }

        guard let itemCount = delegate?.menuItemCount() else { return 0.0 }
        if cachedTotalWidthOfItems == nil {
            var totalWidth: CGFloat = 0
            for i in 0..<itemCount {
                let size = sizeForItem(for: IndexPath(item: i, section: 0))
                totalWidth += size.width
            }
            cachedTotalWidthOfItems = totalWidth
        }
        let space = floor( (frame.size.width - (cachedTotalWidthOfItems ?? 0)) / CGFloat(itemCount + 1) )
        cachedSpaceBetweenCells = space
        return space
    }
}
