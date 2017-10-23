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




open class CustomizeEnrollmentViewController: UIViewController {
    
    fileprivate let colorsByButtonTag: [Int: (UIColor, String)] = [
        1: (.contextRed(), NSLocalizedString("Red", tableName: "Localizable", bundle: .core, value: "", comment: "red course color button")),
        2: (.contextPink(), NSLocalizedString("Pink", tableName: "Localizable", bundle: .core, value: "", comment: "Pink course color button")),
        3: (.contextPurple(), NSLocalizedString("Purple", tableName: "Localizable", bundle: .core, value: "", comment: "Purple course color button")),
        4: (.contextDeepPurple(), NSLocalizedString("DeepPurple", tableName: "Localizable", bundle: .core, value: "", comment: "DeepPurple course color button")),
        5: (.contextIndigo(), NSLocalizedString("Indigo", tableName: "Localizable", bundle: .core, value: "", comment: "Indigo course color button")),
        6: (.contextBlue(), NSLocalizedString("Blue", tableName: "Localizable", bundle: .core, value: "", comment: "Blue course color button")),
        7: (.contextLightBlue(), NSLocalizedString("LightBlue", tableName: "Localizable", bundle: .core, value: "", comment: "LightBlue course color button")),
        8: (.contextCyan(), NSLocalizedString("Cyan", tableName: "Localizable", bundle: .core, value: "", comment: "Cyan course color button")),
        9: (.contextTeal(), NSLocalizedString("Teal", tableName: "Localizable", bundle: .core, value: "", comment: "Teal course color button")),
        10: (.contextGreen(), NSLocalizedString("Green", tableName: "Localizable", bundle: .core, value: "", comment: "Green course color button")),
        11: (.contextLightGreen(), NSLocalizedString("LightGreen", tableName: "Localizable", bundle: .core, value: "", comment: "LightGreen course color button")),
        12: (.contextYellow(), NSLocalizedString("Yellow", tableName: "Localizable", bundle: .core, value: "", comment: "Yellow course color button")),
        13: (.contextOrange(), NSLocalizedString("Orange", tableName: "Localizable", bundle: .core, value: "", comment: "Orange course color button")),
        14: (.contextDeepOrange(), NSLocalizedString("DeepOrange", tableName: "Localizable", bundle: .core, value: "", comment: "DeepOrange course color button")),
        15: (.contextLightPink(), NSLocalizedString("LightPink", tableName: "Localizable", bundle: .core, value: "", comment: "LightPink course color button")),
    ]

    let session: Session
    let dataSource: EnrollmentsDataSource
    let context: ContextID
    
    @IBOutlet var courseColorButtons: [UIButton]!
    @IBOutlet var header: UIView!
    
    public init(session: Session, context: ContextID) {
        self.session = session
        self.dataSource = session.enrollmentsDataSource
        self.context = context
        
        super.init(nibName: "CustomizeEnrollmentViewController", bundle: Bundle(for: CustomizeEnrollmentViewController.classForCoder()))
    }

    public required init(coder aDecoder: NSCoder) {
        ❨╯°□°❩╯⌢"init(coder:) has not been implemented"
    }

    open override func viewDidLoad() {
        super.viewDidLoad()
        ensureConsistentColors()
        
        self.navigationItem.title = NSLocalizedString("Customize", tableName: "Localizable", bundle: .core, value: "", comment: "Header label for a screen that customizes a course")
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(doneButtonTapped(_:)))
        self.view.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:[topGuide]-0-[header]", options: NSLayoutFormatOptions(), metrics: nil, views: ["topGuide": self.topLayoutGuide, "header": self.header]))
        
        for courseColorButton in self.courseColorButtons {
            courseColorButton.layer.cornerRadius = 4.0
        }
    }
    
    open override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        delay(0.001) {
            self.setCurrentContextColorButtonSelected(true)
        }
    }
    
    func doneButtonTapped(_ sender: UIBarButtonItem) {
        dismiss(animated: true, completion: nil)
    }
    
    fileprivate func ensureConsistentColors() {
        for button in courseColorButtons {
            button.backgroundColor = colorsByButtonTag[button.tag]?.0
            button.accessibilityLabel = colorsByButtonTag[button.tag]?.1
            button.accessibilityIdentifier = colorsByButtonTag[button.tag]?.1
        }
        
    }

    @IBAction func colorButtonTapped(_ sender: UIButton) {
        setCurrentContextColorButtonSelected(false)
        
        view.isUserInteractionEnabled = false
        guard let color = colorsByButtonTag[sender.tag]?.0 else { return }
        dataSource.setColor(color, inSession: session, forContextID: context)
            .on(completed: { [weak self] in
                self?.setCurrentContextColorButtonSelected(true)
                self?.view.isUserInteractionEnabled = true
            })
            .startWithFailed { [weak self] err in
                ErrorReporter.reportError(err, from: self)
                self?.view.isUserInteractionEnabled = true
            }
        
    }
    
    fileprivate var currentContextColorButton: UIButton? {
        guard let enrollment = dataSource[context] else { return nil }
        let contextColor = enrollment.color.value
        for courseColorButton in self.courseColorButtons {
            if let courseColorButtonBackgroundColor = courseColorButton.backgroundColor,
                let contextColor = contextColor {
                if colorsAreCloseToSame(color1: courseColorButtonBackgroundColor, color2: contextColor) {
                    return courseColorButton
                }
            }
            
        }
      
        return nil
    }
    
    fileprivate func setCurrentContextColorButtonSelected(_ selected: Bool) {
        if let button = currentContextColorButton {
            let a11yLabel = colorsByButtonTag[button.tag]?.1 ?? ""
            if selected {
                button.accessibilityLabel = a11yLabel + " — " + NSLocalizedString("Selected", tableName: "Localizable", bundle: .core, value: "", comment: "when a button is selected")
                var image: UIImage? = UIImage.icon(.check)
                let imageSize = image?.size ?? CGSize.zero
                
                let targetWidth = button.bounds.size.width * 0.75
                if imageSize.width > targetWidth {
                    image = image?.resizedImage(CGSize(width: targetWidth, height: targetWidth))
                }
                button.setImage(image, for: UIControlState())
                button.tintColor = UIColor.white
            } else {
                button.setImage(nil, for: UIControlState())
                button.accessibilityLabel = a11yLabel
            }
        }
    }
    
    fileprivate func colorsAreCloseToSame(color1: UIColor, color2: UIColor) -> Bool {
        var red1: CGFloat = 0.0, green1: CGFloat = 0.0, blue1: CGFloat = 0.0, alpha1: CGFloat = 0.0;
        color1.getRed(&red1, green: &green1, blue: &blue1, alpha: &alpha1)
        
        var red2: CGFloat = 0.0, green2: CGFloat = 0.0, blue2: CGFloat = 0.0, alpha2: CGFloat = 0.0;
        color2.getRed(&red2, green: &green2, blue: &blue2, alpha: &alpha2)
        
        let color1String = NSString(format: "%.4f,%.4f,%.4f,%.4f", red1, green1, blue1, alpha1) as String
        let color2String = NSString(format: "%.4f,%.4f,%.4f,%.4f", red2, green2, blue2, alpha2) as String
        
        return color1String == color2String
    }
    
}
