//
// Copyright (C) 2016-present Instructure, Inc.
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
    
    

//
//  WhizzyWigViewController.swift
//  WhizzyWig
//
//  Created by Nathan Armstrong on 3/14/16.
//
//

import UIKit

open class WhizzyWigViewController: UIViewController {

    open let whizzyWigView = WhizzyWigView(frame: CGRect(x: 0, y: 0, width: 320, height: 43))

    public override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        super.init(nibName: nil, bundle: nil)
    }

    public required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }

    open override func viewDidLoad() {
        super.viewDidLoad()
        whizzyWigView.scrollView.isScrollEnabled = true
        view.addSubview(whizzyWigView)

        navigationItem.leftBarButtonItem = UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(WhizzyWigViewController.done))

        makeConstraints()
    }

    func makeConstraints() {
        view.addConstraints(NSLayoutConstraint.constraints(
            withVisualFormat: "|[whizzy]|",
            options: [],
            metrics: nil,
            views: ["whizzy": whizzyWigView]))
        view.addConstraints(NSLayoutConstraint.constraints(
            withVisualFormat: "V:|[whizzy]|",
            options: [],
            metrics: nil,
            views: ["whizzy": whizzyWigView]))
    }

    func done() {
        self.dismiss(animated: true, completion: nil)
    }
}
