//
// Copyright (C) 2018-present Instructure, Inc.
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

protocol DashboardViewProtocol: class {
    func updateDisplay(_ viewModel: DashboardViewModel)
}

class DashboardViewController: UIViewController, DashboardViewProtocol {
    var presenter: DashboardPresenterProtocol?
    var viewModel: DashboardViewModel?
    
    let gutterWidth: CGFloat = 15
    let coursesColumns: CGFloat = 2
    let groupsColumns: CGFloat = 1
    
    @IBOutlet weak var collectionView: UICollectionView!
    
    static func create() -> DashboardViewController {
        let storyboard = UIStoryboard(name: "DashboardViewController", bundle: nil)
        let vc = storyboard.instantiateViewController(withIdentifier: "vc") as! DashboardViewController
        let presenter = DashboardPresenter(view: vc)
        vc.presenter = presenter
        return vc
    }
    
    // MARK: Lifecycle methods
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Navigation Bar Setup
        navigationController?.navigationBar.barTintColor = .black
        navigationController?.navigationBar.tintColor = .white
        let editBarButton = UIBarButtonItem(title: NSLocalizedString("Edit", comment: ""), style: .plain, target: self, action: #selector(editBarButtonTapped(object:)))
        navigationItem.rightBarButtonItem = editBarButton
        
        // Collection View Setup
        collectionView.delegate = self
        collectionView.dataSource = self

        presenter?.viewIsReady()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        presenter?.pageViewStarted()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        presenter?.pageViewEnded()
    }
    
    func updateDisplay(_ viewModel: DashboardViewModel) {
        self.viewModel = viewModel
        
        // check for empty state
        
        // display courses
        collectionView.reloadData()
    }
    
    @objc
    func editBarButtonTapped(object: Any) {
        // TODO:
        //delegate?.editButtonWasTapped()
        
        // REMOVE
        let alert = UIAlertController(title: "Edit Favorites", message: "Hook me up chief! See line \(#line) in \(#file)", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Okay", style: .cancel, handler: nil))
        self.present(alert, animated: true, completion: nil)
    }
}

enum DashboardViewSection: Int {
    case courses = 0
    case groups = 1
}

extension DashboardViewController: UICollectionViewDataSource {
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 2
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        guard let viewModel = viewModel else {
            return 0
        }
        
        if section == DashboardViewSection.courses.rawValue {
            return viewModel.favorites.count
        }
        
        return  viewModel.groups.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let viewModel = viewModel else {
            return UICollectionViewCell(frame: CGRect.zero)
        }
        
        if indexPath.section == DashboardViewSection.courses.rawValue {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "courseCard", for: indexPath) as! DashboardCourseCell
            let model = viewModel.favorites[indexPath.row]
            cell.configure(with: model)
            cell.optionsCallback = { [unowned self, model] in
                // TODO:
                //self.delegate?.courseWasSelected(model.courseID)
                
                // REMOVE
                let alert = UIAlertController(title: "Course Options", message: "Course options was tapped for Id => \(model.courseID). See line \(#line) in \(#file)", preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "Okay", style: .cancel, handler: nil))
                self.present(alert, animated: true, completion: nil)
            }
            return cell
        }
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "groupCard", for: indexPath) as! DashboardGroupCell
        let group = viewModel.groups[indexPath.row]
        cell.configure(with: group)
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        if kind == UICollectionElementKindSectionHeader {
            let v = collectionView.dequeueReusableSupplementaryView(ofKind: UICollectionElementKindSectionHeader, withReuseIdentifier: "header", for: indexPath) as! DashboardSectionHeaderView
            
            var title: String
            var rightButtonText: String?
            var action: (() -> Void)?
            if indexPath.section == DashboardViewSection.courses.rawValue {
                title = NSLocalizedString("Courses", comment: "")
                rightButtonText = NSLocalizedString("See All", comment: "")
                action = { [unowned self] in
                    self.presenter?.seeAllWasTapped()
                }
            } else {
                title = NSLocalizedString("Groups", comment: "")
                rightButtonText = nil
                action = nil
            }
            
            v.configure(title: title, rightButtonText: rightButtonText, rightAction: action)
            return v
        }
        
        return UICollectionReusableView()
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
    
        guard let viewModel = viewModel else {
            return
        }
        
        var alertTitle: String
        var itemId: String
        var itemTitle: String
        if indexPath.section == DashboardViewSection.courses.rawValue {
            let course = viewModel.favorites[indexPath.row]
            alertTitle = "Course"
            itemTitle = course.title
            itemId = course.courseID
            
            //delegate?.courseWasSelected(itemId)
        } else {
            let group = viewModel.groups[indexPath.row]
            alertTitle = "Group"
            itemTitle = group.groupName
            itemId = group.groupID
            
            //delegate?.groupWasSelected(itemId)
        }

        // REMOVE
        let alert = UIAlertController(title: "\(alertTitle) Selected", message: "\(alertTitle) Id => \(itemId) and title => \(itemTitle) was selected. See line: \(#line) in \(#file)", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Okay", style: .cancel, handler: nil))
        self.present(alert, animated: true, completion: nil)
    }
}

extension DashboardViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let section = indexPath.section
        if section == DashboardViewSection.courses.rawValue {
            return CGSize(width: (collectionView.bounds.width - ((coursesColumns+1) * gutterWidth)) / coursesColumns, height: 150)
        }
        
        return  CGSize(width: (collectionView.bounds.width - ((groupsColumns+1) * gutterWidth)) / groupsColumns, height: 65)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return UIEdgeInsets(top: 0, left: gutterWidth, bottom: 10, right: gutterWidth)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        if section == DashboardViewSection.courses.rawValue {
            return gutterWidth
        } else if section == DashboardViewSection.groups.rawValue {
            return  gutterWidth
        }
        
        return 0
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        if section == DashboardViewSection.courses.rawValue {
            return gutterWidth
        }
        
        return  0
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {
        return CGSize(width: collectionView.bounds.width, height: 50)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForFooterInSection section: Int) -> CGSize {
        return CGSize.zero
    }
}
