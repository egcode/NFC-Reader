//
//  TagInfoVC.swift
//  NFC-Reader
//
//  Created by Golovanov, Eugene on 10/19/17.
//  Copyright © 2017 Golovanov, Eugene. All rights reserved.
//

import UIKit
import CoreNFC

enum RecordNDEF : String {
    case type = "Type"
    case payload = "Payload"
    case id = "ID"
    case typeName = "Type Name"
}

enum TypeNDEF : String {
    case uri = "URI"
    case text = "Text"
}

enum PayloadActionType {
    case none
    case url
    case geo
    case text
}

struct NdefSection {
    var sectionData: [(title: String, value: String)]
    var payloadActionType: PayloadActionType
}

class TagInfoVC: UIViewController {
    
    
    var internalTagData = [(title: String, value: String)]()
    var ndefSections = [NdefSection]()
    
    @IBOutlet weak var table: UITableView!
    private var nfcSession: NFCNDEFReaderSession!
    var timer:Timer?

    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationController?.navigationBar.prefersLargeTitles = true
    }
    
    // MARK: -
    @IBAction func onScanButton(_ sender: ScanButton) {
        
        switch UIDevice().type {
        case .iPhone5, .iPhone5S, .iPhone4, .iPhone4S, .iPhone6, .iPhone6S, .iPhone6Splus, .simulator:
            self.alert(title: "Warning", msg: "Device does not support NFC reading feature")
            break
        default:
            
            self.nfcSession = NFCNDEFReaderSession(delegate: self,
                                                   queue: DispatchQueue(label: "ndefQueue", attributes: .concurrent), invalidateAfterFirstRead: true)
            self.nfcSession.alertMessage = "Put your NFC TAG over iPhone.."
            self.nfcSession.begin()
            self.timer = Timer.scheduledTimer(timeInterval: 50.0, target: self, selector: #selector(self.timerFunc), userInfo: nil, repeats: false)
        }
    }
    
    // MARK: - Data Parsing
    
    func tagDataChanged(tagID: String, tagTechnology: String, tagType: String) {
        self.internalTagData.removeAll()
        if tagID != "" {
            let n = insert(seperator: ":", afterEveryXChars: 2, intoString: tagID)
            self.internalTagData.append((title: "Serial Number", value: n.uppercased()))
        }
        if tagTechnology != "" {
            self.internalTagData.append((title: "Technology", value: tagTechnology.uppercased()))
        }
        if tagType != "" {
            self.internalTagData.append((title: "Type", value: tagType.uppercased()))
        }
    }
    
    func getTagRecordsData(payload: String, type: String, identifier: String, typeNameFormat: String) -> [(title: String, value: String)] {
        
        var sectionData = [(title: String, value: String)]()
        
        if type != "" {
            var t = type
            switch t {
            case "U":
                t = TypeNDEF.uri.rawValue
            case "T":
                t = TypeNDEF.text.rawValue
            default:
                break
            }
            sectionData.append((title: RecordNDEF.type.rawValue, value: t))
        }
        if identifier != "" {
            sectionData.append((title: RecordNDEF.id.rawValue, value: identifier))
        }
        if typeNameFormat != "" {
            sectionData.append((title: RecordNDEF.typeName.rawValue, value: typeNameFormat))
        }
        if payload != "" {
            sectionData.append((title: RecordNDEF.payload.rawValue, value: payload.replacingOccurrences(of: "\0", with: "")))
        }
        return sectionData
    }
    
    func getTypeNameFormatString(format: NFCTypeNameFormat) -> String {
        switch format {
        case .absoluteURI:
            return "AbsoluteURI"
        case .empty:
            return "Empty"
        case .nfcWellKnown:
            return "NfcWellKnown"
        case .media:
            return "MIME(RFC 2046)"
        case .nfcExternal:
            return "Nfc External"
        case .unknown:
            return "Unknown"
        case .unchanged:
            return "Unchanged"
        }
    }
    
    func insert(seperator: String, afterEveryXChars: Int, intoString: String) -> String {
        var output = ""
        intoString.enumerated().forEach { index, c in
            if index % afterEveryXChars == 0 && index > 0 {
                output += seperator
            }
            output.append(c)
        }
        return output
    }

    //MARK: - Timer
    
    @objc func timerFunc() {
        self.nfcSession.invalidate()
        self.alert(title: "", msg: "Scanner could not detect any tags")
    }
}
