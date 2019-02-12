//
//  String+bs.swift
//  10000ui-swift
//
//  Created by blurryssky on 2018/2/26.
//  Copyright © 2018年 blurryssky. All rights reserved.
//

import UIKit

extension String: NameBox {}

extension Up2Player where T == String {
    
    func size(_ font:UIFont, maxsize:CGSize) -> CGSize {
        let attrs = [NSAttributedString.Key.font: font]
        let rect = (base as NSString).boundingRect(with: maxsize,
                                                   options: [.usesLineFragmentOrigin,.usesFontLeading],
                                                   attributes: attrs, context: nil)
        return rect.size
    }
}
