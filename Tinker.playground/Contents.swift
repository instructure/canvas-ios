//: Playground - noun: a place where people can play

import UIKit
import PlaygroundSupport

let page = PlaygroundPage.current
page.needsIndefiniteExecution = true


import SoPretty
import SoPersistent
import SoIconic

let messages = [
    "The quick brown fox jumps over the lazy dog.",
    "Sed ut perspiciatis, unde omnis iste natus error sit voluptatem accusantium doloremque laudantium, totam rem aperiam eaque ipsa, quae ab illo inventore veritatis et quasi architecto beatae vitae dicta sunt, explicabo.",
    "True"
]

class Pretty: UITableViewController {
    override func viewDidLoad() {
        super.viewDidLoad()
        ColorfulViewModel.tableViewDidLoad(tableView)
        tableView.rowHeight = UITableViewAutomaticDimension
        tableView.estimatedRowHeight = 60
    }
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 100
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let vm = ColorfulViewModel(features: [.icon, .subtitle, .rightDetail, .token])
        vm.title.value = "Cookies"
        vm.subtitle.value = messages[Int(arc4random_uniform(UInt32(messages.count)))]
        vm.rightDetail.value = "Nov 12th"
        vm.icon.value = .icon(.assignment)
        vm.tokenViewText.value = "YUM!"
        vm.color.value = UIColor(hue: 200/360.0, saturation: 1.0, brightness: 1.0, alpha: 1.0)
        
        let cell = vm.cellForTableView(tableView, indexPath: indexPath) as! ColorfulTableViewCell
        cell.subtitleLabel?.numberOfLines = 0
        
        return cell
    }
}


let nav = UINavigationController(rootViewController: Pretty())
nav.navigationBar.barTintColor = #colorLiteral(red: 0.2392156869, green: 0.6745098233, blue: 0.9686274529, alpha: 1)

let tabs = UITabBarController()
tabs.viewControllers = [nav]
page.liveView = tabs
