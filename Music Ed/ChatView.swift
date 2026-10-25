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
                TextField("Ask about music theory...", text: $newMessage)
                    .padding(12)
                    .background(Color(.systemGray6))
                    .cornerRadius(20)
                
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
        .fileImporter(
            isPresented: $isImporting,
            allowedContentTypes: [.audio, .image, .pdf], // Specific types are better
            allowsMultipleSelection: true
        ) { result in
            switch result {
            case .success(let urls):
                for url in urls {
                    if url.startAccessingSecurityScopedResource() {
                        defer { url.stopAccessingSecurityScopedResource() }
                        
                        // Now you can safely pass this URL to your analysis functions
                        selectedFiles.append(url)
                    }
                }
            case .failure(let error):
                print("Error: \(error.localizedDescription)")
            }
        }
    }
    
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
        
        // Cache current files before wiping state arrays
        let filesToProcess = selectedFiles
        
        // Clear inputs immediately for smooth UI response
        newMessage = ""
        selectedFiles = []
        
        // Process audio files asynchronously
        for url in filesToProcess {
            let type = UTType(filenameExtension: url.pathExtension)
            
            if type?.conforms(to: .audio) == true {
                let loadingMsg = ChatMessage(text: "analyzing your audio...", isUser: false)
                messages.append(loadingMsg)
                
                DispatchQueue.global(qos: .userInitiated).async {
                    analyzeUploadedAudio(url: url) { dynamicFeedback in
                        DispatchQueue.main.async {
                            let aiMsg = ChatMessage(text: dynamicFeedback, isUser: false)
                            messages.append(aiMsg)
                        }
                    }
                }
            } else if type?.conforms(to: .image) == true || type?.conforms(to: .pdf) == true {
                if let data = try? Data(contentsOf: url), let img = UIImage(data: data) {
                    SheetMusicScanner().scanImage(image: img)
                }
            }
        }
    }
    
    func uploadVideo() {
        isImporting = true
    }
}
func evaluatePerformance(userNotes: [String], targetSong: SongTemplate) -> String {
    var matches = 0
    for (index, note) in userNotes.enumerated() {
        if index < targetSong.notes.count && note == targetSong.notes[index].pitchName {
            matches += 1
        }
    }
    
    let scorePercentage = (Double(matches) / Double(targetSong.notes.count)) * 100
    return "You matched \(Int(scorePercentage))% of the target sheet music!"
}

#Preview {
    NavigationStack {
        ChatView(isLoggedIn: .constant(true))
    }
}
