//
//  ToDoTabViewController.swift
//  iCanvas
//
//  Created by Brandon Pluim on 4/26/16.
//  Copyright © 2016 Instructure. All rights reserved.
//

import Foundation

import SoPretty
import TooLegit
import TechDebt

public func ToDoTabViewController(session session: Session, route: (UIViewController, NSURL)->()) throws -> UIViewController {

    let toDoListVC: UIViewController
        
    let list = try! ToDoListViewController(session: session, route: route)
    list.cbi_canBecomeMaster = true
    
    if UIDevice.currentDevice().userInterfaceIdiom == .Phone {
        toDoListVC = list
    } else {
        let split = CBISplitViewController()
        split.master = list
        toDoListVC = split
    }

    toDoListVC.tabBarItem.title = NSLocalizedString("To Do", comment: "Title of the Todo screen")
    toDoListVC.tabBarItem.image = UIImage.techDebtImageNamed("icon_todo_tab")
    toDoListVC.tabBarItem.selectedImage = UIImage.techDebtImageNamed("icon_todo_tab_selected")

    return toDoListVC
}
