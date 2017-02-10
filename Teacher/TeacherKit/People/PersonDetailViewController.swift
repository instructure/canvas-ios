//
//  PersonDetailViewController.swift
//  Teacher
//
//  Created by Derrick Hathaway on 2/6/17.
//  Copyright © 2017 Instructure. All rights reserved.
//

import UIKit
import SixtySix


class PersonDetailViewController: UIViewController, Destination {
    static func visit(with parameters: (String, String)) throws -> UIViewController {
//        let (courseID, userID) = parameters
        let person = PersonDetailViewController()
        person.view.backgroundColor = .white
        return person
    }
}
