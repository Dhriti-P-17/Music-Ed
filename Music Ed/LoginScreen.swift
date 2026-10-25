import SwiftUI
import SwiftData


struct LoginScreen: View {
    @Binding var isLoggedIn: Bool
    @State private var username = ""
    @State private var password = ""
    @Environment(\.modelContext) private var modelContext
    @Query private var allUsers: [UserAccount]
    @State private var errorMessage = ""
    @Query private var allAccounts: [UserAccount]
    
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
                        authenticateUser()
                    }) {
                        Text("Log In")
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
            .onAppear {
                print("DEBUG - Accounts currently in database: \(allUsers.map { "User: '\($0.username)', Pass: '\($0.password)'" })")}
        }
    }

    // This function handles the logic when the button is pressed


    func authenticateUser() {
        if username.isEmpty || password.isEmpty {
            errorMessage = "Please fill in all fields."
            return
        }
        
        // Check if an account matches the username and password
        let cleanUser = username.trimmingCharacters(in: .whitespacesAndNewlines).lowercased()
        let cleanPass = password.trimmingCharacters(in: .whitespacesAndNewlines)
        
        if let match = allAccounts.first(where: { 
            $0.username.trimmingCharacters(in: .whitespacesAndNewlines).lowercased() == cleanUser && 
            $0.password.trimmingCharacters(in: .whitespacesAndNewlines) == cleanPass
        }) {
            print("Login matched user: \(match.username)")
            withAnimation {
                isLoggedIn = true // This takes you to your Home screen!
            }
        } else {
            errorMessage = "Invalid username or password."
        }
    }
}

#Preview {
    LoginScreen(isLoggedIn: .constant(false))
        .modelContainer(for: UserAccount.self)
}
