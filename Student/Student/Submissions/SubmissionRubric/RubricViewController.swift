//
// Copyright (C) 2019-present Instructure, Inc.
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

import UIKit
import Core

class RubricViewController: UIViewController {

    static func create(env: AppEnvironment = .shared, courseID: String, assignmentID: String, userID: String = "12") -> RubricViewController {
        let controller = loadFromStoryboard()
        controller.presenter = RubricPresenter(env: env, view: controller, courseID: courseID, assignmentID: assignmentID, userID: userID)
        return controller
    }

    @IBOutlet weak var collectionView: UICollectionView!
    var models: [RubricViewModel] = []
    var presenter: RubricPresenter!

    override func viewDidLoad() {
        super.viewDidLoad()
        setupCollectionView()
        presenter.viewIsReady()
    }

    func setupCollectionView() {
        let id = String(describing: RubricCollectionViewCell.self)
        let nib = UINib(nibName: id, bundle: nil)
        collectionView.register(nib, forCellWithReuseIdentifier: id)
    }
}

extension RubricViewController: UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return models.count
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell: RubricCollectionViewCell = collectionView.dequeue(for: indexPath)
        let r = models[indexPath.item]
        cell.update(r)
        return cell
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let s = CGSize(width: view.bounds.size.width, height: 158)
        return s
    }
}

extension RubricViewController: RubricViewProtocol {
    func update(_ rubric: [RubricViewModel]) {
        models = rubric
        collectionView.reloadData()
    }

    func showEmptyState() {
        print("***** show empty state here *****")
    }
}

class RubricCollectionViewCell: UICollectionViewCell {

    @IBOutlet weak var circleView: RubricCircleView!
    @IBOutlet weak var rubricTitle: DynamicLabel!
    @IBOutlet weak var selectedRatingTitle: DynamicLabel!
    @IBOutlet weak var borderHeightConstraint: NSLayoutConstraint!

    override func awakeFromNib() {
        print("\(#file) awake")
        borderHeightConstraint.constant = 1.0 / UIScreen.main.scale
    }

    func update(_ rubric: RubricViewModel) {
        rubricTitle.text = rubric.title
        selectedRatingTitle.text = rubric.selectedDesc
        circleView.rubric = rubric
    }

    override func prepareForReuse() {
        super.prepareForReuse()
    }

    @IBAction func actionShowLongDescription(_ sender: Any) {
    }
}
