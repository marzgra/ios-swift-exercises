//
//  ContentView.swift
//  Task2
//
//  Created by Grażyna Marzec on 20/05/2023.
//

import SwiftUI

struct RestaurantListView: View {
    
    var restaurantNames = ["Cafe Deadend", "Homei", "Teakha", "Cafe Loisl", "Petite Oyster", "For Kee Restaurant", "Po's Atelier", "Bourke Street Bakery", "Haigh's Chocolate", "Palomino Espresso", "Upstate", "Traif", "Graham Avenue Meats And Deli", "Waffle & Wolf", "Five Leaves", "Cafe Lore", "Confessional", "Barrafina", "Donostia", "Royal Oak", "CASK Pub and Kitchen"]
    
    var restaurantLocations = ["Hong Kong", "Hong Kong", "Hong Kong", "Hong Kong", "Hong Kong", "Hong Kong", "Hong Kong", "Sydney", "Sydney", "Sydney", "New York", "New York", "New York", "New York", "New York", "New York", "New York", "London", "London", "London", "London"]
    
    var restaurantTypes = ["Coffee & Tea Shop", "Cafe", "Tea House", "Austrian / Causual Drink", "French", "Bakery", "Bakery", "Chocolate", "Cafe", "American / Seafood", "American", "American", "Breakfast & Brunch", "Coffee & Tea", "Coffee & Tea", "Latin American", "Spanish", "Spanish", "Spanish", "British", "Thai"]
    
    @State var favs = Array(repeating: false, count: 21)
    
    var body: some View {
        List {
            ForEach(restaurantNames.indices, id: \.self) { index in
                FullImageRow(
                    imageName: restaurantNames[index],
                    name: restaurantNames[index],
                    type: restaurantTypes[index],
                    location: restaurantLocations[index],
                    isFav: $favs[index])
            }.listRowSeparator(.hidden)
        }.listStyle(.plain)
    }
}

struct RestaurantListView_Previews: PreviewProvider {
    static var previews: some View {
        RestaurantListView()
        
        FullImageRow(imageName: "Cafe Deadend", name: "Cafe Deadend", type: "Cafe", location: "Hong Kong", isFav: .constant(true))
            .previewLayout(.sizeThatFits)
    }
}

struct BasicTextImageRow: View {
    var imageName: String
    var name: String
    var type: String
    var location: String
    
    @State private var showOptions = false
    @State private var showError = false
    @Binding var isFav: Bool
    
    var body: some View {
        HStack(alignment: .top, spacing: 20) {
            Image(imageName)
                .resizable()
                .frame(width: 120, height: 118)
                .cornerRadius(20)
            
            VStack(alignment: .leading) {
                Text(name)
                    .font(.system(.title2, design: .rounded))
                Text(type)
                    .font(.system(.body, design: .rounded))
                Text(location)
                    .font(.system(.subheadline, design: .rounded))
                    .foregroundColor(.gray)
            }
            
            if isFav {
                Spacer()
                
                Image(systemName: "heart.fill")
                    .foregroundColor(.yellow)
            }
        }
        .onTapGesture {
            showOptions.toggle()
        }
        .confirmationDialog(
            "What do you want to do?",
            isPresented: $showOptions,
            titleVisibility: .visible
        ) {
            Button("Reserve a table") {
                self.showError.toggle()
            }
            Button(isFav ? "Remove from favorites" : "Mark as favorite") {
                self.isFav.toggle()
            }
            Button("Cancel", role: .cancel) {}
            
        }
        .alert(isPresented: $showError) {
            Alert(
                title: Text("Not yet available"),
                message: Text("Sorry, this feature is not yet available. Please retry later."),
                primaryButton: .default(Text("OK")),
                secondaryButton: .cancel()
            )
        }
    }
}

struct FullImageRow: View {
    var imageName: String
    var name: String
    var type: String
    var location: String
    
    @State private var showOptions = false
    @State private var showError = false
    @Binding var isFav: Bool
    
    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            Image(imageName)
                .resizable()
                .scaledToFill()
                .frame(height: 200)
                .cornerRadius(20)
            
            HStack(alignment: .top, spacing: 20) {
                VStack(alignment: .leading) {
                    Text(name)
                        .font(.system(.title2, design: .rounded))
                    
                    Text(type)
                        .font(.system(.body, design: .rounded))
                    
                    Text(location)
                        .font(.system(.subheadline, design: .rounded))
                        .foregroundColor(.gray)
                }
                .padding(.horizontal)
                .padding(.bottom)
                
                Spacer()
                VStack() {
                    
                    if isFav {
                        Image(systemName: "heart.fill")
                            .foregroundColor(.yellow)
                    }
                }
                .padding(.trailing)
            }
        }
        .onTapGesture {
            showOptions.toggle()
        }
        .confirmationDialog(
            "What do you want to do?",
            isPresented: $showOptions,
            titleVisibility: .visible
        ) {
            Button("Reserve a table") {
                self.showError.toggle()
            }
            Button(isFav ? "Remove from favorites" : "Mark as favorite") {
                self.isFav.toggle()
            }
            Button("Cancel", role: .cancel) {}
            
        }
        .alert(isPresented: $showError) {
            Alert(
                title: Text("Not yet available"),
                message: Text("Sorry, this feature is not yet available. Please retry later."),
                primaryButton: .default(Text("OK")),
                secondaryButton: .cancel()
            )
        }
    }
}

