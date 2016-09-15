//
//  PagedViewController.swift
//  iCanvas
//
//  Created by Nathan Perry on 9/15/15.
//  Copyright (c) 2015 Instructure. All rights reserved.
//

import Foundation
import Cartography

public class ControllerPage {
    private var controller: UIViewController
    private var title: String
    
    public init(title: String, controller: UIViewController) {
        self.title = title
        self.controller = controller
    }
}

extension UIView {
    private var mainScrollView: UIScrollView? {
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

public class PagedViewController: UIViewController {
    private var pages: [ControllerPage]!
    private var segControl: UISegmentedControl!
    private var scrollView: UIScrollView!
    
    public init(pages: [ControllerPage]) {
        super.init(nibName: nil, bundle: nil)
        self.pages = pages
        automaticallyAdjustsScrollViewInsets = false
        view.backgroundColor = UIColor.whiteColor()
        setupSegmentedControl()
        setupScrollView()
        setupPages()
        updateNavigationItem(0)
    }
    
    public required init?(coder aDecoder: NSCoder) {
        fatalError()
    }
    
    public override func viewWillAppear(animated: Bool) {
        if let parent = parentViewController {
            let nav = (parent as? UINavigationController) ?? parent.navigationController
            
            var top = CGFloat(20)
            top += nav?.navigationBar.bounds.height ?? 0.0
            var bottom = parent.tabBarController?.tabBar.bounds.height ?? 0.0
            if nav?.toolbarHidden == false {
                bottom += nav?.toolbar.bounds.height ?? 0.0
            }
            for scroll in pages.flatMap({ $0.controller.view.mainScrollView }) {
                scroll.contentInset = UIEdgeInsets(top: top, left: 0, bottom: bottom, right: 0)
                scroll.scrollIndicatorInsets = UIEdgeInsets(top: top, left: 0, bottom: bottom, right: 0)
            }
        }
        super.viewWillAppear(animated)
    }
    
    private func setupSegmentedControl() {
        let items = pages.map{$0.title}
        let segControl = UISegmentedControl(items: items)
        segControl.selectedSegmentIndex = 0
        segControl.addTarget(self, action: Selector("segPressed:"), forControlEvents: .ValueChanged)
        navigationItem.titleView = segControl
        self.segControl = segControl
    }
    
    func updateNavigationItem(pageIndex: Int) {
        guard pageIndex < pages.count else {
            return
        }
        let page = pages[pageIndex]
        navigationItem.rightBarButtonItems = page.controller.navigationItem.rightBarButtonItems
    }
    
    public func segPressed(control: UISegmentedControl) {
        let newOffset = CGFloat(segControl.selectedSegmentIndex) * view.frame.size.width
        scrollView.setContentOffset(CGPointMake(newOffset, 0), animated: true)
        
        updateNavigationItem(segControl.selectedSegmentIndex)
    }
    
    private func setupScrollView() {
        scrollView = UIScrollView(frame: CGRectZero)
        scrollView.pagingEnabled = true
        scrollView.delegate = self
        scrollView.bounces = false
        scrollView.showsHorizontalScrollIndicator = false
        scrollView.showsVerticalScrollIndicator = false
        scrollView.frame = view.bounds
        scrollView.autoresizingMask = [.FlexibleHeight, .FlexibleWidth]
        scrollView.backgroundColor = UIColor(red: 1, green: 0, blue: 0.5, alpha: 1.0)
        view.addSubview(scrollView)
    }
    
    public override func viewWillTransitionToSize(size: CGSize, withTransitionCoordinator coordinator: UIViewControllerTransitionCoordinator) {
        super.viewWillTransitionToSize(size, withTransitionCoordinator: coordinator)
        coordinator.animateAlongsideTransition({ _ in
            let selected = CGFloat(self.segControl.selectedSegmentIndex)
            self.scrollView.contentOffset = CGPoint(x: size.width * selected, y: 0)
        }, completion: nil)
    }
    
    private func setupPages() {
        if pages.count == 0 {
            return
        }
        for i in 0..<pages.count {
            let page: ControllerPage = pages[i]
            page.controller.automaticallyAdjustsScrollViewInsets = false
            let pageView = page.controller.view
            pageView.translatesAutoresizingMaskIntoConstraints = false
            scrollView.addSubview(pageView)
            
            // line the controller up horizontally
            if page.controller == pages.first!.controller {
                constrain(scrollView, pageView) { scrollView, pageView in
                    pageView.left == scrollView.left
                }
            } else {
                let leftPage = pages[i-1].controller.view
                constrain(leftPage, pageView) { leftPage, pageView in
                    pageView.left == leftPage.right
                }
            }
            
            constrain(view, scrollView, pageView) { parent, scrollView, page in
                page.top == scrollView.top
                page.height == parent.height
                page.width == parent.width
            }

            addChildViewController(page.controller)
            page.controller.didMoveToParentViewController(self)
        }
        let lastPage = pages.last!.controller.view
        constrain(scrollView, lastPage) { scrollView, lastPage in
            lastPage.right == scrollView.right
        }
    }
}

extension PagedViewController: UIScrollViewDelegate {
    public func scrollViewDidEndDecelerating(scrollView: UIScrollView) {
        let scrolledToPage = Int(scrollView.contentOffset.x / view.frame.size.width)
        self.segControl.selectedSegmentIndex = scrolledToPage
        updateNavigationItem(scrolledToPage)
    }
}
