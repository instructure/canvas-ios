//
//  MainPrettyViewController.swift
//  Pretty
//
//  Created by Derrick Hathaway on 11/23/15.
//  Copyright © 2015 Instructure. All rights reserved.
//

import UIKit
import SoPretty

class MainPrettyViewController: UITableViewController {
    
    let segues: [(String, ()->UIViewController)] = [

    ]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.registerClass(UITableViewCell.classForCoder(), forCellReuseIdentifier: "SegueCell")
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return segues.count
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("SegueCell", forIndexPath: indexPath)
        
        cell.textLabel?.text = segues[indexPath.row].0
        
        return cell
    }
    
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        let vc = segues[indexPath.row].1()
        
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
}

