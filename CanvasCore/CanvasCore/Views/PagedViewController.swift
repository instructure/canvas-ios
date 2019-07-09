//
// This file is part of Canvas.
// Copyright (C) 2016-present  Instructure, Inc.
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

import Foundation
import Cartography

open class ControllerPage {
    fileprivate var controller: UIViewController
    fileprivate var title: String
    
    public init(title: String, controller: UIViewController) {
        self.title = title
        self.controller = controller
    }
}

extension UIView {
    fileprivate var mainScrollView: UIScrollView? {
        if let me = self as? UIScrollView {
            return me
        }
        
        for subview in subviews {
            if let scroll = subview.mainScrollView {
                return scroll
            }
        }
        return nil
    }
}

open class PagedViewController: UIViewController {
    fileprivate var pages: [ControllerPage]!
    fileprivate var segControl: UISegmentedControl!
    fileprivate var scrollView: UIScrollView!
    
    public init(pages: [ControllerPage]) {
        super.init(nibName: nil, bundle: nil)
        self.pages = pages
        automaticallyAdjustsScrollViewInsets = false
        view.backgroundColor = UIColor.white
        setupSegmentedControl()
        setupScrollView()
        setupPages()
        updateNavigationItem(0)
    }
    
    public required init?(coder aDecoder: NSCoder) {
        fatalError()
    }
    
    open override func viewWillAppear(_ animated: Bool) {
        if let parent = parent {
            let nav = (parent as? UINavigationController) ?? parent.navigationController
            
            var top = UIApplication.shared.statusBarFrame.height
            top += nav?.navigationBar.bounds.height ?? 0.0
            var bottom = parent.tabBarController?.tabBar.bounds.height ?? 0.0
            if nav?.isToolbarHidden == false {
                bottom += nav?.toolbar.bounds.height ?? 0.0
            }
            for scroll in pages.compactMap({ $0.controller.view.mainScrollView }) {
                scroll.contentInset = UIEdgeInsets(top: top, left: 0, bottom: bottom, right: 0)
                scroll.scrollIndicatorInsets = UIEdgeInsets(top: top, left: 0, bottom: bottom, right: 0)
            }
        }
        super.viewWillAppear(animated)
    }
    
    fileprivate func setupSegmentedControl() {
        let items = pages.map{$0.title}
        let segControl = UISegmentedControl(items: items)
        segControl.selectedSegmentIndex = 0
        segControl.addTarget(self, action: #selector(PagedViewController.segPressed(_:)), for: .valueChanged)
        navigationItem.titleView = segControl
        self.segControl = segControl
    }
    
    @objc func updateNavigationItem(_ pageIndex: Int) {
        guard pageIndex < pages.count else {
            return
        }
        let page = pages[pageIndex]
        navigationItem.rightBarButtonItems = page.controller.navigationItem.rightBarButtonItems
    }
    
    @objc open func segPressed(_ control: UISegmentedControl) {
        let newOffset = CGFloat(segControl.selectedSegmentIndex) * view.frame.size.width
        scrollView.setContentOffset(CGPoint(x: newOffset, y: 0), animated: true)
        
        updateNavigationItem(segControl.selectedSegmentIndex)
    }
    
    fileprivate func setupScrollView() {
        scrollView = UIScrollView(frame: CGRect.zero)
        scrollView.isPagingEnabled = true
        scrollView.delegate = self
        scrollView.bounces = false
        scrollView.showsHorizontalScrollIndicator = false
        scrollView.showsVerticalScrollIndicator = false
        scrollView.frame = view.bounds
        scrollView.autoresizingMask = [.flexibleHeight, .flexibleWidth]
        scrollView.backgroundColor = UIColor(red: 1, green: 0, blue: 0.5, alpha: 1.0)
        view.addSubview(scrollView)
    }
    
    open override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        super.viewWillTransition(to: size, with: coordinator)
        coordinator.animate(alongsideTransition: { _ in
            let selected = CGFloat(self.segControl.selectedSegmentIndex)
            self.scrollView.contentOffset = CGPoint(x: size.width * selected, y: 0)
        }, completion: nil)
    }
    
    fileprivate func setupPages() {
        if pages.count == 0 {
            return
        }
        for i in 0..<pages.count {
            let page: ControllerPage = pages[i]
            page.controller.automaticallyAdjustsScrollViewInsets = false
            let pageView = page.controller.view
            pageView?.translatesAutoresizingMaskIntoConstraints = false
            scrollView.addSubview(pageView!)
            
            // line the controller up horizontally
            if page.controller == pages.first!.controller {
                constrain(scrollView, pageView!) { scrollView, pageView in
                    pageView.left == scrollView.left
                }
            } else {
                let leftPage = pages[i-1].controller.view
                constrain(leftPage!, pageView!) { leftPage, pageView in
                    pageView.left == leftPage.right
                }
            }
            
            constrain(view, scrollView, pageView!) { parent, scrollView, page in
                page.top == scrollView.top
                page.height == parent.height
                page.width == parent.width
            }

            addChild(page.controller)
            page.controller.didMove(toParent: self)
        }
        let lastPage = pages.last!.controller.view
        constrain(scrollView, lastPage!) { scrollView, lastPage in
            lastPage.right == scrollView.right
        }
    }
}

extension PagedViewController: UIScrollViewDelegate {
    public func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        let scrolledToPage = Int(scrollView.contentOffset.x / view.frame.size.width)
        self.segControl.selectedSegmentIndex = scrolledToPage
        updateNavigationItem(scrolledToPage)
    }
}
