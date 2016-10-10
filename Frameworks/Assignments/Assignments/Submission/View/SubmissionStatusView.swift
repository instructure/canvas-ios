//
//  SubmittedStatus.swift
//  Assignments
//
//  Created by Nathan Lambson on 1/27/16.
//  Copyright © 2016 Instructure. All rights reserved.
//

import UIKit
import ReactiveCocoa
import AssignmentKit
import WhizzyWig
import SoLazy

public class SubmissionStatusView: UIView {
    
    @IBOutlet var titleLabel: UILabel!
    @IBOutlet var turnedInLabel: UILabel!
    @IBOutlet var submittedDateLabel: UILabel!
    @IBOutlet var submittedImageView: UIImageView!
    @IBOutlet var submissionDetailsButton: UIButton!
    
    var viewModel: SubmissionStatusViewModel!
    var showSubmissionHistoryButton: Bool = true
    public var viewSubmissionDetailsPressedHandler: (() -> Void)?
    
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
    
    public override func awakeFromNib() {
        super.awakeFromNib()
        bindViewModel()
    }
    
    func bindViewModel() {
        viewModel.hasSubmitted.producer
            .observeOn(UIScheduler())
            .startWithNext { submitted in
                self.titleLabel.hidden = submitted
                self.submittedImageView.hidden = !submitted
                self.turnedInLabel.hidden = !submitted
                self.submissionDetailsButton.hidden = !self.showSubmissionHistoryButton
        }
        
        self.titleLabel.rac_text <~ viewModel.submittedStatus.producer
            .map { $0.description }
        self.submittedDateLabel.rac_text <~ viewModel.submittedDate
        
        viewModel.submittedStatus.producer.observeOn(UIScheduler()).startWithNext { status in
            let textColor: UIColor
            switch status {
            case .Submitted(.Excused):
                textColor = UIColor(red:0.28, green:0.69, blue:0.29, alpha:1)
            case .Submitted(.Late):
                textColor = UIColor(red:0.99, green:0.52, blue:0.41, alpha:1)
            default: textColor = UIColor.darkGrayColor()
            }
            self.submittedDateLabel.textColor = textColor
        }
        
        
        //submission details button
        submissionDetailsButton.addTarget(self, action:#selector(SubmissionStatusView.viewSubmissionDetailsPressed(_:)), forControlEvents: .TouchUpInside)
    }
    
    func setupView() {
        let view = NSBundle(forClass: SubmissionStatusView.self).loadNibNamed("SubmissionStatusView", owner: self, options: nil)!.first as! UIView
        view.frame = self.bounds
        self.addSubview(view)
    }

    public func viewSubmissionDetailsPressed(sender: UIButton!) {
        viewSubmissionDetailsPressedHandler?()
    }
}
