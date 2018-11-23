//
//  CollieGalleryOptions.swift
//
//  Copyright (c) 2016 Guilherme Munhoz <g.araujo.munhoz@gmail.com>
//
//  Permission is hereby granted, free of charge, to any person obtaining a copy
//  of this software and associated documentation files (the "Software"), to deal
//  in the Software without restriction, including without limitation the rights
//  to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
//  copies of the Software, and to permit persons to whom the Software is
//  furnished to do so, subject to the following conditions:
//
//  The above copyright notice and this permission notice shall be included in
//  all copies or substantial portions of the Software.
//
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
//  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
//  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
//  OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
//  THE SOFTWARE.

import UIKit

/// Class used to customize the gallery options
open class CollieGalleryOptions: NSObject {
    
    /// Shared options between all new instances of the gallery
    public static var sharedOptions = CollieGalleryOptions()
    
    /// The amount of the parallax effect from 0 to 1
    open var parallaxFactor: CGFloat = 0.2
    
    /// Indicates weather the pictures can be zoomed or not
    open var enableZoom: Bool = true
    
    /// The maximum scale that images can reach when zoomed
    open var maximumZoomScale: CGFloat = 5.0
    
    /// Indicates weather the progress should be displayed or not
    open var showProgress: Bool = true
    
    /// Indicates weather the caption view should be displayed or not
    open var showCaptionView: Bool = false
    
    /// The amount of pictures that should be preloaded next to the current displayed picture
    open var preLoadedImages: Int = 3
    
    /// The space between each scrollview's page
    open var gapBetweenPages: CGFloat = 10.0
    
    /// Open gallery at specified page
    open var openAtIndex: Int = 0

    /// Custom close button image name
    open var customCloseImageName: String? = nil
    
    /// Custom options button image name
    open var customOptionsImageName: String? = nil
    
    /// Indicates if the user should be able to save the picture
    open var enableSave: Bool = true
    
    /// Indicates if the user should be able to dismiss the gallery interactively with a pan gesture
    open var enableInteractiveDismiss: Bool = true
    
    /// Add fire custom block instead of showing default share menu
    open var customOptionsBlock: (() -> Void)?
    
    /// Array with the custom buttons
    open var customActions: [CollieGalleryCustomAction] = []
    
    /// Default actions to exclude from the gallery actions (UIActivityType Constants)
    open var excludedActions: [UIActivity.ActivityType] = []
}
