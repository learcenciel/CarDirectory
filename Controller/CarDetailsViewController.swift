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
    @IBOutlet weak var bodyTypeYearPickerView: UIPickerView!
    
    var carRecord: CarRecord?
    
    var carReleaseYear: [String] = []
    
    enum PickerViewComponent: Int, CaseIterable {
        case bodyType = 0, year
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        configureYears()
        configureTextFields()
        configurePickerView()
        configureNavigationBarButtons()
    }
    
    private func configureYears() {
        for year in stride(from: 2020, to: 1900, by: -1) {
            carReleaseYear.append(String(year))
        }
    }
    
    private func configureTextFields() {
        guard let carRecord = carRecord else { return }
        manufacturerTextField.text = carRecord.manufacturer
        modelTextField.text = carRecord.model
    }
    
    private func configurePickerView() {
        bodyTypeYearPickerView.dataSource = self
        bodyTypeYearPickerView.delegate = self
        
        guard
            let carRecord = carRecord,
            let bodyRow = CarBodyType.allCases.firstIndex(of: carRecord.bodyType),
            let yearRow = carReleaseYear.firstIndex(of: String(carRecord.releaseYear))
        else { return }
        
        bodyTypeYearPickerView.selectRow(bodyRow, inComponent: 0, animated: false)
        bodyTypeYearPickerView.selectRow(yearRow, inComponent: 1, animated: false)
    }
    
    private func configureNavigationBarButtons() {
        if carRecord == nil {
            navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(onAddButtonTap))
        } else {
            navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .save, target: self, action: #selector(onSaveButtonTap))
        }
    }
    
    // MARK: returns detached realm object
    func createDedatchedCarRecord() -> CarRecord? {
        
        let detachedCarRecord = self.carRecord ?? CarRecord()
        
        guard
            let manufacturer = manufacturerTextField.text,
            let model = modelTextField.text
            else { return nil }
        
        let carcassType = CarBodyType.allCases[bodyTypeYearPickerView.selectedRow(inComponent: 0)]
        
        detachedCarRecord.manufacturer = manufacturer
        detachedCarRecord.model = model
        detachedCarRecord.releaseYear = Int(carReleaseYear[bodyTypeYearPickerView.selectedRow(inComponent: 1)])!
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
        
        let pickerViewComponentRows = PickerViewComponent.allCases[component]
        
        switch pickerViewComponentRows {
        case .bodyType:
            return CarBodyType.allCases.count
        case .year:
            return carReleaseYear.count
        }
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        
        let pickerViewComponentTitle = PickerViewComponent.allCases[component]
        
        switch pickerViewComponentTitle {
        case .bodyType:
            return CarBodyType.allCases[row].rawValue
        case .year:
            return carReleaseYear[row]
        }
    }
}
