//
//  UserDefaults+NameBox.swift
//  kuso
//
//  Created by blurryssky on 2018/7/3.
//  Copyright © 2018年 momo. All rights reserved.
//

import Foundation

enum UserDefaultsKeys: String {
    case playbackPosition
}

extension Up2Player where T: UserDefaults {
    
    func setPlaybackPosition(position: Float, name: String) {
        var targetDict: [String:Float]!
        if let dict = base.dictionary(forKey: UserDefaultsKeys.playbackPosition.rawValue) as? [String:Float] {
            targetDict = dict
        } else {
            targetDict = [:]
        }
        targetDict[name] = position
        base.set(targetDict, forKey: UserDefaultsKeys.playbackPosition.rawValue)
    }
    
    func position(name: String) -> Float? {
        var targetDict: [String:Float]?
        if let dict = base.dictionary(forKey: UserDefaultsKeys.playbackPosition.rawValue) as? [String:Float] {
            targetDict = dict
        }
        return targetDict?[name]
    }
}

