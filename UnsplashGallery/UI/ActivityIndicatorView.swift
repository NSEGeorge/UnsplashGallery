//
//  ActivityIndicatorView.swift
//  UnsplashGallery
//
//  Created by Georgij Emelyanov on 22/09/2019.
//  Copyright © 2019 Georgij Emelyanov. All rights reserved.
//

import UIKit

final class ActivityIndicatorView: UIView {
    private let lineWidth: CGFloat
    private let color: UIColor
    
    private var trackLayer: CAShapeLayer!
    private func createTrackLayer() -> CAShapeLayer {
        let layer = CAShapeLayer()
        layer.fillColor = UIColor.clear.cgColor
        layer.strokeColor = UIColor(white: 1.0, alpha: 0.2).cgColor
        layer.lineWidth = self.lineWidth
        
        layer.frame = self.layer.bounds.insetBy(dx: 4, dy: 4)
        layer.path = UIBezierPath(ovalIn: layer.bounds).cgPath
        return layer
    }
    
    private var progressLayer: CAShapeLayer!
    private func createProgressLayer() -> CAShapeLayer {
        let layer: CAShapeLayer = CAShapeLayer()
        let path: UIBezierPath = UIBezierPath()
        
        path.addArc(withCenter: bounds.boundsCenter,
                    radius: trackLayer.frame.width / 2,
                    startAngle: -(.pi / 2),
                    endAngle: .pi + .pi / 2,
                    clockwise: true)
        layer.fillColor = nil
        layer.strokeColor = self.color.cgColor
        layer.lineWidth = lineWidth
        
        layer.backgroundColor = nil
        layer.path = path.cgPath
        layer.frame = CGRect(x: 0, y: 0, width: self.bounds.width, height: self.bounds.height)
        
        return layer
    }
    
    @objc
    init(frame: CGRect, lineWidth: CGFloat, color: UIColor) {
        self.lineWidth = lineWidth
        self.color = color
        super.init(frame: frame)
        
        self.layer.backgroundColor = UIColor.clear.cgColor
        
        self.trackLayer = createTrackLayer()

        self.progressLayer = createProgressLayer()
        
        layer.addSublayer(self.trackLayer)
        layer.addSublayer(self.progressLayer)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    @objc
    func startAnimation() {
        let beginTime: Double = 0.5
        let strokeStartDuration: Double = 1.2
        let strokeEndDuration: Double = 0.7
        
        let rotationAnimation = CABasicAnimation(keyPath: "transform.rotation")
        rotationAnimation.byValue = Float.pi * 2
        rotationAnimation.timingFunction = CAMediaTimingFunction(name: .linear)
        
        let strokeEndAnimation = CABasicAnimation(keyPath: "strokeEnd")
        strokeEndAnimation.duration = strokeEndDuration
        strokeEndAnimation.timingFunction = CAMediaTimingFunction(controlPoints: 0.4, 0.0, 0.2, 1.0)
        strokeEndAnimation.fromValue = 0
        strokeEndAnimation.toValue = 1
        
        let strokeStartAnimation = CABasicAnimation(keyPath: "strokeStart")
        strokeStartAnimation.duration = strokeStartDuration
        strokeStartAnimation.timingFunction = CAMediaTimingFunction(controlPoints: 0.4, 0.0, 0.2, 1.0)
        strokeStartAnimation.fromValue = 0
        strokeStartAnimation.toValue = 1
        strokeStartAnimation.beginTime = beginTime
        
        let groupAnimation = CAAnimationGroup()
        groupAnimation.animations = [rotationAnimation, strokeEndAnimation, strokeStartAnimation]
        groupAnimation.duration = strokeStartDuration + beginTime
        groupAnimation.repeatCount = .infinity
        groupAnimation.isRemovedOnCompletion = false
        groupAnimation.fillMode = .forwards
        
        self.progressLayer.add(groupAnimation, forKey: "animation")
    }
    
    @objc
    func stopAnimation() {
        self.progressLayer.removeAnimation(forKey: "animation")
    }
}

private extension CGRect {
    var boundsCenter: CGPoint {
        return CGPoint(x: width / 2, y: height / 2)
    }
}
