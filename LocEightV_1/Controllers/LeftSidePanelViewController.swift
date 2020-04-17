//
//  LeftSidePanelViewController.swift
//  LocEightV_1
//
//  Created by Michelle Grover on 4/13/20.
//  Copyright © 2020 Norbert Grover. All rights reserved.
//

import UIKit

class LeftSidePanelViewController: UIViewController {
    
    let appdelegate = AppDelegate.getAppDelegate()
    var menu:MenuFunction?
    

    override func viewDidLoad() {
        super.viewDidLoad()

        
    }
    
    @IBAction func locateVehicleAction(_ sender: Any) {
        appdelegate.MenuContainerVC.configureHomeViewControllerForLocation(.locate_vehicle)
    }
    
    @IBAction func parkingGarageAction(_ sender: Any) {
        appdelegate.MenuContainerVC.configureHomeViewControllerForLocation(.find_parking_garage)
    }
    
    @IBAction func placesToEatAction(_ sender: Any) {
        appdelegate.MenuContainerVC.configureHomeViewControllerForLocation(.find_eating_places)
    }
    
    @IBAction func placesToShopAction(_ sender: Any) {
        appdelegate.MenuContainerVC.configureHomeViewControllerForLocation(.find_shopping_places)
    }
    
    
    

}
