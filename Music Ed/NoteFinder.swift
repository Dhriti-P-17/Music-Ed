//
//  NoteFinder.swift
//  Music Ed
//
//  Created by Dhriti Peshkar on 8/22/26.
//
import Foundation

struct NoteFinder {
    func noteIdentifier(hertz: Double) -> String {
        guard hertz > 0 else { return "C" }
        let A4 = 440.0
        let formula = 12 * log2(hertz / A4)
        let semitones = round(formula)
        let midiNote = Int(semitones) + 69
        
        let noteNames = ["C", "C#", "D", "D#", "E", "F", "F#", "G", "G#", "A", "A#", "B"]
        let noteIndex = (midiNote % 12 + 12) % 12
        return noteNames[noteIndex]
    }
}
