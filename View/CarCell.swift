//
//  CarCell.swift
//  CarDirectory
//
//  Created by Alexander on 27.02.2020.
//  Copyright © 2020 Alexander Team. All rights reserved.
//

import UIKit

class CarCell: UITableViewCell {
    
    @IBOutlet weak var carNameLabel: UILabel!
    @IBOutlet weak var releaseYearLabel: UILabel! {
        didSet {
            releaseYearLabel.font = .monospacedDigitSystemFont(ofSize: 16, weight: .regular)
        }
    }
    @IBOutlet weak var bodyTypeLabel: UILabel!
        
    func setup(carRecord: CarRecord) {
        carNameLabel.text = "\(carRecord.manufacturer) \(carRecord.model)"
        releaseYearLabel.text = String(carRecord.releaseYear)
        bodyTypeLabel.text = carRecord.bodyType.rawValue
    }
}
