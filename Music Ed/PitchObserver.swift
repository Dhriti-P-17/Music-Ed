//
//  PitchObserver.swift
//  Music Ed
//
//  Created by Dhriti Peshkar on 2/16/26.
//

import Foundation
import SoundAnalysis
import CoreML
import UIKit

    class PitchObserver: NSObject, SNResultsObserving {
        var onTechniqueDetected: ((String, Double, Double) -> Void)?
        
        func request(_ request: SNRequest, didProduce result: SNResult) {
            guard let classificationResult = result as? SNClassificationResult,
                  let topClassification = classificationResult.classifications.first else { return }
            
            let time = classificationResult.timeRange.start.seconds
            let techniqueName = topClassification.identifier
            let confidence = topClassification.confidence
            
            print("At \(time)s, technique detected: \(techniqueName) (\(confidence * 100)%)")
            
            if confidence > 0.75 {
                DispatchQueue.main.async {
                    self.onTechniqueDetected?(techniqueName, confidence, time)
                }
            }
            else {
                print("Confidence was too low to display")
            }
        }
    }


func analyzeUploadedAudio(url: URL, completion: @escaping (String) -> Void) {
    do {
        let analyzer = try SNAudioFileAnalyzer(url: url)
        
        let config = MLModelConfiguration()
        let customLabeler = try ViolinTechniqueClassifier(configuration: config)
        let model = customLabeler.model
        
        let request = try SNClassifySoundRequest(mlModel: model)
        
        let observer = PitchObserver()
        var detectedTechniques: [String: Int] = [:]
        var detectedNotes: [String] = []
        
        observer.onTechniqueDetected = { technique, confidence, time in
            detectedTechniques[technique, default: 0] += 1
            // If you track notes from your pitch/frequency logic, append them to detectedNotes here
        }
        
        try analyzer.add(request, withObserver: observer)
        analyzer.analyze()
        
        // Grade the performance against our sample song template
        let scoreFeedback = evaluatePerformance(userNotes: detectedNotes, targetSong: sampleSong)
        
        if let mostUsedTechnique = detectedTechniques.max(by: { $0.value < $1.value })?.key {
            let techniqueFeedback = provideMusicalFeedback(for: mostUsedTechnique, notes: detectedNotes)
            completion("\(techniqueFeedback)\n\n📊 **Performance Score:** \(scoreFeedback)")
        } else {
            completion("I couldn't quite catch the technique, but here is your score: \(scoreFeedback)")
        }
        
    } catch {
        print("CoreML Analysis Error: \(error.localizedDescription)")
        completion("Sorry, I was not able to run your audio through my technique classifier.")
    }
}

// Generates intelligent strings based on the detected label
func provideMusicalFeedback(for technique: String, notes: [String]) -> String {
    let noteString = notes.joined(separator: ", ")
    switch technique.lowercased() {
    case "spiccato":
        return "Spiccato"
    case "vibrato":
        return "Detected Notes: [\(noteString)] with Vibrato. Great pitch warmth! Keep your wrist relaxed."
    case "staccato":
        return "Detected Notes: [\(noteString)] with Staccato. Maintain the short bow strokes."
    case "detache":
        return "Detected Notes: [\(noteString)] with Detache. Make sure bow changes are smooth."
    case "glissando":
        return "Detected Notes: [\(noteString)] with Glissando. Keep the notes transitioning smoothly."
    case "legato":
        return "Detected Notes: [\(noteString)] with Legato. Great pitch warmth! Keep your right arm and wrist more relaxed."
    case "pizzicato":
        return "Detected Notes: [\(noteString)] with Pizzicato. Make sure the notes are clear and not too muddy"
    default:
        return "Detected Notes: [\(noteString)]"
    }
}
