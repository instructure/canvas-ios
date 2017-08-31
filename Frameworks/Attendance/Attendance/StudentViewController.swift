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
