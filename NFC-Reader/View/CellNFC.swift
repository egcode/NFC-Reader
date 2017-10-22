//
//  CellNFC.swift
//  NFC-Reader
//
//  Created by Golovanov, Eugene on 10/20/17.
//  Copyright © 2017 Golovanov, Eugene. All rights reserved.
//

import UIKit
import MapKit

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
            let tgrText = UITapGestureRecognizer(target: self, action: #selector(self.tapText(_:)))
            self.labelDetail.isUserInteractionEnabled = true
            self.labelDetail.addGestureRecognizer(tgrText)
            self.detailText = detail
        } else if section.payloadActionType == .url && title == RecordNDEF.payload.rawValue {
            self.labelDetail.textColor = UIColor.blue
            let tgrUrl = UITapGestureRecognizer(target: self, action: #selector(self.tapUrl(_:)))
            self.labelDetail.isUserInteractionEnabled = true
            self.labelDetail.addGestureRecognizer(tgrUrl)
            self.detailText = detail
        }
    }
    
    // MARK: - Gesutes tap
    
    @objc func tapText(_ sender: UITapGestureRecognizer) {
        self.delegate?.didTapOnTextSegue(text: self.detailText)
    }

    @objc func tapUrl(_ sender: UITapGestureRecognizer) {
//        self.delegate?.didTapOnTextSegue(text: self.detailText)
        if self.detailText.contains("geo:") {
            let allGeoString = self.detailText.replacingOccurrences(of: "geo:", with: "")
            let coords = allGeoString.components(separatedBy: ",")
            if let latString = coords.first, let lat = Double(latString), let longString = coords.last, let long = Double(longString) {
                self.openMapForPlace(lat: lat, long: long)
            } else {
                print("Error extracting coordinates")
            }
        } else if self.detailText.contains("http"), let url = URL(string: self.detailText) {
            UIApplication.shared.open(url, options: [:], completionHandler: { (completed) in
            })
        }
    }
    
    // MARK: - opent coords
    
    
    func openMapForPlace(lat: Double, long: Double) {
//        let latitude: CLLocationDegrees = 37.2
//        let longitude: CLLocationDegrees = 22.9
        let latitude: CLLocationDegrees = lat
        let longitude: CLLocationDegrees = long
        
        let regionDistance:CLLocationDistance = 10000
        let coordinates = CLLocationCoordinate2DMake(latitude, longitude)
        let regionSpan = MKCoordinateRegionMakeWithDistance(coordinates, regionDistance, regionDistance)
        let options = [
            MKLaunchOptionsMapCenterKey: NSValue(mkCoordinate: regionSpan.center),
            MKLaunchOptionsMapSpanKey: NSValue(mkCoordinateSpan: regionSpan.span)
        ]
        let placemark = MKPlacemark(coordinate: coordinates, addressDictionary: nil)
        let mapItem = MKMapItem(placemark: placemark)
        mapItem.name = "Place Name"
        mapItem.openInMaps(launchOptions: options)
    }


}
