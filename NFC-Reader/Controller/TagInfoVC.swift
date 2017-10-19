//
//  TagInfoVC.swift
//  NFC-Reader
//
//  Created by Golovanov, Eugene on 10/19/17.
//  Copyright © 2017 Golovanov, Eugene. All rights reserved.
//

import UIKit

class TagInfoVC: UIViewController {

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
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.navigationController?.navigationBar.prefersLargeTitles = true

    }

    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}




extension TagInfoVC: UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.countries.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        cell.textLabel?.text = self.countries[indexPath.row]
        return cell
    }
}

extension TagInfoVC: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
    }
}

