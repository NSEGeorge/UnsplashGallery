//
//  ProgressView.swift
//  UnsplashGallery
//
//  Created by Georgij Emelyanov on 21/09/2019.
//  Copyright © 2019 Georgij Emelyanov. All rights reserved.
//

import UIKit

typealias ProgressViewCompletion = ((_ index: Int) -> Void)

final class ProgressView: UIView {
    var index: Int = 0
    
    private var completionHandler: ProgressViewCompletion!
    
    fileprivate var progressLayer: CALayer!
    private func createProgressLayer(frame: CGRect) -> CALayer {
        let layer: CALayer = CALayer()
        layer.anchorPoint = CGPoint(x: 0, y: 0.5)
        layer.frame = frame
        layer.cornerRadius = frame.height / 2
        layer.backgroundColor = UIColor(white: 1.0, alpha: 1.0).cgColor
        return layer
    }

    override init(frame: CGRect) {
        super.init(frame: frame)
        progressLayer = createProgressLayer(frame: CGRect(x: 0, y: 0, width: 0, height: frame.height))
        layer.addSublayer(progressLayer)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func start(with duration: TimeInterval, completion: @escaping ProgressViewCompletion) {
        self.completionHandler = completion
        let finalBounds: CGRect = CGRect(x: progressLayer.bounds.origin.x, y: progressLayer.bounds.origin.y, width: self.bounds.width, height: progressLayer.bounds.height)
        
        let animation: CABasicAnimation = CABasicAnimation(keyPath: "bounds")
        animation.delegate = self
        animation.fromValue = CGRect(x: progressLayer.bounds.origin.x, y: progressLayer.bounds.origin.y, width: 0, height: progressLayer.bounds.height)
        animation.toValue = finalBounds
        animation.duration = duration
        animation.timingFunction = CAMediaTimingFunction(name: .linear)
        animation.setValue(Configuration.AnimationNameValue, forKey: Configuration.AnimationNameKey)
        
        progressLayer.bounds = finalBounds
        progressLayer.add(animation, forKey: Configuration.ProgressAnimationKey)
    }
    
    func resume() {
        let pausedTime = progressLayer.timeOffset
        progressLayer.speed = 1.0
        progressLayer.timeOffset = 0.0
        progressLayer.beginTime = 0.0
        let timeSincePause: Double = progressLayer.convertTime(CACurrentMediaTime(), from: nil) - pausedTime
        progressLayer.beginTime = timeSincePause
    }
    
    func pause() {
        let pausedTime = layer.convertTime(CACurrentMediaTime(), from: nil)
        progressLayer.speed = 0.0
        progressLayer.timeOffset = pausedTime
    }
    
    func reset() {
        progressLayer.removeAnimation(forKey: Configuration.ProgressAnimationKey)
        clearProgress()
    }
    
    private func clearProgress() {
        CALayer.performWithoutAnimation {
            self.progressLayer.bounds = CGRect(x: progressLayer.bounds.origin.x, y: progressLayer.bounds.origin.y, width: 0, height: progressLayer.bounds.height)
        }
    }
}

extension ProgressView: CAAnimationDelegate {
    func animationDidStop(_ anim: CAAnimation, finished flag: Bool) {
        guard let name = anim.value(forKey: Configuration.AnimationNameKey) as? String,
            name == Configuration.AnimationNameValue,
            flag
        else { return }
        
        completionHandler(index)
    }
}

extension ProgressView {
    private struct Configuration {
        static let AnimationNameKey: String = "Name"
        static let AnimationNameValue: String = "ProgressAnimation"
        static let ProgressAnimationKey: String = "ProgressAnimationKey"
    }
}
