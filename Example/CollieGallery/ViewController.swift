//
//  ViewController.swift
//  CollieGallery
//
//  Created by Guilherme Munhoz on 02/21/2016.
//  Copyright (c) 2016 Guilherme Munhoz. All rights reserved.
//

import UIKit
import CollieGallery

class ViewController: UIViewController, CollieGalleryZoomTransitionDelegate, CollieGalleryDelegate {
    
    @IBOutlet weak var imageButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }

    @IBAction func showWithLocalImagesTapped(sender: UIButton) {
        var pictures = [CollieGalleryPicture]()
        
        for var i = 1; i <= 5; i++ {
            let image = UIImage(named: "\(i).jpg")!
    
            let picture = CollieGalleryPicture(image: image, title: "", caption: "")
            pictures.append(picture)
            
        }

        let gallery = CollieGallery(pictures: pictures)
        gallery.delegate = self
        
        gallery.presentInViewController(self)
    }
    
    @IBAction func showWithRemoteImagesTapped(sender: UIButton) {
        var pictures = [CollieGalleryPicture]()

        for var i = 1; i <= 5; i++ {
            let url = "http://gmunhoz.com/public/controls/CollieGallery/images/\(i).jpg"
            let picture = CollieGalleryPicture(url: url, placeholder: nil, title: "Remote Image \(i)", caption: "Lorem ipsum dolor sit amet, consectetur adipiscing elit. Fusce ultricies felis id eros commodo interdum. Curabitur ornare semper aliquet. Curabitur sit amet est condimentum, scelerisque turpis vitae, tempus nulla. Nulla facilisi. Sed faucibus dictum elit, vitae tempus felis luctus eu. Ut in lacus ante. Duis egestas mauris in lacus gravida aliquet.")
            pictures.append(picture)
        }
        
        let gallery = CollieGallery(pictures: pictures)
        gallery.presentInViewController(self)
    }
    
    @IBAction func showWithCustomButton(sender: UIButton) {
        var pictures = [CollieGalleryPicture]()
        
        for var i = 1; i <= 5; i++ {
            let image = UIImage(named: "\(i).jpg")!
            
            let picture = CollieGalleryPicture(image: image)
            pictures.append(picture)
            
        }
        
        let options = CollieGalleryOptions()
        
        let customAction = CollieGalleryCustomAction(title: "Custom Action", imageName: "settings") { () -> () in
            
            print("Custom Action Tapped!")
        }
        
        options.customActions = [customAction]
        options.excludedActions = [UIActivityTypeAssignToContact, UIActivityTypeCopyToPasteboard, UIActivityTypePrint]
        
        let gallery = CollieGallery(pictures: pictures, options: options)
        gallery.delegate = self
        
        gallery.presentInViewController(self)
    }
    
    @IBAction func showFromImageTapped(sender: UIButton) {
        var pictures = [CollieGalleryPicture]()
        
        for var i = 1; i <= 5; i++ {
            let image = UIImage(named: "\(i).jpg")!
            let picture = CollieGalleryPicture(image: image)
            pictures.append(picture)
        }
        
        let gallery = CollieGallery(pictures: pictures)
        gallery.presentInViewController(self, transitionType: CollieGalleryTransitionType.Zoom(fromView: sender, zoomTransitionDelegate: self))
    }
    
    func zoomTransitionContainerBounds() -> CGRect {
       return self.view.frame
    }
    
    func zoomTransitionViewToDismissForIndex(index: Int) -> UIView? {
        return self.imageButton
    }
    
    func gallery(gallery: CollieGallery, indexChangedTo index: Int) {
        print("Index changed to: \(index)")
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

}

