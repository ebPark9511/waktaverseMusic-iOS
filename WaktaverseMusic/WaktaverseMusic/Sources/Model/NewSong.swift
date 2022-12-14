//
//  newSong.swift
//  Billboardoo
//
//  Created by yongbeomkwak on 2022/08/11.
//

import Foundation

// MARK: - Datum
struct NewSong: Codable, Identifiable, Equatable {

    let id = UUID()
    let song_id, title, artist: String
    let date, views: Int

    static func == (lhs: Self, rhs: Self) -> Bool {
        return lhs.song_id == rhs.song_id
    }

    private enum CodingKeys: String, CodingKey {
        case song_id = "id"
        case title, artist, date, views
        // case viewsOfficial = "views_official"

    }
}
