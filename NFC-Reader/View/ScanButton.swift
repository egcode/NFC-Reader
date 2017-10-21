//
//  ScanButton.swift
//  NFC-Reader
//
//  Created by Golovanov, Eugene on 10/19/17.
//  Copyright © 2017 Golovanov, Eugene. All rights reserved.
//

import UIKit
@IBDesignable
class ScanButton: UIButton {
    
    override func awakeFromNib() {
        self.configure()
    }
    
    override func prepareForInterfaceBuilder() {
        super.prepareForInterfaceBuilder()
        configure()
    }

    func configure() {
        self.layer.masksToBounds = false
        self.layer.cornerRadius = 10.0
        
//        self.backgroundColor = UIColor(red: 47/255, green: 189/255, blue: 119/255, alpha: 1.0)
        self.setTitleColor(UIColor.white, for: UIControlState.normal)
//        self.layer.shadowColor = UIColor.black.cgColor
//        self.layer.shadowRadius = 2
//        self.layer.shadowOpacity = 0.6
//        self.layer.shadowOffset = CGSize(width: 0, height: 2)

    }
}

