//
//  CollieGalleryDelegate.swift
//  Pods
//
//  Created by Guilherme Munhoz on 5/11/16.
//
//

import UIKit

/// Protocol to implement the gallery
@objc public protocol CollieGalleryDelegate: class {
    
    /// Called when the gallery index changes
    optional func gallery(gallery: CollieGallery, indexChangedTo index: Int)
    
}
