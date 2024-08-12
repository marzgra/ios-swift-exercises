//
//  Restaurant.swift
//  Task4
//
//  Created by Grażyna Marzec on 23/05/2023.
//

import Foundation

struct Restaurant {
    var name: String
    var type: String
    var location: String
    var image: String
    var description: String
    var phone: String
    var isFav: Bool
    
    init(name: String,
         type: String,
         location: String,
         phone: String,
         description: String,
         isFav: Bool) {
        self.name = name
        self.type = type
        self.location = location
        self.isFav = isFav
        self.image = name
        self.phone = phone
        self.description = description
    }
    
    init() {
        self.init(name: "", type: "", location: "", phone: "", description: "", isFav: false)
    }
}
