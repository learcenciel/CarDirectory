//
//  CarRecord.swift
//  CarDirectory
//
//  Created by Alexander on 27.02.2020.
//  Copyright © 2020 Alexander Team. All rights reserved.
//

import Foundation
import RealmSwift

class CarRecord: Object {
    @objc dynamic var id: Int
    @objc dynamic var manufacturer: String
    @objc dynamic var model: String
    @objc dynamic var releaseYear: Int
    @objc dynamic private var bodyTypeRaw: String
    
    var bodyType: CarBodyType {
        get {
            return CarBodyType(rawValue: bodyTypeRaw)!
        }
        set {
            bodyTypeRaw = newValue.rawValue
        }
    }
    
    init(id: Int,
         manufacturer: String,
         model: String,
         releaseYear: Int,
         bodyType: CarBodyType) {
        self.id = id
        self.manufacturer = manufacturer
        self.model = model
        self.releaseYear = releaseYear
        self.bodyTypeRaw = bodyType.rawValue
    }
    
    required init() {
        id = 0
        manufacturer = ""
        model = ""
        releaseYear = 0
        bodyTypeRaw = ""
    }
    
    override class func primaryKey() -> String? {
        return "id"
    }
}

enum CarBodyType: String, CaseIterable {
    case sedan = "Sedan"
    case hatchback = "Hatchback"
    case offroad = "Offroad"
}
