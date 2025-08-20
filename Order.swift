//
//  Order.swift
//  CupcakeLover
//
//  Created by Emilie NOLBAS on 20/08/2025.
//

import SwiftUI

@Observable
class Order: Codable {
    static let types = ["Vanilla", "Strawberry", "Chocolate", "Rainbow"]

    var type = 0
    var quantity = 3

    // toppings
    var extraFrosting = false
    var addSprinkles = false
    
    var specialRequestEnabled = false {
        didSet {
            if specialRequestEnabled == false {
                extraFrosting = false
                addSprinkles = false
            }
        }
    }

    // delivery details
    var name = ""
    var streetAddress = ""
    var city = ""
    var zip = ""
    
    var hasValidAddress: Bool {
        if name.isEmpty || streetAddress.isEmpty || city.isEmpty || zip.isEmpty {
            return false
        }
        return true
    }
    
    // cost
    var cost: Decimal {
        // $3 per cake
        var cost = Decimal(quantity) * 3
        // complicated cakes cost more
        cost += Decimal(type) / 2
        // $1/cake for extra frosting
        if extraFrosting {
            cost += Decimal(quantity)
        }
        // $0.50/cake for sprinkles
        if addSprinkles {
            cost += Decimal(quantity) / 2
        }
        return cost
    }
    
    // for real server names decoding
    enum CodingKeys: String, CodingKey {
        case _type = "type"
        case _quantity = "quantity"
        case _specialRequestEnabled = "specialRequestEnabled"
        case _extraFrosting = "extraFrosting"
        case _addSprinkles = "addSprinkles"
        case _name = "name"
        case _city = "city"
        case _streetAddress = "streetAddress"
        case _zip = "zip"
    }
}
