//
//  SelectionView.swift
//  CarDirectory
//
//  Created by Assistant on $(date)
//  Copyright © 2020 Alexander Team. All rights reserved.
//

import UIKit

protocol SelectionViewDelegate: AnyObject {
    func selectionView(_ selectionView: SelectionView, didChangeFrame frame: CGRect)
    func selectionView(_ selectionView: SelectionView, didBeginSelection frame: CGRect)
    func selectionView(_ selectionView: SelectionView, didEndSelection frame: CGRect)
}

class SelectionView: UIView {
    
    // MARK: - Properties
    weak var delegate: SelectionViewDelegate?
    
    private var borderLayer: CAShapeLayer!
    private var gripViews: [GripView] = []
    private var initialFrame: CGRect = .zero
    private var initialTouchPoint: CGPoint = .zero
    
    // Selection styling
    var borderColor: UIColor = .systemGreen {
        didSet {
            updateAppearance()
        }
    }
    
    var borderWidth: CGFloat = 2.0 {
        didSet {
            updateAppearance()
        }
    }
    
    var fillColor: UIColor = UIColor.systemGreen.withAlphaComponent(0.2) {
        didSet {
            updateAppearance()
        }
    }
    
    var gripSize: CGFloat = 20.0 {
        didSet {
            setupGrips()
        }
    }
    
    // MARK: - Initialization
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupView()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupView()
    }
    
    // MARK: - Setup
    private func setupView() {
        backgroundColor = .clear
        isUserInteractionEnabled = true
        
        setupBorder()
        setupGrips()
        setupGestures()
    }
    
    private func setupBorder() {
        borderLayer = CAShapeLayer()
        borderLayer.fillColor = fillColor.cgColor
        borderLayer.strokeColor = borderColor.cgColor
        borderLayer.lineWidth = borderWidth
        borderLayer.lineDashPattern = [5, 3] // Dashed border like in Songsterr
        layer.addSublayer(borderLayer)
    }
    
    private func setupGrips() {
        // Remove existing grips
        gripViews.forEach { $0.removeFromSuperview() }
        gripViews.removeAll()
        
        // Create 8 grip points (corners and midpoints)
        let gripPositions: [GripPosition] = [.topLeft, .topCenter, .topRight, .centerLeft, .centerRight, .bottomLeft, .bottomCenter, .bottomRight]
        
        for position in gripPositions {
            let gripView = GripView(position: position, size: gripSize)
            gripView.delegate = self
            addSubview(gripView)
            gripViews.append(gripView)
        }
    }
    
    private func setupGestures() {
        let panGesture = UIPanGestureRecognizer(target: self, action: #selector(handlePan(_:)))
        addGestureRecognizer(panGesture)
    }
    
    // MARK: - Layout
    override func layoutSubviews() {
        super.layoutSubviews()
        updateBorderPath()
        positionGrips()
    }
    
    private func updateBorderPath() {
        let path = UIBezierPath(rect: bounds)
        borderLayer.path = path.cgPath
        borderLayer.frame = bounds
    }
    
    private func positionGrips() {
        let halfGrip = gripSize / 2
        
        for gripView in gripViews {
            var center: CGPoint
            
            switch gripView.position {
            case .topLeft:
                center = CGPoint(x: halfGrip, y: halfGrip)
            case .topCenter:
                center = CGPoint(x: bounds.midX, y: halfGrip)
            case .topRight:
                center = CGPoint(x: bounds.maxX - halfGrip, y: halfGrip)
            case .centerLeft:
                center = CGPoint(x: halfGrip, y: bounds.midY)
            case .centerRight:
                center = CGPoint(x: bounds.maxX - halfGrip, y: bounds.midY)
            case .bottomLeft:
                center = CGPoint(x: halfGrip, y: bounds.maxY - halfGrip)
            case .bottomCenter:
                center = CGPoint(x: bounds.midX, y: bounds.maxY - halfGrip)
            case .bottomRight:
                center = CGPoint(x: bounds.maxX - halfGrip, y: bounds.maxY - halfGrip)
            }
            
            gripView.center = center
        }
    }
    
    private func updateAppearance() {
        borderLayer?.fillColor = fillColor.cgColor
        borderLayer?.strokeColor = borderColor.cgColor
        borderLayer?.lineWidth = borderWidth
    }
    
    // MARK: - Gesture Handling
    @objc private func handlePan(_ gesture: UIPanGestureRecognizer) {
        let translation = gesture.translation(in: superview)
        
        switch gesture.state {
        case .began:
            initialFrame = frame
            initialTouchPoint = gesture.location(in: superview)
            delegate?.selectionView(self, didBeginSelection: frame)
            
        case .changed:
            let newFrame = CGRect(
                x: initialFrame.origin.x + translation.x,
                y: initialFrame.origin.y + translation.y,
                width: initialFrame.width,
                height: initialFrame.height
            )
            frame = newFrame
            delegate?.selectionView(self, didChangeFrame: frame)
            
        case .ended, .cancelled:
            delegate?.selectionView(self, didEndSelection: frame)
            
        default:
            break
        }
    }
}

// MARK: - GripViewDelegate
extension SelectionView: GripViewDelegate {
    func gripView(_ gripView: GripView, didPanWithTranslation translation: CGPoint, state: UIGestureRecognizer.State) {
        switch state {
        case .began:
            initialFrame = frame
            delegate?.selectionView(self, didBeginSelection: frame)
            
        case .changed:
            let newFrame = calculateNewFrame(for: gripView.position, translation: translation)
            frame = newFrame
            delegate?.selectionView(self, didChangeFrame: frame)
            
        case .ended, .cancelled:
            delegate?.selectionView(self, didEndSelection: frame)
            
        default:
            break
        }
    }
    
    private func calculateNewFrame(for position: GripPosition, translation: CGPoint) -> CGRect {
        var newFrame = initialFrame
        
        switch position {
        case .topLeft:
            newFrame.origin.x += translation.x
            newFrame.origin.y += translation.y
            newFrame.size.width -= translation.x
            newFrame.size.height -= translation.y
            
        case .topCenter:
            newFrame.origin.y += translation.y
            newFrame.size.height -= translation.y
            
        case .topRight:
            newFrame.origin.y += translation.y
            newFrame.size.width += translation.x
            newFrame.size.height -= translation.y
            
        case .centerLeft:
            newFrame.origin.x += translation.x
            newFrame.size.width -= translation.x
            
        case .centerRight:
            newFrame.size.width += translation.x
            
        case .bottomLeft:
            newFrame.origin.x += translation.x
            newFrame.size.width -= translation.x
            newFrame.size.height += translation.y
            
        case .bottomCenter:
            newFrame.size.height += translation.y
            
        case .bottomRight:
            newFrame.size.width += translation.x
            newFrame.size.height += translation.y
        }
        
        // Ensure minimum size
        newFrame.size.width = max(newFrame.size.width, 50)
        newFrame.size.height = max(newFrame.size.height, 30)
        
        return newFrame
    }
}