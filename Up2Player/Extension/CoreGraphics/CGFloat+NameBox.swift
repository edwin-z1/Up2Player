//
//  CGFloat+bs.swift
//  BSCircleSliderSample
//
//  Created by 张亚东 on 09/08/2017.
//  Copyright © 2017 blurryssky. All rights reserved.
//

import CoreGraphics

extension CGFloat: NameBox {}

extension Up2Player where T == CGFloat {
    
    var circumPositiveValue: CGFloat {
        var value = base
        if value < 0 {
            value += .pi * 2
            return value.up2p.circumPositiveValue
        } else if value > .pi * 2 {
            value -= .pi * 2
            return value.up2p.circumPositiveValue
        } else {
            return value
        }
    }
}

