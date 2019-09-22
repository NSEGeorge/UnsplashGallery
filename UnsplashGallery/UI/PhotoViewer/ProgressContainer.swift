//
//  ProgressContainer.swift
//  UnsplashGallery
//
//  Created by Georgij Emelyanov on 21/09/2019.
//  Copyright © 2019 Georgij Emelyanov. All rights reserved.
//

import UIKit


final class ProgressContainer: UIView {

    var photosCount: Int = 0 {
        didSet {
            self.subviews.forEach { $0.removeFromSuperview() }
            pvArray.removeAll()
            createProgressors()
            layoutIfNeeded()
        }
    }
    
    private var pvArray: [ProgressView] = []
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor = UIColor.clear
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func start(with index: Int, duration: TimeInterval, completion: @escaping ProgressViewCompletion) {
        guard let pv = pvArray[safe: index] else { return }
        pv.start(with: duration, completion: completion)
    }
    
    func reset(at index: Int) {
        guard let pv = pvArray[safe: index] else { return }
        pv.reset()
    }
    
    func pause(at index: Int) {
        guard let pv = pvArray[safe: index] else { return }
        pv.pause()
    }
    
    func resume(at index: Int) {
        guard let pv = pvArray[safe: index] else { return }
        pv.resume()
    }
    
    private func createProgressors() {
        let padding: CGFloat = 4
        
        for index in 0..<photosCount {
            let width: CGFloat
            if photosCount == 1 {
                width = self.bounds.width
            } else {
                let p = padding * CGFloat(photosCount - 1)
                let w = self.bounds.width - p
                width = w / CGFloat(photosCount)
            }
            
            let pv: ProgressView
            
            if index == 0 {
                pv = ProgressView(frame: CGRect(x: 0, y: 0, width: width, height: self.bounds.height))
            } else {
                let prevPV = pvArray[index-1]
                pv = ProgressView(frame: CGRect(x: prevPV.frame.maxX + padding, y: 0, width: width, height: self.bounds.height))
            }
            
            pv.index = index
            self.addSubview(applyProperties(pv, alpha:0.2))
            pvArray.append(pv)
        }
    }
}

extension ProgressContainer {
    private func applyProperties<T: UIView>(_ view: T, alpha: CGFloat = 1.0) -> T {
        view.layer.cornerRadius = 2
        view.layer.masksToBounds = true
        view.backgroundColor = UIColor.white.withAlphaComponent(alpha)
        return view
    }
}
