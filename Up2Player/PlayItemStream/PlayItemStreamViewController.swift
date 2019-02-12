//
//  PlayItemStreamViewController.swift
//  Up2Player
//
//  Created by blurryssky on 2019/2/11.
//  Copyright © 2019 blurryssky. All rights reserved.
//

import UIKit

import RxSwift
import RxCocoa
import RxDataSources

class PlayItemStreamViewController: UIViewController {
    
    var path = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true).first!
    
    private let viewModel = PlayItemStreamViewModel()
    private let bag = DisposeBag()
    
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var layout: PinterestLayout!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        setup()
    }
    
    override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        return .portrait
    }
    
    override var preferredInterfaceOrientationForPresentation: UIInterfaceOrientation {
        return .portrait
    }
}

private extension PlayItemStreamViewController {
    
    func setup() {
        
        layout.delegate = self

        let refreshControl = UIRefreshControl()
        refreshControl.rx.controlEvent(.valueChanged)
            .subscribe(onNext: { [unowned self] (_) in
                self.layout.invalidateLayout()
                self.viewModel.getPlayItems(at: self.path)
            })
            .disposed(by: bag)
        collectionView.refreshControl = refreshControl
        
        let dataSource = RxCollectionViewSectionedAnimatedDataSource<AnimatableSectionModel<Int, PlayItem>>(configureCell: { (dataSource, collectionView, indexPath, playItem) -> UICollectionViewCell in
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: PlayItemStreamCollectionCell.up2p.string, for: indexPath) as! PlayItemStreamCollectionCell
            cell.playItem = playItem
            return cell
        })
        
        viewModel.animatableModelObservable
            .do(onNext: { [weak self] (model) in
                guard let `self` = self else { return }
                self.collectionView.refreshControl?.endRefreshing()
                self.layout.numberOfItems = model.first?.items.count ?? 0
            })
            .bind(to: collectionView.rx.items(dataSource: dataSource))
            .disposed(by: bag)
        
        collectionView.rx.modelSelected(PlayItem.self)
            .subscribe(onNext: { [unowned self] (playItem) in
                if playItem.isDirectory {
                    let playItemVC = PlayItemStreamViewController.up2p.instantiateFromStoryboard()
                    playItemVC.path = playItem.path
                    playItemVC.title = playItem.name
                    self.navigationController?.pushViewController(playItemVC, animated: true)
                } else {
                    let playerVC = PlayerViewController.up2p.instantiateFromStoryboard()
                    playerVC.playItem = playItem
                    self.present(playerVC, animated: true, completion: nil)
                }
            })
            .disposed(by: bag)
        
        let longPress = UILongPressGestureRecognizer()
        longPress.rx.event
            .subscribe(onNext: { [unowned self] (longPress) in
                
                switch longPress.state {
                case .began:
                    let location = longPress.location(in: self.collectionView)
                    guard let indexPath = self.collectionView.indexPathForItem(at: location),
                        let items = try? self.viewModel.playItemsSubject.value() else {
                            return
                    }
                    let item = items[indexPath.item]
                    let alertController = UIAlertController(title: "确认删除?", message: item.name, preferredStyle: .alert)
                    let cancelAction = UIAlertAction(title: "取消", style: .default, handler: nil)
                    let confirmAction = UIAlertAction(title: "确认", style: .destructive, handler: { [unowned self] (_) in
                        self.layout.invalidateLayout()
                        self.viewModel.removePlayerItem(at: indexPath.item)
                    })
                    alertController.addAction(cancelAction)
                    alertController.addAction(confirmAction)
                    self.present(alertController, animated: true, completion: nil)
                default:
                    break
                }
            })
            .disposed(by: bag)
        collectionView.addGestureRecognizer(longPress)
        
        viewModel.getPlayItems(at: path)
    }
}

extension PlayItemStreamViewController: PinterestLayoutDelegate {
    
    func collectionView(_ collectionView: UICollectionView, heightForPhotoAtIndexPath indexPath: IndexPath) -> CGFloat {
        guard let items = try? viewModel.playItemsSubject.value() else {
            return 0
        }
        return items[indexPath.item].height
    }
}
