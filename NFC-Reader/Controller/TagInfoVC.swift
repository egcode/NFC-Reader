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
    
    struct NdefSection {
        var sectionData = [(title: String, value: String)]()
    }
    var internalTagData = [(title: String, value: String)]()
    var recordSections = [NdefSection]()
    
    @IBOutlet weak var table: UITableView!
    private var nfcSession: NFCNDEFReaderSession!
    var timer:Timer?

    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationController?.navigationBar.prefersLargeTitles = true
    }
    
    // MARK: -
    @IBAction func onScanButton(_ sender: ScanButton) {
        self.nfcSession = NFCNDEFReaderSession(delegate: self,
                                               queue: DispatchQueue(label: "ndefQueue", attributes: .concurrent), invalidateAfterFirstRead: true)
        self.nfcSession.alertMessage = "Bla bla, Put your NFC TAG over iPhone.."
        self.nfcSession.begin()
        self.timer = Timer.scheduledTimer(timeInterval: 50.0, target: self, selector: #selector(self.timerFunc), userInfo: nil, repeats: false)
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
    }
    
    //MARK: - Timer
    
    @objc func timerFunc() {
        self.nfcSession.invalidate()
        self.alert(title: "", msg: "Scanner could not detect any tags")
    }
}

extension TagInfoVC: UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1 + self.recordSections.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 0 {
            return self.internalTagData.count
        } else {
            return self.recordSections[section-1].sectionData.count
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        if indexPath.section == 0 {
            let tuple = self.internalTagData[indexPath.row]
            cell.textLabel?.text = tuple.title
            cell.detailTextLabel?.text = tuple.value
        } else {
            let tuple = self.recordSections[indexPath.section-1].sectionData[indexPath.row]
            cell.textLabel?.text = tuple.title
            cell.detailTextLabel?.text = tuple.value
        }
        
        return cell
    }
}

extension TagInfoVC: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 24
    }
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let view = UIView(frame: CGRect(x:0, y:0, width:tableView.frame.size.width, height:18))
        let label = UILabel(frame: CGRect(x:10, y:5, width:tableView.frame.size.width, height:18))
        label.font = UIFont.systemFont(ofSize: 14)
        view.addSubview(label);
        view.backgroundColor = UIColor.clear;
        if section == 0 && internalTagData.count > 0 {
            label.text = "Tag Info";
        } else if section >= 0 {
            label.text = "NDEF Record \(section)";
        }
        return view
    }
    
}

