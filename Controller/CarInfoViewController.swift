//
//  CarInfoViewController.swift
//  CarDirectory
//
//  Created by Alexander on 27.02.2020.
//  Copyright © 2020 Alexander Team. All rights reserved.
//

import UIKit

class CarInfoViewController: UIViewController {

    @IBOutlet weak var manufacturerTextField: UITextField!
    @IBOutlet weak var modelTextField: UITextField!
    @IBOutlet weak var releaseYearTextField: UITextField!
    @IBOutlet weak var bodyTypePickerView: UIPickerView!
    
    var carRecord: CarRecord?
    
    var carcassType: CarBodyType!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        configureTextFields()
        configurePickerView()
        configureNavigationBarButtons()
    }
    
    private func configureTextFields() {
        guard let carRecord = carRecord else { return }
        manufacturerTextField.text = carRecord.manufacturer
        modelTextField.text = carRecord.model
        releaseYearTextField.text = String(carRecord.releaseYear)
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
    
    @objc private func onAddButtonTap() {
        print("Add")
    }
    
    @objc private func onSaveButtonTap() {
        //let newBodyType = CarBodyType.allCases[bodyTypePickerView.selectedRow(inComponent: 0)]
        
        guard
            let manufacturerName = manufacturerTextField.text,
            let modelName = modelTextField.text,
            let releaseYear = releaseYearTextField.text,
            let carcassType = carcassType
        else { return }
        
        DataBase.shared.updateCarRecord(carRecord!,
                                        manufacturerName: manufacturerName,
                                        modelName: modelName,
                                        releaseYear: releaseYear,
                                        carcassType: carcassType)
    }
}

extension CarInfoViewController: UIPickerViewDataSource, UIPickerViewDelegate {
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        switch CarBodyType.allCases[row] {
        case CarBodyType.hatchback:
            carcassType = CarBodyType.hatchback
        case CarBodyType.sedan:
            carcassType = CarBodyType.sedan
        case CarBodyType.offroad:
            carcassType = CarBodyType.offroad
        }
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return CarBodyType.allCases.count
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return CarBodyType.allCases[row].rawValue
    }
}
