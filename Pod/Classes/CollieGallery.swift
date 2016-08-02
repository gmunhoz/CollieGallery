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
    private var theme = CollieGalleryTheme.Dark
    private var pictures: [CollieGalleryPicture] = []
    private var pictureViews: [CollieGalleryView] = []
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
            return !closeButton.hidden
        }
    }
    private var activityController: UIActivityViewController!
    
    
    // MARK: - Internal properties
    internal var options = CollieGalleryOptions()
    internal var displayedView: CollieGalleryView {
        get {
            return pictureViews[currentPageIndex]
        }
    }
    
    
    // MARK: - Public properties
    public weak var delegate: CollieGalleryDelegate?
    public var currentPageIndex: Int = 0
    public var pagingScrollView: UIScrollView!
    public var closeButton: UIButton!
    public var actionButton: UIButton?
    public var progressTrackView: UIView?
    public var progressBarView: UIView?
    public var captionView: CollieGalleryCaptionView!
    public var displayedImageView: UIImageView {
        get {
            return displayedView.imageView
        }
    }
    
    // MARK: - Initializers
    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    public override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: NSBundle?) {
        super.init(nibName: nil, bundle: nil)
    }
    
    public convenience init(pictures: [CollieGalleryPicture],
                            options: CollieGalleryOptions? = nil,
                            theme: CollieGalleryTheme? = nil)
    {
        self.init(nibName: nil, bundle: nil)
        self.pictures = pictures
        
        self.options = (options != nil) ? options! : CollieGalleryOptions.sharedOptions
        self.theme = (theme != nil) ? theme! : CollieGalleryTheme.defaultTheme
    }
    
    
    // MARK: - UIViewController functions
    public override func viewDidLoad() {
        super.viewDidLoad()
        setupView()
    }
    
    public override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        if !UIApplication.sharedApplication().statusBarHidden {
            UIApplication.sharedApplication().setStatusBarHidden(true, withAnimation: UIStatusBarAnimation.Slide)
        }
        
        scrollToIndex(options.openAtIndex, animated: false)
    }
    
    public override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        
        updateCaptionText()
    }
    
    public override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        captionView.layoutIfNeeded()
        captionView.setNeedsLayout()
    }
    
    public override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        
        if UIApplication.sharedApplication().statusBarHidden {
            UIApplication.sharedApplication().setStatusBarHidden(false, withAnimation: UIStatusBarAnimation.None)
        }
    }
    
    public override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        clearImagesFarFromIndex(currentPageIndex)
    }
    
    override public func prefersStatusBarHidden() -> Bool {
        return true
    }
    
    public override func viewWillTransitionToSize(size: CGSize, withTransitionCoordinator coordinator: UIViewControllerTransitionCoordinator) {
        super.viewWillTransitionToSize(size, withTransitionCoordinator: coordinator)
        
        coordinator.animateAlongsideTransition({ [weak self] _ in
                self?.updateView(size)
            }, completion: nil)
    }
    
    
    // MARK: - Private functions
    private func setupView() {
        view.backgroundColor = theme.backgroundColor
        
        setupScrollView()
        setupPictures()
        setupCloseButton()
        
        if options.enableSave {
            setupActionButton()
        }
        
        setupCaptionView()

        if options.showProgress {
            setupProgressIndicator()
        }
        
        loadImagesNextToIndex(currentPageIndex)
        
    }
    
    private func setupScrollView() {
        let avaiableSize = getInitialAvaiableSize()
        let scrollFrame = getScrollViewFrame(avaiableSize)
        let contentSize = getScrollViewContentSize(scrollFrame)
        
        pagingScrollView = UIScrollView(frame: scrollFrame)
        pagingScrollView.delegate = self
        pagingScrollView.pagingEnabled = true
        pagingScrollView.showsHorizontalScrollIndicator = !options.showProgress
        pagingScrollView.backgroundColor = UIColor.clearColor()
        pagingScrollView.contentSize = contentSize
        
        switch theme {
        case .Dark:
            pagingScrollView.indicatorStyle = .White
        case .Light:
            pagingScrollView.indicatorStyle = .Black
        default:
            pagingScrollView.indicatorStyle = .Default
        }
        
        view.addSubview(pagingScrollView)
    }
    
    private func setupPictures() {
        let avaiableSize = getInitialAvaiableSize()
        let scrollFrame = getScrollViewFrame(avaiableSize)
        
        for i in 0 ..< pictures.count {
            let picture = pictures[i]
            let pictureFrame = getPictureFrame(scrollFrame, pictureIndex: i)
            let pictureView = CollieGalleryView(picture: picture, frame: pictureFrame, options: options, theme: theme)
            pictureView.delegate = self
            
            pagingScrollView.addSubview(pictureView)
            pictureViews.append(pictureView)
        }
    }
    
    private func setupCloseButton() {
        if self.closeButton != nil {
            self.closeButton.removeFromSuperview()
        }
        
        let avaiableSize = getInitialAvaiableSize()
        let closeButtonFrame = getCloseButtonFrame(avaiableSize)
        
        
        let closeButton = UIButton(frame: closeButtonFrame)
        if let customImageName = options.customCloseImageName,
            let image = UIImage(named: customImageName) {
            closeButton.setImage(image, forState: .Normal)
        } else {
            closeButton.setTitle("+", forState: .Normal)
            closeButton.titleLabel!.font = UIFont(name: "HelveticaNeue-Medium", size: 30)
            closeButton.setTitleColor(theme.closeButtonColor, forState: UIControlState.Normal)
            closeButton.transform = CGAffineTransformMakeRotation(CGFloat(M_PI_4))
        }
        closeButton.addTarget(self, action: #selector(closeButtonTouched), forControlEvents: .TouchUpInside)
        
        var shouldBeHidden = false
        
        if self.closeButton != nil {
            shouldBeHidden = closeButton.hidden
        }
        
        closeButton.hidden = shouldBeHidden
        
        
        self.closeButton = closeButton
        
        view.addSubview(self.closeButton)
    }
    
    private func setupActionButton() {
        if let actionButton = self.actionButton {
            actionButton.removeFromSuperview()
        }
        
        let avaiableSize = getInitialAvaiableSize()
        let closeButtonFrame = getActionButtonFrame(avaiableSize)
        
        let actionButton = UIButton(frame: closeButtonFrame)
        if let customImageName = options.customOptionsImageName,
            let image = UIImage(named: customImageName) {
            closeButton.setImage(image, forState: .Normal)
        } else {
            actionButton.setTitle("•••", forState: .Normal)
            actionButton.titleLabel!.font = UIFont(name: "HelveticaNeue-Thin", size: 15)
            actionButton.setTitleColor(theme.closeButtonColor, forState: UIControlState.Normal)
        }
        
        actionButton.addTarget(self, action: #selector(actionButtonTouched), forControlEvents: .TouchUpInside)
        
        
        var shouldBeHidden = false
        
        if self.actionButton != nil {
            shouldBeHidden = self.actionButton!.hidden
        }
        
        actionButton.hidden = shouldBeHidden
        
        
        self.actionButton = actionButton
        
        view.addSubview(actionButton)
    }
    
    private func setupProgressIndicator() {
        let avaiableSize = getInitialAvaiableSize()
        let progressFrame = getProgressViewFrame(avaiableSize)
        let progressBarFrame = getProgressInnerViewFrame(progressFrame)

        let progressTrackView = UIView(frame: progressFrame)
        progressTrackView.backgroundColor = UIColor(white: 0.6, alpha: 0.2)
        progressTrackView.clipsToBounds = true
        self.progressTrackView = progressTrackView
        
        let progressBarView = UIView(frame: progressBarFrame)
        progressBarView.backgroundColor = theme.progressBarColor
        progressBarView.clipsToBounds = true
        self.progressBarView = progressBarView
        
        progressTrackView.addSubview(progressBarView)
        
        if let progressTrackView = self.progressTrackView {
            view.addSubview(progressTrackView)
        }
    }
    
    private func setupCaptionView() {
        let avaiableSize = getInitialAvaiableSize()
        let captionViewFrame = getCaptionViewFrame(avaiableSize)
        
        let captionView = CollieGalleryCaptionView(frame: captionViewFrame)
        self.captionView = captionView
        
        if options.showCaptionView {
            view.addSubview(self.captionView)
        }
    }
    
    private func updateView(avaiableSize: CGSize) {
        pagingScrollView.frame = getScrollViewFrame(avaiableSize)
        pagingScrollView.contentSize = getScrollViewContentSize(pagingScrollView.frame)
        
        for i in 0 ..< pictureViews.count {
            let innerView = pictureViews[i]
            innerView.frame = getPictureFrame(pagingScrollView.frame, pictureIndex: i)
        }
        
        if let progressTrackView = progressTrackView {
            progressTrackView.frame = getProgressViewFrame(avaiableSize)
        }
        
        var popOverPresentationRect = getActionButtonFrame(view.frame.size)
        popOverPresentationRect.origin.x += popOverPresentationRect.size.width
        
        activityController?.popoverPresentationController?.sourceView = view
        activityController?.popoverPresentationController?.sourceRect = popOverPresentationRect
        
        setupCloseButton()
        setupActionButton()
        
        updateContentOffset()
        
        updateCaptionText()
    }
    
    private func loadImagesNextToIndex(index: Int) {
        pictureViews[index].loadImage()
        
        let imagesToLoad = options.preLoadedImages
        
        for i in 1 ... imagesToLoad {
            let previousIndex = index - i
            let nextIndex = index + i
            
            if previousIndex >= 0 {
                pictureViews[previousIndex].loadImage()
            }
            
            if nextIndex < pictureViews.count {
                pictureViews[nextIndex].loadImage()
            }
        }
    }
    
    private func clearImagesFarFromIndex(index: Int) {
        let imagesToLoad = options.preLoadedImages
        let firstIndex = max(index - imagesToLoad, 0)
        let lastIndex = min(index + imagesToLoad, pictureViews.count - 1)
        
        var imagesCleared = 0
        
        for i in 0 ..< pictureViews.count {
            if i < firstIndex || i > lastIndex {
                pictureViews[i].clearImage()
                imagesCleared += 1
            }
        }
        
        print("\(imagesCleared) images cleared.")
    }
    
    private func updateContentOffset() {
        pagingScrollView.setContentOffset(CGPointMake(pagingScrollView.frame.size.width * CGFloat(currentPageIndex), 0), animated: false)
    }
    
    private func getInitialAvaiableSize() -> CGSize {
        return view.bounds.size
    }
    
    private func getScrollViewFrame(avaiableSize: CGSize) -> CGRect {
        let x: CGFloat = -options.gapBetweenPages
        let y: CGFloat = 0.0
        let width: CGFloat = avaiableSize.width + options.gapBetweenPages
        let height: CGFloat = avaiableSize.height
        
        return CGRectMake(x, y, width, height)
    }
    
    private func getScrollViewContentSize(scrollFrame: CGRect) -> CGSize {
        let width = scrollFrame.size.width * CGFloat(pictures.count)
        let height = scrollFrame.size.height
        
        return CGSizeMake(width, height)
    }
    
    private func getPictureFrame(scrollFrame: CGRect, pictureIndex: Int) -> CGRect {
        let x: CGFloat = ((scrollFrame.size.width) * CGFloat(pictureIndex)) + options.gapBetweenPages
        let y: CGFloat = 0.0
        let width: CGFloat = scrollFrame.size.width - (1 * options.gapBetweenPages)
        let height: CGFloat = scrollFrame.size.height
        
        return CGRectMake(x, y, width, height)
    }
    
    private func toggleControlsVisibility() {
        if isShowingActionControls {
            hideControls()
        } else {
            showControls()
        }
    }
    
    private func showControls() {
        closeButton.hidden = false
        actionButton?.hidden = false
        progressTrackView?.hidden = false
        captionView.hidden = captionView.titleLabel.text == nil && captionView.captionLabel.text == nil
        
        UIView.animateWithDuration(0.2, delay: 0.0,
                                   options: UIViewAnimationOptions.CurveEaseInOut,
                                   animations: { [weak self] in
                                                    self?.closeButton.alpha = 1.0
                                                    self?.actionButton?.alpha = 1.0
                                                    self?.progressTrackView?.alpha = 1.0
                                                    self?.captionView.alpha = 1.0
                                   }, completion: nil)
    }
    
    private func hideControls() {
        UIView.animateWithDuration(0.2, delay: 0.0,
                                   options: UIViewAnimationOptions.CurveEaseInOut,
                                   animations: { [weak self] in
                                        self?.closeButton.alpha = 0.0
                                        self?.actionButton?.alpha = 0.0
                                        self?.progressTrackView?.alpha = 0.0
                                        self?.captionView.alpha = 0.0
                                   },
                                   completion: { [weak self] _ in
                                        self?.closeButton.hidden = true
                                        self?.actionButton?.hidden = true
                                        self?.progressTrackView?.hidden = true
                                        self?.captionView.hidden = true
                                   })
    }
    
    private func getCaptionViewFrame(availableSize: CGSize) -> CGRect {
        return CGRectMake(0.0, availableSize.height - 70, availableSize.width, 70)
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
    
    private func getCustomButtonFrame(avaiableSize: CGSize, forIndex index: Int) -> CGRect {
        let position = index + 2
        
        return CGRectMake(avaiableSize.width - CGFloat(50 * position), 0, 50, 50)
    }
    
    private func updateCaptionText () {
        let picture = pictures[currentPageIndex]
        
        captionView.titleLabel.text = picture.title
        captionView.captionLabel.text = picture.caption
        
        captionView.adjustView()
    }
    
    
    // MARK: - Internal functions
    @objc internal func closeButtonTouched(sender: AnyObject) {
        dismissViewControllerAnimated(true, completion: nil)
    }
    
    @objc internal func actionButtonTouched(sender: AnyObject) {
        
        if let customHandleBlock = options.customOptionsBlock {
            customHandleBlock()
            return
        }
        
        showShareActivity()
    }
    
    internal func showShareActivity() {
        if let image = displayedImageView.image {
            let objectsToShare = [image]
            
            activityController = UIActivityViewController(activityItems: objectsToShare, applicationActivities: options.customActions)
            
            activityController.excludedActivityTypes = options.excludedActions
            
            var popOverPresentationRect = getActionButtonFrame(view.frame.size)
            popOverPresentationRect.origin.x += popOverPresentationRect.size.width
            
            activityController.popoverPresentationController?.sourceView = view
            activityController.popoverPresentationController?.sourceRect = popOverPresentationRect
            activityController.popoverPresentationController?.permittedArrowDirections = UIPopoverArrowDirection.Up
            
            presentViewController(activityController, animated: true, completion: nil)
            
            activityController.view.layoutIfNeeded()
        }
    }
    
    
    // MARK: - UIScrollView delegate
    public func scrollViewDidScroll(scrollView: UIScrollView) {
        for i in 0 ..< pictureViews.count {
            pictureViews[i].scrollView.contentOffset = CGPointMake((scrollView.contentOffset.x - pictureViews[i].frame.origin.x + options.gapBetweenPages) * -options.parallaxFactor, 0)
        }

        if let progressBarView = progressBarView, progressTrackView = progressTrackView {
            let maxProgress = progressTrackView.frame.size.width * CGFloat(pictures.count - 1)
            let currentGap = CGFloat(currentPageIndex) * options.gapBetweenPages
            let offset = scrollView.contentOffset.x - currentGap
            let progress = (maxProgress - (maxProgress - offset)) / CGFloat(pictures.count - 1)
            progressBarView.frame.size.width = max(progress, 0)
        }
    }
    
    public func scrollViewDidEndDecelerating(scrollView: UIScrollView) {
        let page = Int(scrollView.contentOffset.x / scrollView.frame.size.width)
        
        if page != currentPageIndex {
            delegate?.gallery?(self, indexChangedTo: page)
        }
        
        currentPageIndex = page
        loadImagesNextToIndex(currentPageIndex)
        
        updateCaptionText()
    }

    
    // MARK: - CollieGalleryView delegate
    func galleryViewTapped(scrollview: CollieGalleryView) {
        let scrollView = pictureViews[currentPageIndex].scrollView
        
        if scrollView.zoomScale == scrollView.minimumZoomScale {
            toggleControlsVisibility()
            
        }
    }
    
    func galleryViewPressed(scrollview: CollieGalleryView) {
        if options.enableSave {
            showControls()
            showShareActivity()
        }
    }
    
    func galleryViewDidRestoreZoom(galleryView: CollieGalleryView) {
        showControls()
    }
    
    func galleryViewDidZoomIn(galleryView: CollieGalleryView) {
        hideControls()
    }
    
    func galleryViewDidEnableScroll(galleryView: CollieGalleryView) {
        pagingScrollView.scrollEnabled = false
    }
    
    func galleryViewDidDisableScroll(galleryView: CollieGalleryView) {
        pagingScrollView.scrollEnabled = true
    }
    
    
    // MARK: - Public functions
    public func scrollToIndex(index: Int, animated: Bool = true) {
        currentPageIndex = index
        loadImagesNextToIndex(currentPageIndex)
        pagingScrollView.setContentOffset(CGPointMake(pagingScrollView.frame.size.width * CGFloat(index), 0), animated: animated)
    }
    
    public func presentInViewController(sourceViewController: UIViewController, transitionType: CollieGalleryTransitionType? = nil) {
        
        let type = transitionType == nil ? CollieGalleryTransitionType.defaultType : transitionType!
        
        transitionManager.enableInteractiveTransition = options.enableInteractiveDismiss
        transitionManager.transitionType = type
        transitionManager.sourceViewController = sourceViewController
        transitionManager.targetViewController = self
        
        modalPresentationStyle = UIModalPresentationStyle.OverCurrentContext
        transitioningDelegate = transitionManager
        
        sourceViewController.presentViewController(self, animated: type.animated, completion: nil)
    }
}
