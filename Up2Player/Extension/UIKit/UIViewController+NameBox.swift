//
//  UIViewController+bs.swift
//  10000ui-swift
//
//  Created by 张亚东 on 11/08/2017.
//  Copyright © 2017 blurryssky. All rights reserved.
//

import UIKit

fileprivate struct AssociatedObjectKeys {
    static var dismissCompletion = "dismissCompletion"
    static var leftClickHandler = "leftClickHandler"
    static var rightClickHandler = "rightClickHandler"
}

extension Up2Player where T: UIViewController {
    
    var visibleViewController: UIViewController? {
        
        if let presented = base.presentedViewController {
            return presented.up2p.visibleViewController
        } else if let tabBar = base as? UITabBarController {
            return tabBar.selectedViewController?.up2p.visibleViewController
        } else if let navi = base as? UINavigationController {
            return navi.visibleViewController?.up2p.visibleViewController
        } else {
            return base
        }
    }
    
    var parentViewController: UIViewController? {
        
        if let parent = base.parent,
            parent != base.presentingViewController,
            !parent.isKind(of: UITabBarController.self),
            !parent.isKind(of: UINavigationController.self) {
            return parent.up2p.parentViewController
        } else {
            return base
        }
    }
}

extension Up2Player where T: UIViewController {
    
    func setLeftItem(image: UIImage, clickHandler:(() -> Void)? = nil) {
        base.leftClickHandler = clickHandler
        base.navigationItem.leftBarButtonItem = UIBarButtonItem(image: image.withRenderingMode(.alwaysOriginal), style: .plain, target: base, action: #selector(UIViewController.handleBackLeftItem(sender:)))
    }
    
    func setRightItem(image: UIImage, clickHandler: (() -> Void)?)  {
        base.rightClickHandler = clickHandler
        base.navigationItem.rightBarButtonItem = UIBarButtonItem(image: image, style:.plain, target: base, action: #selector(UIViewController.handleRightItem(sender:)))
    }
    
    static func instantiateFromStoryboard(name: String = "Main", bundle: Bundle? = nil, identifier: String? = nil) -> T {
        let ident = identifier ?? T.up2p.string
        return UIStoryboard(name: name, bundle: bundle).instantiateViewController(withIdentifier: ident) as! T
    }
}

fileprivate extension UIViewController {
    
    var leftClickHandler: (() -> Void)? {
        set {
            objc_setAssociatedObject(self, &AssociatedObjectKeys.leftClickHandler, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        }
        get {
            return objc_getAssociatedObject(self, &AssociatedObjectKeys.leftClickHandler) as? (() -> Void)
        }
    }
    
    @objc func handleBackLeftItem(sender: UIBarButtonItem) {
        if let handler = leftClickHandler {
            handler()
        } else {
            navigationController?.popViewController(animated: true)
        }
    }
    
    var dismissCompletion: (() -> Void)? {
        set {
            objc_setAssociatedObject(self, &AssociatedObjectKeys.dismissCompletion, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        }
        get {
            return objc_getAssociatedObject(self, &AssociatedObjectKeys.dismissCompletion) as? (() -> Void)
        }
    }
    
    @objc func handleDismissItem(sender: UIBarButtonItem) {
        dismiss(animated: true, completion: self.dismissCompletion)
    }
    
    var rightClickHandler: (() -> Void)? {
        set {
            objc_setAssociatedObject(self, &AssociatedObjectKeys.rightClickHandler, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        }
        get {
            return objc_getAssociatedObject(self, &AssociatedObjectKeys.rightClickHandler) as? (() -> Void)
        }
    }
    
    @objc func handleRightItem(sender: UIBarButtonItem) {
        rightClickHandler?()
    }
}
