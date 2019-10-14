//
// This file is part of Canvas.
// Copyright (C) 2019-present  Instructure, Inc.
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

open class HorizontalMenuViewController: UIViewController {

    fileprivate static let defaultMenuHeight: CGFloat = 52
    var menu: UICollectionView?
    var pages: UICollectionView?
    var underlineView: UIView?
    var bottomBorder: UIView?
    var underlineWidthConstraint: NSLayoutConstraint?
    var underlineLeftConstraint: NSLayoutConstraint?
    var menuHeightConstraint: NSLayoutConstraint?
    public weak var delegate: HorizontalPagedMenuDelegate?
    private var selectedIndexPath: IndexPath = IndexPath(item: 0, section: 0)

    private var itemCount: Int {
        return delegate?.viewControllers.count ?? 0
    }

    private var menuCellHeight: CGFloat {
        return delegate?.menuHeight ?? HorizontalMenuViewController.defaultMenuHeight
    }

    override open func viewDidLoad() {
        super.viewDidLoad()
        edgesForExtendedLayout = []
        view.backgroundColor = UIColor.named(.backgroundLightest)
        NotificationCenter.default.addObserver(self, selector: #selector(splitViewControllerWillChangeDisplayModes),
                                               name: Notification.Name.SplitViewControllerWillChangeDisplayModeNotification, object: nil)
    }

    override open func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        pages?.collectionViewLayout.invalidateLayout()
        menu?.collectionViewLayout.invalidateLayout()
    }

    public func reload() {
        menu?.reloadData()
        pages?.reloadData()
    }

    public func layoutViewControllers() {
        if menu != nil {
            updateFrames()
        } else {
            setupMenu()
            setupPages()
            setupUnderline()
            setupBottomBorder()
        }
    }

    func updateFrames() {
        guard let menuLayout = menu?.collectionViewLayout as? UICollectionViewFlowLayout else { return }
        let menuItemWidth = view.bounds.size.width / CGFloat(itemCount)
        menuLayout.itemSize = CGSize(width: menuItemWidth, height: menuCellHeight)
        menuHeightConstraint?.constant = itemCount == 1 ? 0 : menuCellHeight
        underlineWidthConstraint?.constant = menuItemWidth
        view.layoutIfNeeded()
        reload()
    }

    func setupMenu() {
        assert(delegate != nil)
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .horizontal
        layout.itemSize = CGSize(width: view.bounds.size.width / CGFloat(itemCount), height: menuCellHeight)
        layout.minimumLineSpacing = 0

        menu = UICollectionView(frame: .zero, collectionViewLayout: layout)
        guard let menu = menu else { return }
        menu.backgroundColor = UIColor.named(.backgroundLightest)
        menu.register(MenuCell.self, forCellWithReuseIdentifier: String(describing: MenuCell.self))
        menu.showsHorizontalScrollIndicator = false
        menu.dataSource = self
        menu.delegate = self

        view.addSubview(menu)
        menu.pinToLeftAndRightOfSuperview()
        menuHeightConstraint = menu.addConstraintsWithVFL("V:[view(height)]", metrics: ["height": menuCellHeight])?.first
        menu.addConstraintsWithVFL("V:|[view]")
    }

    func setupPages() {
        assert(delegate != nil)
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .horizontal
        layout.itemSize = CGSize(width: view.frame.width, height: view.frame.height)
        layout.minimumLineSpacing = 0.0

        pages = UICollectionView(frame: .zero, collectionViewLayout: layout)
        guard let pages = pages, let menu = menu else { return }
        pages.backgroundColor = UIColor.named(.backgroundLightest)
        pages.isPagingEnabled = true
        pages.showsHorizontalScrollIndicator = false
        pages.dataSource = self
        pages.delegate = self

        // we do not want to reuse these cells
        for i in 0..<itemCount {
            pages.register(UICollectionViewCell.self, forCellWithReuseIdentifier: "child_\(i)")
        }

        view.addSubview(pages)
        pages.pinToLeftAndRightOfSuperview()
        pages.addConstraintsWithVFL("V:[menu][view]|", views: ["menu": menu])
    }

    func setupUnderline() {
        underlineView = UIView()
        guard let underlineView = underlineView else { return }
        view.addSubview(underlineView)
        let w = view.bounds.size.width / CGFloat(itemCount)
        underlineWidthConstraint = underlineView.addConstraintsWithVFL("H:[view(w)]", metrics: ["w": w])?.first
        underlineLeftConstraint = underlineView.addConstraintsWithVFL("H:|[view]")?.first
        underlineView.addConstraintsWithVFL("V:[view(2)]")
        let bottoms = NSLayoutConstraint(item: underlineView, attribute: .bottom, relatedBy: .equal, toItem: menu, attribute: .bottom, multiplier: 1.0, constant: -1.1)
        view.addConstraint(bottoms)
        underlineView.backgroundColor = delegate?.menuItemSelectedColor ?? UIColor.blue
    }

    func setupBottomBorder() {
        bottomBorder = UIView()
        guard let bottomBorder = bottomBorder, let underlineView = underlineView else { return }
        bottomBorder.backgroundColor = UIColor.named(.borderDark)
        view.insertSubview(bottomBorder, belowSubview: underlineView)
        bottomBorder.pinToLeftAndRightOfSuperview()
        let bottoms = NSLayoutConstraint(item: bottomBorder, attribute: .bottom, relatedBy: .equal, toItem: menu, attribute: .bottom, multiplier: 1.0, constant: -1)
        view.addConstraint(bottoms)
        bottomBorder.addConstraintsWithVFL("V:[view(\(1.0 / UIScreen.main.scale))]")
    }
}

extension HorizontalMenuViewController: UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {
    public func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return itemCount
    }

    public func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if collectionView == menu {
            let cell: MenuCell = collectionView.dequeue(for: indexPath)
            cell.title?.text = delegate?.menuItemTitle(at: indexPath)
            cell.title?.font = delegate?.menuItemFont
            cell.title?.textColor = delegate?.menuItemDefaultColor
            cell.selectionColor = delegate?.menuItemSelectedColor
            cell.isAccessibilityElement = true
            cell.accessibilityTraits = [.button, .header]
            cell.accessibilityIdentifier = delegate?.accessibilityIdentifier(at: indexPath)
            cell.accessibilityLabel = cell.title?.text
            if indexPath == selectedIndexPath {
                cell.isSelected = true
                cell.accessibilityTraits.insert(.selected)
            }

            return cell
        } else {
            let identifier = "child_\(indexPath.item)"
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: identifier, for: indexPath)
            if let vc = delegate?.viewControllers[indexPath.item] {
                embed(vc, in: cell.contentView)
            }
            return cell
        }
    }

    public func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if collectionView == menu {
            pages?.scrollToItem(at: indexPath, at: .centeredHorizontally, animated: true)

            let cell = collectionView.cellForItem(at: selectedIndexPath)
            cell?.isSelected = false
            selectedIndexPath = indexPath
        }
    }

    public func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        if collectionView == menu {
            return CGSize(width: view.bounds.size.width / CGFloat(itemCount), height: menuCellHeight)
        } else {
            return collectionView.bounds.size
        }
    }

    public func scrollViewDidScroll(_ scrollView: UIScrollView) {
      if scrollView == pages {
          underlineLeftConstraint?.constant = scrollView.contentOffset.x / CGFloat(itemCount)
      }
    }

    public func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        let rect = CGRect(origin: scrollView.contentOffset, size: CGSize(width: 1, height: 1))
        let attributes = pages?.collectionViewLayout.layoutAttributesForElements(in: rect)

        if let indexPath = attributes?.first?.indexPath {
            menu?.cellForItem(at: selectedIndexPath)?.isSelected = false
            menu?.cellForItem(at: indexPath)?.isSelected = true
            selectedIndexPath = indexPath
        }
    }

    override open func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        super.viewWillTransition(to: size, with: coordinator)
        coordinator.animate(alongsideTransition: { [weak self] _ in
            self?.refreshOnLayoutTransitions()
        }, completion: nil)
    }

    func refreshOnLayoutTransitions() {
        layoutViewControllers()
        reload()
        menu?.scrollToItem(at: selectedIndexPath, at: .left, animated: false)
        pages?.scrollToItem(at: selectedIndexPath, at: .left, animated: false)
    }

    @objc public func splitViewControllerWillChangeDisplayModes() {
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.04) { [weak self] in
            UIView.animate(withDuration: 0.1) {
                self?.refreshOnLayoutTransitions()
            }
        }
    }

    public class MenuCell: UICollectionViewCell {
        public var title: UILabel?
        public var selectionColor: UIColor? = UIColor.named(.borderDarkest)

        override init(frame: CGRect) {
            super.init(frame: frame)
            setup()
        }

        required init?(coder: NSCoder) {
            super.init(coder: coder)
            setup()
        }

        func setup() {
            title = UILabel(frame: .zero)
            guard let title = title else { return }
            title.textAlignment = .center
            contentView.addSubview(title)
            title.pin(inside: contentView)
            title.textColor = .systemBlue
            contentView.backgroundColor = .white
        }

        override public var isSelected: Bool {
            didSet {
                UIView.animate(withDuration: 0.2) { [weak self] in
                    let selected = self?.isSelected ?? false
                    let selectedColor = self?.selectionColor?.ensureContrast(against: UIColor.named(.backgroundLightest))
                    let deSelectedColor = UIColor.named(.textDark).ensureContrast(against: UIColor.named(.backgroundLightest))
                    self?.title?.textColor = selected ? selectedColor : deSelectedColor
                }
            }
        }
    }
}

public protocol HorizontalPagedMenuDelegate: class {
    var viewControllers: [UIViewController] { get }
    var menuHeight: CGFloat { get }
    var menuItemSelectedColor: UIColor? { get }
    var menuItemDefaultColor: UIColor? { get }
    var menuItemFont: UIFont { get }

    func menuItemTitle(at: IndexPath) -> String
    func accessibilityIdentifier(at: IndexPath) -> String
}

public extension HorizontalPagedMenuDelegate {
    var menuHeight: CGFloat {
        HorizontalMenuViewController.defaultMenuHeight
    }

    var menuItemDefaultColor: UIColor? { UIColor.named(.textDark) }

    var menuItemFont: UIFont { .scaledNamedFont(.semibold16) }
}
