//
//  NoteFinder.swift
//  Music Ed
//
//  Created by Dhriti Peshkar on 8/22/26.
//
import Foundation
import Foundation

struct NoteFinder {
    func noteIdentifier(hertz: Double) -> String {
        let A4 = 440.0
        let formula = 12 * log2(hertz / A4)
        let semitones = round(formula)
        let midiNote = Int(semitones) + 69
        return String(midiNote % 12)
    }
}
