//
//  TagInfoVC+NDEF.swift
//  NFC-Reader
//
//  Created by Golovanov, Eugene on 10/19/17.
//  Copyright © 2017 Golovanov, Eugene. All rights reserved.
//

import UIKit
import CoreNFC

extension TagInfoVC: NFCNDEFReaderSessionDelegate {
    func readerSession(_ session: NFCNDEFReaderSession, didInvalidateWithError error: Error) {
        print("-->didInvalidateWithError: \(error)")
    }
    
    func readerSession(_ session: NFCNDEFReaderSession, didDetectNDEFs messages: [NFCNDEFMessage]) {
        self.timer?.invalidate()
        self.getInternalTagData(session: session)//////////
        print("-->didDetectNDEFs: \(messages)")
        var resultString = ""
        
        self.ndefSections.removeAll()
        for message in messages {
            for record in message.records {
                print(record.payload)
                
                let payload = String.init(data: record.payload, encoding: .utf8)?.replacingOccurrences(of: "\0", with: "") ?? ""
                let type = String.init(data: record.type, encoding: .utf8) ?? ""
                let ident = String.init(data: record.identifier, encoding: .utf8) ?? ""
                let typeNameForm = "\(self.getTypeNameFormatString(format: record.typeNameFormat))"
                
                resultString += "---\n"
                resultString += "Payload: \(payload)\n"
                resultString += "Type: \(String(describing: String.init(data: record.type, encoding: .utf8)!))\n" //U - url,sms,phone,location, T - text, android.com:pkg - android app,
                resultString += "Identifier: \(record.identifier)\n"
                resultString += "TypeNameFormat: \(self.getTypeNameFormatString(format: record.typeNameFormat))"
                print(resultString)
                resultString += "\n---"
                
                let section = NdefSection(sectionData: self.getTagRecordsData(payload: payload, type: type, identifier: ident, typeNameFormat: typeNameForm))
                self.ndefSections.append(section)
            }
            
        }

        DispatchQueue.main.async {
            self.table.reloadData()
            self.alert(title: "Tag read success", msg: resultString)
        }
    }
    
    
    // MARK: - Helpers
    
 private  func getInternalTagData(session: NFCNDEFReaderSession) {
        if let tagsArray = session.value(forKey: "_foundTags") as? [AnyObject], let foundTag = tagsArray.first {
            print("Internal Tag Data: \(foundTag)")
            var tagID = ""
            var tagTechnology = ""
            var tagType = ""
            
            if let tagIdData = foundTag.value(forKey: "_tagID") {
                print("Raw ID : \(tagIdData)")
                tagID = String.init(describing: tagIdData).replacingOccurrences(of: " ", with: "").replacingOccurrences(of: "<", with: "").replacingOccurrences(of: ">", with: "")
            } else {
                print("Failed to get Tag ID")
            }
            
            let tagDataString = String.init(describing: foundTag)
            let arr = tagDataString.components(separatedBy: " ")
            for word in arr {
                if let range = word.range(of: "TagTech=") {
                    tagTechnology = "\(word[range.upperBound...])"
                }
                if let range = word.range(of: "Type=") {
                    tagType = "\(word[range.upperBound...])"
                }
            }
            print("\n\n<<<")
            print("tagID: \(tagID)")
            print("tagTechnology: \(tagTechnology)")
            print("tagType: \(tagType)")
            print(">>>\n\n")
            self.tagDataChanged(tagID: tagID, tagTechnology: tagTechnology, tagType: tagType)
        } else {
            print("No Internal Tag Data")
        }
    }
    
 private func getTagRecordsData(payload: String, type: String, identifier: String, typeNameFormat: String) -> [(title: String, value: String)] {
        
        var sectionData = [(title: String, value: String)]()
        
        if payload != "" {
            sectionData.append((title: "payload", value: payload))
        }
        if type != "" {
            sectionData.append((title: "Type", value: type))
        }
        if identifier != "" {
            sectionData.append((title: "Identifier", value: identifier))
        }
        if typeNameFormat != "" {
            sectionData.append((title: "TypeNameFormat", value: typeNameFormat))
        }
        return sectionData
    }

 private func getTypeNameFormatString(format: NFCTypeNameFormat) -> String {
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
            return "NfcExternal"
        case .unknown:
            return "Unknown"
        case .unchanged:
            return "Unchanged"
        }
    }
}
