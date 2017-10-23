//
// Copyright (C) 2016-present Instructure, Inc.
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
// http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.
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


