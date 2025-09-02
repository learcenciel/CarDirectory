//
//  SelectionView.swift
//  CarDirectory
//
//  Created by Assistant on 2025-09-02.
//

import UIKit

protocol SelectionViewDelegate: AnyObject {
    func selectionViewDidBeginUpdating(_ view: SelectionView)
    func selectionView(_ view: SelectionView, didChangeLeft leftX: CGFloat, right rightX: CGFloat)
    func selectionViewDidEndUpdating(_ view: SelectionView)
}

/// A horizontal selection overlay with draggable grips on the left and right.
/// Designed to emulate range selection similar to audio/tab scrubbing UIs.
final class SelectionView: UIView {

    weak var delegate: SelectionViewDelegate?

    /// Left edge x position in the view's bounds coordinates
    var leftPositionX: CGFloat { didSet { setNeedsLayout() } }
    /// Right edge x position in the view's bounds coordinates
    var rightPositionX: CGFloat { didSet { setNeedsLayout() } }

    /// Whether to show a centered arrow indicator above the selection.
    var showsArrow: Bool = false { didSet { arrowView.isHidden = !showsArrow } }

    private let dimmingView = UIView()
    private let selectionFillView = UIView()
    private let leftGrip = SelectionGripView(edge: .left)
    private let rightGrip = SelectionGripView(edge: .right)
    private let arrowView = ArrowIndicatorView()

    private var activeDrag: DragState?

    private struct DragState {
        enum Target { case left, right, center }
        let target: Target
        let initialLeft: CGFloat
        let initialRight: CGFloat
        let startPoint: CGPoint
    }

    // MARK: Init
    override init(frame: CGRect) {
        self.leftPositionX = 32.0
        self.rightPositionX = 160.0
        super.init(frame: frame)
        commonInit()
    }

    required init?(coder: NSCoder) {
        self.leftPositionX = 32.0
        self.rightPositionX = 160.0
        super.init(coder: coder)
        commonInit()
    }

    private func commonInit() {
        isOpaque = false
        clipsToBounds = false

        dimmingView.backgroundColor = UIColor.black.withAlphaComponent(0.1)
        selectionFillView.backgroundColor = UIColor.systemGreen.withAlphaComponent(0.15)
        selectionFillView.layer.borderColor = UIColor.systemGreen.cgColor
        selectionFillView.layer.borderWidth = 2
        selectionFillView.layer.cornerRadius = 6
        selectionFillView.layer.masksToBounds = true

        addSubview(dimmingView)
        addSubview(selectionFillView)
        addSubview(leftGrip)
        addSubview(rightGrip)
        addSubview(arrowView)

        // Gestures
        let leftPan = UIPanGestureRecognizer(target: self, action: #selector(handlePan(_:)))
        leftGrip.addGestureRecognizer(leftPan)
        let rightPan = UIPanGestureRecognizer(target: self, action: #selector(handlePan(_:)))
        rightGrip.addGestureRecognizer(rightPan)
        let centerPan = UIPanGestureRecognizer(target: self, action: #selector(handlePan(_:)))
        selectionFillView.addGestureRecognizer(centerPan)
    }

    // MARK: Layout
    override func layoutSubviews() {
        super.layoutSubviews()

        dimmingView.frame = bounds

        let minX = max(0, min(leftPositionX, bounds.width - 1))
        let maxX = max(minX + 1, min(rightPositionX, bounds.width))

        let selectionRect = CGRect(x: minX, y: 0, width: maxX - minX, height: bounds.height)
        selectionFillView.frame = selectionRect.insetBy(dx: 0, dy: bounds.height * 0.25)

        let gripSize = CGSize(width: 22, height: selectionFillView.bounds.height + 12)
        leftGrip.frame = CGRect(
            x: selectionFillView.frame.minX - gripSize.width / 2,
            y: selectionFillView.frame.midY - gripSize.height / 2,
            width: gripSize.width,
            height: gripSize.height
        )
        rightGrip.frame = CGRect(
            x: selectionFillView.frame.maxX - gripSize.width / 2,
            y: selectionFillView.frame.midY - gripSize.height / 2,
            width: gripSize.width,
            height: gripSize.height
        )

        arrowView.sizeToFit()
        arrowView.center = CGPoint(x: selectionFillView.frame.midX, y: selectionFillView.frame.minY - arrowView.bounds.height / 2 - 6)

        // Update dimming to exclude selection area
        applyDimmingMask(excluding: selectionFillView.frame)
    }

    private func applyDimmingMask(excluding rect: CGRect) {
        let path = UIBezierPath(rect: bounds)
        let cutoutPath = UIBezierPath(roundedRect: rect, cornerRadius: selectionFillView.layer.cornerRadius)
        path.append(cutoutPath)
        path.usesEvenOddFillRule = true

        let shape = CAShapeLayer()
        shape.path = path.cgPath
        shape.fillRule = .evenOdd
        dimmingView.layer.mask = shape
    }

    // MARK: Gestures
    @objc private func handlePan(_ recognizer: UIPanGestureRecognizer) {
        let location = recognizer.location(in: self)

        switch recognizer.state {
        case .began:
            if recognizer.view === leftGrip {
                activeDrag = DragState(target: .left, initialLeft: leftPositionX, initialRight: rightPositionX, startPoint: location)
            } else if recognizer.view === rightGrip {
                activeDrag = DragState(target: .right, initialLeft: leftPositionX, initialRight: rightPositionX, startPoint: location)
            } else {
                activeDrag = DragState(target: .center, initialLeft: leftPositionX, initialRight: rightPositionX, startPoint: location)
            }
            delegate?.selectionViewDidBeginUpdating(self)

        case .changed:
            guard let drag = activeDrag else { return }
            let deltaX = location.x - drag.startPoint.x

            let minimumWidth: CGFloat = 24

            switch drag.target {
            case .left:
                leftPositionX = max(0, min(drag.initialLeft + deltaX, rightPositionX - minimumWidth))
            case .right:
                rightPositionX = min(bounds.width, max(drag.initialRight + deltaX, leftPositionX + minimumWidth))
            case .center:
                let width = drag.initialRight - drag.initialLeft
                var newLeft = drag.initialLeft + deltaX
                newLeft = max(0, min(newLeft, bounds.width - width))
                leftPositionX = newLeft
                rightPositionX = newLeft + width
            }
            setNeedsLayout()
            layoutIfNeeded()
            delegate?.selectionView(self, didChangeLeft: leftPositionX, right: rightPositionX)

        default:
            activeDrag = nil
            delegate?.selectionViewDidEndUpdating(self)
        }
    }
}

// MARK: - Grip View
final class SelectionGripView: UIView {

    enum Edge { case left, right }
    private let edge: Edge

    init(edge: Edge) {
        self.edge = edge
        super.init(frame: .zero)
        commonInit()
    }

    required init?(coder: NSCoder) {
        self.edge = .left
        super.init(coder: coder)
        commonInit()
    }

    private func commonInit() {
        backgroundColor = .clear
        isUserInteractionEnabled = true
    }

    override func draw(_ rect: CGRect) {
        let path = UIBezierPath(roundedRect: bounds, cornerRadius: 8)
        UIColor.systemGreen.setFill()
        path.fill()

        // draw three grabber lines
        let grabberColor = UIColor.white.withAlphaComponent(0.9)
        grabberColor.setStroke()
        let inset: CGFloat = 6
        let spacing: CGFloat = 4
        let startX: CGFloat
        if edge == .left {
            startX = bounds.midX - spacing
        } else {
            startX = bounds.midX - spacing
        }
        for i in 0..<3 {
            let x = startX + CGFloat(i) * spacing
            let line = UIBezierPath()
            line.move(to: CGPoint(x: x, y: bounds.minY + inset))
            line.addLine(to: CGPoint(x: x, y: bounds.maxY - inset))
            line.lineWidth = 1.5
            line.stroke()
        }
    }
}

// MARK: - Arrow Indicator
final class ArrowIndicatorView: UIView {
    override init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor = .clear
        isUserInteractionEnabled = false
    }
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        backgroundColor = .clear
        isUserInteractionEnabled = false
    }

    override var intrinsicContentSize: CGSize { CGSize(width: 20, height: 10) }

    override func draw(_ rect: CGRect) {
        let path = UIBezierPath()
        path.move(to: CGPoint(x: rect.midX, y: rect.maxY))
        path.addLine(to: CGPoint(x: rect.maxX, y: rect.minY))
        path.addLine(to: CGPoint(x: rect.minX, y: rect.minY))
        path.close()
        UIColor.systemGreen.setFill()
        path.fill()
    }
}

