//
//  FileManager+NameBox.swift
//  kuso
//
//  Created by blurryssky on 2018/5/3.
//  Copyright © 2018年 momo. All rights reserved.
//

import Foundation

private let libraryPath = NSSearchPathForDirectoriesInDomains(.libraryDirectory, .userDomainMask, true).first!
private let thumbnailsDir = URL(fileURLWithPath: libraryPath).appendingPathComponent("Thumbnails")

extension Up2Player where T: FileManager {
    func size(url: URL) -> Double? {
        if let attributes = try? base.attributesOfItem(atPath: url.path),
            let size = attributes[.size] as? Double {
            return size
        } else {
            return nil
        }
    }
    
    func loadImg(name: String) -> UIImage? {
        let path = thumbnailsDir.appendingPathComponent(name).path
        return UIImage(contentsOfFile: path)
    }
    
    func saveImg(imgData: Data, name: String) {
        let path = thumbnailsDir.appendingPathComponent(name)
        try? imgData.write(to: path)
    }
}

extension Up2Player where T: FileManager {
    
    static func createDirectorys() {
        let dirs = [thumbnailsDir]
        for dir in dirs {
            if !FileManager.default.fileExists(atPath: dir.path) {
                do {
                    try FileManager.default.createDirectory(at: dir, withIntermediateDirectories: true)
                } catch let error {
                    print("create \(dir) = \(error)")
                }
            }
        }
    }
    
    static func removeDirectorys() {
        
        let dirs = [thumbnailsDir]
        for dir in dirs {
            do {
                try T.default.removeItem(at: dir)
            } catch let error {
                print("clearFiles \(dir) = \(error)")
            }
        }
    }
}
