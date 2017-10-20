//
//  TagInfoVC+Text.swift
//  NFC-Reader
//
//  Created by Golovanov, Eugene on 10/20/17.
//  Copyright © 2017 Golovanov, Eugene. All rights reserved.
//

import UIKit

protocol CellTapDelegate {
    func didTapOnTextSegue(text: String)
}

extension TagInfoVC: CellTapDelegate {
    func didTapOnTextSegue(text: String) {
        self.performSegue(withIdentifier: "textSegue", sender: text)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "textSegue", let vc = segue.destination as? TextViewerVC, let senderText = sender as? String {
            vc.text = senderText
        }
    }
}
