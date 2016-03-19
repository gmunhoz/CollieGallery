//
//  CollieGallery.swift
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

public class CollieGallery: UIViewController, UIScrollViewDelegate, CollieGalleryViewDelegate {
    
    // MARK: - Private properties
    private let transitionManager = CollieGalleryTransitionManager()
    private var options = CollieGalleryOptions()
    private var theme = CollieGalleryTheme.Dark
    private var pictures: [CollieGalleryPicture] = []
    private var pictureViews: [CollieGalleryView] = []
    private var currentPageIndex: Int = 0
    private var isShowingLandscapeView: Bool {
        let orientation = UIApplication.sharedApplication().statusBarOrientation
        
        switch (orientation) {
        case UIInterfaceOrientation.LandscapeLeft, UIInterfaceOrientation.LandscapeRight:
            return true
        default:
            return false
        }
    }
    private var isShowingActionControls: Bool {
        get {
            return !self.closeButton.hidden
        }
    }
    private var displayedView: CollieGalleryView {
        get {
            return self.pictureViews[self.currentPageIndex]
        }
    }
    private var displayedImageView: UIImageView {
        get {
            return self.displayedView.imageView
        }
    }
    
    
    // MARK: - Public properties
    public var pagingScrollView: UIScrollView!
    public var closeButton: UIButton!
    public var actionButton: UIButton?
    public var progressTrackView: UIView?
    public var progressBarView: UIView?

    
    // MARK: - Initializers
    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    public override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: NSBundle?) {
        super.init(nibName: nil, bundle: nil)
    }
    
    public convenience init(pictures: [CollieGalleryPicture], options: CollieGalleryOptions? = nil, theme: CollieGalleryTheme? = nil) {
        self.init(nibName: nil, bundle: nil)
        self.pictures = pictures
        
        self.options = (options != nil) ? options! : CollieGalleryOptions.sharedOptions
        self.theme = (theme != nil) ? theme! : CollieGalleryTheme.defaultTheme
    }
    
    
    // MARK: - UIViewController functions
    public override func viewDidLoad() {
        super.viewDidLoad()
        self.setupView()
    }
    
    public override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        self.clearImagesFarFromIndex(self.currentPageIndex)
    }
    
    override public func prefersStatusBarHidden() -> Bool {
        return true
    }
    
    public override func viewWillTransitionToSize(size: CGSize, withTransitionCoordinator coordinator: UIViewControllerTransitionCoordinator) {
        super.viewWillTransitionToSize(size, withTransitionCoordinator: coordinator)
        
        coordinator.animateAlongsideTransition({ (context: UIViewControllerTransitionCoordinatorContext) -> Void in
            self.updateView(size)
            }, completion: nil)
    }
    
    
    // MARK: - Private functions
    private func setupView() {
        self.view.backgroundColor = self.theme.backgroundColor
        
        self.setupScrollView()
        self.setupPictures()
        self.setupCloseButton()
        
        if self.options.enableSave {
            self.setupActionButton()
        }
        
        if self.options.showProgress {
            self.setupProgressIndicator()
        }
        
        self.loadImagesNextToIndex(self.currentPageIndex)
    }
    
    private func setupScrollView() {
        let avaiableSize = self.getInitialAvaiableSize()
        let scrollFrame = self.getScrollViewFrame(avaiableSize)
        let contentSize = self.getScrollViewContentSize(scrollFrame)
        
        self.pagingScrollView = UIScrollView(frame: scrollFrame)
        self.pagingScrollView.delegate = self
        self.pagingScrollView.pagingEnabled = true
        self.pagingScrollView.showsHorizontalScrollIndicator = false
        self.pagingScrollView.backgroundColor = UIColor.clearColor()
        self.pagingScrollView.contentSize = contentSize
        
        self.view.addSubview(self.pagingScrollView)
    }
    
    private func setupPictures() {
        let avaiableSize = self.getInitialAvaiableSize()
        let scrollFrame = self.getScrollViewFrame(avaiableSize)
        
        for var i = 0; i < pictures.count; i++ {
            let picture = pictures[i]
            let pictureFrame = self.getPictureFrame(scrollFrame, pictureIndex: i)
            let pictureView = CollieGalleryView(picture: picture, frame: pictureFrame, options: self.options, theme: self.theme)
            pictureView.delegate = self
            
            self.pagingScrollView.addSubview(pictureView)
            self.pictureViews.append(pictureView)
        }
    }
    
    private func setupCloseButton() {
        if self.closeButton != nil {
            self.closeButton.removeFromSuperview()
        }
        
        let avaiableSize = self.getInitialAvaiableSize()
        let closeButtonFrame = self.getCloseButtonFrame(avaiableSize)
        
        self.closeButton = UIButton(frame: closeButtonFrame)
        self.closeButton.setTitle("+", forState: .Normal)
        self.closeButton.titleLabel!.font = UIFont(name: "HelveticaNeue-Medium", size: 30)
        self.closeButton.setTitleColor(self.theme.closeButtonColor, forState: UIControlState.Normal)
        self.closeButton.transform = CGAffineTransformMakeRotation(CGFloat(M_PI_4))
        self.closeButton.addTarget(self, action: "closeButtonTouched:", forControlEvents: .TouchUpInside)
        self.view.addSubview(self.closeButton)
    }
    
    private func setupActionButton() {
        if let actionButton = self.actionButton {
            actionButton.removeFromSuperview()
        }
        
        let avaiableSize = self.getInitialAvaiableSize()
        let closeButtonFrame = self.getActionButtonFrame(avaiableSize)
        
        let actionButton = UIButton(frame: closeButtonFrame)
        actionButton.setTitle("•••", forState: .Normal)
        actionButton.titleLabel!.font = UIFont(name: "HelveticaNeue-Thin", size: 15)
        actionButton.setTitleColor(self.theme.closeButtonColor, forState: UIControlState.Normal)
        actionButton.addTarget(self, action: "actionButtonTouched:", forControlEvents: .TouchUpInside)
        self.actionButton = actionButton
        
        self.view.addSubview(actionButton)
    }
    
    private func setupProgressIndicator() {
        let avaiableSize = self.getInitialAvaiableSize()
        let progressFrame = self.getProgressViewFrame(avaiableSize)
        let progressBarFrame = self.getProgressInnerViewFrame(progressFrame)

        let progressTrackView = UIView(frame: progressFrame)
        progressTrackView.backgroundColor = UIColor(white: 0.6, alpha: 0.2)
        progressTrackView.clipsToBounds = true
        self.progressTrackView = progressTrackView
        
        let progressBarView = UIView(frame: progressBarFrame)
        progressBarView.backgroundColor = self.theme.progressBarColor
        progressBarView.clipsToBounds = true
        self.progressBarView = progressBarView
        
        progressTrackView.addSubview(progressBarView)
        
        if let progressTrackView = self.progressTrackView {
            self.view.addSubview(progressTrackView)
        }
    }
    
    private func updateView(avaiableSize: CGSize) {
        self.pagingScrollView.frame = self.getScrollViewFrame(avaiableSize)
        self.pagingScrollView.contentSize = self.getScrollViewContentSize(self.pagingScrollView.frame)
        
        for var i = 0; i < self.pictureViews.count; i++ {
            let innerView = self.pictureViews[i]
            innerView.frame = self.getPictureFrame(self.pagingScrollView.frame, pictureIndex: i)
        }
        
        if let progressTrackView = self.progressTrackView {
            progressTrackView.frame = self.getProgressViewFrame(avaiableSize)
        }
        
        self.setupCloseButton()
        self.setupActionButton()
        self.updateContentOffset()
    }
    
    private func loadImagesNextToIndex(index: Int) {
        self.pictureViews[index].loadImage()
        
        let imagesToLoad = self.options.preLoadedImages
        
        for var i = 1; i <= imagesToLoad; i++ {
            let previousIndex = index - i
            let nextIndex = index + i
            
            if previousIndex >= 0 {
                self.pictureViews[previousIndex].loadImage()
            }
            
            if nextIndex < self.pictureViews.count {
                self.pictureViews[nextIndex].loadImage()
            }
        }
    }
    
    private func clearImagesFarFromIndex(index: Int) {
        let imagesToLoad = self.options.preLoadedImages
        let firstIndex = max(index - imagesToLoad, 0)
        let lastIndex = min(index + imagesToLoad, self.pictureViews.count - 1)
        
        var imagesCleared = 0
        
        for var i = 0; i < self.pictureViews.count; i++ {
            if i < firstIndex || i > lastIndex {
                self.pictureViews[i].clearImage()
                imagesCleared++
            }
        }
        
        print("\(imagesCleared) images cleared.")
    }
    
    private func updateContentOffset() {
        self.pagingScrollView.setContentOffset(CGPointMake(self.pagingScrollView.frame.size.width * CGFloat(self.currentPageIndex), 0), animated: false)
    }
    
    private func getInitialAvaiableSize() -> CGSize {
        return self.view.bounds.size
    }
    
    private func getScrollViewFrame(avaiableSize: CGSize) -> CGRect {
        let x: CGFloat = -self.options.gapBetweenPages
        let y: CGFloat = 0.0
        let width: CGFloat = avaiableSize.width + self.options.gapBetweenPages
        let height: CGFloat = avaiableSize.height
        
        return CGRectMake(x, y, width, height)
    }
    
    private func getScrollViewContentSize(scrollFrame: CGRect) -> CGSize {
        let width = scrollFrame.size.width * CGFloat(pictures.count)
        let height = scrollFrame.size.height
        
        return CGSizeMake(width, height)
    }
    
    private func getPictureFrame(scrollFrame: CGRect, pictureIndex: Int) -> CGRect {
        let x: CGFloat = ((scrollFrame.size.width) * CGFloat(pictureIndex)) + self.options.gapBetweenPages
        let y: CGFloat = 0.0
        let width: CGFloat = scrollFrame.size.width - (1 * self.options.gapBetweenPages)
        let height: CGFloat = scrollFrame.size.height
        
        return CGRectMake(x, y, width, height)
    }
    
    private func toggleControlsVisibility() {
        if self.isShowingActionControls {
            self.hideControls()
        } else {
            self.showControls()
        }
    }
    
    private func showControls() {
        self.closeButton.hidden = false
        self.actionButton?.hidden = false
        self.progressTrackView?.hidden = false
        
        UIView.animateWithDuration(0.2, delay: 0.0, options: UIViewAnimationOptions.CurveEaseInOut, animations: { () -> Void in
            self.closeButton.alpha = 1.0
            self.actionButton?.alpha = 1.0
            self.progressTrackView?.alpha = 1.0
            
            }, completion: nil)
    }
    
    private func hideControls() {
        UIView.animateWithDuration(0.2, delay: 0.0, options: UIViewAnimationOptions.CurveEaseInOut, animations: { () -> Void in
            self.closeButton.alpha = 0.0
            self.actionButton?.alpha = 0.0
            self.progressTrackView?.alpha = 0.0
            
            }, completion: { (finished: Bool) -> Void in
                self.closeButton.hidden = true
                self.actionButton?.hidden = true
                self.progressTrackView?.hidden = true
        })
    }
    
    private func getProgressViewFrame(avaiableSize: CGSize) -> CGRect {
        return CGRectMake(0.0, avaiableSize.height - 2, avaiableSize.width, 2)
    }
    
    private func getProgressInnerViewFrame(progressFrame: CGRect) -> CGRect {
        return CGRectMake(0, 0, 0, progressFrame.size.height)
    }
    
    private func getCloseButtonFrame(avaiableSize: CGSize) -> CGRect {
        return CGRectMake(0, 0, 50, 50)
    }
    
    private func getActionButtonFrame(avaiableSize: CGSize) -> CGRect {
        return CGRectMake(avaiableSize.width - 50, 0, 50, 50)
    }
    
    
    // MARK: - Internal functions
    internal func closeButtonTouched(sender: AnyObject) {
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    internal func actionButtonTouched(sender: AnyObject) {
        self.showActionsMenu()
    }
    
    internal func showActionsMenu() {
        let optionMenu = UIAlertController(title: nil, message: "Choose Option", preferredStyle: .ActionSheet)
        
        let saveAction = UIAlertAction(title: "Save", style: .Default, handler: {
            (alert: UIAlertAction!) -> Void in
            
            self.savePicture()
        })
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .Cancel, handler: {
            (alert: UIAlertAction!) -> Void in
            print("Cancelled")
        })
        
        optionMenu.addAction(saveAction)
        optionMenu.addAction(cancelAction)
        
        self.presentViewController(optionMenu, animated: true, completion: nil)
    }
    
    internal func savePicture() {
        let imageView = self.pictureViews[self.currentPageIndex].imageView
        
        if let image = imageView.image {
            UIImageWriteToSavedPhotosAlbum(image, self, "image:didFinishSavingWithError:contextInfo:", nil)
        }
    }
    
    internal func image(image: UIImage, didFinishSavingWithError error: NSError?, contextInfo:UnsafePointer<Void>) {
        if error == nil {
            let ac = UIAlertController(title: "Saved!", message: "Your altered image has been saved to your photos.", preferredStyle: .Alert)
            ac.addAction(UIAlertAction(title: "OK", style: .Default, handler: nil))
            presentViewController(ac, animated: true, completion: nil)
        } else {
            let ac = UIAlertController(title: "Save error", message: error?.localizedDescription, preferredStyle: .Alert)
            ac.addAction(UIAlertAction(title: "OK", style: .Default, handler: nil))
            presentViewController(ac, animated: true, completion: nil)
        }
    }
    
    
    // MARK: - UIScrollView delegate
    public func scrollViewDidScroll(scrollView: UIScrollView) {
        for var i = 0; i < pictureViews.count; i++ {
            pictureViews[i].scrollView.contentOffset = CGPointMake((scrollView.contentOffset.x - pictureViews[i].frame.origin.x + self.options.gapBetweenPages) * -self.options.parallaxFactor, 0)
        }

        if let progressBarView = self.progressBarView, progressTrackView = self.progressTrackView {
            let maxProgress = progressTrackView.frame.size.width * CGFloat(self.pictures.count - 1)
            let currentGap = CGFloat(self.currentPageIndex) * self.options.gapBetweenPages
            let offset = scrollView.contentOffset.x - currentGap
            let progress = (maxProgress - (maxProgress - offset)) / CGFloat(self.pictures.count - 1)
            progressBarView.frame.size.width = max(progress, 0)
        }
    }
    
    public func scrollViewDidEndDecelerating(scrollView: UIScrollView) {
        let page = Int(scrollView.contentOffset.x / scrollView.frame.size.width)
        currentPageIndex = page
        self.loadImagesNextToIndex(self.currentPageIndex)
        self.displayedImageView
    }

    
    // MARK: - CollieGalleryView delegate
    func galleryViewTapped(scrollview: CollieGalleryView) {
        let scrollView = self.pictureViews[self.currentPageIndex].scrollView
        
        if scrollView.zoomScale == scrollView.minimumZoomScale {
            self.toggleControlsVisibility()
            
        }
    }
    
    func galleryViewPressed(scrollview: CollieGalleryView) {
        if self.options.enableSave {
            self.showActionsMenu()
        }
    }
    
    func galleryViewDidRestoreZoom(galleryView: CollieGalleryView) {
        self.showControls()
    }
    
    func galleryViewDidZoomIn(galleryView: CollieGalleryView) {
        self.hideControls()
    }
    
    func galleryViewDidEnableScroll(galleryView: CollieGalleryView) {
        self.pagingScrollView.scrollEnabled = false
    }
    
    func galleryViewDidDisableScroll(galleryView: CollieGalleryView) {
        self.pagingScrollView.scrollEnabled = true
    }
    
    
    // MARK: - Public functions
    public func scrollToIndex(index: Int) {
        self.currentPageIndex = index
        self.loadImagesNextToIndex(self.currentPageIndex)
        self.pagingScrollView.setContentOffset(CGPointMake(self.pagingScrollView.frame.size.width * CGFloat(index), 0), animated: true)
    }
    
    public func presentInViewController(sourceViewController: UIViewController, transitionType: CollieGalleryTransitionType? = nil) {
        
        let type = transitionType == nil ? CollieGalleryTransitionType.defaultType : transitionType!
        
        self.transitionManager.enableInteractiveTransition = self.options.enableInteractiveDismiss
        self.transitionManager.transitionType = type
        self.transitionManager.sourceViewController = sourceViewController
        self.transitionManager.targetViewController = self
        
        self.modalPresentationStyle = UIModalPresentationStyle.OverCurrentContext
        self.transitioningDelegate = self.transitionManager
        
        sourceViewController.presentViewController(self, animated: type.animated, completion: nil)
    }
}
