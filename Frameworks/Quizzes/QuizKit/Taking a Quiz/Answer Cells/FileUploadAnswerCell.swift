//
//  FileUploadAnswerCell.swift
//  Quizzes
//
//  Created by Nathan Armstrong on 2/6/17.
//  Copyright © 2017 Instructure. All rights reserved.
//

import ReactiveSwift
import Result
import SoIconic

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
            textLabel?.text = fileName ?? NSLocalizedString("Choose a File", tableName: "Localizable", bundle: Bundle(identifier: "com.instructure.QuizKit")!, value: "", comment: "Choose a file")
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
