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
    func accessibilityLabel(at: IndexPath) -> String
}

public class HorizontalMenuView: UIView {
    @IBOutlet private weak var contentView: UIView!
    @IBOutlet private weak var collectionView: UICollectionView!
    private var selectedIndexPath: IndexPath? // = IndexPath(item: 0, section: 0)
    public weak var delegate: HorizontalMenuDelegate?
    private var cachedTotalWidthOfItems: CGFloat?
    private var cachedSpaceBetweenCells: CGFloat?
    private var underlineView: UIView?

    public override init(frame: CGRect) {
        super.init(frame: frame)
        commonInit()
    }

    public required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        commonInit()
    }

    func commonInit() {
        contentView = loadFromXib()
        backgroundColor = UIColor.named(.backgroundLightest)
        contentView.backgroundColor = UIColor.named(.backgroundLightest)
        collectionView.registerCell(HorizontalMenuViewCell.self, bundle: Bundle.core)
        collectionView.dataSource = self
        collectionView.delegate = self
    }

    override public func layoutSubviews() {
        super.layoutSubviews()
        if selectedIndexPath == nil {
            selectedIndexPath = IndexPath(item: 0, section: 0)
            setupUnderlineView()
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
        collectionView(collectionView, didSelectItemAt: at)
    }

    private func setupUnderlineView() {
        underlineView = UIView()
        underlineView?.backgroundColor = delegate?.selectedColor
        underlineView?.frame = CGRect.zero
        guard let underlineView = underlineView else { return }
        addSubview(underlineView)
        animateUnderlineView(to: selectedIndexPath)
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
        cell.accessibilityLabel = delegate?.accessibilityLabel(at: indexPath)
        return cell
    }

    public func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if let selectedIndexPath = selectedIndexPath {
            let cell = collectionView.cellForItem(at: selectedIndexPath)
            cell?.isSelected = false
        }
        selectedIndexPath = indexPath
        delegate?.didSelectItem(at: indexPath)
        animateUnderlineView(to: indexPath)
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

    func frameForCollectionViewCell(at: IndexPath?, translationView: UIView? = nil) -> CGRect {
        guard let at = at else { return CGRect.zero }
        let attributes = collectionView.layoutAttributesForItem(at: at)
        if var frame = attributes?.frame {
            frame = collectionView.convert(frame, to: translationView ?? collectionView.superview)
            return frame
        }
        return CGRect.zero
    }

    func animateUnderlineView(to: IndexPath?) {
        underlineView?.backgroundColor = delegate?.selectedColor
        let frame = frameForCollectionViewCell(at: to)
        var newFrame = frame
        let underlineViewHeight: CGFloat = 2
        newFrame.origin.y = frame.maxY - underlineViewHeight
        newFrame.size.height = underlineViewHeight

        let duration: Double = Double(self.frame.size.width) * 0.00054

        UIView.animate(withDuration: duration, delay: 0, options: [.beginFromCurrentState, .curveEaseInOut], animations: { [weak self] in
            self?.underlineView?.frame = newFrame
            }, completion: nil)
    }
}
