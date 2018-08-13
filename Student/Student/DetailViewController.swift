//
//  DetailViewController.swift
//  Student
//
//  Created by Layne Moseley on 8/10/18.
//  Copyright © 2018 Instructure, Inc. All rights reserved.
//

import UIKit

class DetailViewController: UIViewController {
    static func create() -> DetailViewController {
        let controller = UIStoryboard(name: "DetailViewController", bundle: nil).instantiateInitialViewController() as! DetailViewController
        return controller
    }
}
