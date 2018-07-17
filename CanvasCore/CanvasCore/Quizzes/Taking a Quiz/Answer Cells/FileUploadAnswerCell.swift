//
// Copyright (C) 2017-present Instructure, Inc.
//
// This program is free software: you can redistribute it and/or modify
// it under the terms of the GNU General Public License as published by
// the Free Software Foundation, version 3 of the License.
//
// This program is distributed in the hope that it will be useful,
// but WITHOUT ANY WARRANTY; without even the implied warranty of
// MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
// GNU General Public License for more details.
//
// You should have received a copy of the GNU General Public License
// along with this program.  If not, see <http://www.gnu.org/licenses/>.
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
