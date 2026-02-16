import SwiftUI
import UniformTypeIdentifiers

struct ChatView: View {
    @Binding var isLoggedIn: Bool
    
    @State private var messages: [ChatMessage] = [
        ChatMessage(text: "Hi! I'm your Music Ed Tutor. What are we practicing today?", isUser: false)
    ]
    @State private var newMessage = ""
    
    // --- NEW STATE FOR FILES ---
    @State private var isImporting = false
    @State private var selectedFiles: [URL] = []
    
    var body: some View {
        VStack(spacing: 0) {
            // Chat History
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
            allowedContentTypes: [.item], // Allows all file types, or use [.pdf, .audio, .movie]
            allowsMultipleSelection: true
        ) { result in
            switch result {
            case .success(let urls):
                selectedFiles.append(contentsOf: urls)
            case .failure(let error):
                print("Error picking files: \(error.localizedDescription)")
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
                    .background(Color.pink.opacity(0.1))
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
        
        // Guard against empty send (must have text or files)
        guard !trimmed.isEmpty || !selectedFiles.isEmpty else { return }
        
        // 1. Map URLs to simple Strings for the Bubble
        let fileNames = selectedFiles.map { $0.lastPathComponent }
        
        // 2. Create the message
        let userMsg = ChatMessage(
            text: trimmed,
            isUser: true,
            attachmentNames: fileNames.isEmpty ? nil : fileNames
        )
        
        messages.append(userMsg)
        
        // 3. Clear inputs
        newMessage = ""
        selectedFiles = []
        
        // Mock AI Response
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
            let aiMsg = ChatMessage(text: "I see your files! Let me analyze them.", isUser: false, attachmentNames: nil)
            messages.append(aiMsg)
        }
    }
    
    func uploadVideo() {
        isImporting = true
    }
}

#Preview {
    NavigationStack {
        ChatView(isLoggedIn: .constant(true))
    }
}
