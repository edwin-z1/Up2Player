//
//  PlayerItemListViewModel.swift
//  Up2Player
//
//  Created by blurryssky on 2019/1/21.
//  Copyright © 2019 blurryssky. All rights reserved.
//

import Foundation

import RxSwift
import RxDataSources

struct PlayItemStreamViewModel {
    
    let playItemsSubject: BehaviorSubject<[PlayItem]> = BehaviorSubject(value: [])
    
    var animatableModelObservable: Observable<[AnimatableSectionModel<Int, PlayItem>]> {
        return playItemsSubject
            .map{ [AnimatableSectionModel(model: 0, items: $0)] }
    }
    
    func getPlayItems(at path: String) {
        
        DispatchQueue(label: "com.up2player.getplayitems").async {
            guard let contents = try? FileManager.default.contentsOfDirectory(atPath: path) else {
                return
            }
            let playerItems = contents.map { content -> PlayItem in
                let subpath = path.appending("/\(content)")
                var isDirectory = ObjCBool(false)
                FileManager.default.fileExists(atPath: subpath, isDirectory: &isDirectory)
                return PlayItem(isDirectory: isDirectory.boolValue, name: content, path: subpath)
                }.sorted { (lhs, rhs) -> Bool in
                    if lhs.isDirectory {
                        return true
                    } else if rhs.isDirectory {
                        return false
                    } else {
                        return lhs.name > rhs.name
                    }
            }
            
            let semaphore = DispatchSemaphore(value: 0)
            for playItem in playerItems {
                _ = playItem.coverSubject
                    .skip(1)
                    .subscribe(onNext: { (_) in
                        semaphore.signal()
                    })
                playItem.getCover()
                semaphore.wait()
            }

            DispatchQueue.main.async {
                self.playItemsSubject.onNext(playerItems)
            }
        }
    }
    
    func removePlayerItem(at idx: Int) {
        guard var items = try? playItemsSubject.value() else {
            return
        }
        let deleteItem = items.remove(at: idx)
        try? FileManager.default.removeItem(atPath: deleteItem.path)
        playItemsSubject.onNext(items)
    }
}
