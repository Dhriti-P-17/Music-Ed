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
    }
}

func analyzeUploadedAudio(audioURL: URL, targetNotes: [TargetNote], completion: @escaping (String) -> Void) {
    do {
        let analyzer = try SNAudioFileAnalyzer(url: audioURL)
         
        let config = MLModelConfiguration()
        let customLabeler = try ViolinTechniqueClassifier(configuration: config)
        let model = customLabeler.model
        let request = try SNClassifySoundRequest(mlModel: model)
         
        let observer = PitchObserver()
        var detectedTechniques: [String: Int] = [:]
        let noteFinder = NoteFinder()
         
        observer.onTechniqueDetected = { technique, confidence, time in
            detectedTechniques[technique, default: 0] += 1
        }
         
        try analyzer.add(request, withObserver: observer)
         
        // --- REAL AUDIO BUFFER PITCH DETECTION (Zero-Crossing Rate Algorithm) ---
        let audioFile = try AVAudioFile(forReading: audioURL)
        let format = audioFile.processingFormat
        let sampleRate = format.sampleRate
        let frameCount = AVAudioFrameCount(audioFile.length)
        
        var rawDetectedNotes: [String] = []
        
        if let buffer = AVAudioPCMBuffer(pcmFormat: format, frameCapacity: frameCount) {
            try audioFile.read(into: buffer)
            if let channelData = buffer.floatChannelData {
                let channelPointer = channelData[0]
                let totalFrames = Int(buffer.frameLength)
                let windowSize = 2048 // Standard analysis window size
                
                if totalFrames > windowSize {
                    // Step through frames with a balanced stride to prevent over-sampling
                    for startFrame in stride(from: 0, to: totalFrames - windowSize, by: windowSize * 4) {
                        var zeroCrossings = 0
                        for i in 0..<(windowSize - 1) {
                            let current = channelPointer[startFrame + i]
                            let next = channelPointer[startFrame + i + 1]
                            // Count sign changes (zero crossings)
                            if (current < 0 && next >= 0) || (current >= 0 && next < 0) {
                                zeroCrossings += 1
                            }
                        }
                        
                        // Calculate frequency in Hz using Zero-Crossing Rate formula
                        let frequency = (sampleRate * Double(zeroCrossings)) / (2.0 * Double(windowSize))
                        
                        // Constrain frequency to valid musical instrument range
                        if frequency >= 80.0 && frequency <= 2000.0 {
                            let noteName = noteFinder.noteIdentifier(hertz: frequency)
                            rawDetectedNotes.append(noteName)
                        }
                    }
                }
            }
        }
         
        // Debounce: Collapse immediate adjacent duplicates into sustained notes
        var detectedNotes: [String] = []
        for note in rawDetectedNotes {
            if detectedNotes.last != note {
                detectedNotes.append(note)
            }
        }
         
        analyzer.analyze()
         
        // Build dynamic song template and calculate true performance score
        let dynamicSong = SongTemplate(title: "Uploaded Score", notes: targetNotes)
        let score = evaluatePerformance(userNotes: detectedNotes, targetSong: dynamicSong)
         
        let noteString = detectedNotes.isEmpty ? "No notes detected" : detectedNotes.joined(separator: ", ")
        
        if let mostUsedTechnique = detectedTechniques.max(by: { $0.value < $1.value })?.key {
            let techniqueFeedback = provideMusicalFeedback(for: mostUsedTechnique, notes: detectedNotes)
            completion("\(techniqueFeedback)\n\n📊 **Performance Score:** You matched \(score)% of the target sheet music!")
        } else {
            completion("Detected Notes: [\(noteString)]\n\n📊 **Performance Score:** You matched \(score)% of the target sheet music!")
        }
         
    } catch {
        print("Analysis Error: \(error.localizedDescription)")
        completion("Error processing audio or sheet music file.")
    }
}
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
        return "Detected Notes: [\(noteString)] with Pizzicato. Make sure the notes are clear and not too muddy."
    default:
        return "Detected Notes: [\(noteString)]"
    }
}

func provideTechniqueFeedback(for technique: String) -> String {
    switch technique.lowercased() {
    case "spiccato":
        return "Detected technique: **Spiccato**. Excellent bouncy bow control!"
    case "vibrato":
        return "Detected technique: **Vibrato**. Great pitch warmth and wrist flexibility!"
    case "staccato":
        return "Detected technique: **Staccato**. Crisp, clean short strokes observed."
    case "detache":
        return "Detected technique: **Detaché**. Smooth, well-connected bow changes."
    case "glissando":
        return "Detected technique: **Glissando**. Fluid shifting between pitches."
    case "legato":
        return "Detected technique: **Legato**. Beautifully connected phrasing and relaxed bow arm."
    case "pizzicato":
        return "Detected technique: **Pizzicato**. Clean, resonant plucked notes."
    default:
        return "Detected technique: **\(technique)**."
    }
}
