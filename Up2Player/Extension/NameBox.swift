//
//  NameBox.swift
//  Up2Player
//
//  Created by blurryssky on 2019/1/22.
//  Copyright © 2019 blurryssky. All rights reserved.
//

import Foundation

class Up2Player<T> {
    
    var base: T
    
    init(_ base: T) {
        self.base = base
    }
}

protocol NameBox {
    associatedtype U
    
    static var up2p: Up2Player<U>.Type { get }
    
    var up2p: Up2Player<U> { get }
}

extension NameBox {
    
    static var up2p: Up2Player<Self>.Type {
        return Up2Player<Self>.self
    }
    
    var up2p: Up2Player<Self> {
        return Up2Player(self)
    }
}
