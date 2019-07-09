//
// This file is part of Canvas.
// Copyright (C) 2016-present  Instructure, Inc.
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

import UIKit

private func pandifyImages(fromIndex start: Int, toIndex end: Int) -> [UIImage] {
    var images: [UIImage] = []
    for i in start...end {
        let imageName = String(format: "pandify-%d", i)
        if let image = UIImage(named: imageName, in: Bundle(for: PandatarBuilderViewController.classForCoder()), compatibleWith: nil) {
            images.append(image)
        }
    }
    return images
}

open class PandatarBuilderViewController: UIViewController {

    @IBOutlet var pandatarBox: UIView!
    @IBOutlet var headViews: InfinitePagedImagesView!
    @IBOutlet var bodyViews: InfinitePagedImagesView!
    @IBOutlet var legViews: InfinitePagedImagesView!

    @objc open var doneBuilding: (UIImage)->Void = { _ in }
    @objc open var canceledBuilding: ()->Void = { }

    @objc lazy var headImages: [UIImage] = {
        return pandifyImages(fromIndex: 1, toIndex: 9)
    }()
    @objc lazy var bodyImages: [UIImage] = {
        return pandifyImages(fromIndex: 10, toIndex: 22)
    }()
    @objc lazy var legImages: [UIImage] = {
        return pandifyImages(fromIndex: 23, toIndex: 27)
    }()

    public init() {
        super.init(nibName: "PandatarBuilderViewController", bundle: Bundle(for: PandatarBuilderViewController.classForCoder()))
    }
    
    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override open func viewDidLoad() {
        super.viewDidLoad()

        navigationItem.title = NSLocalizedString("Build Your Panda!", tableName: "Localizable", bundle: Bundle(for: type(of: self)), value: "", comment: "Title for screen to build a panda avatar")
        navigationItem.leftBarButtonItem = UIBarButtonItem(barButtonSystemItem: .cancel, target: self, action: #selector(PandatarBuilderViewController.cancel(_:)))
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(PandatarBuilderViewController.done(_:)))

        automaticallyAdjustsScrollViewInsets = false
    }

    override open func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        buildFrankenPanda()
        navigationItem.rightBarButtonItem?.isEnabled = false // don't allow the user to press done until the randomizePanda animation is completed
    }

    override open func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        randomizePanda()
    }

    @objc func cancel(_ sender: UIBarButtonItem) {
        canceledBuilding()
    }

    @objc func done(_ sender: UIBarButtonItem) {
        let image = snapshotPanda()
        doneBuilding(image)
    }

    fileprivate func buildFrankenPanda() {
        headViews.setImages(headImages)
        bodyViews.setImages(bodyImages)
        legViews.setImages(legImages)
    }

    fileprivate func randomizePanda() {
        pandatarBox.isUserInteractionEnabled = false
        navigationItem.rightBarButtonItem?.isEnabled = false
        UIView.animate(withDuration: 2.0, delay: 0.0, options: UIView.AnimationOptions(rawValue: 0), animations: {
            let headPage = arc4random_uniform(UInt32(self.headImages.count-1))+1
            var bodyPage = headPage
            if self.bodyImages.count > 2 {
                while bodyPage == headPage { bodyPage = arc4random_uniform(UInt32(self.bodyImages.count-1))+1 }
            } else {
                bodyPage = arc4random_uniform(UInt32(self.bodyImages.count))
            }
            var legPage = headPage
            if self.legImages.count > 3 {
                while legPage == headPage || legPage == bodyPage { legPage = arc4random_uniform(UInt32(self.legImages.count-1))+1 }
            } else {
                legPage = arc4random_uniform(UInt32(self.legImages.count))
            }
            self.headViews.goToPage(Int(headPage), animated: false)
            self.bodyViews.goToPage(Int(bodyPage), animated: false)
            self.legViews.goToPage(Int(legPage), animated: false)
        }, completion: { finished in
            self.pandatarBox.isUserInteractionEnabled = true
            self.navigationItem.rightBarButtonItem?.isEnabled = true
        })
    }

    fileprivate func snapshotPanda() -> UIImage {
        let padding: CGFloat = 0.25
        let headSize = headImages.first!.size
        let clipSize = CGSize(width: headSize.width * (1 + (padding * 2)), height: headSize.height * (1 + (padding * 2)))
        let clipFrame = CGRect(x: pandatarBox.frame.midX - clipSize.width/2.0, y: 0 - (headSize.height * padding), width: clipSize.width, height: clipSize.height)

        UIGraphicsBeginImageContextWithOptions(clipFrame.size, true, UIScreen.main.scale)
        let ctx = UIGraphicsGetCurrentContext()

        ctx!.translateBy(x: -clipFrame.origin.x, y: -clipFrame.origin.y)

        ctx!.setFillColor(UIColor.lightGray.cgColor)
        ctx!.fill(clipFrame)

        pandatarBox.layer.render(in: ctx!)

        let img = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()

        return img!
    }

}
