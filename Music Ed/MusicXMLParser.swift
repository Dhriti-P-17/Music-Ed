import Foundation

class MusicXMLParser: NSObject, XMLParserDelegate {
    private var targetNotes: [TargetNote] = []
    private var currentElement = ""
    private var currentStep = ""
    private var currentDuration: Double = 1.0
    private var isInNote = false
    private var isInPitch = false
    private var isRest = false

    func parse(data: Data) -> [TargetNote] {
        targetNotes.removeAll()
        let parser = XMLParser(data: data)
        parser.delegate = self
        parser.parse()
        print("Parsed target notes count: \(targetNotes.count)") // Debug log
        return targetNotes
    }

    // MARK: - XMLParserDelegate

    func parser(_ parser: XMLParser, didStartElement elementName: String, namespaceURI: String?, qualifiedName qName: String?, attributes attributeDict: [String : String] = [:]) {
        currentElement = elementName.lowercased()
        
        if currentElement == "note" {
            isInNote = true
            currentStep = ""
            currentDuration = 1.0
            isRest = false
        } else if currentElement == "pitch" {
            isInPitch = true
        } else if currentElement == "rest" {
            isRest = true
        }
    }

    func parser(_ parser: XMLParser, foundCharacters string: String) {
        let trimmed = string.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else { return }

        if isInNote {
            if isInPitch && currentElement == "step" {
                currentStep = trimmed.uppercased()
            } else if currentElement == "duration" {
                if let dur = Double(trimmed) {
                    currentDuration = dur
                }
            }
        }
    }

    func parser(_ parser: XMLParser, didEndElement elementName: String, namespaceURI: String?, qualifiedName qName: String?) {
        let element = elementName.lowercased()
        
        if element == "pitch" {
            isInPitch = false
        } else if element == "note" {
            if !isRest && !currentStep.isEmpty {
                targetNotes.append(TargetNote(note: currentStep, duration: currentDuration))
            }
            isInNote = false
        }
        currentElement = ""
    }
}
