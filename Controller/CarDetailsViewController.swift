//
//  CarInfoViewController.swift
//  CarDirectory
//
//  Created by Alexander on 27.02.2020.
//  Copyright © 2020 Alexander Team. All rights reserved.
//

import UIKit
import RealmSwift

class CarDetailsViewController: UIViewController {
    
    @IBOutlet weak var manufacturerTextField: UITextField!
    @IBOutlet weak var modelTextField: UITextField!
    @IBOutlet weak var bodyTypePickerView: UIPickerView!
    
    var carRecord: CarRecord?
    
    var carReleaseYear: [String] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        configureYears()
        configureTextFields()
        configurePickerView()
        configureNavigationBarButtons()
    }
    
    private func configureYears() {
        for year in 1990...2020 {
            carReleaseYear.append(String(year))
        }
    }
    
    private func configureTextFields() {
        guard let carRecord = carRecord else { return }
        manufacturerTextField.text = carRecord.manufacturer
        modelTextField.text = carRecord.model
    }
    
    private func configurePickerView() {
        bodyTypePickerView.dataSource = self
        bodyTypePickerView.delegate = self
        
        guard
            let carRecord = carRecord,
            let row = CarBodyType.allCases.firstIndex(of: carRecord.bodyType)
            else { return }
        
        bodyTypePickerView.selectRow(row, inComponent: 0, animated: false)
    }
    
    private func configureNavigationBarButtons() {
        if carRecord == nil {
            navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(onAddButtonTap))
        } else {
            navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .save, target: self, action: #selector(onSaveButtonTap))
        }
    }
    
    func createDedatchedCarRecord() -> CarRecord? {
        
        let detachedCarRecord = self.carRecord ?? CarRecord()
        
        guard
            let manufacturer = manufacturerTextField.text,
            let model = modelTextField.text
            else { return nil }
        
        let carcassType = CarBodyType.allCases[bodyTypePickerView.selectedRow(inComponent: 0)]
        
        detachedCarRecord.manufacturer = manufacturer
        detachedCarRecord.model = model
        detachedCarRecord.releaseYear = Int(carReleaseYear[bodyTypePickerView.selectedRow(inComponent: 1)])!
        detachedCarRecord.bodyType = carcassType
        
        return detachedCarRecord
    }
    
    @objc private func onAddButtonTap() {
        let detachedCarRecordToAdd = createDedatchedCarRecord()
        
        DataBase.shared.addCarRecord(detachedCarRecordToAdd!)
    }
    
    @objc private func onSaveButtonTap() {
        
        let detachedCarRecordToUpdate = createDedatchedCarRecord()
        
        DataBase.shared.updateCarRecord(detachedCarRecordToUpdate!)
    }
}

extension CarDetailsViewController: UIPickerViewDataSource, UIPickerViewDelegate {
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 2
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        
        switch component {
        case 0:
            return CarBodyType.allCases.count
        case 1:
            return carReleaseYear.count
        default:
            return 0
        }
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        
        switch component {
        case 0:
            return CarBodyType.allCases[row].rawValue
        case 1:
            return carReleaseYear[row]
        default:
            return ""
        }
    }
}
