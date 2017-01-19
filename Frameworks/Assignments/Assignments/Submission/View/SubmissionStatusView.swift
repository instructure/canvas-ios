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
import ReactiveSwift
import AssignmentKit
import WhizzyWig
import SoLazy

open class SubmissionStatusView: UIView {
    
    @IBOutlet var titleLabel: UILabel!
    @IBOutlet var turnedInLabel: UILabel!
    @IBOutlet var submittedDateLabel: UILabel!
    @IBOutlet var submittedImageView: UIImageView!
    @IBOutlet var submissionDetailsButton: UIButton!
    
    var viewModel: SubmissionStatusViewModel!
    var showSubmissionHistoryButton: Bool = true
    open var viewSubmissionDetailsPressedHandler: (() -> Void)?
    
    public required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    public init(frame: CGRect, viewModel: SubmissionStatusViewModel, showSubmissionHistory: Bool) {
        super.init(frame: frame)
        self.viewModel = viewModel
        self.showSubmissionHistoryButton = showSubmissionHistory
        setupView()
        bindViewModel()
    }
    
    open override func awakeFromNib() {
        super.awakeFromNib()
        bindViewModel()
    }
    
    func bindViewModel() {
        viewModel.hasSubmitted.producer
            .observe(on: UIScheduler())
            .startWithValues { submitted in
                self.titleLabel.isHidden = submitted
                self.submittedImageView.isHidden = !submitted
                self.turnedInLabel.isHidden = !submitted
                self.submissionDetailsButton.isHidden = !self.showSubmissionHistoryButton
        }
        
        self.titleLabel.rac_text <~ viewModel.submittedStatus.producer
            .map { $0.description }
        self.submittedDateLabel.rac_text <~ viewModel.submittedDate
        
        viewModel.submittedStatus.producer.observe(on: UIScheduler()).startWithValues { status in
            let textColor: UIColor
            switch status {
            case .submitted(.excused):
                textColor = UIColor(red:0.28, green:0.69, blue:0.29, alpha:1)
            case .submitted(.late):
                textColor = UIColor(red:0.99, green:0.52, blue:0.41, alpha:1)
            default: textColor = .darkGray
            }
            self.submittedDateLabel.textColor = textColor
        }
        
        
        //submission details button
        submissionDetailsButton.addTarget(self, action:#selector(SubmissionStatusView.viewSubmissionDetailsPressed(_:)), for: .touchUpInside)
    }
    
    func setupView() {
        let view = Bundle(for: SubmissionStatusView.self).loadNibNamed("SubmissionStatusView", owner: self, options: nil)!.first as! UIView
        view.frame = self.bounds
        self.addSubview(view)
    }

    open func viewSubmissionDetailsPressed(_ sender: UIButton!) {
        viewSubmissionDetailsPressedHandler?()
    }
}
