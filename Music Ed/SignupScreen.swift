import SwiftUI
import SwiftData

struct SignupScreen: View {
    @State private var username = ""
    @State private var password = ""
    @Environment(\.modelContext) private var modelContext
    @Query private var allUsers: [UserAccount]
    @State private var errorMessage = ""
    
    var body: some View {
        GeometryReader { proxy in
            VStack(spacing: 0) {
                // Header Section
                ZStack {
                    Rectangle()
                        .foregroundColor(.pink)
                    VStack(spacing: 8) {
                        Text("Music Ed")
                            .font(.system(size: 50, weight: .bold))
                            .foregroundColor(.white)
                        Text("Learn Music Easily")
                            .foregroundColor(.white)
                            .font(.system(size: 22))
                    }
                    .padding(.top, 40)
                }
                .frame(height: max(proxy.size.height * 0.3, 180))
                .ignoresSafeArea(edges: .top)

                // Login Fields & Buttons
                VStack(spacing: 20) {
                    TextField("Username", text: $username)
                        .padding()
                        .background(Color(.systemGray6))
                        .cornerRadius(10)
                        .textInputAutocapitalization(.never)
                    
                    SecureField("Password", text: $password)
                        .padding()
                        .background(Color(.systemGray6))
                        .cornerRadius(10)
                    if !errorMessage.isEmpty {
                        Text(errorMessage)
                            .foregroundColor(.red)
                            .font(.caption)
                            .padding(.bottom, 5)
                    }
                    Button(action: {
                        registerUser()
                    }) {
                        Text("Sign Up")
                            .font(.headline)
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .frame(height: 50)
                            .background(Color.pink)
                            .cornerRadius(10)
                    }
                    .padding(.top, 10)
                    .font(.footnote)
                    .foregroundColor(.gray)
                }
                .padding(.horizontal, 30)
                .padding(.top, 40)

                Spacer()
            }
        }
    }

    // This function handles the logic when the button is pressed
    func registerUser() {
        if username.isEmpty || password.isEmpty {
            errorMessage = "Please fill in all fields."
            return
        }

        // 1. Create the object
        let newUser = UserAccount(username: username, password: password)
        
        // 2. Insert it
        modelContext.insert(newUser)
        
        // 3. FORCE the save to the SQL file
        do {
            try modelContext.save()
            print("Successfully saved \(username) to the database.")
            
            // Clear fields so you know it worked
            username = ""
            password = ""
            errorMessage = "Account created! You can now log in."
        } catch {
            print("Failed to save: \(error.localizedDescription)")
            errorMessage = "Database error. Try again."
        }
    }
}

#Preview {
    SignupScreen()
}
