//
//  RestaurantDetailView.swift
//  Task4
//
//  Created by Grażyna Marzec on 04/06/2023.
//

import SwiftUI

struct RestaurantDetailView: View {
    var restaurant: Restaurant
    @Environment(\.dismiss) var dismiss
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading) {
                Image(restaurant.image)
                    .resizable()
                    .scaledToFill()
                    .frame(minWidth: 0, maxWidth: .infinity)
                    .frame(height: 445)
            }
            .overlay {
                VStack {
                    if(restaurant.isFav) {
                        Image(systemName: "heart.fill")
                            .frame(minWidth: 0, maxWidth: .infinity, minHeight: 0, maxHeight: .infinity, alignment: .topTrailing)
                            .padding()
                            .font(.system(size: 30))
                            .foregroundColor(.yellow)
                            .padding(.top, 40)
                        
                    } else {
                        Image(systemName: "heart")
                        // frame used to put heart icon into top right corner
                            .frame(minWidth: 0, maxWidth: .infinity, minHeight: 0, maxHeight: .infinity, alignment: .topTrailing)
                            .padding()
                            .font(.system(size: 30))
                            .foregroundColor(.white)
                            .padding(.top, 40)
                    }
                    
                    
                    VStack(alignment: .leading, spacing: 5) { // spacing used to reduce gap between elements - here two texts
                        Text(restaurant.name)
                            .font(.system(size: 35, design: .rounded))
                            .bold()
                        
                        Text(restaurant.type)
                            .font(.system(.headline, design: .rounded))
                            .padding(.all, 5)
                            .background(Color.black)
                    }
                    .frame(minWidth: 0, maxWidth: . infinity, minHeight: 0, maxHeight: .infinity, alignment: .bottomLeading)
                    .foregroundColor(.white)
                    .padding()
                }
            }
            Text(restaurant.description)
                .padding()
            
            HStack(alignment: .top) {
                VStack(alignment: .leading) {
                    Text("ADDRES")
                        .font(.system(.headline, design: .rounded))
                    
                    Text(restaurant.location)
                }
                .frame(minWidth: 0, maxWidth: . infinity, alignment: .leading)
                
                VStack(alignment: .leading) {
                    Text("PHONE")
                        .font(.system(.headline, design: .rounded))
                    
                    Text(restaurant.phone)
                }
                .frame(minWidth: 0, maxWidth: . infinity, alignment: .leading)
            }
            .padding(.horizontal)
        }
        .ignoresSafeArea()
        //        ZStack(alignment: .top) {
        //            Image(restaurant.image)
        //                .resizable()
        //                .scaledToFill()
        //                .frame(minWidth: 0, maxWidth: .infinity)
        //                .ignoresSafeArea()
        //
        //            Color.black
        //                .frame(height: 100)
        //                .opacity(0.8)
        //                .cornerRadius(20)
        //                .padding()
        //                .overlay {
        //                    VStack(spacing: 5) {
        //                        Text(restaurant.name)
        //                        Text(restaurant.type)
        //                        Text(restaurant.location)
        //                    }
        //                    .font(.system(.headline, design: .rounded))
        //                    .foregroundColor(.white)
        //                }
        //        }
        .navigationBarBackButtonHidden(true)
        .toolbar {
            ToolbarItem(placement: .navigationBarLeading) {
                Button(action: {
                    dismiss()
                }) {
                    Text("\(Image(systemName: "chevron.left")) \(restaurant.name)")
                        .foregroundColor(.white)
                }
            }
        }
    }
}

struct RestaurantDetailView_Previews: PreviewProvider {
    static var previews: some View {
        RestaurantDetailView(restaurant: Restaurant(name: "Cafe Deadend", type: "Coffee & Tea Shop", location: "G/F, 72 Po Hing Fong, Sheung Wan, Hong Kong", phone: "232-923423", description: "Searching for great breakfast eateries and coffee? This place is for you. We open at 6:30 every morning, and close at 9 PM. We offer espresso and espresso based drink, such as capuccino, cafe latte, piccolo and many more. Come over and enjoy a great meal.", isFav: true))
    }
}
