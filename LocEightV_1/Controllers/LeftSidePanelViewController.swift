//
//  LeftSidePanelViewController.swift
//  LocEightV_1
//
//  Created by Michelle Grover on 4/13/20.
//  Copyright © 2020 Norbert Grover. All rights reserved.
//

import UIKit

class LeftSidePanelViewController: UIViewController {
    
    let appDelegate = AppDelegate.getAppDelegate()

    override func viewDidLoad() {
        super.viewDidLoad()
        
        

        // Do any additional setup after loading the view.
    }
    
    @IBAction func locateVehicleAction(_ sender: UIButton) {
        
//        appDelegate.MenuContainerVC.animateLeftPanel(shouldExpand: false)
//        appDelegate.MenuContainerVC.toggleLeftPanel()
        appDelegate.MenuContainerVC.initCenter(screen: .locateVehicleViewController)
        
        
    }
    
    

}
