//
//  SongModel.swift
//  Music Ed
//
//  Created by Dhriti Peshkar on 10/23/26.
//
import Foundation

struct TargetNote {
    let note: String
    let duration: Double
}

struct SongTemplate {
    let title: String
    let notes: [TargetNote]
}

let sampleSong = SongTemplate(
    title: "Basic Scale Practice",
    notes: [
        TargetNote(note: "C", duration: 1.0),
        TargetNote(note: "D", duration: 1.0),
        TargetNote(note: "E", duration: 1.0)
    ]
)
