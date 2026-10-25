//
//  ContentView.swift
//  Music Ed
//
//  Created by Dhriti Peshkar on 2/8/26.
//

import SwiftUI

struct ContentView: View {
    @State private var isAuthenticated = false
    
    var body: some View {
        ZStack{
            if isAuthenticated {
                HomeView(isLoggedIn: $isAuthenticated) // Show Home if logged in
            } else {
                NavigationStack {
                    VStack {
                        Text("Welcome to Music Ed")
                            .font(.largeTitle)
                            .fontWeight(.black)
                            .padding(.bottom,  42)
                        
                        // Pass the binding to the LoginScreen
                        NavigationLink(destination:LoginScreen(isLoggedIn: $isAuthenticated)) {
                            Text("Log In")
                                .fontWeight(.heavy)
                                .font(.title3)
                                .frame(maxWidth: 350)
                                .padding()
                                .foregroundColor(.white)
                                .background(.pink)
                                .cornerRadius(40)
                        }
                        
                        NavigationLink(destination: SignupScreen()) {
                            Text("Sign Up")
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
        }
    }
}

#Preview {
    ContentView()
}
