//
//  PlayerItem.swift
//  Up2Player
//
//  Created by blurryssky on 2019/1/21.
//  Copyright © 2019 blurryssky. All rights reserved.
//

import UIKit
import AVFoundation

import RxSwift
import RxDataSources

class PlayItem {
    
    var isDirectory: Bool!
    var name: String!
    var path: String!
    let coverSubject = BehaviorSubject<UIImage?>(value: nil)
    var isVertical = false
    let positionSubject = BehaviorSubject<Float>(value: 0)

    lazy var imgHeight: CGFloat = {
        if isDirectory {
            return 140
        } else {
            guard let imgValue = try? coverSubject.value(),
                let img = imgValue else {
                    return 0
            }
            isVertical = img.size.width <= img.size.height
            
            let width = UIScreen.main.bounds.width/2 * 1.1
            let h = floor((width/img.size.width) * img.size.height)
            return min(280, h)
        }
    }()
    
    lazy var height: CGFloat = {
        let cellPadding: CGFloat = 12
        let labelLeading: CGFloat = 6
        let width = (UIScreen.main.bounds.width - cellPadding * 3)/2 - labelLeading * 2
        let textHeight = name.up2p.size(UIFont.systemFont(ofSize: 15, weight: UIFont.Weight.light), maxsize: CGSize(width: width, height: 40)).height
        return 28 + imgHeight + floor(textHeight)
    }()
    
    private lazy var mediaThumbnailer: VLCMediaThumbnailer = {
        let mediaThumbnailer = VLCMediaThumbnailer(media: media, andDelegate: self)!
        return mediaThumbnailer
    }()
    
    init(isDirectory: Bool, name: String, path: String) {
        self.isDirectory = isDirectory
        self.name = name
        self.path = path
        getPosition()
    }
}

extension PlayItem {
    
    var media: VLCMedia {
        return VLCMedia(path: path)
    }
    
    func getCover() {
        
        guard !isDirectory else {
            coverSubject.onNext(#imageLiteral(resourceName: "folder"))
            return
        }
        
        if let img = FileManager.default.up2p.loadImg(name: name) {
            coverSubject.onNext(img)
            return
        }
        
        guard mediaThumbnailer.media.mediaType != .unknown else {
            coverSubject.onNext(nil)
            return
        }
        
        _ = coverSubject
            .filter{ $0 != nil }
            .subscribe(onNext: { [weak self] (img) in
                guard let `self` = self else { return }
                guard let data = img?.pngData() else { return }
                FileManager.default.up2p.saveImg(imgData: data, name: self.name)
            })
        
        mediaThumbnailer.fetchThumbnail()
    }
}

extension PlayItem {
    
    func setPosition(_ position: Float) {
        UserDefaults.standard.up2p.setPlaybackPosition(position: position, name: name)
        positionSubject.onNext(position)
    }
    
    private func getPosition() {
        let position = UserDefaults.standard.up2p.position(name: name) ?? 0
        positionSubject.onNext(position)
    }
}

extension PlayItem: VLCMediaThumbnailerDelegate {
    
    func mediaThumbnailerDidTimeOut(_ mediaThumbnailer: VLCMediaThumbnailer!) {
        coverSubject.onNext(nil)
    }
    
    func mediaThumbnailer(_ mediaThumbnailer: VLCMediaThumbnailer!, didFinishThumbnail thumbnail: CGImage!) {
        let img = UIImage(cgImage: thumbnail)
        coverSubject.onNext(img)
    }
}

extension PlayItem: IdentifiableType {
    typealias Identity = String
    
    var identity: String {
        return name
    }
}

extension PlayItem: Equatable {
    
    static func == (lhs: PlayItem, rhs: PlayItem) -> Bool{
        return lhs.name == rhs.name
    }
}
