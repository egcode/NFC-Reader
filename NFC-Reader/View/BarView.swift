//
//  BarView.swift
//  NFC-Reader
//
//  Created by Golovanov, Eugene on 10/20/17.
//  Copyright © 2017 Golovanov, Eugene. All rights reserved.
//

import UIKit
@IBDesignable
class BarView: UIView {
    override func awakeFromNib() {
        self.configure()
    }
    override func prepareForInterfaceBuilder() {
        super.prepareForInterfaceBuilder()
        configure()
    }
    func configure() {
        self.layer.shadowColor = UIColor.black.cgColor
        self.layer.shadowRadius = 1
        self.layer.shadowOpacity = 0.3
        self.layer.shadowOffset = CGSize(width: 0, height: -2)
    }
}


