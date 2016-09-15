//
//  CustomizeCourseViewController.swift
//  iCanvas
//
//  Created by Ben Kraus on 6/23/15.
//  Copyright (c) 2015 Instructure. All rights reserved.
//

import UIKit
import SoLazy
import TooLegit

public class CustomizeEnrollmentViewController: UIViewController {
    
    private let colorsByButtonTag: [Int: (UIColor, String)] = [
        1: (.contextRed(), NSLocalizedString("Red", comment: "red course color button")),
        2: (.contextPink(), NSLocalizedString("Pink", comment: "Pink course color button")),
        3: (.contextPurple(), NSLocalizedString("Purple", comment: "Purple course color button")),
        4: (.contextDeepPurple(), NSLocalizedString("DeepPurple", comment: "DeepPurple course color button")),
        5: (.contextIndigo(), NSLocalizedString("Indigo", comment: "Indigo course color button")),
        6: (.contextBlue(), NSLocalizedString("Blue", comment: "Blue course color button")),
        7: (.contextLightBlue(), NSLocalizedString("LightBlue", comment: "LightBlue course color button")),
        8: (.contextCyan(), NSLocalizedString("Cyan", comment: "Cyan course color button")),
        9: (.contextTeal(), NSLocalizedString("Teal", comment: "Teal course color button")),
        10: (.contextGreen(), NSLocalizedString("Green", comment: "Green course color button")),
        11: (.contextLightGreen(), NSLocalizedString("LightGreen", comment: "LightGreen course color button")),
        12: (.contextYellow(), NSLocalizedString("Yellow", comment: "Yellow course color button")),
        13: (.contextOrange(), NSLocalizedString("Orange", comment: "Orange course color button")),
        14: (.contextDeepOrange(), NSLocalizedString("DeepOrange", comment: "DeepOrange course color button")),
        15: (.contextLightPink(), NSLocalizedString("LightPink", comment: "LightPink course color button")),
    ]

    let session: Session
    let dataSource: ContextDataSource
    let context: ContextID
    
    @IBOutlet var courseColorButtons: [UIButton]!
    @IBOutlet var header: UIView!
    
    public init(session: Session, context: ContextID) {
        self.session = session
        self.dataSource = session.enrollmentsDataSource
        self.context = context
        
        super.init(nibName: "CustomizeEnrollmentViewController", bundle: NSBundle(forClass: CustomizeEnrollmentViewController.classForCoder()))
    }

    public required init(coder aDecoder: NSCoder) {
        ❨╯°□°❩╯⌢"init(coder:) has not been implemented"
    }

    public override func viewDidLoad() {
        super.viewDidLoad()
        ensureConsistentColors()
        
        self.navigationItem.title = NSLocalizedString("Customize", comment: "Header label for a screen that customizes a course")
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .Done, target: self, action: #selector(doneButtonTapped(_:)))
        self.view.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("V:[topGuide]-0-[header]", options: NSLayoutFormatOptions(), metrics: nil, views: ["topGuide": self.topLayoutGuide, "header": self.header]))
        
        for courseColorButton in self.courseColorButtons {
            courseColorButton.layer.cornerRadius = 4.0
        }
    }
    
    public override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        delay(0.001) {
            self.setCurrentContextColorButtonSelected(true)
        }
    }
    
    func doneButtonTapped(sender: UIBarButtonItem) {
        dismissViewControllerAnimated(true, completion: nil)
    }
    
    private func ensureConsistentColors() {
        for button in courseColorButtons {
            button.backgroundColor = colorsByButtonTag[button.tag]?.0
            button.accessibilityLabel = colorsByButtonTag[button.tag]?.1
            button.accessibilityIdentifier = colorsByButtonTag[button.tag]?.1
        }
        
    }

    @IBAction func colorButtonTapped(sender: UIButton) {
        setCurrentContextColorButtonSelected(false)
        
        view.userInteractionEnabled = false
        guard let color = colorsByButtonTag[sender.tag]?.0 else { return }
        dataSource.setColor(color, inSession: session, forContextID: context)
            .on(completed: {
                self.setCurrentContextColorButtonSelected(true)
                self.view.userInteractionEnabled = true
            })
            .startWithFailed { err in
                err.presentAlertFromViewController(self)
                self.view.userInteractionEnabled = true
            }
        
    }
    
    private var currentContextColorButton: UIButton? {
        guard let enrollment = dataSource[context] else { return nil }
        let contextColor = enrollment.color
        for courseColorButton in self.courseColorButtons {
            if let courseColorButtonBackgroundColor = courseColorButton.backgroundColor,
                contextColor = contextColor {
                if colorsAreCloseToSame(color1: courseColorButtonBackgroundColor, color2: contextColor) {
                    return courseColorButton
                }
            }
            
        }
      
        return nil
    }
    
    private func setCurrentContextColorButtonSelected(selected: Bool) {
        if let button = currentContextColorButton {
            let a11yLabel = colorsByButtonTag[button.tag]?.1 ?? ""
            if selected {
                button.accessibilityLabel = a11yLabel + " — " + NSLocalizedString("Selected", comment: "when a button is selected")
                var image = UIImage(named: "icon_check", inBundle: NSBundle(forClass: CustomizeEnrollmentViewController.self), compatibleWithTraitCollection: nil)
                let imageSize = image?.size ?? CGSizeZero
                
                let targetWidth = button.bounds.size.width * 0.75
                if imageSize.width > targetWidth {
                    image = image?.resizedImage(CGSize(width: targetWidth, height: targetWidth))
                }
                button.setImage(image, forState: .Normal)
                button.tintColor = UIColor.whiteColor()
            } else {
                button.setImage(nil, forState: .Normal)
                button.accessibilityLabel = a11yLabel
            }
        }
    }
    
    private func colorsAreCloseToSame(color1 color1: UIColor, color2: UIColor) -> Bool {
        var red1: CGFloat = 0.0, green1: CGFloat = 0.0, blue1: CGFloat = 0.0, alpha1: CGFloat = 0.0;
        color1.getRed(&red1, green: &green1, blue: &blue1, alpha: &alpha1)
        
        var red2: CGFloat = 0.0, green2: CGFloat = 0.0, blue2: CGFloat = 0.0, alpha2: CGFloat = 0.0;
        color2.getRed(&red2, green: &green2, blue: &blue2, alpha: &alpha2)
        
        let color1String = NSString(format: "%.4f,%.4f,%.4f,%.4f", red1, green1, blue1, alpha1) as String
        let color2String = NSString(format: "%.4f,%.4f,%.4f,%.4f", red2, green2, blue2, alpha2) as String
        
        return color1String == color2String
    }
    
}
