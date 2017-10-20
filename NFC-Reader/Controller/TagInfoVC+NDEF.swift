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
        print("-->didDetectNDEFs: \(messages)")
        self.getInternalTagData(session: session)//////////
        var resultString = ""
        for message in messages {
            for record in message.records {
                print(record.payload)
                
                resultString += "---\n"
                resultString += "Payload: \(String(describing: String.init(data: record.payload, encoding: .utf8)!))\n"
                resultString += "Type: \(String(describing: String.init(data: record.type, encoding: .utf8)!))\n" //U - url,sms,phone,location, T - text, android.com:pkg - android app,
                resultString += "Identifier: \(record.identifier)\n"
                resultString += "TypeNameFormat: \(self.getTypeNameFormatString(format: record.typeNameFormat))"
                print(resultString)
                resultString += "\n---"

            }
        }
        DispatchQueue.main.async {
            self.alert(title: "Tag read success", msg: resultString)
        }
    }
    
    
    // MARK: - Helpers
    
    func getInternalTagData(session: NFCNDEFReaderSession) {
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
            return "NfcExternal"
        case .unknown:
            return "Unknown"
        case .unchanged:
            return "Unchanged"
        }
    }

}
