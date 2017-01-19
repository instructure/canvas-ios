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

open class FlyingPandaTableViewController: UITableViewController {
    
    open fileprivate(set) var flyingPandaRefreshControl: CSGFlyingPandaRefreshControl?
    fileprivate var loadedViewInitially: Bool = false
    
    public override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
    }
    
    public required init!(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    public override init(style: UITableViewStyle) {
        super.init(style: style)
    }
        
    open override func viewDidLoad() {
        super.viewDidLoad()
        flyingPandaRefreshControl = CSGFlyingPandaRefreshControl(scrollView: self.tableView)
        flyingPandaRefreshControl?.setToIdle()
        self.tableView.addSubview(flyingPandaRefreshControl!)
    }
    
    open override func viewWillLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        if !loadedViewInitially {
            flyingPandaRefreshControl!.originalTopContentInset = self.topLayoutGuide.length
            loadedViewInitially = true
        }
        
        let insets = UIEdgeInsets(top: topLayoutGuide.length, left: 0, bottom: bottomLayoutGuide.length, right: 0)
        tableView.contentInset = insets
        tableView.scrollIndicatorInsets = insets
    }
    
    open override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        flyingPandaRefreshControl!.updateFrame()
    }

    open override func scrollViewDidScroll(_ scrollView: UIScrollView) {
        flyingPandaRefreshControl!.scrollViewDidScroll()
    }
    
    open override func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        flyingPandaRefreshControl!.scrollViewDidEndDragging()
    }
}
