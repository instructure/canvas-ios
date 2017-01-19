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
    
    

//
//  WhizzyCarsViewController.swift
//  Whizzy
//
//  Created by Derrick Hathaway on 6/10/15.
//
//

import UIKit
import WhizzyWig

class WhizzyCarsViewController: UITableViewController {
    override func viewDidLoad() {
        super.viewDidLoad()
    
        tableView.register(WhizzyWigTableViewCell.classForCoder(), forCellReuseIdentifier: "WhizzyCell")
    }
    
    let html = [
        "<p><a href=\"https://secure.flickr.com/photos/16759096@N00/526258924\"><img style=\"display: block; margin-left: auto; margin-right: auto; max-width: 949px;\" src=\"https://farm2.static.flickr.com/1221/526258924_31a701414f.jpg\" alt=\"Carmen Gia\" width=\"500\" height=\"375\"></a></p><p style=\"text-align: center;\">-OR-</p><p style=\"text-align: center;\"><a href=\"https://secure.flickr.com/photos/28370466@N05/9107482901\"><img src=\"https://farm3.static.flickr.com/2845/9107482901_16aa055cc0.jpg\" alt=\"Lamborghini Aventedor\" width=\"500\" height=\"375\" style=\"max-width: 949px;\"></a></p><p><a href=\"https://secure.flickr.com/photos/16759096@N00/526258924\" class=\"external\" target=\"_blank\"><span><span></span><span class=\"screenreader-only\">&nbsp;(Links to an external site.)</span></span><span class=\"ui-icon ui-icon-extlink ui-icon-inline\" title=\"Links to an external site.\"></span></a></p>"
    ]
    
    var cellHeightCache = [Int: CGFloat]()

    
    // MARK: - UITableViewDataSource
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return html.count
    }
    
    func configureCell(_ cell: WhizzyWigTableViewCell, forRowAtIndexPath indexPath:IndexPath) {
        cell.whizzyWigView.loadHTMLString(html[indexPath.row], baseURL: nil)
        cell.indexPath = indexPath
        cell.cellSizeUpdated = { [weak self] indexPath in
            self?.updateHeight(cell.expectedHeight, forRowAtIndexPath: indexPath)
        }
    }
    
    fileprivate func updateHeight(_ height: CGFloat, forRowAtIndexPath indexPath: IndexPath) {
        
        // this prevents the text height bug. It's weird. but it works
        // other things might cause it to break.
        if tableView.rectForRow(at: indexPath).height == height {
            return
        }
        
        let existingHeight = cellHeightCache[indexPath.row]
        if existingHeight != height {
            cellHeightCache[indexPath.row] = height
            tableView.beginUpdates()
            tableView.endUpdates()
        }
    }

    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "WhizzyCell") as! WhizzyWigTableViewCell
        configureCell(cell, forRowAtIndexPath: indexPath)
        return cell
    }
    
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        // EMPTY: must be implemented, but can be empty when using UITableViewRowAction
    }
    

    // MARK: - UITableViewDelegate
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        guard let height = cellHeightCache[indexPath.row] else {
            return 44.0
        }
        
        return height
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        print("Strong work: \(indexPath)")
    }
    
    override func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]? {
        let deleted = UITableViewRowAction(style: .default, title: "Delete") { action, indexPath in
            print("Go ahead... make my day!")
        }
        
        return [deleted]
    }

}

