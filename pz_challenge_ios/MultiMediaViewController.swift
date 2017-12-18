//
//  MultiMediaViewController.swift
//  pz_challenge_ios
//
//  Created by Jonathan Nascimento on 16/12/2017.
//  Copyright © 2017 Jonathan Nascimento. All rights reserved.
//

import UIKit
import AVKit
import AVFoundation
import IJProgressView

class MultiMediaViewController: BaseViewController {

    // MARK: - Propects   
    @IBOutlet weak var contentView: UIView!
    
    var baseAsset: String = ""
    var medias: [Media] = []
    var currentMidia: Media?
    var playButton:UIButton?

    var player:AVPlayer?
    var audioPlayer:AVPlayer?
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        self.configNavigationItems()
        
        self.title = currentMidia?.name
        
        mediaDelegate = self
        player = nil
        audioPlayer = nil
        
        downloadOrStartVideo()
    
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        
        if (player != nil) {
            player?.pause()
            player = nil
        }
        
        if (audioPlayer != nil){
            audioPlayer?.pause()
        }
        
        stopDownload()
        NotificationCenter.default.removeObserver(self)
    }
}

// MARK: - Private Methods
private extension MultiMediaViewController {
    
    func configNavigationItems() {
        let previousButton = UIBarButtonItem(image: UIImage(named: "ic_skip_previous"), style: .plain, target: self, action: #selector(previousTrackAction))
        let nextButton = UIBarButtonItem(image: UIImage(named: "ic_skip_next"), style: .plain, target: self, action: #selector(nextTrackAction))
        
        navigationItem.rightBarButtonItems = [nextButton, previousButton]
    }
    
    @objc func previousTrackAction(_ sender:Any) {
        
        let position = medias.index(of: currentMidia!)
        let previousPosition = position! == 0 ? medias.count - 1 : position! - 1
        
        player?.pause()
        player = nil
        audioPlayer?.pause()
        audioPlayer = nil
        
        currentMidia = medias[previousPosition]
        viewDidLoad()
    }
    
    @objc func nextTrackAction(_ sender:Any) {
        let position = medias.index(of: currentMidia!)
        let nextPosition = position! == (medias.count - 1) ? 0 : position! + 1
        
        player?.pause()
        player = nil
        audioPlayer?.pause()
        audioPlayer = nil
        
        currentMidia = medias[nextPosition]
        viewDidLoad()
    }
}

// MARK: - Audio
extension MultiMediaViewController {
    
    public func playAudio() {
        
        let audioUrl = baseAsset + "/" + (currentMidia?.audio)!
        let url = URL(string: audioUrl)
        let playerItem:AVPlayerItem = AVPlayerItem(url: url!)
        audioPlayer = AVPlayer(playerItem: playerItem)
        audioPlayer?.play()
    }
}

// MARK: - Video Start and Download
extension MultiMediaViewController {
    
    public func getVideoFilePath(fileName: String) -> String {
        
        let path = NSSearchPathForDirectoriesInDomains(FileManager.SearchPathDirectory.documentDirectory, .userDomainMask, true)[0] as String
        
        let fileManager = FileManager()
        let fullPath = path.appendingFormat("/"+fileName)
        let destinationURLForFile = URL(fileURLWithPath: fullPath)
        
        if fileManager.fileExists(atPath: destinationURLForFile.path){
            
            return destinationURLForFile.path
        } else {
            
            return ""
        }
    }
    
    public func downloadOrStartVideo() {
        
        let mediaName = self.currentMidia?.video
        let mediaUrl = self.baseAsset + "/" + mediaName!
        
        let path: String? = getVideoFilePath(fileName: mediaName!)
        
        if (path?.isEmpty)! {
            
            IJProgressView.shared.showProgressView(view)
            startDownload(url: mediaUrl, assetName: mediaName!)
            
        } else {
            
            playAudio()
            playVideo(videoPath: path!)
        }
    }
    
    private func buildOverlayView(avPlayerViewController: AVPlayerViewController) -> UIView{
        
        let overlayView: UIView? = UIView()
        
        overlayView?.frame = CGRect(x: 0, y: 30, width: avPlayerViewController.view.bounds.width, height: 100)
        overlayView?.isHidden = true
        overlayView?.backgroundColor = UIColor ( red: 0.5, green: 0.5, blue: 0.5, alpha: 0.379 )
        
        let btnNext = UIButton(frame:CGRect(x: avPlayerViewController.view.bounds.width - 60, y: 0, width: 60, height: 44))
        btnNext.setTitle(">>", for: .focused)
        overlayView?.addSubview(btnNext)
        
        let a: Float = Float((avPlayerViewController.view.bounds.width/2) - 40)
        
        let btnReplay = UIButton(frame:CGRect(x: Int(a),y: 0, width: 80,height: 44))
        btnReplay.setTitle("Replay", for: .application)
        btnReplay.addTarget(self, action:Selector(("replayVideo")), for:.touchUpInside)
        overlayView?.addSubview(btnReplay)
        
        let btnPrevious = UIButton(frame:CGRect(x: 0, y: 0, width: 80, height: 44))
        btnPrevious.setTitle("<<", for: .focused)
        btnPrevious.addTarget(self, action:Selector(("previousVideo")), for:.touchUpOutside)
        overlayView?.addSubview(btnPrevious)
        
        return overlayView!
    }
    
    func playVideo(videoPath: String) {
        
        let avPlayerViewController = AVPlayerViewController()
        
        player = AVPlayer(url: URL(fileURLWithPath: videoPath))
        let playerLayerAV = AVPlayerLayer(player: player)
        playerLayerAV.frame = self.view.frame

        avPlayerViewController.view.frame = self.view.bounds
        avPlayerViewController.player = player
        avPlayerViewController.videoGravity = AVLayerVideoGravityResize
        self.addChildViewController(avPlayerViewController)
        avPlayerViewController.showsPlaybackControls = true
        
        avPlayerViewController.contentOverlayView?.addSubview(buildOverlayView(avPlayerViewController: avPlayerViewController))
        
        self.view.addSubview(avPlayerViewController.view)
        
        avPlayerViewController.player?.prepareForInterfaceBuilder()
        avPlayerViewController.player?.play()
        
        self.player?.addObserver(self, forKeyPath: "rate", options: .new, context: nil)

        NotificationCenter.default.addObserver(self, selector:#selector(self.playerDidFinishPlaying(note:)),name: NSNotification.Name.AVPlayerItemDidPlayToEndTime, object: player?.currentItem)
    }
    
}

// MARK: - Observers Audio and Video
extension MultiMediaViewController {
    
    override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        
        if keyPath == "rate" && (change?[NSKeyValueChangeKey.newKey] as? Float) == 0 {
            audioPlayer?.pause()
        } else if keyPath == "rate" && (change?[NSKeyValueChangeKey.newKey] as? Float) == 1 {
            audioPlayer?.play()
        }
        
    }
    
    func audioPlayerDidFinishPlaying(_ player: AVAudioPlayer, successfully flag: Bool){
        player.pause()
    }
    
    func playerDidFinishPlaying(note: NSNotification){
        player?.seek(to: kCMTimeZero)
        player?.play()
    }
}

// MARK: - Finish Download Event
extension MultiMediaViewController: MediaDownloadDelegate {
    
    func finishDownload(currentPath: String, assetName: String, isSucess: Bool) {
        
            IJProgressView.shared.hideProgressView()

            if (isSucess) {
                
                downloadOrStartVideo()
            } else {

                showAlertView(title: "Falha", message: "Não foi possível completar o download desse arquivo")
            }
    }
}

extension AVPlayer {
    
    var isPlaying: Bool {
        if (self.rate != 0 && self.error == nil) {
            return true
        } else {
            return false
        }
    }
    
}

