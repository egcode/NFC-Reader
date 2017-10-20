//
//  TagInfoVC+TableView.swift
//  NFC-Reader
//
//  Created by Golovanov, Eugene on 10/20/17.
//  Copyright © 2017 Golovanov, Eugene. All rights reserved.
//

import UIKit

extension TagInfoVC: UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        if self.internalTagData.isEmpty && self.ndefSections.isEmpty {
            self.table.backgroundView = self.emptyMessage(tableView: self.table)
            return 0
        } else {
            self.table.backgroundView = UIView()
            return 1 + self.ndefSections.count
        }
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 0 {
            return self.internalTagData.count
        } else {
            return self.ndefSections[section-1].sectionData.count
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.section == 0 {
            let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
            let tuple = self.internalTagData[indexPath.row]
            cell.textLabel?.text = tuple.title
            cell.detailTextLabel?.text = tuple.value
            return cell
        } else {
            guard let cell = tableView.dequeueReusableCell(withIdentifier: "cellNFC", for: indexPath) as? CellNFC else {
                print("CellNFC error")
                return UITableViewCell()
            }
            let section = self.ndefSections[indexPath.section-1]
            let tuple = section.sectionData[indexPath.row]
            cell.configureCell(title: tuple.title, detail: tuple.value, section: section)
            cell.delegate = self
            return cell
        }
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
        label.textColor = UIColor.lightGray
        view.addSubview(label);
        view.backgroundColor = UIColor.clear;
        if section == 0 && internalTagData.count > 0 {
            label.text = "Tag Info";
            return view
        } else if section >= 0 && ndefSections.count > 0 {
            label.text = "NDEF Record \(section)";
            return view
        }
        return nil
    }
}

extension TagInfoVC {
    func emptyMessage(tableView: UITableView) -> UIView {
        let bgView = UIView(frame: CGRect(x:0,y:0,width:self.view.bounds.size.width, height:self.view.bounds.size.height))
        bgView.backgroundColor = UIColor.clear
        
        let centerLabel = UILabel(frame: CGRect(x:0,y:self.view.bounds.size.width/2,width:self.view.bounds.size.width, height:50))
        centerLabel.text = "No Tag Scanned yet"
        centerLabel.textColor = UIColor.black
        centerLabel.numberOfLines = 0;
        centerLabel.textAlignment = .center;
        centerLabel.font = UIFont.systemFont(ofSize: 20, weight: .bold)
        centerLabel.backgroundColor = UIColor.clear
        bgView.addSubview(centerLabel)
        
        let vOffset: CGFloat = 50
        let imageSize: CGFloat = 120
        
        let detailLabel = UILabel(frame: CGRect(x:0,y:self.view.bounds.size.width/2+vOffset,width:self.view.bounds.size.width, height:50))
        detailLabel.text = "Tap big 'scan' button \nto scan NFC NDEF Tag"
        detailLabel.textColor = UIColor.darkGray
        detailLabel.numberOfLines = 0;
        detailLabel.textAlignment = .center;
        detailLabel.font = UIFont.systemFont(ofSize: 15, weight: .light)
        detailLabel.backgroundColor = UIColor.clear
        bgView.addSubview(detailLabel)

        let imageView = UIImageView(frame: CGRect(x:self.view.bounds.size.width/2-imageSize/2,y:self.view.bounds.size.width/2-vOffset-imageSize/3,width:imageSize, height:imageSize))
        imageView.image = UIImage(named: "tag")
        imageView.autoresizingMask = [.flexibleWidth, .flexibleHeight, .flexibleBottomMargin, .flexibleRightMargin, .flexibleLeftMargin, .flexibleTopMargin]
        imageView.contentMode = .scaleAspectFit // OR .scaleAspectFill
        imageView.clipsToBounds = true
        imageView.backgroundColor = UIColor.clear
        bgView.addSubview(imageView)
        
        return bgView
    }
}


