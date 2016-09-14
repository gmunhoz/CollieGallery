//
//  CollieGalleryPicture.swift
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

/// Class used to represent a picture in the gallery
open class CollieGalleryPicture: NSObject {
    
    // MARK: - Internal properties
    internal var image: UIImage!
    internal var url: String!
    internal var placeholder: UIImage?
    internal var title: String?
    internal var caption: String?
    
    
    // MARK: - Initializers
    
    /**
     
        Initializer that takes an image object

        - Parameters:
            - image: The image
            - title: An optional title to the image
            - caption: An optional caption to describe the image
     
    */
    public convenience init(image: UIImage, title: String? = nil, caption: String? = nil) {
        self.init()
        self.image = image
        self.title = title
        self.caption = caption
    }
    
    /**
     
        Initializer that takes a string url of a remote image

        - Parameters:
            - url: The remote url
            - placeholder: An optional placeholder image
            - title: An optional title to the image
            - caption: An optional caption to describe the image
     
    */
    public convenience init(url: String, placeholder: UIImage? = nil, title: String? = nil, caption: String? = nil) {
        self.init()
        self.url = url
        self.placeholder = placeholder
        self.title = title
        self.caption = caption
    }
}
