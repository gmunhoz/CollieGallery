//
//  ViewController.swift
//  CollieGallery
//
//  Created by Guilherme Munhoz on 02/21/2016.
//  Copyright (c) 2016 Guilherme Munhoz. All rights reserved.
//

import UIKit
import CollieGallery

class ViewController: UIViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }

    @IBAction func showWithLocalImagesTapped(sender: UIButton) {
        var pictures = [CollieGalleryPicture]()
        
        for var i = 1; i <= 5; i++ {
            let image = UIImage(named: "\(i).jpg")!
            let picture = CollieGalleryPicture(image: image)
            pictures.append(picture)
        }

        let gallery = CollieGallery(pictures: pictures)
        gallery.presentInViewController(self)
    }
    
    @IBAction func showWithRemoteImagesTapped(sender: UIButton) {
        var pictures = [CollieGalleryPicture]()

        for var i = 1; i <= 8; i++ {
            let url = "http://lorempixel.com/640/480/nature/\(i)/"
            let picture = CollieGalleryPicture(url: url)
            pictures.append(picture)
        }
        
        let gallery = CollieGallery(pictures: pictures)
        gallery.presentInViewController(self)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

}

