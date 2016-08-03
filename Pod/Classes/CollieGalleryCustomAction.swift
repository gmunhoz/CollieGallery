//
//  CollieGalleryCustomAction.swift
//  Pods
//
//  Created by Guilherme Munhoz on 5/11/16.
//
//

import UIKit

/// Class used to create a custom action in the activity controller
public class CollieGalleryCustomAction: UIActivity {
    private var customActivityType = ""
    private var activityName = ""
    private var activityImageName = ""
    private var customActionWhenTapped:( (Void)-> Void)!
    
    /**
     
        Default initializer to create a custom action

        - Parameters:
            - title: The title
            - imageName: The image that will be displayed with the action
            - performAction: The action that should be performed when tapped

    */
    public init(title: String, imageName: String, performAction: (() -> ()) ) {
        self.activityName = title
        self.activityImageName = imageName
        self.customActivityType = "Action \(title)"
        self.customActionWhenTapped = performAction
        super.init()
    }
    
    override public func activityType() -> String? {
        return customActivityType
    }
    
    override public func activityTitle() -> String? {
        return activityName
    }
    
    override public func activityImage() -> UIImage? {
        return UIImage(named: activityImageName)
    }
    
    override public func canPerformWithActivityItems(activityItems: [AnyObject]) -> Bool {
        return true
    }
    
    override public func prepareWithActivityItems(activityItems: [AnyObject]) {
        // nothing to prepare
    }
    
    override public func activityViewController() -> UIViewController? {
        return nil
    }
    
    override public func performActivity() {
        customActionWhenTapped()
    }
}
