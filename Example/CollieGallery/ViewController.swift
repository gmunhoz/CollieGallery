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

    @IBAction func showWithLocalImagesTapped(_ sender: UIButton) {
        var pictures = [CollieGalleryPicture]()
        
        for i in 1 ..< 5 {
            let image = UIImage(named: "\(i).jpg")!
    
            let picture = CollieGalleryPicture(image: image, title: "", caption: "")
            pictures.append(picture)
        }

        let gallery = CollieGallery(pictures: pictures)
        gallery.delegate = self
        
        gallery.presentInViewController(self)
    }
    
    @IBAction func showWithRemoteImagesTapped(_ sender: UIButton) {
        var pictures = [CollieGalleryPicture]()

        for i in 1 ..< 5 {
            let url = "http://gmunhoz.com/public/controls/CollieGallery/images/\(i).jpg"
            let picture = CollieGalleryPicture(url: url, placeholder: nil, title: "Remote Image \(i)", caption: "Lorem ipsum dolor sit amet, consectetur adipiscing elit. Fusce ultricies felis id eros commodo interdum. Curabitur ornare semper aliquet. Curabitur sit amet est condimentum, scelerisque turpis vitae, tempus nulla. Nulla facilisi. Sed faucibus dictum elit, vitae tempus felis luctus eu. Ut in lacus ante. Duis egestas mauris in lacus gravida aliquet.")
            pictures.append(picture)
        }
        
        let gallery = CollieGallery(pictures: pictures)
        gallery.presentInViewController(self)
    }
    
    @IBAction func showWithCustomButton(_ sender: UIButton) {
        var pictures = [CollieGalleryPicture]()
        
        for i in 1 ..< 5 {
            let image = UIImage(named: "\(i).jpg")!
            
            let picture = CollieGalleryPicture(image: image)
            pictures.append(picture)
            
        }
        
        let options = CollieGalleryOptions()
        
        let customAction = CollieGalleryCustomAction(title: "Custom Action", imageName: "settings") { () -> () in
            
            print("Custom Action Tapped!")
        }
        
        options.customActions = [customAction]
        options.excludedActions = [UIActivityType.assignToContact, UIActivityType.copyToPasteboard, UIActivityType.print]
        
        let gallery = CollieGallery(pictures: pictures, options: options)
        gallery.delegate = self
        
        gallery.presentInViewController(self)
    }
    
    @IBAction func showFromImageTapped(_ sender: UIButton) {
        var pictures = [CollieGalleryPicture]()
        
        for i in 1 ..< 5 {
            let image = UIImage(named: "\(i).jpg")!
            let picture = CollieGalleryPicture(image: image)
            pictures.append(picture)
        }
        
        let options = CollieGalleryOptions()
        options.customOptionsBlock = { [weak self] in
            let alert = UIAlertController(title: "Hey",
                                          message: "Custom handle block",
                                          preferredStyle: .alert)
            let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: { _ in})
            alert.addAction(cancelAction)
            self?.presentedViewController?.present(alert, animated: true) {}
        }
        
        let gallery = CollieGallery(pictures: pictures, options: options)
        gallery.presentInViewController(self, transitionType: CollieGalleryTransitionType.zoom(fromView: sender, zoomTransitionDelegate: self))
    }
    
    func zoomTransitionContainerBounds() -> CGRect {
       return self.view.frame
    }
    
    func zoomTransitionViewToDismissForIndex(_ index: Int) -> UIView? {
        return self.imageButton
    }
    
    func gallery(_ gallery: CollieGallery, indexChangedTo index: Int) {
        print("Index changed to: \(index)")
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

}

