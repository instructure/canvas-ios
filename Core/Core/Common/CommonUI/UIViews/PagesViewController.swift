//
// This file is part of Canvas.
// Copyright (C) 2020-present  Instructure, Inc.
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

public protocol PagesViewControllerDataSource: AnyObject {
    func pagesViewController(_ pages: PagesViewController, pageBefore page: UIViewController) -> UIViewController?
    func pagesViewController(_ pages: PagesViewController, pageAfter page: UIViewController) -> UIViewController?
}

@objc public protocol PagesViewControllerDelegate: AnyObject {
    @objc optional func pagesViewController(_ pages: PagesViewController, isShowing list: [UIViewController])
    @objc optional func pagesViewController(_ pages: PagesViewController, didTransitionTo page: UIViewController)
}

public class PagesViewController: UIViewController, UIScrollViewDelegate {
    public weak var dataSource: PagesViewControllerDataSource?
    public weak var delegate: PagesViewControllerDelegate?
    public let scrollView = UIScrollView()

    private var leftPage: UIViewController?
    public private(set) var currentPage: UIViewController! = UIViewController()
    private var rightPage: UIViewController?

    private var showing: [UIViewController] = []

    private var currentWidth: CGFloat = 0

    public override func loadView() {
        view = scrollView
        view.backgroundColor = .backgroundLightest
    }

    public override func viewDidLoad() {
        scrollView.alwaysBounceHorizontal = true
        scrollView.delegate = self
        scrollView.isPagingEnabled = true
        scrollView.showsHorizontalScrollIndicator = false
        scrollView.showsVerticalScrollIndicator = false
        scrollView.canCancelContentTouches = true

        embedPage(currentPage, at: 0)
    }

    public override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        let frame = scrollView.frame.inset(by: scrollView.adjustedContentInset)
        let width = frame.width
        let height = frame.height
        let views = scrollView.subviews.filter({ $0.tag == 1 })
        for (i, subview) in views.enumerated() {
            subview.frame = CGRect(x: CGFloat(i) * width, y: 0, width: width, height: height)
        }
        scrollView.contentSize = CGSize(width: CGFloat(views.count) * width, height: height)

        if width != currentWidth {
            currentWidth = width
            let currentPageNumber = scrollView.subviews.firstIndex(of: currentPage.view)
            scrollView.contentOffset.x = CGFloat(currentPageNumber ?? 0) * frame.width
        }
    }

    public override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        setCurrentPage(currentPage) // remove other pages to avoid messed up contentOffset
        super.viewWillTransition(to: size, with: coordinator)
    }

    private func getPage(onLeft: Bool) -> UIViewController? {
        let isBefore = view.effectiveUserInterfaceLayoutDirection == .leftToRight ? onLeft : !onLeft
        return isBefore
            ? dataSource?.pagesViewController(self, pageBefore: currentPage)
            : dataSource?.pagesViewController(self, pageAfter: currentPage)
    }

    public func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        if let left = getPage(onLeft: true) {
            leftPage?.unembed()
            embedPage(left, at: 0)
            if leftPage == nil {
                scrollView.contentOffset.x += scrollView.frame.width
            }
            leftPage = left
        }
        if let right = getPage(onLeft: false) {
            rightPage?.unembed()
            embedPage(right, at: leftPage == nil ? 1 : 2)
            rightPage = right
        }
        view.setNeedsLayout()
        view.layoutIfNeeded()
    }

    public func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let frame = scrollView.frame.inset(by: scrollView.adjustedContentInset)
        let visible = CGRect(
            x: scrollView.contentOffset.x,
            y: 0,
            width: frame.width,
            height: frame.height
        )
        var newValue: [UIViewController] = []
        if let left = leftPage, left.view.frame.intersects(visible) {
            newValue.append(left)
        }
        if currentPage.view.frame.intersects(visible) {
            newValue.append(currentPage)
        }
        if let right = rightPage, right.view.frame.intersects(visible) {
            newValue.append(right)
        }
        guard newValue != showing else { return }
        showing = newValue
        delegate?.pagesViewController?(self, isShowing: showing)
    }

    public func scrollViewWillEndDragging(_ scrollView: UIScrollView, withVelocity velocity: CGPoint, targetContentOffset: UnsafeMutablePointer<CGPoint>) {
        let x = targetContentOffset.pointee.x
        if x < currentPage.view.frame.minX, let left = leftPage {
            rightPage?.unembed()
            leftPage = nil
            rightPage = currentPage
            currentPage = left
            notifyUpdated()
        } else if x >= currentPage.view.frame.maxX, let right = rightPage {
            let removedView = leftPage != nil
            leftPage?.unembed()
            rightPage = nil
            leftPage = currentPage
            currentPage = right
            if removedView { // only adjust offset when leftPage was there and removed
                scrollView.contentOffset.x -= scrollView.frame.width
                targetContentOffset.pointee = CGPoint(x: x - scrollView.frame.width, y: 0)
            }
            notifyUpdated()
        }
        view.setNeedsLayout()
    }

    public override func accessibilityScroll(_ direction: UIAccessibilityScrollDirection) -> Bool {
        let isLTR = view.effectiveUserInterfaceLayoutDirection == .leftToRight
        var onLeft: Bool
        switch direction {
        case .down, .previous: onLeft = isLTR
        case .up, .next: onLeft = !isLTR
        case .left: onLeft = false // swipe to left needs to get new one on right
        case .right: onLeft = true
        @unknown default: onLeft = false
        }
        guard let page = getPage(onLeft: onLeft) else { return false }
        setCurrentPage(page)
        notifyUpdated()
        return true
    }

    private func notifyUpdated() {
        UIAccessibility.post(notification: .pageScrolled, argument: currentPage.title)
        delegate?.pagesViewController?(self, didTransitionTo: currentPage)
    }

    private func embedPage(_ page: UIViewController, at: Int) {
        addChild(page)
        scrollView.insertSubview(page.view, at: at)
        page.view.tag = 1
        page.didMove(toParent: self)
    }

    public enum Direction {
        case reverse, forward
    }
    public func setCurrentPage(_ page: UIViewController, direction: Direction? = nil) {
        let leftDir: Direction = view.effectiveUserInterfaceLayoutDirection == .leftToRight
            ? .reverse : .forward
        leftPage?.unembed()
        rightPage?.unembed()
        var x: CGFloat = 0
        if direction == leftDir {
            leftPage = nil
            rightPage = currentPage
            embedPage(page, at: 0)
            scrollView.contentOffset.x = scrollView.frame.width
        } else if direction == nil {
            leftPage = nil
            rightPage = nil
            currentPage.unembed()
            embedPage(page, at: 0)
        } else {
            rightPage = nil
            leftPage = currentPage
            embedPage(page, at: 1)
            scrollView.contentOffset.x = 0
            x = scrollView.frame.width
        }
        currentPage = page
        view.setNeedsLayout()
        scrollView.setContentOffset(CGPoint(x: x, y: 0), animated: direction != nil)
        view.layoutIfNeeded()
    }
}
