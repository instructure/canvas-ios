//
//  PrettyCardsLayout.swift
//  SoPretty
//
//  Created by Derrick Hathaway on 2/17/16.
//  Copyright © 2016 Instructure. All rights reserved.
//

import UIKit
import SoLazy

extension UITraitCollection {
    private var prettyCardsPadding: CGFloat {
        return (horizontalSizeClass == .Compact || userInterfaceIdiom == .Phone) ? 20.0 : 40
    }
}

private let minCardWidth: CGFloat = 250.0
private let maxCardWidth: CGFloat = 350.0


public class PrettyCardsLayout: UICollectionViewFlowLayout {
    public override func prepareLayout() {
        
        guard let collectionView = collectionView else { ❨╯°□°❩╯⌢"You can't prepare a layout for a nil collectionView" }
        let traits = collectionView.traitCollection
        let boundsWidth = collectionView.bounds.width
        
        let padding: CGFloat = traits.prettyCardsPadding
        updatePadding(padding)
        scrollDirection = .Vertical
        estimatedItemSize = CGSize(width: widthOfItemIn(boundsWidth, traits: traits), height: 160)
        
        for cell in collectionView.visibleCells() {
            if let prettyCell = cell as? PrettyCardsCell {
                prettyCell.widthConstraint.constant = estimatedItemSize.width
                prettyCell.setNeedsLayout()
            }
        }
        
        super.prepareLayout()
    }
    
    func updatePadding(padding: CGFloat) {
        minimumLineSpacing = padding
        minimumInteritemSpacing = padding
        sectionInset = UIEdgeInsets(top: padding, left: padding, bottom: padding, right: padding)
    }
    
    public func widthOfItemIn(width: CGFloat, traits: UITraitCollection) -> CGFloat {
        let padding = traits.prettyCardsPadding
        let widthForOneColumn = width - 2.0 * padding
        return (1...5).reduce(widthForOneColumn, combine: {initial, new in
            let totalPadding = CGFloat(new+1)*padding
            let proposedWidth = (width-totalPadding)/CGFloat(new)
            if minCardWidth <= proposedWidth && proposedWidth <= maxCardWidth {
                return proposedWidth
            }
            return initial
        })
    }
    
    public override func shouldInvalidateLayoutForBoundsChange(newBounds: CGRect) -> Bool {
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
        
        return super.shouldInvalidateLayoutForBoundsChange(newBounds)
    }
}


public class PrettyCardsCell: UICollectionViewCell {
    private(set) public lazy var widthConstraint: NSLayoutConstraint = {
        let constraint = NSLayoutConstraint(item: self.contentView, attribute: .Width, relatedBy: .Equal, toItem: nil, attribute: .NotAnAttribute, multiplier: 1, constant: 300)
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


