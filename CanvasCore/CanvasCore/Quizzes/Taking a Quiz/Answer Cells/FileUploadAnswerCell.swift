//
// This file is part of Canvas.
// Copyright (C) 2017-present  Instructure, Inc.
//
// This program is free software: you can redistribute it and/or modify
// it under the terms of the GNU Affero General Public License as
// published by the Free Software Foundation, either version 3 of the
// License, or (at your option) any later version.
//
// This program is distributed in the hope that it will be useful,
// but WITHOUT ANY WARRANTY; without even the implied warranty of
// MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
// GNU Affero General Public License for more details.
//
// You should have received a copy of the GNU Affero General Public License
// along with this program.  If not, see <https://www.gnu.org/licenses/>.
//

import Core

class FileUploadAnswerCell: UITableViewCell {
    @objc static var ReuseID: String {
        return "FileUploadAnswerCellReuseID"
    }

    @objc lazy var removeFileButton: UIButton = {
        let button = UIButton(type: .system)
        button.setImage(.icon(.cancel), for: .normal)
        button.addTarget(self, action: #selector(removeFile), for: .primaryActionTriggered)
        button.frame = CGRect(x: 0, y: 0, width: 21, height: 21)
        button.tintColor = .named(.textDark)
        return button
    }()

    @objc var fileName: String? {
        didSet {
            textLabel?.text = fileName ?? NSLocalizedString("Choose a File", tableName: "Localizable", bundle: .core, value: "", comment: "Choose a file")
            if fileName == nil {
                accessoryType = .disclosureIndicator
            } else {
                accessoryView = removeFileButton
            }
        }
    }

    @objc var removeFileAction: (()->())?

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: .value1, reuseIdentifier: FileUploadAnswerCell.ReuseID)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    @objc func removeFile() {
        removeFileAction?()
    }
}
