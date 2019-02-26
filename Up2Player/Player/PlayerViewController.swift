//
//  PlayerViewController.swift
//  Up2Player
//
//  Created by blurryssky on 2019/1/22.
//  Copyright © 2019 blurryssky. All rights reserved.
//

import UIKit
import AVKit

import RxSwift
import RxCocoa

class PlayerViewController: UIViewController {
    
    var playItem: PlayItem!
    
    private let player = VLCMediaPlayer()
    private let bag = DisposeBag()
    private var hasSetPosition = false
    private var isPanHorizontal: Bool?
    
    @IBOutlet weak var playerView: UIView!
    @IBOutlet weak var seekTimeView: UIVisualEffectView!
    @IBOutlet weak var seekTimeLabel: UILabel!
    @IBOutlet weak var gestureView: UIView!
    @IBOutlet weak var backView: UIVisualEffectView!
    @IBOutlet weak var backButton: UIButton!
    @IBOutlet weak var controlBar: UIVisualEffectView!
    @IBOutlet weak var timeLabel: UILabel!
    @IBOutlet weak var remainingTimeLabel: UILabel!
    @IBOutlet weak var progressSlider: AnimationSlider!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        setup()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        setupPlayer()
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        player.stop()
    }
    
    override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        return playItem.isVertical ? .portrait : .landscapeLeft
    }
    
    override var preferredInterfaceOrientationForPresentation: UIInterfaceOrientation {
        return playItem.isVertical ? .portrait : .landscapeLeft
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    
    override var prefersHomeIndicatorAutoHidden: Bool {
        return true
    }
}

private extension PlayerViewController {
    
    func setup() {
        alphaControlViews(isShow: false)
        alphaSeekView(isShow: false)
        
        setupGestureView()
        setupBackButton()
        setupProgressBar()
        setupRecordPosition()
        setupAppNoti()
    }
    
    func setupPlayer() {
        AVAudioSession.up2p.setAudioSession(category: .playback, policy: .default)
        
        player.drawable = playerView
        player.media = playItem.media
        player.delegate = self
        player.play()
    }

    func setupGestureView() {
        
        let tap = UITapGestureRecognizer()
        tap.rx.event
            .subscribe(onNext: { [unowned self] (tap) in
                self.alphaControlViews(isShow: self.controlBar.alpha != 1)
            })
            .disposed(by: bag)
        gestureView.addGestureRecognizer(tap)
        
        let doubleTap = UITapGestureRecognizer()
        doubleTap.numberOfTapsRequired = 2
        doubleTap.rx.event
            .subscribe(onNext: { [unowned self] (tap) in
                if self.player.isPlaying {
                    self.player.pause()
                } else {
                    self.player.play()
                }
            })
            .disposed(by: bag)
        gestureView.addGestureRecognizer(doubleTap)
        tap.require(toFail: doubleTap)
        
        let pan = UIPanGestureRecognizer()
        pan.rx.event
            .subscribe(onNext: { [unowned self] (pan) in
                
                let translation = pan.translation(in: self.gestureView)

                switch pan.state {
                case .began:
                    self.player.pause()
                case .changed:
                    if self.isPanHorizontal == nil {
                        self.isPanHorizontal = abs(translation.x) > abs(translation.y)
                    }
                    
                    if self.isPanHorizontal! {
                        self.alphaControlViews(isShow: true)
                        self.alphaSeekView(isShow: true)
                        
                        let location = pan.location(in: self.gestureView)
                        let each = self.gestureView.up2p.height/3
                        var factor: CGFloat = 0.5
                        if location.y < each {
                            factor *= 3
                        } else if location.y < each * 2 {
                            factor *= 2
                        } else {
                            factor *= 1
                        }
                        
                        let fractionX = (translation.x/self.gestureView.up2p.width) * factor
                        let changedPosition = CGFloat(self.player.position) + fractionX
                        self.progressSlider.value = max(min(1, changedPosition), 0)
                        
                        let totalTime = TimeInterval(self.player.media.length.intValue/1000)
                        let currentTime = TimeInterval(self.progressSlider.value) * totalTime
                        self.seekTimeLabel.text = "\(currentTime.up2p.colonFormattedText())/\(totalTime.up2p.colonFormattedText())"
                    } else {
                        self.alphaControlViews(isShow: false)
                        let fractionY = translation.y/self.gestureView.up2p.height
                        let scale = CGAffineTransform(scaleX: 1 - fractionY, y: 1 - fractionY)
                        let translation = scale.translatedBy(x: translation.x, y: translation.y)
                        self.playerView.transform = translation
                    }
                case .cancelled: fallthrough
                case .ended:
                    self.alphaControlViews(isShow: false)
                    
                    if self.isPanHorizontal ?? false {
                        self.alphaSeekView(isShow: false)
                    } else {
                        UIView.up2p.animate(content: {
                            self.playerView.transform = .identity
                        })
                        let velocity = pan.velocity(in: self.gestureView)
                        if velocity.y > 0, translation.y > 30 {
                            self.dismiss(animated: true, completion: nil)
                            return
                        }
                    }
                    self.player.position = Float(self.progressSlider.value)
                    self.player.play()
                    
                    self.isPanHorizontal = nil
                default: break
                }
            })
            .disposed(by: bag)
        gestureView.addGestureRecognizer(pan)
        tap.require(toFail: pan)
        
    }
    
    func setupBackButton() {
        backButton.setImage(#imageLiteral(resourceName: "close").withRenderingMode(.alwaysTemplate), for: .normal)
        backButton.rx.tap
            .subscribe(onNext: { [unowned self] (_) in
                self.dismiss(animated: true, completion: nil)
            })
            .disposed(by: bag)
    }
    
    func setupProgressBar() {
        progressSlider.thumbImage = #imageLiteral(resourceName: "slider_square").withRenderingMode(.alwaysTemplate)
        progressSlider.maximunTrackTintColors = [#colorLiteral(red: 1, green: 1, blue: 1, alpha: 0.2), #colorLiteral(red: 1, green: 1, blue: 1, alpha: 0.2)]
        progressSlider.minimunTrackTintColors = [#colorLiteral(red: 1, green: 1, blue: 1, alpha: 0.5), #colorLiteral(red: 1, green: 1, blue: 1, alpha: 0.5)]
        progressSlider.thumbExtendRespondsRadius = 20
        progressSlider.lineWidth = 2
        
        progressSlider.rx.controlEvent(.touchDown)
            .subscribe(onNext: { [unowned self] (_) in
                self.player.pause()
            })
            .disposed(by: bag)
        
        progressSlider.rx.controlEvent([.touchUpInside, .touchUpOutside])
            .subscribe(onNext: { [unowned self] (_) in
                self.player.play()
            })
            .disposed(by: bag)
        
        progressSlider.rx.controlEvent([.valueChanged])
            .subscribe(onNext: { [unowned self] (_) in
                self.player.position = Float(self.progressSlider.value)
            })
            .disposed(by: bag)
    }
    
    func setupRecordPosition() {
        
        let didDisappear = rx.methodInvoked(#selector(viewDidDisappear(_:))).map{_ in}
        let willResign = NotificationCenter.default.rx.notification(UIApplication.willResignActiveNotification).map{_ in}
        Observable.merge([didDisappear, willResign])
            .subscribe(onNext: { [unowned self] (_) in
                self.playItem.setPosition(self.player.position)
            })
            .disposed(by: bag)
    }
    
    func setupAppNoti() {
        NotificationCenter.default.rx.notification(UIApplication.didEnterBackgroundNotification)
            .subscribe(onNext: { [unowned self] (_) in
                self.player.pause()
            })
            .disposed(by: bag)
    }
}

private extension PlayerViewController {
    
    func alphaControlViews(isShow: Bool) {
        let controlViews = [backView, controlBar]
        UIView.up2p.animate(content: {
            controlViews.forEach { $0?.alpha = isShow ? 1 : 0 }
        })
    }
    
    func alphaSeekView(isShow: Bool) {
        UIView.up2p.animate(content: {
            self.seekTimeView.alpha = isShow ? 1 : 0
        })
    }
}

extension PlayerViewController: VLCMediaPlayerDelegate {
    
    func mediaPlayerTimeChanged(_ aNotification: Notification!) {
        guard let player = aNotification.object as? VLCMediaPlayer else {
            return
        }
        progressSlider.value = CGFloat(player.position)
        timeLabel.text = player.time.stringValue
        remainingTimeLabel.text = player.remainingTime.stringValue

        if !hasSetPosition, let position = playItem.position {
            player.position = position
            hasSetPosition = true
        }
    }
    
    func mediaPlayerStateChanged(_ aNotification: Notification!) {
        guard let player = aNotification.object as? VLCMediaPlayer else {
            return
        }
        if player.state == .stopped {
            playItem.setPosition(0)
            setupPlayer()
        }
    }
}
