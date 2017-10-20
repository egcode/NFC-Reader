//
//  CellNFC.swift
//  NFC-Reader
//
//  Created by Golovanov, Eugene on 10/20/17.
//  Copyright © 2017 Golovanov, Eugene. All rights reserved.
//

import UIKit

class CellNFC: UITableViewCell {

    @IBOutlet weak var labelTitle: UILabel!
    @IBOutlet weak var labelDetail: UILabel!
    
    var delegate: CellTapDelegate?
    private var detailText: String = ""
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func configureCell(title: String, detail: String, section: NdefSection, action: (()->())? = nil) {
        self.labelTitle.text = title
        self.labelDetail.text = detail
        
        if section.payloadActionType == .text && title == RecordNDEF.payload.rawValue {
            self.accessoryType = .disclosureIndicator
            let tgr = UITapGestureRecognizer(target: self, action: #selector(self.tapText(_:)))
            self.labelDetail.isUserInteractionEnabled = true
            self.labelDetail.addGestureRecognizer(tgr)
            self.detailText = detail
        } else if section.payloadActionType == .url && title == RecordNDEF.payload.rawValue {
            self.labelDetail.textColor = UIColor.blue
        }
    }
    
    @objc func tapText(_ sender: UITapGestureRecognizer) {
        self.delegate?.didTapOnTextSegue(text: self.detailText)
    }


}
