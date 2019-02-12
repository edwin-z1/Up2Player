//
//  PlayItemStreamCollectionCell.swift
//  Up2Player
//
//  Created by blurryssky on 2019/2/11.
//  Copyright © 2019 blurryssky. All rights reserved.
//

import UIKit

class PlayItemStreamCollectionCell: UICollectionViewCell {

    var playItem: PlayItem! {
        didSet {
            update()
        }
    }
    
    @IBOutlet weak var imgView: UIImageView!
    @IBOutlet weak var label: UILabel!
    @IBOutlet weak var constraintImgViewHeight: NSLayoutConstraint!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        layer.shadowColor = UIColor.black.cgColor
        layer.shadowOpacity = 0.1
        layer.shadowOffset = CGSize(width: 0, height: 1)
    }
}

private extension PlayItemStreamCollectionCell {
    
    func update() {
        
        if playItem.isDirectory {
            imgView.contentMode = .center
        } else {
            imgView.contentMode = .scaleAspectFill
        }
        constraintImgViewHeight.constant = playItem.imgHeight
        
        _ = playItem.coverSubject
            .bind(to: imgView.rx.image)
        
        label.text = playItem.name
    }
    
}

