//
//  UIViewController.swift
//  Pods-PublicUI_Example
//
//  Created by Di on 2019/6/5.
//

protocol ManagerControllerProtocol: UIViewController {
    var controllers: [UIViewController] { get }
}

extension UISplitViewController: ManagerControllerProtocol {
    var controllers: [UIViewController] {
        return viewControllers
    }
}
extension UITabBarController: ManagerControllerProtocol {
    var controllers: [UIViewController] {
        return viewControllers ?? []
    }
}
extension UINavigationController: ManagerControllerProtocol {
    var controllers: [UIViewController] {
        return viewControllers
    }
}

extension UIView {
    func clearKeyboard() {
        for item in subviews {
            if let item = item as? UITextView {
                item.endEditing(true)
                break
            } else if let item = item as? UITextField {
                item.endEditing(true)
                break
            }

            item.clearKeyboard()
        }
    }
}

extension UIViewController {
    public func showAlert(title: String = "提示",
                          message: String,
                          preferStyle: UIAlertController.Style = .alert,
                          actionTitles: [String] = ["确定"],
                          actionDo: @escaping (String, Int) -> Void) {
        let alertController = UIAlertController(title: title, message: message, preferredStyle: preferStyle)

        for (index, item) in actionTitles.enumerated() {
            alertController.addAction(UIAlertAction(title: item, style: .default, handler: { (_) in
                actionDo(item, index)
            }))
        }

        self.present(alertController, animated: true, completion: nil)
    }

    public class var current: UIViewController? {
        guard let controller = UIApplication.shared.keyWindow?.rootViewController else {
            return nil
        }

        return findBestViewController(from: controller)
    }

    public func clearKeyboard() {
        self.view.clearKeyboard()
    }

    private class func findBestViewController(from viewController: UIViewController) -> UIViewController {
        if let controller = viewController.presentedViewController {
            return findBestViewController(from: controller)
        } else if let viewController = viewController as? ManagerControllerProtocol {
            if let last = viewController.controllers.last {
                return last
            } else {
                return viewController
            }
        } else {
            return viewController
        }
    }
}
