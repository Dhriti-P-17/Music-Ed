//
//  HomeView.swift
//  Music Ed
//
//  Created by Dhriti Peshkar on 2/8/26.
//

import SwiftUI

struct HomeView: View {
    @Binding var isLoggedIn: Bool
    
    var body: some View {
        NavigationStack {
            
            // Use the new iOS 18 TabView syntax
            TabView {
                
                Tab("Home", systemImage: "house.fill") {
                    ProfileView()
                }
                .badge(2)
                
                // FIXED: Removed the <Never, Any...> and fixed the quotes
                Tab("Chatbot", systemImage: "sparkles") {
                    ChatView(isLoggedIn: $isLoggedIn)
                }
                
                
                Tab("Sign Out", systemImage: "person.crop.circle.fill") {
                    VStack(spacing: 20) {
                        Text("Are you sure you want to sign out?")
                            .font(.headline)
                            .fontWeight(.black)
                            .padding(.bottom, 42)
                        
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
                                .foregroundColor(.white)
                                .background(.pink)
                                .cornerRadius(40)
                        }
                    }
                }
            }
            .tint(.pink)
        }
    }
}
    
    // Preview fix
    #Preview {
        HomeView(isLoggedIn: .constant(true))
    }

