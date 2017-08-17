//
//  StudentViewController.swift
//  Attendance
//
//  Created by Derrick Hathaway on 7/24/17.
//  Copyright © 2017 Instructure. All rights reserved.
//

import UIKit
import AttendanceLE

class StudentViewController: UIViewController {
    var studentConnector: StudentBTLEConnector?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let idField = UITextField()
        idField.borderStyle = .roundedRect
        idField.placeholder = "Student ID"
        idField.translatesAutoresizingMaskIntoConstraints = false
        idField.delegate = self
        
        view.addSubview(idField)
        let guide = view.readableContentGuide
        NSLayoutConstraint.activate([
            guide.leadingAnchor.constraint(equalTo: idField.leadingAnchor),
            guide.trailingAnchor.constraint(equalTo: idField.trailingAnchor),
            guide.topAnchor.constraint(equalTo: idField.topAnchor, constant: -64),
            idField.heightAnchor.constraint(equalToConstant: 34),
        ])
    }
}

extension StudentViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        let id = textField.text ?? "NO ID"
        studentConnector = StudentBTLEConnector(with: id) { [weak self] in
            let alert = UIAlertController(title: "Attendance", message: "✅ Welcome to class!", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "Thanks!", style: .default, handler: nil))
            self?.present(alert, animated: true, completion: nil)
        }
        textField.text = ""
        textField.resignFirstResponder()
        return true
    }
}
