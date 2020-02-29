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
    @objc dynamic var id = UUID().uuidString
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
    
    init(id: String = UUID().uuidString,
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
        manufacturer = ""
        model = ""
        releaseYear = 0
        bodyTypeRaw = ""
    }
    
    override static func primaryKey() -> String? {
      return "id"
    }
    
    func copy() -> CarRecord {
        return CarRecord(
            id: self.id,
            manufacturer: self.manufacturer,
            model: self.model,
            releaseYear: self.releaseYear,
            bodyType: self.bodyType
        )
    }
}

enum CarBodyType: String, CaseIterable {
    case sedan = "Sedan"
    case hatchback = "Hatchback"
    case offroad = "Offroad"
}
