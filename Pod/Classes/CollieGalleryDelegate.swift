//
//  CollieGalleryDelegate.swift
//  Pods
//
//  Created by Guilherme Munhoz on 5/11/16.
//
//

import UIKit

@objc public protocol CollieGalleryDelegate: class {
    optional func gallery(gallery: CollieGallery, indexChangedTo index: Int)
}
