//
//  CollieGalleryCustomAction.swift
//  Pods
//
//  Created by Guilherme Munhoz on 5/11/16.
//
//

import UIKit

/// Class used to create a custom action in the activity controller
open class CollieGalleryCustomAction: UIActivity {
    fileprivate var customActivityType = ""
    fileprivate var activityName = ""
    fileprivate var activityImageName = ""
    fileprivate var customActionWhenTapped:( ()-> Void)!
    
    /**
     
        Default initializer to create a custom action

        - Parameters:
            - title: The title
            - imageName: The image that will be displayed with the action
            - performAction: The action that should be performed when tapped

    */
    public init(title: String, imageName: String, performAction: @escaping (() -> ()) ) {
        self.activityName = title
        self.activityImageName = imageName
        self.customActivityType = "Action \(title)"
        self.customActionWhenTapped = performAction
        super.init()
    }
    
    override open var activityType : UIActivity.ActivityType? {
        return UIActivity.ActivityType(rawValue: customActivityType)
    }
    
    override open var activityTitle : String? {
        return activityName
    }
    
    override open var activityImage : UIImage? {
        return UIImage(named: activityImageName)
    }
    
    override open func canPerform(withActivityItems activityItems: [Any]) -> Bool {
        return true
    }
    
    override open func prepare(withActivityItems activityItems: [Any]) {
        // nothing to prepare
    }
    
    override open var activityViewController : UIViewController? {
        return nil
    }
    
    override open func perform() {
        customActionWhenTapped()
    }
}
