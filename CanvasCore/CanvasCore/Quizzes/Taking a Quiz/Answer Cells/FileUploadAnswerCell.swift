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

import ReactiveSwift
import Result


class FileUploadAnswerCell: UITableViewCell {
    static var ReuseID: String {
        return "FileUploadAnswerCellReuseID"
    }

    lazy var removeFileButton: UIButton = {
        let button = UIButton(type: .system)
        button.setImage(.icon(.cancel), for: .normal)
        button.addTarget(self, action: #selector(removeFile), for: .touchUpInside)
        button.frame = CGRect(x: 0, y: 0, width: 21, height: 21)
        button.tintColor = UIColor(r: 165, g: 175, b: 181)
        return button
    }()

    var fileName: String? {
        didSet {
            textLabel?.text = fileName ?? NSLocalizedString("Choose a File", tableName: "Localizable", bundle: .core, value: "", comment: "Choose a file")
            if fileName == nil {
                accessoryType = .disclosureIndicator
            } else {
                accessoryView = removeFileButton
            }
        }
    }

    var removeFileAction: (()->())?

    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: .value1, reuseIdentifier: FileUploadAnswerCell.ReuseID)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func removeFile() {
        removeFileAction?()
    }
}
