//
//  ResultDetailsViewController.swift
//  JobChallenge
//
//  Created by Big Brother on 25/11/2018.
//  Copyright © 2018 Big Brother. All rights reserved.
//

import UIKit
import AVKit
import Kingfisher


class ResultDetailsViewController: UIViewController {
    
    // data
    var resultIndex: Int?
    var result: Result?
    var results: [Result] = []
    
    // player
    var player: AVPlayer?
    var playerLayer: AVPlayerLayer?
    var playerIndex: Int?
    var playerItem: Result?
    
    @IBOutlet weak var artwork: UIImageView!
    @IBOutlet weak var playButton: UIToolbar!
    @IBOutlet weak var pauseButton: UIToolbar!
    @IBOutlet weak var previousButton: UIBarButtonItem!
    @IBOutlet weak var nextButton: UIBarButtonItem!
    
    @IBOutlet weak var trackName: UILabel!
    @IBOutlet weak var artistName: UILabel!
    @IBOutlet weak var albumName: UILabel!
    @IBOutlet weak var albumPrice: UILabel!
    @IBOutlet weak var releaseDate: UILabel!
    @IBOutlet weak var primaryGenre: UILabel!
    @IBOutlet weak var trackPrice: UILabel!
    @IBOutlet weak var trackDuration: UILabel!
    
    
    
    
    
    
    @IBOutlet weak var buttonTwitter: UIButton!
    @IBOutlet weak var buttonFB: UIButton!
    
    // todo:
    /**
     Shares the current playing track information to Facebook e.g. I am listening to 'Man in the mirror' By Michael Jackson.
     
     - Parameter sender: The sending object.
     */
    @IBAction func shareFB(_ sender: Any) {
    }
    
    /**
     Shares the current playing track information to Twitter e.g. I am listening to 'Man in the mirror' By Michael Jackson.
     
     - Parameter sender: The sending object.
     */
    @IBAction func shareTwitter(_ sender: Any) {
        let tweetText = "I am listening to \(playerItem?.trackName! ?? "my own voice") by \(playerItem?.artistName! ?? "The sound in my head")"
        
        let shareString = "https://twitter.com/intent/tweet?text=\(tweetText)&url=\(playerItem?.trackViewUrl ?? "Broken URL")"
        
        // encode a space to %20 for example
        let escapedShareString = shareString.addingPercentEncoding(withAllowedCharacters: CharacterSet.urlQueryAllowed)!
        
        // cast to an url
        let url = URL(string: escapedShareString)
        
        // open in safari
        UIApplication.shared.open(url!, options: [:])
    }
    
    /**
     Plays the track.
     
     - Parameter sender: The sending object.
     */
    @IBAction func playTrack(_ sender: UIBarButtonItem) {
        player!.play()
    }
    
    /**
     Pauses the track.
     
     - Parameter sender: The sending object.
     */
    @IBAction func pauseTrack(_ sender: UIBarButtonItem) {
        player!.pause()
    }
    
    /**
     Gets the next previous if there is one.
     
     - Parameter sender: The sending object.
     */
    @IBAction func previousTrack(_ sender: UIBarButtonItem) {
        if playerIndex! > 0 {
            playerIndex! -= 1
            setTrack(trackInfo: results[playerIndex!])
            player!.play()
        }
    }
    /**
     Gets the next track if there is one.
     
     - Parameter sender: The sending object.
     */
    @IBAction func nextTrack(_ sender: Any) {
        // wrapper for nextTrack func
        nextTrack()
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        playerItem = results[resultIndex!]
        playerIndex = resultIndex!
        playerLayer = AVPlayerLayer(player: player)
        playerLayer!.frame = self.view.bounds
        self.view.layer.addSublayer(playerLayer!)
        
        setTrack(trackInfo: playerItem!)
    }
    
    /**
     Sets the track information in the view controller.
     
     - Parameter trackInfo: The object containing the track information.
     */
    func setTrack(trackInfo: Result) {
        
        let previewURL = URL(string: trackInfo.previewUrl!)
        let playerItem = AVPlayerItem(url: previewURL!)
        NotificationCenter.default.addObserver(self, selector: #selector(self.playerDidFinishPlaying(sender:)), name: NSNotification.Name.AVPlayerItemDidPlayToEndTime, object: playerItem)
        
        player = AVPlayer(playerItem: playerItem)
        
        if let artURL = trackInfo.artworkUrl100 {
            let photoUrl = URL(string: artURL)
            self.artwork.kf.setImage(with: photoUrl, placeholder: UIImage(named: "placeholderImg"))
        }
        
        if let title = trackInfo.trackName {
            self.trackName.text = title
        }
        if let artist = trackInfo.artistName {
            self.artistName.text = artist
        }
        if let album = trackInfo.collectionName {
            self.albumName.text = album
        }
        if let albumPrice = trackInfo.collectionPrice {
            self.albumPrice.text = "Album Price: $\(albumPrice)"
        }
        if let release = trackInfo.releaseDate {
            // todo: create as helper
            let dateFormatter = DateFormatter()
            let tempLocale = dateFormatter.locale // save locale temporarily
            dateFormatter.locale = Locale(identifier: "en_EN_POSIX") // set locale to reliable US_POSIX
            dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ssZ"
            
            // release date string
            let date = dateFormatter.date(from: release)!
            dateFormatter.dateFormat = "MMM d, yyyy" ; //"dd-MM-yyyy HH:mm:ss"
            dateFormatter.locale = tempLocale // reset the locale --> but no need here
            self.releaseDate.text = "Released: \(dateFormatter.string(from: date))"
        }
        if let genre = trackInfo.primaryGenreName {
            self.primaryGenre.text = "Genre: \(genre)"
        }
        if let trackPrice = trackInfo.trackPrice {
            // todo: create currency enum
            self.trackPrice.text = "Price: $\(trackPrice)"
        }
        if let duration = trackInfo.trackTimeMillis {
            let time = NSDate(timeIntervalSince1970: Double(duration) / 1000)
            let timeFormatter = DateFormatter()
            timeFormatter.timeZone = NSTimeZone(name: "UTC")! as TimeZone
            timeFormatter.dateFormat = "HH:mm:ss"
            
            self.trackDuration.text = "Duration: \(timeFormatter.string(from: time as Date))"
        }
        
        
        NotificationCenter.default.addObserver(self, selector: #selector(self.playerDidFinishPlaying(sender:)), name: NSNotification.Name.AVPlayerItemDidPlayToEndTime, object: player)
        
    }
    /**
     Gets the next track.
     */
    func nextTrack() {
        if playerIndex! < results.count-1 {
            playerIndex! += 1
            setTrack(trackInfo: results[playerIndex!])
            
            player!.play()
        }
    }
    
    /**
     Triggers when the track has finished playing and fetches the next track if there is one.
     
     - Parameter sender: Notification from the observer.
     */
    @objc func playerDidFinishPlaying(sender: Notification) {
        //print("fin")
        nextTrack()
    }
    /*
     // MARK: - Navigation
     
     // In a storyboard-based application, you will often want to do a little preparation before navigation
     override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
     // Get the new view controller using segue.destination.
     // Pass the selected object to the new view controller.
     }
     */
    
}
