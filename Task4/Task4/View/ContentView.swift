//
//  ContentView.swift
//  Task2
//
//  Created by Grażyna Marzec on 20/05/2023.
//

import SwiftUI

struct RestaurantListView: View {
    
    @State var restaurants = [
        Restaurant(name: "Cafe Deadend", type: "Coffee & Tea Shop", location: "Hong Kong", isFav: false),
        Restaurant(name: "Homei", type: "Cafe", location: "Hong Kong", isFav: false),
        Restaurant(name: "Teakha", type: "Tea House", location: "Hong Kong", isFav: false),
        Restaurant(name: "Cafe Loisl", type: "Austrian / Causual Drink", location: "Hong Kong", isFav: false),
        Restaurant(name: "Petite Oyster", type: "French", location: "Hong Kong", isFav: false),
        Restaurant(name: "For Kee Restaurant", type: "Bakery", location: "Hong Kong", isFav: false),
        Restaurant(name: "Po's Atelier", type: "Bakery", location: "Hong Kong", isFav: false),
        Restaurant(name: "Bourke Street Bakery", type: "Chocolate", location: "Sydney", isFav: false),
        Restaurant(name: "Haigh's Chocolate", type: "Cafe", location: "Sydney", isFav: false),
        Restaurant(name: "Palomino Espresso", type: "American / Seafood", location: "Sydney", isFav: false),
        Restaurant(name: "Upstate", type: "American", location: "New York", isFav: false),
        Restaurant(name: "Traif", type: "American", location: "New York", isFav: false),
        Restaurant(name: "Graham Avenue Meats And Deli", type: "Breakfast & Brunch", location: "New York", isFav: false),
        Restaurant(name: "Waffle & Wolf", type: "Coffee & Tea", location: "NewYork", isFav: false),
        Restaurant(name: "Five Leaves", type: "Coffee & Tea", location: "New York", isFav: false),
        Restaurant(name: "Cafe Lore", type: "Latin American", location: "New York", isFav: false),
        Restaurant(name: "Confessional", type: "Spanish", location: "New York", isFav: false),
        Restaurant(name: "Barrafina", type: "Spanish", location: "London", isFav: false),
        Restaurant(name: "Donostia", type: "Spanish", location: "London", isFav: false),
        Restaurant(name: "Royal Oak", type: "British", location: "London", isFav: false),
        Restaurant(name: "CASK Pub and Kitchen", type: "Thai", location: "London", isFav: false)
    ]
    
    var body: some View {
        List {
            ForEach(restaurants.indices, id: \.self) { index in
                BasicTextImageRow(restaurant: $restaurants[index])
                    .swipeActions(edge: .leading, allowsFullSwipe: false, content: {
                        Button {
                            
                        } label: {
                            Image(systemName: "heart")
                        } .tint(.green)
                        
                        Button {
                            
                        } label: {
                            Image(systemName: "square.and.arrow.up")
                        } .tint(.orange)
                    })
            }
            .onDelete(perform: { indexSet in
                restaurants.remove(atOffsets: indexSet)
            })
            .listRowSeparator(.hidden)
        }
        .listStyle(.plain)
    }
}

struct BasicTextImageRow: View {
    
    @State private var showOptions = false
    @State private var showError = false
    @Binding var restaurant: Restaurant
    
    var body: some View {
        HStack(alignment: .top, spacing: 20) {
            Image(restaurant.image)
                .resizable()
                .frame(width: 120, height: 118)
                .cornerRadius(20)
            
            VStack(alignment: .leading) {
                Text(restaurant.name)
                    .font(.system(.title2, design: .rounded))
                Text(restaurant.type)
                    .font(.system(.body, design: .rounded))
                Text(restaurant.location)
                    .font(.system(.subheadline, design: .rounded))
                    .foregroundColor(.gray)
            }
            
            if restaurant.isFav {
                Spacer()
                
                Image(systemName: "heart.fill")
                    .foregroundColor(.yellow)
            }
        }
        .contextMenu{ // visble as dropdown menu after long press on list element
            Button(action: {
                self.showError.toggle()
            }) {
                HStack {
                    Text("Reserve a table")
                    Image(systemName: "phone")
                }
            }
            
            Button(action: {
                self.restaurant.isFav.toggle()
            }) {
                HStack {
                    Text(restaurant.isFav ? "Remove from favorites" : "Mark as favorite")
                    Image(systemName: "heart")
                    
                }
            }
            
            Button(action: {
                self.showOptions.toggle()
            }) {
                HStack {
                    Text("Share")
                    Image(systemName: "square.and.arrow.up")
                }
            }
        }
        .onTapGesture {
            showOptions.toggle()
        }
//        .confirmationDialog( // cannot be used together with sheet
//            "What do you want to do?",
//            isPresented: $showOptions,
//            titleVisibility: .visible
//        ) {
//            Button("Reserve a table") {
//                self.showError.toggle()
//            }
//            Button(restaurant.isFav ? "Remove from favorites" : "Mark as favorite") {
//                self.restaurant.isFav.toggle()
//            }
//            Button("Cancel", role: .cancel) {}
//
//        }
        .alert(isPresented: $showError) {
            Alert(
                title: Text("Not yet available"),
                message: Text("Sorry, this feature is not yet available. Please retry later."),
                primaryButton: .default(Text("OK")),
                secondaryButton: .cancel()
            )
        }
        .sheet(isPresented: $showOptions) { // allows to show the "share" menu
            let defaultText = "Just checking in at \(restaurant.name)"
            if let imageToShare = UIImage(named: restaurant.image) {
                ActivityView(activityItems: [defaultText, imageToShare])
            } else {
                ActivityView(activityItems: [defaultText])
            }
        }
    }
}

struct FullImageRow: View {
    
    @State private var showOptions = false
    @State private var showError = false
    @Binding var restaurant: Restaurant
    
    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            Image(restaurant.image)
                .resizable()
                .scaledToFill()
                .frame(height: 200)
                .cornerRadius(20)
            
            HStack(alignment: .top, spacing: 20) {
                VStack(alignment: .leading) {
                    Text(restaurant.name)
                        .font(.system(.title2, design: .rounded))
                    
                    Text(restaurant.type)
                        .font(.system(.body, design: .rounded))
                    
                    Text(restaurant.location)
                        .font(.system(.subheadline, design: .rounded))
                        .foregroundColor(.gray)
                }
                .padding(.horizontal)
                .padding(.bottom)
                
                Spacer()
                VStack() {
                    
                    if restaurant.isFav {
                        Image(systemName: "heart.fill")
                            .foregroundColor(.yellow)
                    }
                }
                .padding(.trailing)
            }
        }
        .contextMenu{ // visble as dropdown menu after long press on list element
            Button(action: {
                self.showError.toggle()
            }) {
                HStack {
                    Text("Reserve a table")
                    Image(systemName: "phone")
                }
            }
            
            Button(action: {
                self.restaurant.isFav.toggle()
            }) {
                HStack {
                    Text(restaurant.isFav ? "Remove from favorites" : "Mark as favorite")
                    Image(systemName: "heart")
                    
                }
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
            Button(restaurant.isFav ? "Remove from favorites" : "Mark as favorite") {
                self.restaurant.isFav.toggle()
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



struct RestaurantListView_Previews: PreviewProvider {
    static var previews: some View {
        RestaurantListView()
    }
}

