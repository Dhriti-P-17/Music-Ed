//
//  SongModel.swift
//  Music Ed
//
//  Created by Dhriti Peshkar on 10/23/26.
//

import Foundation

struct TargetNote {
    let pitchName: String
    let expectedTime: Double
}

struct SongTemplate {
    let title: String
    let notes: [TargetNote]
}

let sampleSong = SongTemplate(
    title: "Basic Scale Practice",
    notes: [
        TargetNote(pitchName: "C", expectedTime: 1.0),
        TargetNote(pitchName: "D", expectedTime: 2.0),
        TargetNote(pitchName: "E", expectedTime: 3.0)
    ]
)

