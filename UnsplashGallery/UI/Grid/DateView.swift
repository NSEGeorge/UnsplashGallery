//
//  DateView.swift
//  UnsplashGallery
//
//  Created by Georgij Emelyanov on 22/09/2019.
//  Copyright © 2019 Georgij Emelyanov. All rights reserved.
//

import UIKit

class DateView: UIView {
    var date: Date? {
        didSet {
            guard let date = date else { return }
            dayLabel.text = date.day
            monthLabel.text = date.month.uppercased()
        }
    }
    
    private lazy var dayLabel: UILabel = {
        let view = UILabel()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.textAlignment = .center
        view.font = UIFont.subheadlineBoldFont
        view.textColor = UIColor.orange
        return view
    }()
    
    private lazy var monthLabel: UILabel = {
        let view = UILabel()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.textAlignment = .center
        view.font = UIFont.captionFont
        view.textColor = UIColor.lightGray
        return view
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        configureLayout()
        configureStyle()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}


private extension DateView {
    func configureLayout() {
        addSubviews([dayLabel,
                     monthLabel])
        
        NSLayoutConstraint.activate([
            dayLabel.leftAnchor.constraint(equalTo: self.leftAnchor),
            dayLabel.topAnchor.constraint(equalTo: self.topAnchor, constant: 4),
            dayLabel.rightAnchor.constraint(equalTo: self.rightAnchor),
        ])
        
        NSLayoutConstraint.activate([
            monthLabel.leftAnchor.constraint(equalTo: self.leftAnchor),
            monthLabel.topAnchor.constraint(equalTo: dayLabel.bottomAnchor),
            monthLabel.rightAnchor.constraint(equalTo: self.rightAnchor),
            monthLabel.bottomAnchor.constraint(equalTo: self.bottomAnchor, constant: -4),
        ])
    }
    
    func configureStyle() {
        self.backgroundColor = UIColor.white
        self.layer.cornerRadius = 4
        self.layer.shadowRadius = 6
        self.layer.shadowColor = UIColor(white: 0, alpha: 1).cgColor
        self.layer.shadowOpacity = 0.12
        self.layer.shadowOffset = CGSize(width: 2, height: 2)
    }
}
