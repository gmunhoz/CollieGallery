//
//  AppearanceTableViewController.swift
//  CollieGallery
//
//  Created by Guilherme Munhoz on 3/18/16.
//  Copyright © 2016 CocoaPods. All rights reserved.
//

import UIKit
import CollieGallery

class AppearanceTableViewController: UITableViewController {

    @IBOutlet weak var themeSegmentedControl: UISegmentedControl!
    @IBOutlet weak var transitionTypeSegmentedControl: UISegmentedControl!
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    @IBAction func themeChanged(sender: UISegmentedControl) {
        if sender.selectedSegmentIndex == 0 {
            CollieGalleryTheme.defaultTheme = CollieGalleryTheme.Dark
            
        } else {
            CollieGalleryTheme.defaultTheme = CollieGalleryTheme.Light
            
        }
    }
    
    @IBAction func transitionTypeChanged(sender: UISegmentedControl) {
        if sender.selectedSegmentIndex == 0 {
            CollieGalleryTransitionType.defaultType = CollieGalleryTransitionType.Default
            
        } else {
            CollieGalleryTransitionType.defaultType = CollieGalleryTransitionType.None
            
        }
    }
    
}
