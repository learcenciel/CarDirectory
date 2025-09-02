//
//  GripView.swift
//  CarDirectory
//
//  Created by Assistant on $(date)
//  Copyright © 2020 Alexander Team. All rights reserved.
//

import UIKit

enum GripPosition {
    case topLeft, topCenter, topRight
    case centerLeft, centerRight
    case bottomLeft, bottomCenter, bottomRight
}

protocol GripViewDelegate: AnyObject {
    func gripView(_ gripView: GripView, didPanWithTranslation translation: CGPoint, state: UIGestureRecognizer.State)
}

class GripView: UIView {
    
    // MARK: - Properties
    weak var delegate: GripViewDelegate?
    let position: GripPosition
    private let gripSize: CGFloat
    
    // MARK: - Initialization
    init(position: GripPosition, size: CGFloat) {
        self.position = position
        self.gripSize = size
        super.init(frame: CGRect(x: 0, y: 0, width: size, height: size))
        setupView()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Setup
    private func setupView() {
        backgroundColor = .systemGreen
        layer.cornerRadius = gripSize / 2
        layer.borderWidth = 1.0
        layer.borderColor = UIColor.white.cgColor
        
        // Add shadow for better visibility
        layer.shadowColor = UIColor.black.cgColor
        layer.shadowOffset = CGSize(width: 0, height: 1)
        layer.shadowOpacity = 0.3
        layer.shadowRadius = 2
        
        setupGestures()
        setupArrow()
    }
    
    private func setupArrow() {
        // Create arrow shape based on position
        let arrowLayer = CAShapeLayer()
        let arrowPath = createArrowPath()
        
        arrowLayer.path = arrowPath.cgPath
        arrowLayer.fillColor = UIColor.white.cgColor
        arrowLayer.strokeColor = UIColor.clear.cgColor
        
        layer.addSublayer(arrowLayer)
    }
    
    private func createArrowPath() -> UIBezierPath {
        let path = UIBezierPath()
        let center = CGPoint(x: gripSize / 2, y: gripSize / 2)
        let arrowSize: CGFloat = 6
        
        switch position {
        case .topLeft, .bottomRight:
            // Diagonal resize cursor (↖ ↘)
            path.move(to: CGPoint(x: center.x - arrowSize/2, y: center.y - arrowSize/2))
            path.addLine(to: CGPoint(x: center.x + arrowSize/2, y: center.y + arrowSize/2))
            path.move(to: CGPoint(x: center.x - arrowSize/2, y: center.y + arrowSize/2))
            path.addLine(to: CGPoint(x: center.x + arrowSize/2, y: center.y - arrowSize/2))
            
        case .topRight, .bottomLeft:
            // Diagonal resize cursor (↗ ↙)
            path.move(to: CGPoint(x: center.x - arrowSize/2, y: center.y + arrowSize/2))
            path.addLine(to: CGPoint(x: center.x + arrowSize/2, y: center.y - arrowSize/2))
            path.move(to: CGPoint(x: center.x - arrowSize/2, y: center.y - arrowSize/2))
            path.addLine(to: CGPoint(x: center.x + arrowSize/2, y: center.y + arrowSize/2))
            
        case .topCenter, .bottomCenter:
            // Vertical resize cursor (↕)
            path.move(to: CGPoint(x: center.x, y: center.y - arrowSize))
            path.addLine(to: CGPoint(x: center.x - 3, y: center.y - arrowSize/2))
            path.addLine(to: CGPoint(x: center.x + 3, y: center.y - arrowSize/2))
            path.close()
            
            path.move(to: CGPoint(x: center.x, y: center.y + arrowSize))
            path.addLine(to: CGPoint(x: center.x - 3, y: center.y + arrowSize/2))
            path.addLine(to: CGPoint(x: center.x + 3, y: center.y + arrowSize/2))
            path.close()
            
        case .centerLeft, .centerRight:
            // Horizontal resize cursor (↔)
            path.move(to: CGPoint(x: center.x - arrowSize, y: center.y))
            path.addLine(to: CGPoint(x: center.x - arrowSize/2, y: center.y - 3))
            path.addLine(to: CGPoint(x: center.x - arrowSize/2, y: center.y + 3))
            path.close()
            
            path.move(to: CGPoint(x: center.x + arrowSize, y: center.y))
            path.addLine(to: CGPoint(x: center.x + arrowSize/2, y: center.y - 3))
            path.addLine(to: CGPoint(x: center.x + arrowSize/2, y: center.y + 3))
            path.close()
        }
        
        return path
    }
    
    private func setupGestures() {
        let panGesture = UIPanGestureRecognizer(target: self, action: #selector(handlePan(_:)))
        addGestureRecognizer(panGesture)
    }
    
    // MARK: - Gesture Handling
    @objc private func handlePan(_ gesture: UIPanGestureRecognizer) {
        let translation = gesture.translation(in: superview)
        delegate?.gripView(self, didPanWithTranslation: translation, state: gesture.state)
    }
    
    // MARK: - Visual Feedback
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesBegan(touches, with: event)
        animatePress(pressed: true)
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesEnded(touches, with: event)
        animatePress(pressed: false)
    }
    
    override func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesCancelled(touches, with: event)
        animatePress(pressed: false)
    }
    
    private func animatePress(pressed: Bool) {
        UIView.animate(withDuration: 0.1, delay: 0, options: [.allowUserInteraction]) {
            self.transform = pressed ? CGAffineTransform(scaleX: 1.2, y: 1.2) : .identity
            self.alpha = pressed ? 0.8 : 1.0
        }
    }
}