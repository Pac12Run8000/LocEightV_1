//
//  ContainerViewController.swift
//  LocEightV_1
//
//  Created by Michelle Grover on 4/13/20.
//  Copyright © 2020 Norbert Grover. All rights reserved.
//

import UIKit
import QuartzCore

enum SlideOutState {
    case collapsed
    case leftPanelExpanded
}

enum ShowWhichViewController {
    case homeViewController
    case locateVehicleViewController
}




class ContainerViewController: UIViewController {
    
    var homeViewController:HomeViewController!
    var leftViewcontroller:LeftSidePanelViewController!
    var currentState:SlideOutState = .collapsed {
        didSet {
            let shouldShowShadow = (currentState != .collapsed)
            shouldShowShadowForCenterViewcontroller(shouldShowShadow)
        }
    }
    var isHidden = false
    let centerpanelExpandedOffset:CGFloat = 160
    var centerController:UIViewController!
    var tap:UITapGestureRecognizer!

    override func viewDidLoad() {
        super.viewDidLoad()
        
        initCenter(screen: .homeViewController)
        
    }
    
    func initCenter(screen:ShowWhichViewController) {
        
        if homeViewController == nil {
            homeViewController = UIStoryboard.homeViewController()
            homeViewController.delegate = self
        }

        
        if let controller = centerController {
            controller.view.removeFromSuperview()
            controller.removeFromParent()
        }
        
        
        centerController = homeViewController
        view.addSubview(centerController.view)
        addChild(centerController)
        centerController.didMove(toParent: self)
        
        
        
    }
   
    override var preferredStatusBarUpdateAnimation: UIStatusBarAnimation {
        return UIStatusBarAnimation.slide
    }
    
    override var prefersStatusBarHidden: Bool {
        return isHidden
    }

}

extension ContainerViewController:CenterViewControllerDelegate {
    func toggleLeftPanel() {
        let notAlreadyExpanded = currentState != .leftPanelExpanded
        if notAlreadyExpanded {
            addLeftPanelViewController()
        }
        animateLeftPanel(shouldExpand: notAlreadyExpanded)
    }
    
    func addLeftPanelViewController() {
        if leftViewcontroller == nil {
            leftViewcontroller = UIStoryboard.leftViewController()
            addChildSidePanelViewcontroller(leftViewcontroller)
        }
    }
    
    func addChildSidePanelViewcontroller(_ sidePanelController: LeftSidePanelViewController) {
        view.insertSubview(sidePanelController.view, at: 0)
        addChild(sidePanelController)
        sidePanelController.didMove(toParent: self)
    }
    
    @objc func animateLeftPanel(shouldExpand: Bool) {
        if shouldExpand {
            isHidden = !isHidden
            animateStatusBar()
            setupWhiteCoverView()
            animateCenterPanelXPosition(targetPosition: centerController.view.frame.width - centerpanelExpandedOffset)
            currentState = .leftPanelExpanded
        } else {
            isHidden = !isHidden
            animateStatusBar()
            hideWhiteCoverView()
            animateCenterPanelXPosition(targetPosition: 0) { (finished) in
                if finished {
                    self.currentState = .collapsed
                    self.leftViewcontroller = nil
                }
            }
        }
    }
    
    func shouldShowShadowForCenterViewcontroller(_ status:Bool) {
        if status {
            centerController.view.layer.shadowOpacity = 0.6
        } else {
            centerController.view.layer.shadowOpacity = 0.0
        }
    }
    
    func hideWhiteCoverView() {
        centerController.view.removeGestureRecognizer(tap)
        for subview in self.centerController.view.subviews {
            if subview.tag == 25 {
                UIView.animate(withDuration: 0.2, animations: {
                    subview.alpha = 0.0
                }) { (finished) in
                    subview.removeFromSuperview()
                }
            }
        }
    }
    
    func setupWhiteCoverView() {
        let whiteCoverView = UIView(frame: CGRect(x: 0, y: 0, width: view.frame.width, height: view.frame.height))
        whiteCoverView.alpha = 0.0
        whiteCoverView.backgroundColor = UIColor.white
        whiteCoverView.tag = 25
        self.centerController.view.addSubview(whiteCoverView)
        UIView.animate(withDuration: 0.2) {
            whiteCoverView.alpha = 0.75
        }
        tap = UITapGestureRecognizer(target: self, action: #selector(animateLeftPanel(shouldExpand:)))
        tap.numberOfTapsRequired = 1
        self.centerController.view.addGestureRecognizer(tap)
    }
    
    func animateStatusBar() {
        UIView.animate(withDuration: 1.0, delay: 0, usingSpringWithDamping: 0.8, initialSpringVelocity: 0, options: .curveEaseInOut, animations: {
            self.setNeedsStatusBarAppearanceUpdate()
        }, completion: nil)
    }
    
    func animateCenterPanelXPosition(targetPosition:CGFloat, completion:((Bool) -> Void)! = nil) {
        UIView.animate(withDuration: 1.0, delay: 0, usingSpringWithDamping: 0.8, initialSpringVelocity: 0, options: .curveEaseInOut, animations: {
            self.centerController.view.frame.origin.x = targetPosition
        }, completion: completion)
    }
    
    
}

// MARK:- Storyboard functionality
private extension UIStoryboard {
    
    class func mainStoryboard() -> UIStoryboard {
        
        return UIStoryboard(name: "Main", bundle: Bundle.main)
        
    }
    
    
    
    class func leftViewController() -> LeftSidePanelViewController? {
        return mainStoryboard().instantiateViewController(identifier: "LeftSidePanelViewController") as? LeftSidePanelViewController
    }
    
    class func homeViewController() -> HomeViewController? {
        return mainStoryboard().instantiateViewController(identifier: "HomeViewController") as? HomeViewController
    }
    
}
