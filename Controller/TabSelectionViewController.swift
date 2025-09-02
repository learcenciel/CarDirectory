//
//  TabSelectionViewController.swift
//  CarDirectory
//
//  Created by Assistant on $(date)
//  Copyright © 2020 Alexander Team. All rights reserved.
//

import UIKit

class TabSelectionViewController: UIViewController {
    
    // MARK: - Properties
    private var contentView: UIView!
    private var selectionView: SelectionView?
    private var isSelectionMode: Bool = false
    
    // Mock tablature content view
    private var tablatureView: UIView!
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupNavigationBar()
    }
    
    // MARK: - Setup
    private func setupUI() {
        view.backgroundColor = .systemBackground
        
        // Create content container
        contentView = UIView()
        contentView.backgroundColor = .secondarySystemBackground
        contentView.layer.cornerRadius = 8
        contentView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(contentView)
        
        // Setup tablature mock view
        setupTablatureView()
        
        // Layout constraints
        NSLayoutConstraint.activate([
            contentView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 20),
            contentView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            contentView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            contentView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -20)
        ])
    }
    
    private func setupTablatureView() {
        tablatureView = UIView()
        tablatureView.backgroundColor = .systemBackground
        tablatureView.layer.cornerRadius = 4
        tablatureView.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(tablatureView)
        
        // Create mock tablature lines
        createMockTablature()
        
        NSLayoutConstraint.activate([
            tablatureView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 20),
            tablatureView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            tablatureView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
            tablatureView.heightAnchor.constraint(equalToConstant: 200)
        ])
        
        // Add tap gesture to enable selection
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(handleTablatureTap(_:)))
        tablatureView.addGestureRecognizer(tapGesture)
    }
    
    private func createMockTablature() {
        let stringNames = ["e", "B", "G", "D", "A", "E"]
        let lineHeight: CGFloat = 30
        
        for (index, stringName) in stringNames.enumerated() {
            // String name label
            let nameLabel = UILabel()
            nameLabel.text = stringName
            nameLabel.font = .systemFont(ofSize: 16, weight: .medium)
            nameLabel.textAlignment = .center
            nameLabel.translatesAutoresizingMaskIntoConstraints = false
            tablatureView.addSubview(nameLabel)
            
            // Tablature line
            let lineView = UIView()
            lineView.backgroundColor = .separator
            lineView.translatesAutoresizingMaskIntoConstraints = false
            tablatureView.addSubview(lineView)
            
            let yPosition = CGFloat(index) * lineHeight + 40
            
            NSLayoutConstraint.activate([
                nameLabel.leadingAnchor.constraint(equalTo: tablatureView.leadingAnchor, constant: 10),
                nameLabel.centerYAnchor.constraint(equalTo: tablatureView.topAnchor, constant: yPosition),
                nameLabel.widthAnchor.constraint(equalToConstant: 20),
                
                lineView.leadingAnchor.constraint(equalTo: nameLabel.trailingAnchor, constant: 10),
                lineView.trailingAnchor.constraint(equalTo: tablatureView.trailingAnchor, constant: -10),
                lineView.centerYAnchor.constraint(equalTo: nameLabel.centerYAnchor),
                lineView.heightAnchor.constraint(equalToConstant: 1)
            ])
            
            // Add some fret numbers
            addFretNumbers(to: lineView, yPosition: yPosition)
        }
    }
    
    private func addFretNumbers(to lineView: UIView, yPosition: CGFloat) {
        let fretNumbers = ["0", "3", "0", "0", "7", "0"]
        let spacing: CGFloat = 60
        
        for (index, number) in fretNumbers.enumerated() {
            if number != "0" {
                let numberLabel = UILabel()
                numberLabel.text = number
                numberLabel.font = .monospacedDigitSystemFont(ofSize: 14, weight: .medium)
                numberLabel.textAlignment = .center
                numberLabel.translatesAutoresizingMaskIntoConstraints = false
                tablatureView.addSubview(numberLabel)
                
                NSLayoutConstraint.activate([
                    numberLabel.leadingAnchor.constraint(equalTo: lineView.leadingAnchor, constant: CGFloat(index) * spacing + 40),
                    numberLabel.centerYAnchor.constraint(equalTo: tablatureView.topAnchor, constant: yPosition),
                    numberLabel.widthAnchor.constraint(equalToConstant: 20)
                ])
            }
        }
    }
    
    private func setupNavigationBar() {
        title = "Tab Selection Demo"
        
        let selectButton = UIBarButtonItem(
            title: isSelectionMode ? "Done" : "Select",
            style: .plain,
            target: self,
            action: #selector(toggleSelectionMode)
        )
        navigationItem.rightBarButtonItem = selectButton
    }
    
    // MARK: - Actions
    @objc private func toggleSelectionMode() {
        isSelectionMode.toggle()
        
        if isSelectionMode {
            // Enable selection mode but don't create selection until user taps
            navigationItem.rightBarButtonItem?.title = "Done"
        } else {
            // Disable selection mode
            removeSelection()
            navigationItem.rightBarButtonItem?.title = "Select"
        }
    }
    
    @objc private func handleTablatureTap(_ gesture: UITapGestureRecognizer) {
        guard isSelectionMode else { return }
        
        let location = gesture.location(in: tablatureView)
        
        if selectionView == nil {
            createSelection(at: location)
        } else {
            // Move existing selection or create new one
            removeSelection()
            createSelection(at: location)
        }
    }
    
    private func createSelection(at point: CGPoint) {
        // Create selection with initial size
        let selectionFrame = CGRect(
            x: max(0, point.x - 50),
            y: max(0, point.y - 30),
            width: 100,
            height: 60
        )
        
        selectionView = SelectionView(frame: selectionFrame)
        selectionView?.delegate = self
        tablatureView.addSubview(selectionView!)
        
        // Animate in
        selectionView?.alpha = 0
        selectionView?.transform = CGAffineTransform(scaleX: 0.8, y: 0.8)
        
        UIView.animate(withDuration: 0.3, delay: 0, usingSpringWithDamping: 0.7, initialSpringVelocity: 0.5) {
            self.selectionView?.alpha = 1
            self.selectionView?.transform = .identity
        }
    }
    
    private func removeSelection() {
        guard let selectionView = selectionView else { return }
        
        UIView.animate(withDuration: 0.2) {
            selectionView.alpha = 0
            selectionView.transform = CGAffineTransform(scaleX: 0.8, y: 0.8)
        } completion: { _ in
            selectionView.removeFromSuperview()
            self.selectionView = nil
        }
    }
}

// MARK: - SelectionViewDelegate
extension TabSelectionViewController: SelectionViewDelegate {
    func selectionView(_ selectionView: SelectionView, didChangeFrame frame: CGRect) {
        // Handle selection frame changes
        print("Selection frame changed: \(frame)")
        
        // Ensure selection stays within bounds
        var constrainedFrame = frame
        constrainedFrame.origin.x = max(0, min(frame.origin.x, tablatureView.bounds.width - frame.width))
        constrainedFrame.origin.y = max(0, min(frame.origin.y, tablatureView.bounds.height - frame.height))
        
        if constrainedFrame != frame {
            selectionView.frame = constrainedFrame
        }
    }
    
    func selectionView(_ selectionView: SelectionView, didBeginSelection frame: CGRect) {
        print("Selection began: \(frame)")
        // Could add haptic feedback here
        let impactFeedback = UIImpactFeedbackGenerator(style: .medium)
        impactFeedback.impactOccurred()
    }
    
    func selectionView(_ selectionView: SelectionView, didEndSelection frame: CGRect) {
        print("Selection ended: \(frame)")
        // Could save selection state or trigger other actions
    }
}