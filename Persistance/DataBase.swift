//
//  DataBase.swift
//  CarDirectory
//
//  Created by Alexander on 27.02.2020.
//  Copyright © 2020 Alexander Team. All rights reserved.
//

import Foundation
import RealmSwift

final class DataBase {
    
    static let shared = DataBase()
    private let isDataBasePrefilledKey = "isDataBasePrefilled"
    private let schemaVersion: UInt64 = 1
    
    // MARK: realm configuration with migration support only
    private lazy var realmConfiguration = Realm.Configuration(schemaVersion: schemaVersion, migrationBlock: runMigrations)
    private lazy var realm = try! Realm(configuration: realmConfiguration)
    
    func fetchCarRecords() -> [CarRecord] {
        return Array(realm.objects(CarRecord.self))
    }
    
    func addCarRecord(_ carRecord: CarRecord) {
        #warning("TODO")
    }
    
    func updateCarRecord(_ carRecord: CarRecord,
                         manufacturerName: String,
                         modelName: String,
                         releaseYear: String,
                         carcassType: CarBodyType) {
        try! realm.write {
            carRecord.manufacturer = manufacturerName
            carRecord.model = modelName
            carRecord.releaseYear = Int(releaseYear)!
            carRecord.bodyType = carcassType
        }
    }
    
    func deleteCarRecord(_ carRecord: CarRecord) {
        try! realm.write {
            realm.delete(carRecord)
        }
    }
    
    init() {
        prefillDataBaseIfNeeded()
    }
    
    private func prefillDataBaseIfNeeded() {
        guard UserDefaults.standard.bool(forKey: isDataBasePrefilledKey) == false else { return }
        
        try! realm.write {
            realm.add([
                CarRecord(id: 1, manufacturer: "Hyundai", model: "Creta", releaseYear: 2018, bodyType: .offroad),
                CarRecord(id: 2, manufacturer: "Toyota", model: "Corolla", releaseYear: 1996, bodyType: .sedan),
                CarRecord(id: 3, manufacturer: "Ford", model: "Focus", releaseYear: 2006, bodyType: .hatchback)
            ])
        }
        
        UserDefaults.standard.set(true, forKey: isDataBasePrefilledKey)
    }
    
    private func runMigrations(_ migration: Migration, oldSchemaVersion: UInt64) {
        
    }
    
    func createUnmanagedObject(value: Any) -> Object {
        return Object(value: value)
    }
}
