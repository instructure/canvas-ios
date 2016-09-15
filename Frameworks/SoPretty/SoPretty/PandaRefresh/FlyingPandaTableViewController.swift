//
//  PandaTableViewController.swift
//  iCanvas
//
//  Created by Ben Kraus on 7/16/15.
//  Copyright (c) 2015 Instructure. All rights reserved.
//

import UIKit

public class FlyingPandaTableViewController: UITableViewController {
    
    public private(set) var flyingPandaRefreshControl: CSGFlyingPandaRefreshControl?
    private var loadedViewInitially: Bool = false
    
    public override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: NSBundle?) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
    }
    
    public required init!(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    public override init(style: UITableViewStyle) {
        super.init(style: style)
    }
        
    public override func viewDidLoad() {
        super.viewDidLoad()
        flyingPandaRefreshControl = CSGFlyingPandaRefreshControl(scrollView: self.tableView)
        flyingPandaRefreshControl?.setToIdle()
        self.tableView.addSubview(flyingPandaRefreshControl!)
    }
    
    public override func viewWillLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        if !loadedViewInitially {
            flyingPandaRefreshControl!.originalTopContentInset = self.topLayoutGuide.length
            loadedViewInitially = true
        }
        
        let insets = UIEdgeInsets(top: topLayoutGuide.length, left: 0, bottom: bottomLayoutGuide.length, right: 0)
        tableView.contentInset = insets
        tableView.scrollIndicatorInsets = insets
    }
    
    public override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        flyingPandaRefreshControl!.updateFrame()
    }

    public override func scrollViewDidScroll(scrollView: UIScrollView) {
        flyingPandaRefreshControl!.scrollViewDidScroll()
    }
    
    public override func scrollViewDidEndDragging(scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        flyingPandaRefreshControl!.scrollViewDidEndDragging()
    }
}
