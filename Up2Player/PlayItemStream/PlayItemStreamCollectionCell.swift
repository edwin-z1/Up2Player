//
//  PlayItemStreamCollectionCell.swift
//  Up2Player
//
//  Created by blurryssky on 2019/2/11.
//  Copyright © 2019 blurryssky. All rights reserved.
//

import UIKit

import RxSwift
import RxCocoa

class PlayItemStreamCollectionCell: UICollectionViewCell {

    var playItem: PlayItem! {
        didSet {
            update()
        }
    }
    
    @IBOutlet weak var imgView: UIImageView!
    @IBOutlet weak var label: UILabel!
    @IBOutlet weak var constraintImgViewHeight: NSLayoutConstraint!
    @IBOutlet weak var progressView: UIProgressView!
    
    private var reuseBag = DisposeBag()
    
    override func awakeFromNib() {
        super.awakeFromNib()
        layer.shadowColor = UIColor.black.cgColor
        layer.shadowOpacity = 0.1
        layer.shadowOffset = CGSize(width: 0, height: 1)
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        reuseBag = DisposeBag()
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
        
        playItem.coverSubject
            .bind(to: imgView.rx.image)
            .disposed(by: reuseBag)
        
        progressView.isHidden = playItem.isDirectory
        playItem.positionSubject
            .bind(to: progressView.rx.progress)
            .disposed(by: reuseBag)
        
        label.text = playItem.name
    }
    
}

