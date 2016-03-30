//
//  CollieGalleryZoomTransition.swift
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

public protocol CollieGalleryZoomTransitionDelegate {
    func zoomTransitionContainerBounds() -> CGRect
    func zoomTransitionViewToDismissForIndex(index: Int) -> UIView?
}

public class CollieGalleryZoomTransition: CollieGalleryTransitionProtocol {
    
    // MARK: - Private properties
    private var fromView: UIView
    private let offStage: CGFloat = 100.0
    
    // MARK: - Internal properties
    internal var zoomTransitionDelegate: CollieGalleryZoomTransitionDelegate
    
    
    // MARK: - Initializers
    public init(fromView: UIView, zoomTransitionDelegate: CollieGalleryZoomTransitionDelegate) {
        self.fromView = fromView
        self.zoomTransitionDelegate = zoomTransitionDelegate
    }
    
    
    // MARK: - CollieGalleryTransitionProtocol
    internal func animatePresentationWithTransitionContext(transitionContext: UIViewControllerContextTransitioning, duration: NSTimeInterval) {
        let presentedController = transitionContext.viewControllerForKey(UITransitionContextToViewControllerKey) as! CollieGallery
        let presentedControllerView = transitionContext.viewForKey(UITransitionContextToViewKey)!
        let containerView = transitionContext.containerView()!
        
        presentedController.view.backgroundColor = presentedController.view.backgroundColor?.colorWithAlphaComponent(0.0)
        
        presentedController.closeButton.center.x -= self.offStage
        presentedController.actionButton?.center.x += self.offStage
        presentedController.progressTrackView?.center.y += self.offStage
        
        let fromRect = presentedController.displayedImageView.frame
        let containerBounds = self.zoomTransitionDelegate.zoomTransitionContainerBounds()
        presentedController.displayedImageView.transform = self.generateTransformFromImageRect(fromRect, targetView: self.fromView, containerBounds: containerBounds)
        
        containerView.addSubview(presentedControllerView)
        
        UIView.animateWithDuration(duration, delay: 0.0, usingSpringWithDamping: 1.0, initialSpringVelocity: 0.0, options: .AllowUserInteraction, animations: {
            
            presentedController.view.backgroundColor = presentedController.view.backgroundColor?.colorWithAlphaComponent(1.0)
            presentedController.closeButton.center.x += self.offStage
            presentedController.actionButton?.center.x -= self.offStage
            presentedController.progressTrackView?.center.y -= self.offStage
            presentedController.displayedImageView.transform = CGAffineTransformIdentity
            
            }, completion: {(completed: Bool) -> Void in
                transitionContext.completeTransition(completed)
        })
    }
    
    internal func animateDismissalWithTransitionContext(transitionContext: UIViewControllerContextTransitioning, duration: NSTimeInterval) {
        let presentingController = transitionContext.viewControllerForKey(UITransitionContextFromViewControllerKey) as! CollieGallery
        let presentingControllerView = transitionContext.viewForKey(UITransitionContextFromViewKey)!
        let containerView = transitionContext.containerView()!
        
        containerView.addSubview(presentingControllerView)
        
        let dismissView: UIView? = self.zoomTransitionDelegate.zoomTransitionViewToDismissForIndex(presentingController.currentPageIndex)
        
        UIView.animateWithDuration(duration, delay: 0.0, usingSpringWithDamping: 1.0, initialSpringVelocity: 0.0, options: .AllowUserInteraction, animations: {
            
            presentingController.view.backgroundColor = presentingController.view.backgroundColor?.colorWithAlphaComponent(0.0)
            presentingController.closeButton.center.x -= self.offStage
            presentingController.actionButton?.center.x += self.offStage
            presentingController.progressTrackView?.center.y += self.offStage
            
            let fromRect = presentingController.displayedImageView.frame
            let containerBounds = self.zoomTransitionDelegate.zoomTransitionContainerBounds()
            presentingController.displayedImageView.transform = self.generateTransformFromImageRect(fromRect, targetView: dismissView, containerBounds: containerBounds)
            
            }, completion: {(completed: Bool) -> Void in
                if(transitionContext.transitionWasCancelled()){
                    transitionContext.completeTransition(false)
                    
                }
                else {
                    transitionContext.completeTransition(true)
                    
                }
        })
    }
    
    private func generateTransformFromImageRect(imageRect: CGRect, targetView: UIView?, containerBounds: CGRect?) -> CGAffineTransform {
        if let view = targetView {
            let rectInWindow =  self.fromView.superview?.convertRect(view.frame, toView: nil)
    
            if let toRect = rectInWindow, let bounds = containerBounds where CGRectContainsRect(bounds, toRect) {
                let scales = CGSizeMake(toRect.size.width/imageRect.size.width, toRect.size.height/imageRect.size.height)
                let offset = CGPointMake(CGRectGetMidX(toRect) - CGRectGetMidX(imageRect), CGRectGetMidY(toRect) - CGRectGetMidY(imageRect))
                return CGAffineTransformMake(scales.width, 0, 0, scales.height, offset.x, offset.y)
                
            }
        }
        
        return CGAffineTransformMakeScale(0.001, 0.001)
    }
}
