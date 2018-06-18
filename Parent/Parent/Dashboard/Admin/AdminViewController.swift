//
//  AdminPageViewController.swift
//  Parent
//
//  Created by Veha Souphom on 6/13/18.
//  Copyright © 2018 Instructure Inc. All rights reserved.
//

import Foundation

class AdminViewController : UIViewController {
    @IBOutlet weak var actAsUserButton: UIButton!
    @IBOutlet weak var directionsLabel: UILabel!
    @IBOutlet weak var welcomeLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = .clear
        
        welcomeLabel.text = NSLocalizedString("Welcome!", comment: "Header title of admin view")
        directionsLabel.text = NSLocalizedString("Tap to start viewing Canvas as another person.", comment: "Directions in the admin view")
        
        actAsUserButton.titleLabel?.text = NSLocalizedString("Act as User", comment: "Label for button that allows admin to Act as User")
        actAsUserButton.layer.cornerRadius = 5
        actAsUserButton.clipsToBounds = true
    }
}
