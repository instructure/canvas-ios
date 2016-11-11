//
//  MessagesTab.swift
//  Canvas
//
//  Created by Derrick Hathaway on 11/11/16.
//  Copyright © 2016 Instructure. All rights reserved.
//

import UIKit
import Foundation
import TechDebt
import SoIconic

func MessagesTab() -> UIViewController {
    let vc = UIViewController.messagesTab()
    vc.tabBarItem.image = .icon(.inbox)
    vc.tabBarItem.selectedImage = .icon(.inbox, filled: true)
    return vc
}
