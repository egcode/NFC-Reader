//
//  TagInfoVC.swift
//  NFC-Reader
//
//  Created by Golovanov, Eugene on 10/19/17.
//  Copyright © 2017 Golovanov, Eugene. All rights reserved.
//

import UIKit
import CoreNFC

class TagInfoVC: UIViewController {
    
    var internalTagData = [(title: String, value: String)]()
    
    lazy var countries: [String] = {
        var names = [String]()
        let current = NSLocale(localeIdentifier: "en_US")
        for code in NSLocale.isoCountryCodes {
            let id = NSLocale.localeIdentifier(fromComponents: [NSLocale.Key.countryCode.rawValue: code])
            let name = current.displayName(forKey: NSLocale.Key.identifier, value: id)
            if let country = name {
                names.append(country)
            }
        }
        return names
    }()

    
    @IBOutlet weak var table: UITableView!
    private var nfcSession: NFCNDEFReaderSession!

    override func viewDidLoad() {
        super.viewDidLoad()

        self.navigationController?.navigationBar.prefersLargeTitles = true

    }

    
    @IBAction func onScanButton(_ sender: ScanButton) {
        self.nfcSession = NFCNDEFReaderSession(delegate: self,
                                               queue: DispatchQueue(label: "ndefQueue", attributes: .concurrent), invalidateAfterFirstRead: true)
        self.nfcSession.alertMessage = "Bla bla, Put your NFC TAG over iPhone.."
        self.nfcSession.begin()
    }
    
    func tagDataChanged(tagID: String, tagTechnology: String, tagType: String) {
        self.internalTagData.removeAll()
        if tagID != "" {
            self.internalTagData.append((title: "UID", value: tagID.uppercased()))
        }
        if tagTechnology != "" {
            self.internalTagData.append((title: "Technology", value: tagTechnology.uppercased()))
        }
        if tagType != "" {
            self.internalTagData.append((title: "Type", value: tagType.uppercased()))
        }
        DispatchQueue.main.async {
            self.table.reloadData()
        }
    }
}




extension TagInfoVC: UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.internalTagData.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        let tuple = self.internalTagData[indexPath.row]
        cell.textLabel?.text = tuple.title
        cell.detailTextLabel?.text = tuple.value
        return cell
    }
    
}

extension TagInfoVC: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 24
    }
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        if section == 0 && internalTagData.count > 0 {
            let view = UIView(frame: CGRect(x:0, y:0, width:tableView.frame.size.width, height:18))
            let label = UILabel(frame: CGRect(x:10, y:5, width:tableView.frame.size.width, height:18))
            label.font = UIFont.systemFont(ofSize: 14)
            label.text = "Tag Info";
            view.addSubview(label);
            view.backgroundColor = UIColor.clear;
            return view
        }
        return nil
    }

    
}

