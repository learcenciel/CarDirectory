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
    
    var carReleaseYear: [Int] = []
    
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
    
    // MARK: Configure block
    private func configureYears() {
        let currentYear = Calendar.current.component(.year, from: Date())
        carReleaseYear = Array(1900...currentYear).reversed()
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
            let yearRow = carReleaseYear.firstIndex(of: carRecord.releaseYear)
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
    
    private func buildAndValidateCarRecord() -> CarRecord? {
        let carRecord = self.carRecord ?? CarRecord()
        
        let carcassType = CarBodyType.allCases[bodyTypeYearPickerView.selectedRow(inComponent: 0)]
        
        carRecord.releaseYear = carReleaseYear[bodyTypeYearPickerView.selectedRow(inComponent: 1)]
        carRecord.bodyType = carcassType
        
        do {
            carRecord.manufacturer = try manufacturerTextField.validatedText(validationType: .manufacturer)
            carRecord.model = try modelTextField.validatedText(validationType: .model)
            
            return carRecord
        } catch(let error) {
            showAlert("All the fields are required.", message: (error as! ValidationError).message)
        }
        
        return nil
    }
    
    @objc private func onAddButtonTap() {
        guard let validatedCarRecord = buildAndValidateCarRecord() else { return }
        
        DataBase.shared.addCarRecord(validatedCarRecord)
        self.navigationController?.popViewController(animated: true)
    }
    
    @objc private func onSaveButtonTap() {
        guard let validatedCarRecord = buildAndValidateCarRecord() else { return }
        
        DataBase.shared.updateCarRecord(validatedCarRecord)
        self.navigationController?.popViewController(animated: true)
    }
}

// MARK: UIPickerViewDataSource, UIPickerViewDelegate
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
            return String(carReleaseYear[row])
        }
    }
}
