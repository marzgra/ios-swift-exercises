//
//  ContentView.swift
//  Task1
//
//  Created by Grażyna Marzec on 16/05/2023.
//

import SwiftUI

struct Task1: View {
    var body: some View {
        VStack {
            VStack {
                Text("Instant Developer")
                    .fontWeight(.medium)
                    .font(.system(size: 40))
                    .foregroundColor(.white)
                
                
                Text("Get help from experts in 15 minutes")
                    .foregroundColor(.white)
                
                HStack(alignment: .bottom, spacing: 10){
                    Image("student")
                        .resizable()
                        .scaledToFit()
                    
                    Image("tutor")
                        .resizable()
                        .scaledToFit()
                }
                .padding(.horizontal, 60)
                
                Text("Need help with coding problems? Register!")
                    .foregroundColor(.white)
                
            }
            .padding(.top, 30)
            
            Spacer()
            
            Button{} label: {
                Text("Sign Up")
            }
            .frame(width: 200)
            .padding()
            .background(Color.indigo)
            .foregroundColor(Color.white)
            .cornerRadius(10)
            
            
            Button{} label: {
                Text("Log in")
            }
            .frame(width: 200)
            .padding()
            .background(Color.gray)
            .foregroundColor(Color.white)
            .cornerRadius(10)
            
        }
        
        .background {
            Image("background")
                .resizable()
                .ignoresSafeArea() // ignore top and bottom line
        }
    }
}

struct Task1_Previews: PreviewProvider {
    static var previews: some View {
        Task1()
    }
}
