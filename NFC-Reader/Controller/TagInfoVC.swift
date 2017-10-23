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
    case langCode = "Language Code"

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
            let n = insertToId(seperator: ":", afterEveryXChars: 2, intoString: tagID)
            self.internalTagData.append((title: "Serial Number", value: n.uppercased()))
        }
        if tagTechnology != "" {
            self.internalTagData.append((title: "Technology", value: tagTechnology.uppercased()))
        }
        if tagType != "" {
            self.internalTagData.append((title: "Type", value: tagType.uppercased()))
        }
    }
    
    func getTagRecordsData(payload: String, type: String, identifier: String, typeNameFormat: String, payloadAction: PayloadActionType) -> [(title: String, value: String)] {
                
        var sectionData = [(title: String, value: String)]()
        
        if type != "" {
            var t = type
            switch payloadAction {
            case .url:
                t = TypeNDEF.uri.rawValue
            case .text:
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
            if payloadAction == .text {
                let lc = self.handlePayloadData(payload: payload, type: payloadAction, langCode: true)
                if lc != "" {
                    sectionData.append((title: RecordNDEF.langCode.rawValue, value: lc))
                }
            }
            let finalPayload = self.handlePayloadData(payload: payload, type: payloadAction)
            sectionData.append((title: RecordNDEF.payload.rawValue, value: finalPayload))
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
    
    // MARK: - finalize data
    
    func handlePayloadData(payload: String, type: PayloadActionType, langCode: Bool = false) -> String {
        /*
         let geo = "\"\\0geo:47.321472,5.041382\""
         let url = "\"\\u{02}google.com\""
         */
        let nullData = "\0"
        let geo = "geo:"
        
        var result = payload
        if payload.contains(nullData) {
            result = payload.replacingOccurrences(of: nullData, with: "")
        }
        
        guard let i = payload.unicodeScalars.index(where: { $0.value <= 16 }) else {
            print("No Scalars")
            if langCode {
                return ""
            } else {
                return result
            }
        }
        let asciiPrefix = String(payload.unicodeScalars[...i])  // "\u{02}"

        if type == .url {
            if payload.contains(geo) {
                print("We've got location URI")
            } else {
                var protocolPrefix = ""
                if asciiPrefix == "\u{04}" {
                    protocolPrefix = "https://"
                } else if asciiPrefix == "\u{03}" {
                    protocolPrefix = "http://"
                }
                result = String(payload.unicodeScalars.filter({String($0) != asciiPrefix})) // Remove scalars lower than 16
                result = protocolPrefix + result
            }
        } else if type == .text {
            if asciiPrefix == "\u{02}" {
                result = String(payload.unicodeScalars.filter({ String($0) != asciiPrefix   })) // Remove scalars lower than 16
                let languageCode = String(result.prefix(2)) // en
                if langCode {   return languageCode     }
                result = String(result.dropFirst(2))        //result wigthou en
            }
        }
        if langCode {
            return ""
        } else {
            return result
        }
    }

    func insertToId(seperator: String, afterEveryXChars: Int, intoString: String) -> String {
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

