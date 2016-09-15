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
    
        tableView.registerClass(WhizzyWigTableViewCell.classForCoder(), forCellReuseIdentifier: "WhizzyCell")
    }
    
    let html = [
        "<p><a href=\"https://secure.flickr.com/photos/16759096@N00/526258924\"><img style=\"display: block; margin-left: auto; margin-right: auto; max-width: 949px;\" src=\"https://farm2.static.flickr.com/1221/526258924_31a701414f.jpg\" alt=\"Carmen Gia\" width=\"500\" height=\"375\"></a></p><p style=\"text-align: center;\">-OR-</p><p style=\"text-align: center;\"><a href=\"https://secure.flickr.com/photos/28370466@N05/9107482901\"><img src=\"https://farm3.static.flickr.com/2845/9107482901_16aa055cc0.jpg\" alt=\"Lamborghini Aventedor\" width=\"500\" height=\"375\" style=\"max-width: 949px;\"></a></p><p><a href=\"https://secure.flickr.com/photos/16759096@N00/526258924\" class=\"external\" target=\"_blank\"><span><span></span><span class=\"screenreader-only\">&nbsp;(Links to an external site.)</span></span><span class=\"ui-icon ui-icon-extlink ui-icon-inline\" title=\"Links to an external site.\"></span></a></p>"
    ]
    
    var cellHeightCache = [Int: CGFloat]()

    
    // MARK: - UITableViewDataSource
    
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return html.count
    }
    
    func configureCell(cell: WhizzyWigTableViewCell, forRowAtIndexPath indexPath:NSIndexPath) {
        cell.whizzyWigView.loadHTMLString(html[indexPath.row], baseURL: nil)
        cell.indexPath = indexPath
        cell.cellSizeUpdated = { [weak self] indexPath in
            self?.updateHeight(cell.expectedHeight, forRowAtIndexPath: indexPath)
        }
    }
    
    private func updateHeight(height: CGFloat, forRowAtIndexPath indexPath: NSIndexPath) {
        
        // this prevents the text height bug. It's weird. but it works
        // other things might cause it to break.
        if tableView.rectForRowAtIndexPath(indexPath).height == height {
            return
        }
        
        let existingHeight = cellHeightCache[indexPath.row]
        if existingHeight != height {
            cellHeightCache[indexPath.row] = height
            tableView.beginUpdates()
            tableView.endUpdates()
        }
    }

    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("WhizzyCell") as! WhizzyWigTableViewCell
        configureCell(cell, forRowAtIndexPath: indexPath)
        return cell
    }
    
    override func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        return true
    }
    
    override func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        // EMPTY: must be implemented, but can be empty when using UITableViewRowAction
    }
    

    // MARK: - UITableViewDelegate
    
    override func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        guard let height = cellHeightCache[indexPath.row] else {
            return 44.0
        }
        
        return height
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        print("Strong work: \(indexPath)")
    }
    
    override func tableView(tableView: UITableView, editActionsForRowAtIndexPath indexPath: NSIndexPath) -> [UITableViewRowAction]? {
        let deleted = UITableViewRowAction(style: .Default, title: "Delete") { action, indexPath in
            print("Go ahead... make my day!")
        }
        
        return [deleted]
    }

}

