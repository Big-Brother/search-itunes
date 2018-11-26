//
//  Result.swift
//  JobChallenge
//
//  Created by Big Brother on 25/11/2018.
//  Copyright © 2018 Big Brother. All rights reserved.
//

import UIKit

struct Result: Codable {
    
    let artistName: String?
    let collectionName: String?
    let trackName: String?
    let collectionViewUrl: String?
    let trackViewUrl: String?
    let previewUrl: String?
    let artworkUrl30: String?
    let artworkUrl60: String?
    let artworkUrl100: String?
    let collectionPrice: Double?
    let trackPrice: Double?
    let releaseDate: String?
    let trackTimeMillis: Int?
    let currency: String?
    let primaryGenreName: String?
}
