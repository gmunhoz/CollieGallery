//
//  CollieGalleryTheme.swift
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

public enum CollieGalleryTheme {
    case Custom(appearance: CollieGalleryAppearance)
    case Dark
    case Light
    
    internal var backgroundColor: UIColor {
        switch self {
        case .Custom(let appearance):
            return appearance.backgroundColor
        case .Dark:
            return UIColor.blackColor()
        case .Light:
            return UIColor.whiteColor()
        }
    }
    
    internal var progressBarColor: UIColor {
        switch self {
        case .Custom(let appearance):
            return appearance.progressBarColor
        case .Dark:
            return UIColor.whiteColor()
        case .Light:
            return UIColor.blackColor()
        }
    }
    
    internal var closeButtonColor: UIColor {
        switch self {
        case .Custom(let appearance):
            return appearance.closeButtonColor
        case .Dark:
            return UIColor.whiteColor()
        case .Light:
            return UIColor.blackColor()
        }
    }
    
    internal var progressIndicatorColor: UIColor {
        switch self {
        case .Custom(let appearance):
            return appearance.activityIndicatorColor
        case .Dark:
            return UIColor.whiteColor()
        case .Light:
            return UIColor.blackColor()
        }
    }
    
    /// The default theme for all new instances of the gallery
    public static var defaultTheme = CollieGalleryTheme.Custom(appearance: CollieGalleryAppearance.sharedAppearance)
}
