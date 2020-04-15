//
//  LocateVehicleViewController.swift
//  LocEightV_1
//
//  Created by Michelle Grover on 4/14/20.
//  Copyright © 2020 Norbert Grover. All rights reserved.
//

import UIKit

class LocateVehicleViewController: UIViewController {
    
    var delegate:CenterViewControllerDelegate?

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    
    @IBAction func menuButtonAction(_ sender: Any) {
       
        delegate?.toggleLeftPanel()
    }
    
   

}
