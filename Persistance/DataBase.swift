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
    
    // MARK: realm configuration with migration support
    private lazy var realmConfiguration = Realm.Configuration(schemaVersion: schemaVersion, migrationBlock: runMigrations)
    private lazy var realm = try! Realm(configuration: realmConfiguration)
    
    func fetchCarRecords() -> [CarRecord] {
        return Array(realm.objects(CarRecord.self))
    }
    
    func addCarRecord(_ carRecord: CarRecord) {
        try! realm.write {
            realm.add(carRecord)
        }
    }
    
    func updateCarRecord(_ carRecord: CarRecord) {
        try! realm.write {
            realm.add(carRecord, update: .all)
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
    
    // MARK: first app launch data prefill
    private func prefillDataBaseIfNeeded() {
        guard UserDefaults.standard.bool(forKey: isDataBasePrefilledKey) == false else { return }
        
        try! realm.write {
            realm.add([
                CarRecord(manufacturer: "Hyundai", model: "Creta", releaseYear: 2018, bodyType: .offroad),
                CarRecord(manufacturer: "Toyota", model: "Corolla", releaseYear: 1996, bodyType: .sedan),
                CarRecord(manufacturer: "Ford", model: "Mondeo", releaseYear: 2006, bodyType: .hatchback)
            ])
        }
        
        UserDefaults.standard.set(true, forKey: isDataBasePrefilledKey)
    }
    
    private func runMigrations(_ migration: Migration, oldSchemaVersion: UInt64) {
        
    }
}
