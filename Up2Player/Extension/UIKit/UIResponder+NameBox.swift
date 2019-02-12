//
//  UIResponder+NameBox.swift
//  kuso
//
//  Created by blurryssky on 2018/5/16.
//  Copyright © 2018年 momo. All rights reserved.
//

import UIKit

extension Up2Player where T: UIResponder {
    
    var nextViewController: UIViewController? {
        if let next = base.next  {
            if let vc = next as? UIViewController,
                !vc.isKind(of: UINavigationController.self) {
                return vc
            } else {
                return next.up2p.nextViewController
            }
        } else {
            return nil
        }
    }
    
    var nextNaviViewController: UINavigationController? {
        if let next = base.next  {
            if let vc = next as? UINavigationController {
                return vc
            } else {
                return next.up2p.nextNaviViewController
            }
        } else {
            return nil
        }
    }
    
}
