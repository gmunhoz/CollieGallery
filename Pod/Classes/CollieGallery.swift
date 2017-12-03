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

/// Class used to display the gallery
open class CollieGallery: UIViewController, UIScrollViewDelegate, CollieGalleryViewDelegate {
    
    // MARK: - Private properties
    fileprivate let transitionManager = CollieGalleryTransitionManager()
    fileprivate var theme = CollieGalleryTheme.dark
    fileprivate var pictures: [CollieGalleryPicture] = []
    fileprivate var pictureViews: [CollieGalleryView] = []
    fileprivate var isShowingLandscapeView: Bool {
        let orientation = UIApplication.shared.statusBarOrientation
        
        switch (orientation) {
        case UIInterfaceOrientation.landscapeLeft, UIInterfaceOrientation.landscapeRight:
            return true
        default:
            return false
        }
    }
    fileprivate var isShowingActionControls: Bool {
        get {
            return !closeButton.isHidden
        }
    }
    fileprivate var activityController: UIActivityViewController!
    
    
    // MARK: - Internal properties
    internal var options = CollieGalleryOptions()
    internal var displayedView: CollieGalleryView {
        get {
            return pictureViews[currentPageIndex]
        }
    }
    
    
    // MARK: - Public properties
    
    /// The delegate
    open weak var delegate: CollieGalleryDelegate?
    
    /// The current page index
    open var currentPageIndex: Int = 0
    
    /// The scrollview used for paging
    open var pagingScrollView: UIScrollView!
    
    /// The close button
    open var closeButton: UIButton!
    
    /// The action button
    open var actionButton: UIButton?
    
    /// The view used to show the progress
    open var progressTrackView: UIView?
    
    /// The background view of the progress bar
    open var progressBarView: UIView?
    
    /// The view used to display the title and caption properties
    open var captionView: CollieGalleryCaptionView!
    
    /// The currently displayed imageview
    open var displayedImageView: UIImageView {
        get {
            return displayedView.imageView
        }
    }
    
    // MARK: - Initializers
    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    public override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        super.init(nibName: nil, bundle: nil)
    }
    
    
    /**
     
        Default gallery initializer

        - Parameters:
            - pictures: The pictures to display in the gallery
            - options: An optional object with the customization options
            - theme: An optional theme to customize the gallery appearance

    */
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
    open override func viewDidLoad() {
        super.viewDidLoad()
        setupView()
    }
    
    open override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        if !UIApplication.shared.isStatusBarHidden {
            UIApplication.shared.setStatusBarHidden(true, with: UIStatusBarAnimation.slide)
        }
        
        pagingScrollView.delegate = self
        
        if self.pagingScrollView.contentOffset.x == 0.0 {
            scrollToIndex(options.openAtIndex, animated: false)
        }
    }
    
    open override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        updateCaptionText()
    }
    
    open override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        captionView.layoutIfNeeded()
        captionView.setNeedsLayout()
    }
    
    open override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        if UIApplication.shared.isStatusBarHidden {
            UIApplication.shared.setStatusBarHidden(false, with: UIStatusBarAnimation.none)
        }
        
        pagingScrollView.delegate = nil
    }
    
    open override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        clearImagesFarFromIndex(currentPageIndex)
    }
    
    override open var prefersStatusBarHidden : Bool {
        return true
    }
    
    open override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        super.viewWillTransition(to: size, with: coordinator)
        
        coordinator.animate(alongsideTransition: { [weak self] _ in
                self?.updateView(size)
            }, completion: nil)
    }
    
    
    // MARK: - Private functions
    fileprivate func setupView() {
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
    
    fileprivate func setupScrollView() {
        let avaiableSize = getInitialAvaiableSize()
        let scrollFrame = getScrollViewFrame(avaiableSize)
        let contentSize = getScrollViewContentSize(scrollFrame)
        
        pagingScrollView = UIScrollView(frame: scrollFrame)
        pagingScrollView.isPagingEnabled = true
        pagingScrollView.showsHorizontalScrollIndicator = !options.showProgress
        pagingScrollView.backgroundColor = UIColor.clear
        pagingScrollView.contentSize = contentSize
        
        switch theme {
        case .dark:
            pagingScrollView.indicatorStyle = .white
        case .light:
            pagingScrollView.indicatorStyle = .black
        default:
            pagingScrollView.indicatorStyle = .default
        }
        
        view.addSubview(pagingScrollView)
    }
    
    fileprivate func setupPictures() {
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
    
    fileprivate func setupCloseButton() {
        if self.closeButton != nil {
            self.closeButton.removeFromSuperview()
        }
        
        let avaiableSize = getInitialAvaiableSize()
        let closeButtonFrame = getCloseButtonFrame(avaiableSize)
        
        
        let closeButton = UIButton(frame: closeButtonFrame)
        if let customImageName = options.customCloseImageName,
            let image = UIImage(named: customImageName) {
            closeButton.setImage(image, for: UIControlState())
        } else {
            closeButton.setTitle("+", for: UIControlState())
            closeButton.titleLabel!.font = UIFont(name: "HelveticaNeue-Medium", size: 30)
            closeButton.setTitleColor(theme.closeButtonColor, for: UIControlState())
            closeButton.transform = CGAffineTransform(rotationAngle: CGFloat(CGFloat.pi / 4))
        }
        closeButton.addTarget(self, action: #selector(closeButtonTouched), for: .touchUpInside)
        
        var shouldBeHidden = false
        
        if self.closeButton != nil {
            shouldBeHidden = closeButton.isHidden
        }
        
        closeButton.isHidden = shouldBeHidden
        
        
        self.closeButton = closeButton
        
        view.addSubview(self.closeButton)
    }
    
    fileprivate func setupActionButton() {
        if let actionButton = self.actionButton {
            actionButton.removeFromSuperview()
        }
        
        let avaiableSize = getInitialAvaiableSize()
        let closeButtonFrame = getActionButtonFrame(avaiableSize)
        
        let actionButton = UIButton(frame: closeButtonFrame)
        if let customImageName = options.customOptionsImageName,
            let image = UIImage(named: customImageName) {
            closeButton.setImage(image, for: UIControlState())
        } else {
            actionButton.setTitle("•••", for: UIControlState())
            actionButton.titleLabel!.font = UIFont(name: "HelveticaNeue-Thin", size: 15)
            actionButton.setTitleColor(theme.closeButtonColor, for: UIControlState())
        }
        
        actionButton.addTarget(self, action: #selector(actionButtonTouched), for: .touchUpInside)
        
        
        var shouldBeHidden = false
        
        if self.actionButton != nil {
            shouldBeHidden = self.actionButton!.isHidden
        }
        
        actionButton.isHidden = shouldBeHidden
        
        
        self.actionButton = actionButton
        
        view.addSubview(actionButton)
    }
    
    fileprivate func setupProgressIndicator() {
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
    
    fileprivate func setupCaptionView() {
        let avaiableSize = getInitialAvaiableSize()
        let captionViewFrame = getCaptionViewFrame(avaiableSize)
        
        let captionView = CollieGalleryCaptionView(frame: captionViewFrame)
        self.captionView = captionView
        
        if options.showCaptionView {
            view.addSubview(self.captionView)
        }
    }
    
    fileprivate func updateView(_ avaiableSize: CGSize) {
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
    
    fileprivate func loadImagesNextToIndex(_ index: Int) {
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
    
    fileprivate func clearImagesFarFromIndex(_ index: Int) {
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
    
    fileprivate func updateContentOffset() {
        pagingScrollView.setContentOffset(CGPoint(x: pagingScrollView.frame.size.width * CGFloat(currentPageIndex), y: 0), animated: false)
    }
    
    fileprivate func getInitialAvaiableSize() -> CGSize {
        return view.bounds.size
    }
    
    fileprivate func getScrollViewFrame(_ avaiableSize: CGSize) -> CGRect {
        let x: CGFloat = -options.gapBetweenPages
        let y: CGFloat = 0.0
        let width: CGFloat = avaiableSize.width + options.gapBetweenPages
        let height: CGFloat = avaiableSize.height
        
        return CGRect(x: x, y: y, width: width, height: height)
    }
    
    fileprivate func getScrollViewContentSize(_ scrollFrame: CGRect) -> CGSize {
        let width = scrollFrame.size.width * CGFloat(pictures.count)
        let height = scrollFrame.size.height
        
        return CGSize(width: width, height: height)
    }
    
    fileprivate func getPictureFrame(_ scrollFrame: CGRect, pictureIndex: Int) -> CGRect {
        let x: CGFloat = ((scrollFrame.size.width) * CGFloat(pictureIndex)) + options.gapBetweenPages
        let y: CGFloat = 0.0
        let width: CGFloat = scrollFrame.size.width - (1 * options.gapBetweenPages)
        let height: CGFloat = scrollFrame.size.height
        
        return CGRect(x: x, y: y, width: width, height: height)
    }
    
    fileprivate func toggleControlsVisibility() {
        if isShowingActionControls {
            hideControls()
        } else {
            showControls()
        }
    }
    
    fileprivate func showControls() {
        closeButton.isHidden = false
        actionButton?.isHidden = false
        progressTrackView?.isHidden = false
        captionView.isHidden = captionView.titleLabel.text == nil && captionView.captionLabel.text == nil
        
        UIView.animate(withDuration: 0.2, delay: 0.0,
                                   options: UIViewAnimationOptions(),
                                   animations: { [weak self] in
                                                    self?.closeButton.alpha = 1.0
                                                    self?.actionButton?.alpha = 1.0
                                                    self?.progressTrackView?.alpha = 1.0
                                                    self?.captionView.alpha = 1.0
                                   }, completion: nil)
    }
    
    fileprivate func hideControls() {
        UIView.animate(withDuration: 0.2, delay: 0.0,
                                   options: UIViewAnimationOptions(),
                                   animations: { [weak self] in
                                        self?.closeButton.alpha = 0.0
                                        self?.actionButton?.alpha = 0.0
                                        self?.progressTrackView?.alpha = 0.0
                                        self?.captionView.alpha = 0.0
                                   },
                                   completion: { [weak self] _ in
                                        self?.closeButton.isHidden = true
                                        self?.actionButton?.isHidden = true
                                        self?.progressTrackView?.isHidden = true
                                        self?.captionView.isHidden = true
                                   })
    }
    
    fileprivate func getCaptionViewFrame(_ availableSize: CGSize) -> CGRect {
        return CGRect(x: 0.0, y: availableSize.height - 70, width: availableSize.width, height: 70)
    }
    
    fileprivate func getProgressViewFrame(_ avaiableSize: CGSize) -> CGRect {
        return CGRect(x: 0.0, y: avaiableSize.height - 2, width: avaiableSize.width, height: 2)
    }
    
    fileprivate func getProgressInnerViewFrame(_ progressFrame: CGRect) -> CGRect {
        return CGRect(x: 0, y: 0, width: 0, height: progressFrame.size.height)
    }
    
    fileprivate func getCloseButtonFrame(_ avaiableSize: CGSize) -> CGRect {
        return CGRect(x: 0, y: 0, width: 50, height: 50)
    }
    
    fileprivate func getActionButtonFrame(_ avaiableSize: CGSize) -> CGRect {
        return CGRect(x: avaiableSize.width - 50, y: 0, width: 50, height: 50)
    }
    
    fileprivate func getCustomButtonFrame(_ avaiableSize: CGSize, forIndex index: Int) -> CGRect {
        let position = index + 2
        
        return CGRect(x: avaiableSize.width - CGFloat(50 * position), y: 0, width: 50, height: 50)
    }
    
    fileprivate func updateCaptionText () {
        let picture = pictures[currentPageIndex]
        
        captionView.titleLabel.text = picture.title
        captionView.captionLabel.text = picture.caption
        
        captionView.adjustView()
    }

    fileprivate func updateProgressBar() {
        if let progressBarView = progressBarView,
           let progressTrackView = progressTrackView,
           let scrollView = self.pagingScrollView {

            if pictures.count > 1 {
                let maxProgress = progressTrackView.frame.size.width * CGFloat(pictures.count - 1)
                let currentGap = CGFloat(currentPageIndex) * options.gapBetweenPages
                let offset = scrollView.contentOffset.x - currentGap
                let progress = (maxProgress - (maxProgress - offset)) / CGFloat(pictures.count - 1)
                progressBarView.frame.size.width = max(progress, 0)

            } else if pictures.count == 1 {
                progressBarView.frame.size.width = progressTrackView.frame.size.width

            }

        }
    }
    
    
    // MARK: - Internal functions
    @objc internal func closeButtonTouched(_ sender: AnyObject) {
        dismiss(animated: true, completion: nil)
    }
    
    @objc internal func actionButtonTouched(_ sender: AnyObject) {
        
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
            activityController.popoverPresentationController?.permittedArrowDirections = UIPopoverArrowDirection.up
            
            present(activityController, animated: true, completion: nil)
            
            activityController.view.layoutIfNeeded()
        }
    }
    
    
    // MARK: - UIScrollView delegate
    open func scrollViewDidScroll(_ scrollView: UIScrollView) {
        for i in 0 ..< pictureViews.count {
            pictureViews[i].scrollView.contentOffset = CGPoint(x: (scrollView.contentOffset.x - pictureViews[i].frame.origin.x + options.gapBetweenPages) * -options.parallaxFactor, y: 0)
        }

        updateProgressBar()
    }
    
    open func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        let page = Int(scrollView.contentOffset.x / scrollView.frame.size.width)
        
        if page != currentPageIndex {
            delegate?.gallery?(self, indexChangedTo: page)
        }
        
        currentPageIndex = page
        loadImagesNextToIndex(currentPageIndex)
        
        updateCaptionText()
    }

    
    // MARK: - CollieGalleryView delegate
    func galleryViewTapped(_ scrollview: CollieGalleryView) {
        let scrollView = pictureViews[currentPageIndex].scrollView
        
        if scrollView?.zoomScale == scrollView?.minimumZoomScale {
            toggleControlsVisibility()
            
        }
    }
    
    func galleryViewPressed(_ scrollview: CollieGalleryView) {
        if options.enableSave {
            showControls()
            showShareActivity()
        }
    }
    
    func galleryViewDidRestoreZoom(_ galleryView: CollieGalleryView) {
        showControls()
    }
    
    func galleryViewDidZoomIn(_ galleryView: CollieGalleryView) {
        hideControls()
    }
    
    func galleryViewDidEnableScroll(_ galleryView: CollieGalleryView) {
        pagingScrollView.isScrollEnabled = false
    }
    
    func galleryViewDidDisableScroll(_ galleryView: CollieGalleryView) {
        pagingScrollView.isScrollEnabled = true
    }
    
    
    // MARK: - Public functions
    
    /**
     
        Scrolls the gallery to an index

        - Parameters:
            - index: The index to scroll
            - animated: Indicates if it should be animated or not

    */
    open func scrollToIndex(_ index: Int, animated: Bool = true) {
        currentPageIndex = index
        loadImagesNextToIndex(currentPageIndex)
        pagingScrollView.setContentOffset(CGPoint(x: pagingScrollView.frame.size.width * CGFloat(index), y: 0), animated: animated)
        updateProgressBar()
    }
    
    /**
     
        Presents the gallery from a view controller

        - Parameters:
            - sourceViewController: The source view controller
            - transitionType: The transition type used to present the gallery
     
    */
    open func presentInViewController(_ sourceViewController: UIViewController, transitionType: CollieGalleryTransitionType? = nil) {
        
        let type = transitionType == nil ? CollieGalleryTransitionType.defaultType : transitionType!
        
        transitionManager.enableInteractiveTransition = options.enableInteractiveDismiss
        transitionManager.transitionType = type
        transitionManager.sourceViewController = sourceViewController
        transitionManager.targetViewController = self
        
        modalPresentationStyle = UIModalPresentationStyle.overCurrentContext
        transitioningDelegate = transitionManager
        
        sourceViewController.present(self, animated: type.animated, completion: nil)
    }
}
