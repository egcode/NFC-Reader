//
//  TextViewerVC.swift
//  NFC-Reader
//
//  Created by Golovanov, Eugene on 10/20/17.
//  Copyright © 2017 Golovanov, Eugene. All rights reserved.
//

import UIKit

class TextViewerVC: UIViewController {

    @IBOutlet weak var textView: UITextView!
    var text: String = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "NFC Text"
        self.navigationController?.navigationBar.prefersLargeTitles = true
        self.text = self.textView.text
    }

}
