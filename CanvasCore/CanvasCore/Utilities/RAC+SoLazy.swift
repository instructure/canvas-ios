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



import UIKit
import Result
import ReactiveSwift

private struct AssociationKey {
    static var hidden: UInt8 = 0
    static var alpha: UInt8 = 0
    static var text: UInt8 = 0
    static var a11yLabel: UInt8 = 0
    static var a11yIdentifier: UInt8 = 0
    static var a11yHint: UInt8 = 0
    static var image: UInt8 = 0
    static var title: UInt8 = 0
    static var enabled: UInt8 = 0
    static var rightBarButtonItems: UInt8 = 0
    static var backgroundColor: UInt8 = 0
    static var tintColor: UInt8 = 0
}

// lazily creates a gettable associated property via the given factory
func lazyAssociatedProperty<T: AnyObject>(_ host: AnyObject, key: UnsafeRawPointer, factory: ()->T) -> T {
    return objc_getAssociatedObject(host, key) as? T ?? {
        let associatedProperty = factory()
        objc_setAssociatedObject(host, key, associatedProperty, objc_AssociationPolicy.OBJC_ASSOCIATION_RETAIN)
        return associatedProperty
        }()
}

func lazyMutableProperty<T>(_ host: AnyObject, key: UnsafeRawPointer, setter: @escaping (T) -> (), getter: @escaping () -> T) -> MutableProperty<T> {
    return lazyAssociatedProperty(host, key: key) {
        let property = MutableProperty<T>(getter())
        property.producer
            .startWithValues {
                newValue in
                setter(newValue)
        }

        return property
    }
}

extension NSObject {
    public var rac_a11yLabel: MutableProperty<String?> {
        return lazyMutableProperty(self, key: &AssociationKey.a11yLabel, setter: { [unowned self] in self.accessibilityLabel = $0 }, getter: { [unowned self] in self.accessibilityLabel })
    }

    public var rac_a11yHint: MutableProperty<String?> {
        return lazyMutableProperty(self, key: &AssociationKey.a11yHint, setter: { [unowned self] in self.accessibilityHint = $0 }, getter: { [unowned self] in self.accessibilityHint })
    }
}

extension UIView {
    public var rac_alpha: MutableProperty<CGFloat> {
        return lazyMutableProperty(self, key: &AssociationKey.alpha, setter: { [unowned self] in self.alpha = $0 }, getter: { [unowned self] in self.alpha  })
    }

    public var rac_hidden: MutableProperty<Bool> {
        return lazyMutableProperty(self, key: &AssociationKey.hidden, setter: { [unowned self] in self.isHidden = $0 }, getter: { [unowned self] in self.isHidden  })
    }

    public var rac_backgroundColor: MutableProperty<UIColor?> {
        return lazyMutableProperty(self, key: &AssociationKey.backgroundColor, setter: { [unowned self] in self.backgroundColor = $0 }, getter: { [unowned self] in self.backgroundColor })
    }

    public var rac_tintColor: MutableProperty<UIColor> {
        return lazyMutableProperty(self, key: &AssociationKey.tintColor, setter: { [unowned self] in self.tintColor = $0 }, getter: { [unowned self] in self.tintColor })
    }
}

extension UILabel {
    public var rac_text: MutableProperty<String> {
        return lazyMutableProperty(self, key: &AssociationKey.text, setter: { [unowned self] in self.text = $0 }, getter: { [unowned self] in self.text ?? "" })
    }
}

extension UITextField {
    public var rac_text: MutableProperty<String> {
        return lazyAssociatedProperty(self, key: &AssociationKey.text) {

            self.addTarget(self, action: #selector(UITextField.changed), for: .editingChanged)

            let property = MutableProperty<String>(self.text ?? "")
            property.producer
                .startWithValues {
                    newValue in
                    self.text = newValue
            }
            return property
        }
    }

    func changed() {
        rac_text.value = self.text ?? ""
    }
}

extension UIImageView {
    public var rac_image: MutableProperty<UIImage?> {
        return lazyMutableProperty(self, key: &AssociationKey.image, setter: { [unowned self] in self.image = $0 }, getter: { [unowned self] in self.image })
    }
}

extension UIButton {
    public var rac_image: MutableProperty<UIImage?> {
        return lazyMutableProperty(self, key: &AssociationKey.image, setter: { [unowned self] in self.setImage($0, for: .normal) }, getter: { [unowned self] in self.imageView?.image })
    }

    public var rac_title: MutableProperty<String?> {
        return lazyMutableProperty(self, key: &AssociationKey.text, setter: { [unowned self] in self.setTitle($0, for: .normal) }, getter: { [unowned self] in self.titleLabel?.text })
    }
}

extension UIViewController {
    public var rac_title: MutableProperty<String?> {
        return lazyMutableProperty(self, key: &AssociationKey.title, setter: { [unowned self] in self.title = $0 }, getter: { [unowned self] in self.title })
    }
}

extension UIControl {
    public var rac_enabled: MutableProperty<Bool> {
        return lazyMutableProperty(self, key: &AssociationKey.enabled, setter: { [unowned self] in self.isEnabled = $0 }, getter: { [unowned self] in self.isEnabled  })
    }
}

extension UIAccessibilityIdentification {
    public var rac_a11yIdentifier: MutableProperty<String?> {
        return lazyMutableProperty(self, key: &AssociationKey.a11yIdentifier, setter: { [unowned self] in self.accessibilityIdentifier = $0 }, getter: { [unowned self] in self.accessibilityIdentifier })
    }
}

extension UIBarItem {
    public var rac_enabled: MutableProperty<Bool> {
        return lazyMutableProperty(self, key: &AssociationKey.enabled, setter: { [unowned self] in self.isEnabled = $0 }, getter: { [unowned self] in self.isEnabled  })
    }
}

extension UINavigationItem {
    public var rac_rightBarButtonItems: MutableProperty<[UIBarButtonItem]?> {
        return lazyMutableProperty(self, key: &AssociationKey.rightBarButtonItems, setter: { [unowned self] in self.rightBarButtonItems = $0 }, getter: { [unowned self] in self.rightBarButtonItems })
    }
}
