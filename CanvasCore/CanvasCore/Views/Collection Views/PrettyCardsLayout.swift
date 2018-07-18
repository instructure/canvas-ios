//
// Copyright (C) 2016-present Instructure, Inc.
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


extension UITraitCollection {
    fileprivate var prettyCardsPadding: CGFloat {
        return (horizontalSizeClass == .compact || userInterfaceIdiom == .phone) ? 20.0 : 40
    }
}

private let minCardWidth: CGFloat = 220.0
private let maxCardWidth: CGFloat = 360.0


open class PrettyCardsLayout: UICollectionViewFlowLayout {
    open override func prepare() {
        
        guard let collectionView = collectionView else { ❨╯°□°❩╯⌢"You can't prepare a layout for a nil collectionView" }
        let traits = collectionView.traitCollection
        let boundsWidth = collectionView.bounds.width
        
        let padding: CGFloat = traits.prettyCardsPadding
        updatePadding(padding)
        scrollDirection = .vertical
        estimatedItemSize = CGSize(width: widthOfItemIn(boundsWidth, traits: traits), height: 160)
        
        for cell in collectionView.visibleCells {
            if let prettyCell = cell as? PrettyCardsCell {
                prettyCell.widthConstraint.constant = estimatedItemSize.width
                prettyCell.setNeedsLayout()
            }
        }
        
        super.prepare()
    }
    
    func updatePadding(_ padding: CGFloat) {
        minimumLineSpacing = padding
        minimumInteritemSpacing = padding
        sectionInset = UIEdgeInsets(top: padding, left: padding, bottom: padding, right: padding)
    }
    
    open func widthOfItemIn(_ width: CGFloat, traits: UITraitCollection) -> CGFloat {
        let padding = traits.prettyCardsPadding
        let widthForOneColumn = width - 2.0 * padding
        return (1...5).reduce(widthForOneColumn, {initial, new in
            let totalPadding = CGFloat(new+1)*padding
            let proposedWidth = (width-totalPadding)/CGFloat(new)
            if minCardWidth <= proposedWidth && proposedWidth <= maxCardWidth {
                return proposedWidth
            }
            return initial
        })
    }
    
    open override func shouldInvalidateLayout(forBoundsChange newBounds: CGRect) -> Bool {
        if let collectionView = collectionView {
            let traits = collectionView.traitCollection
            let padding = traits.prettyCardsPadding
            if minimumLineSpacing != padding {
                updatePadding(padding)
                return true
            }
            
            if estimatedItemSize.width != widthOfItemIn(newBounds.size.width, traits: traits) {
                return true
            }
        }
        
        return super.shouldInvalidateLayout(forBoundsChange: newBounds)
    }
}


open class PrettyCardsCell: UICollectionViewCell {
    fileprivate(set) open lazy var widthConstraint: NSLayoutConstraint = {
        let constraint = NSLayoutConstraint(item: self.contentView, attribute: .width, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1, constant: 300)
        constraint.identifier = "Pretty Card Width"
        return constraint
    }()
    
    public override init(frame: CGRect) {
        super.init(frame: frame)
        translatesAutoresizingMaskIntoConstraints = false
        contentView.translatesAutoresizingMaskIntoConstraints = false
        contentView.addConstraint(widthConstraint)
    }
    
    public required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        translatesAutoresizingMaskIntoConstraints = false
        contentView.translatesAutoresizingMaskIntoConstraints = false
        contentView.addConstraint(widthConstraint)
    }
}


