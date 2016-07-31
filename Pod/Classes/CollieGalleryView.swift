//
//  CollieGalleryView.swift
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

internal class CollieGalleryView: UIView, UIScrollViewDelegate {
    
    // MARK: - Internal properties
    var delegate: CollieGalleryViewDelegate?
    var picture: CollieGalleryPicture!
    var scrollView: UIScrollView!
    var imageView: UIImageView!
    var activityIndicator: UIActivityIndicatorView!
    var isZoomed: Bool {
        get {
            return scrollView.zoomScale > scrollView.minimumZoomScale
        }
    }
    
    // MARK: - Private properties
    private var options: CollieGalleryOptions!
    private var theme: CollieGalleryTheme!
    private var scrollFrame: CGRect {
        get {
            return CGRectMake(0, 0, frame.size.width, frame.size.height)
        }
    }
    
    
    // MARK: - Initializers
    override init(frame: CGRect) {
        super.init(frame: frame)
    }

    convenience init(picture: CollieGalleryPicture, frame: CGRect,
                     options: CollieGalleryOptions, theme: CollieGalleryTheme)
    {
        self.init(frame: frame)
        
        self.picture = picture
        self.options = options
        self.theme = theme
        
        setupView()
        setupGestures()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }

    // MARK: - Private functions
    private func setupView() {
        backgroundColor = UIColor.clearColor()
        
        setupScrollView()
        setupImageView()
        setupActivityIndicatorView()
    }

    private func setupScrollView() {
        scrollView = UIScrollView(frame: scrollFrame)
        scrollView.delegate = self
        scrollView.contentSize = frame.size
        scrollView.bounces = false
        scrollView.scrollEnabled = false
        scrollView.showsVerticalScrollIndicator = false
        scrollView.showsHorizontalScrollIndicator = false
        scrollView.minimumZoomScale = 1.0
        scrollView.maximumZoomScale = options.maximumZoomScale
        scrollView.decelerationRate = UIScrollViewDecelerationRateFast
        scrollView.backgroundColor = UIColor.clearColor()
        userInteractionEnabled = options.enableZoom
        
        addSubview(scrollView)
    }
    
    private func setupImageView() {
        imageView = UIImageView(frame: scrollFrame)
        imageView.contentMode = UIViewContentMode.ScaleToFill
        imageView.backgroundColor = UIColor.clearColor()
        
        scrollView.addSubview(imageView)
    }
    
    private func setupActivityIndicatorView() {
        activityIndicator = UIActivityIndicatorView()
        activityIndicator.frame = CGRectMake(0.0, 0.0, 40.0, 40.0);
        activityIndicator.center = imageView.center
        activityIndicator.hidesWhenStopped = true
        activityIndicator.color = theme.progressIndicatorColor

        addSubview(activityIndicator)
    }

    private func setupGestures() {
        let tapRecognizer = UITapGestureRecognizer(target: self, action: "viewTapped:")
        tapRecognizer.numberOfTapsRequired = 1
        tapRecognizer.numberOfTouchesRequired = 1
        addGestureRecognizer(tapRecognizer)
        
        let doubleTapRecognizer = UITapGestureRecognizer(target: self, action: "viewDoubleTapped:")
        doubleTapRecognizer.numberOfTapsRequired = 2
        doubleTapRecognizer.numberOfTouchesRequired = 1
        addGestureRecognizer(doubleTapRecognizer)
        
        let longPressRecognizer = UILongPressGestureRecognizer(target: self, action: "viewPressed:")
        longPressRecognizer.numberOfTouchesRequired = 1
        addGestureRecognizer(longPressRecognizer)
        
        tapRecognizer.requireGestureRecognizerToFail(doubleTapRecognizer)
    }
    
    private func zoomToScale(newZoomScale: CGFloat, pointInView: CGPoint) {
        let scrollViewSize = bounds.size
        
        let width = scrollViewSize.width / newZoomScale
        let height = scrollViewSize.height / newZoomScale
        
        let x = pointInView.x - (width / 2.0)
        let y = pointInView.y - (height / 2.0)
        
        let rectToZoomTo = CGRectMake(x, y, width, height);
        
        scrollView.zoomToRect(rectToZoomTo, animated: true)
    }

    private func centerImageViewToSuperView() {
        var zoomFrame = imageView.frame
        
        if(zoomFrame.size.width < scrollView.bounds.size.width) {
            zoomFrame.origin.x = (scrollView.bounds.size.width - zoomFrame.size.width) / 2.0
            
        } else {
            zoomFrame.origin.x = 0.0
            
        }
        
        if(zoomFrame.size.height < scrollView.bounds.size.height) {
            zoomFrame.origin.y = (scrollView.bounds.size.height - zoomFrame.size.height) / 2.0
            
        } else {
            zoomFrame.origin.y = 0.0
            
        }
        
        imageView.frame = zoomFrame
        
    }
    
    private func updateImageViewSize() {
        if let image = imageView.image {
            var imageSize = CGSizeMake(image.size.width / image.scale, image.size.height / image.scale)
            
            let widthRatio = imageSize.width / bounds.size.width
            let heightRatio = imageSize.height / bounds.size.height
            let imageScaleRatio = max(widthRatio, heightRatio)
            
            imageSize = CGSizeMake(imageSize.width / imageScaleRatio, imageSize.height / imageScaleRatio)
            
            imageView.frame = CGRectMake(0.0, 0.0, imageSize.width, imageSize.height)
            
            restoreZoom(false)
            centerImageViewToSuperView()
        }
    }
    
    
    // MARK: - Internal functions
    func zoomToPoint(pointInView: CGPoint) {
        var newZoomScale = scrollView.minimumZoomScale
        
        if scrollView.zoomScale < (scrollView.maximumZoomScale / 2) {
            newZoomScale = options.maximumZoomScale
        }
        
        zoomToScale(newZoomScale, pointInView: pointInView)
    }

    func restoreZoom(animated: Bool = true) {
        if animated {
            zoomToScale(scrollView.minimumZoomScale, pointInView: CGPointZero)
        } else {
            scrollView.zoomScale = scrollView.minimumZoomScale
        }
    }
    
    func loadImage() {
        if imageView.image == nil {
            if let image = picture.image {
                imageView.image = image
                updateImageViewSize()
                
            } else if let url = picture.url {
                
                if let placeholder = picture.placeholder {
                    imageView.image = placeholder
                    updateImageViewSize()
                }
                
                activityIndicator.startAnimating()
                
                let request: NSURLRequest = NSURLRequest(URL: NSURL(string: url)!)
                let mainQueue = NSOperationQueue.mainQueue()
                NSURLConnection.sendAsynchronousRequest(request,
                                                        queue: mainQueue,
                                                        completionHandler:
                    { [weak self] response, data, error in
                    if error == nil {
                        let image = UIImage(data: data!)!
                        
                        dispatch_async(dispatch_get_main_queue(), {
                            self?.imageView.image = image
                            self?.updateImageViewSize()
                            
                            self?.activityIndicator.stopAnimating()
                        })
                    }
                })
            }
        }
    }
    
    func clearImage() {
        imageView.image = nil
    }

    
    // MARK: - UIView methods
    override func layoutSubviews() {
        scrollView.frame = scrollFrame
        scrollView.contentSize = scrollView.frame.size
        scrollView.zoomScale = scrollView.minimumZoomScale
        updateImageViewSize()
    }
    
    
    // MARK: - UIGestureRecognizer handlers
    func viewPressed(recognizer: UILongPressGestureRecognizer) {
        if (recognizer.state == UIGestureRecognizerState.Began) {
            if let delegate = delegate {
                delegate.galleryViewPressed(self)
            }
        }
    }
    
    func viewTapped(recognizer: UITapGestureRecognizer) {
        if scrollView.zoomScale > scrollView.minimumZoomScale {
            restoreZoom()
            
        }
        
        if let delegate = delegate {
            delegate.galleryViewTapped(self)
        }
    }

    func viewDoubleTapped(recognizer: UITapGestureRecognizer) {
        let pointInView = recognizer.locationInView(imageView)
        zoomToPoint(pointInView)
    }
    
    
    //  MARK: - UIScrollView delegate
    func viewForZoomingInScrollView(scrollView: UIScrollView) -> UIView? {
        return imageView
    }

    func scrollViewDidZoom(scrollView: UIScrollView) {
        if (scrollView.zoomScale > scrollView.maximumZoomScale) {
            scrollView.zoomScale = scrollView.maximumZoomScale
        }

        centerImageViewToSuperView()
    }
    
    func scrollViewDidEndZooming(scrollView: UIScrollView, withView view: UIView?, atScale scale: CGFloat) {
        if let delegate = delegate {
            if scrollView.zoomScale == scrollView.minimumZoomScale {
                delegate.galleryViewDidRestoreZoom(self)
                
            } else {
                delegate.galleryViewDidZoomIn(self)
                
            }
        }
        
        let oldState = scrollView.scrollEnabled
        
        scrollView.scrollEnabled = (scrollView.zoomScale > scrollView.minimumZoomScale)
        
        if let delegate = delegate where scrollView.scrollEnabled != oldState {
            if scrollView.scrollEnabled {
                delegate.galleryViewDidEnableScroll(self)
            } else {
                delegate.galleryViewDidDisableScroll(self)
            }
        }
    }
}
