import SwiftUI
import UniformTypeIdentifiers
import SoundAnalysis
import Vision
import Foundation
    

struct ChatView: View {
    @Binding var isLoggedIn: Bool
    
    @State private var messages: [ChatMessage] = [
        ChatMessage(text: "Hi! I'm your Music Ed Tutor. What are we practicing today?", isUser: false)
    ]
    @State private var newMessage = ""
    @State private var isImporting = false
    @State private var selectedFiles: [URL] = []
    
    var body: some View {
        VStack(spacing: 0) {
            
            ScrollViewReader { proxy in
                ScrollView {
                    LazyVStack(spacing: 12) {
                        ForEach(messages) { message in
                            ChatBubble(message: message)
                                .id(message.id)
                        }
                    }
                    .padding()
                }
                .onChange(of: messages.count) { oldValue, newValue in
                    withAnimation {
                        proxy.scrollTo(messages.last?.id, anchor: .bottom)
                    }
                }
            }
            
            // --- NEW: ATTACHMENT PREVIEW BAR ---
            if !selectedFiles.isEmpty {
                filePreviewBar
            }
            
            Divider()
            
            // Input Area
            HStack(spacing: 15) {
                
                
                Button(action: sendMessage) {
                    Image(systemName: "paperplane.fill")
                    // Enable if there is text OR files
                        .foregroundColor(newMessage.isEmpty && selectedFiles.isEmpty ? .gray : .pink)
                        .font(.system(size: 22))
                }
                .disabled(newMessage.isEmpty && selectedFiles.isEmpty)
                
                Button(action: uploadVideo) {
                    Image(systemName: "folder.fill.badge.plus")
                        .foregroundColor(.pink)
                        .font(.system(size: 22))
                }
            }
            .padding()
            .background(Color(.systemBackground))
        }
        .navigationTitle("AI Tutor")
        // --- FILE PICKER MODIFIER ---
        // --- FILE PICKER MODIFIER ---
                .fileImporter(
                    isPresented: $isImporting,
                    allowedContentTypes: [.audio, .image, .pdf, UTType(filenameExtension: "musicxml") ?? .data, UTType(filenameExtension: "xml") ?? .data],
                    allowsMultipleSelection: true
                ) { result in
                    switch result {
                    case .success(let urls):
                        for url in urls {
                            if url.startAccessingSecurityScopedResource() {
                                defer { url.stopAccessingSecurityScopedResource() }
                                selectedFiles.append(url)
                            }
                        }
                    case .failure(let error):
                        print("Error: \(error.localizedDescription)")
                    }
                }
            } // <-- Closes var body

            // --- PREVIEW UI FOR SELECTED FILES ---
            private var filePreviewBar: some View {
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack {
                        ForEach(selectedFiles, id: \.self) { url in
                            HStack {
                                Text(url.lastPathComponent)
                                    .font(.caption)
                                Button(action: { selectedFiles.removeAll { $0 == url } }) {
                                    Image(systemName: "xmark.circle.fill")
                                        .foregroundColor(.gray)
                                }
                            }
                            .padding(8)
                            .background(Color.pink.opacity(0.5))
                            .cornerRadius(8)
                        }
                    }
                    .padding(.horizontal)
                    .padding(.vertical, 8)
                }
                .background(Color(.systemGray6).opacity(0.5))
            }

            func sendMessage() {
                let trimmed = newMessage.trimmingCharacters(in: .whitespacesAndNewlines)
                guard !trimmed.isEmpty || !selectedFiles.isEmpty else { return }

                let fileNames = selectedFiles.map { $0.lastPathComponent }
                let userMsg = ChatMessage(
                    text: trimmed,
                    isUser: true,
                    attachmentNames: fileNames.isEmpty ? nil : fileNames
                )
                messages.append(userMsg)
                
                let filesToProcess = selectedFiles
                newMessage = ""
                selectedFiles = []
                
                let audioFiles = filesToProcess.filter { url in
                    let type = UTType(filenameExtension: url.pathExtension)
                    return type?.conforms(to: .audio) == true
                }
                
                let scoreFiles = filesToProcess.filter { url in
                    let ext = url.pathExtension.lowercased()
                    return ext == "xml" || ext == "musicxml" || ext == "pdf"
                }
                
                for audioURL in audioFiles {
                    let loadingMsg = ChatMessage(text: "analyzing your audio...", isUser: false)
                    messages.append(loadingMsg)
                    
                    DispatchQueue.global(qos: .userInitiated).async {
                        var targetNotes: [TargetNote] = []
                        
                                    let scoreURL = scoreFiles.first(where: {
                                        $0.pathExtension.lowercased() == "musicxml" || $0.pathExtension.lowercased() == "xml"
                                    }) ?? scoreFiles.first
                                    
                                    if let scoreURL = scoreURL {
                                        let ext = scoreURL.pathExtension.lowercased()
                                        
                                        if scoreURL.startAccessingSecurityScopedResource() {
                                            defer { scoreURL.stopAccessingSecurityScopedResource() }
                                            
                                            if ext == "xml" || ext == "musicxml" {
                                                if let xmlData = try? Data(contentsOf: scoreURL) {
                                                    let parser = MusicXMLParser()
                                                    targetNotes = parser.parse(data: xmlData)
                                                }
                                            }
                                        }
                                    }
                                     
                                    analyzeUploadedAudio(audioURL: audioURL, targetNotes: targetNotes) { dynamicFeedback in
                                        DispatchQueue.main.async {
                                            let aiMsg = ChatMessage(text: dynamicFeedback, isUser: false)
                                            messages.append(aiMsg)
                                        }
                                    }
                                }
                            }
                        }

                        func uploadVideo() {
                            isImporting = true
                        }
        }


func evaluatePerformance(userNotes: [String], targetSong: SongTemplate) -> Int {
    let targetNotes = targetSong.notes.map { $0.note.uppercased() }
    guard !targetNotes.isEmpty, !userNotes.isEmpty else { return 0 }
    
    let cleanedUserNotes = userNotes.map { $0.uppercased() }
    
    var matches = 0
    var targetIndex = 0
    let tolerance = 2 // Allows a small lookahead window for audio detection variance
    
    for userNote in cleanedUserNotes {
        var foundMatch = false
        let scanLimit = min(targetIndex + tolerance, targetNotes.count)
        
        // Look ahead within the tolerance window for the correct next note in sequence
        for i in targetIndex..<scanLimit {
            if targetNotes[i] == userNote {
                matches += 1
                targetIndex = i + 1 // Advance past the matched note
                foundMatch = true
                break
            }
        }
        
        if targetIndex >= targetNotes.count {
            break
        }
    }
    
    // Calculate authentic percentage based on correct chronological sequence
    let score = (Double(matches) / Double(targetNotes.count)) * 100.0
    return min(max(Int(score), 0), 100)
}
#Preview {
            NavigationStack {
                ChatView(isLoggedIn: .constant(true))
            }
        }
