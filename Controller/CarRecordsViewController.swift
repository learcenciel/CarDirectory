//
//  CarRecordsViewController.swift
//  CarDirectory
//
//  Created by Alexander on 27.02.2020.
//  Copyright © 2020 Alexander Team. All rights reserved.
//

import UIKit

class CarRecordsViewController: UIViewController {
    
    @IBOutlet weak var carTableView: UITableView!
    private var carRecords: [CarRecord] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        configureTableView()
        configureNavigationBarButtons()
        
        fetchData()
    }
    
    private func configureTableView() {
        carTableView.delegate = self
        carTableView.dataSource = self
    }
    
    override func viewWillAppear(_ animated: Bool) {
        fetchData()
    }
    
    private func configureNavigationBarButtons() {
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(onAddButtonTap))
    }
    
    @objc private func onAddButtonTap() {
        guard
            let carInfoVC = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "CarInfo") as? CarDetailsViewController
            else { return }
        self.navigationController?.pushViewController(carInfoVC, animated: true)
    }
    
    // MARK: fetch records from database
    func fetchData() {
        carRecords = DataBase.shared.fetchCarRecords()
        carTableView.reloadData()
    }
}

extension CarRecordsViewController: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        guard
            let carInfoVC = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "CarInfo") as? CarDetailsViewController
            else { return }
        
        carInfoVC.carRecord = carRecords[indexPath.row].copy()
        
        self.navigationController?.pushViewController(carInfoVC, animated: true)
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return carRecords.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let carRecord = carRecords[indexPath.row]
        
        guard
            let cell = tableView.dequeueReusableCell(withIdentifier: "CarCell", for: indexPath) as? CarCell
            else { fatalError() }
        
        cell.setup(carRecord: carRecord)
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 76.0
    }
    
    // MARK: trailing swipe delete animation
    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        
        let deleteAction = UIContextualAction(style: .destructive, title: "Delete") { [unowned self] _, _, completion in
            DataBase.shared.deleteCarRecord(self.carRecords[indexPath.row])
            self.carRecords.remove(at: indexPath.row)
            tableView.deleteRows(at: [indexPath], with: .automatic)
            completion(true)
        }
        
        return UISwipeActionsConfiguration(actions: [deleteAction])
    }
}
