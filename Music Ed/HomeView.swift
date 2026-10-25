//
//  HomeView.swift
//  Music Ed
//
//  Created by Dhriti Peshkar on 2/8/26.
//

import SwiftUI
import SwiftData

struct HomeView: View {
    @Binding var isLoggedIn: Bool
    
    var body: some View {
        NavigationStack {
            
            TabView {
                Tab("Profile", systemImage: "person.crop.circle.fill") {
                    ProfileView()
                }
                
                Tab("Chatbot", systemImage: "sparkles") {
                    ChatView(isLoggedIn: $isLoggedIn)
                }
                
                
                Tab("Sign Out", systemImage: "laptopcomputer") {
                    ZStack{
                        Color.pink
                            .ignoresSafeArea()
                        VStack(spacing: 15) {
                            Text("Are you sure you want to sign out???")
                                .font(.headline)
                                .fontWeight(.black)
                                .padding(.bottom, 42)
                                .foregroundColor(.white)
                            
                            Button(action: {
                                withAnimation {
                                    isLoggedIn = false
                                }
                            }) {
                                Text("Yes, Sign Out")
                                    .fontWeight(.heavy)
                                    .font(.title3)
                                    .frame(maxWidth: 350)
                                    .padding()
                                    .foregroundColor(.pink)
                                    .background(.white)
                                    .cornerRadius(40)
                            }
                        }
                    }
                }
            }
        }
    }
}
        

    #Preview {
        LoginScreen(isLoggedIn: .constant(false))
            .modelContainer(for: UserAccount.self)
    }
