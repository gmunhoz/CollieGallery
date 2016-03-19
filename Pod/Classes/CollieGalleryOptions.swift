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

public class CollieGalleryOptions: NSObject {
    
    /// Shared options between all new instances of the gallery
    public static var sharedOptions = CollieGalleryOptions()
    
    /// The amount of the parallax effect from 0 to 1
    public var parallaxFactor: CGFloat = 0.2
    
    /// Indicates weather the pictures can be zoomed or not
    public var enableZoom: Bool = true
    
    /// The maximum scale that images can reach when zoomed
    public var maximumZoomScale: CGFloat = 5.0
    
    /// Indicates weather the progress should be displayed or not
    public var showProgress: Bool = true
    
    /// The amount of pictures that should be preloaded next to the current displayed picture
    public var preLoadedImages: Int = 3
    
    /// The space between each scrollview's page
    public var gapBetweenPages: CGFloat = 10.0
    
    /// Indicates if the user should be able to save the picture
    public var enableSave: Bool = true
    
    /// Indicates if the user should be able to dismiss the gallery interactively with a pan gesture
    public var enableInteractiveDismiss: Bool = true
}
