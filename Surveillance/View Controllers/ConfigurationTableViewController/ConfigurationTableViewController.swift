//
//  ConfigurationTableViewController.swift
//  Surveillance
//
//  Created by Robert Dougan on 01/11/2018.
//  Copyright © 2018 Robert Dougan. All rights reserved.
//

import UIKit

class ConfigurationTableViewController: UITableViewController {
    
    private var urlTextFieldCell: TextFieldTableViewCell?
    private var apiKeyTextFieldCell: TextFieldTableViewCell?
    
    @IBAction func done(_ sender: Any) {
        guard let url = self.urlTextFieldCell?.textField.text else {
            return
        }
        
        guard let apiKey = self.apiKeyTextFieldCell?.textField.text else {
            return
        }
        
        NVR.shared.url = URL(string: url)
        NVR.shared.apiKey = apiKey
        
        do {
            try NVR.shared.getCameras()
            
            self.dismiss(animated: true, completion: nil)
        } catch {
            
        }
    }

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 2
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "TextFieldCell", for: indexPath)
        
        if let textFieldCell = cell as? TextFieldTableViewCell {
            if (indexPath.row == 0) {
                self.urlTextFieldCell = textFieldCell
            }
            else if (indexPath.row == 1) {
                self.apiKeyTextFieldCell = textFieldCell
            }
            
            textFieldCell.label.text = indexPath.row == 0 ? "NVR URL" : "NVR API Key"
            textFieldCell.textField.placeholder = indexPath.row == 0 ? "http://192.168.1.68:7080" : "y44q3Y2LScOVGEh5l9I8uhCcgX2UGK4r"
            textFieldCell.textField.text = indexPath.row == 0 ? NVR.shared.url?.absoluteString : NVR.shared.apiKey
        }
        
        return cell
    }

}

