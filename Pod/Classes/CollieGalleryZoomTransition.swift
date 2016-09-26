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

/// Protocol to implement the zoom transition
public protocol CollieGalleryZoomTransitionDelegate {
    
    /// Called in the presentation and dismissal to indicate the bounds where the zoom animation can happen
    func zoomTransitionContainerBounds() -> CGRect
        
    /// Called in the dismissal to indicate which view should be used to zoom out
    func zoomTransitionViewToDismissForIndex(_ index: Int) -> UIView?
}

open class CollieGalleryZoomTransition: CollieGalleryTransitionProtocol {
    
    // MARK: - Private properties
    fileprivate var fromView: UIView
    fileprivate let offStage: CGFloat = 100.0
    
    // MARK: - Internal properties
    internal var zoomTransitionDelegate: CollieGalleryZoomTransitionDelegate
    
    
    // MARK: - Initializers
    
    /**
     
        Initializer that takes a view and a delegate
        
        - Parameters:
            - fromView: The view from where the animation will zoom in
            - zoomTransitionDelegate: The delegate
    
    */
    public init(fromView: UIView, zoomTransitionDelegate: CollieGalleryZoomTransitionDelegate) {
        self.fromView = fromView
        self.zoomTransitionDelegate = zoomTransitionDelegate
    }
    
    
    // MARK: - CollieGalleryTransitionProtocol
    internal func animatePresentationWithTransitionContext(_ transitionContext: UIViewControllerContextTransitioning, duration: TimeInterval) {
        let presentedController = transitionContext.viewController(forKey: UITransitionContextViewControllerKey.to) as! CollieGallery
        let presentedControllerView = transitionContext.view(forKey: UITransitionContextViewKey.to)!
        let containerView = transitionContext.containerView
        
        presentedController.view.backgroundColor = presentedController.view.backgroundColor?.withAlphaComponent(0.0)
        
        presentedController.closeButton.center.x -= self.offStage
        presentedController.actionButton?.center.x += self.offStage
        presentedController.progressTrackView?.center.y += self.offStage
        presentedController.captionView.center.y += self.offStage
        
        let fromRect = presentedController.displayedImageView.frame
        let containerBounds = self.zoomTransitionDelegate.zoomTransitionContainerBounds()
        presentedController.displayedImageView.transform = self.generateTransformFromImageRect(fromRect, targetView: self.fromView, containerBounds: containerBounds)
        
        containerView.addSubview(presentedControllerView)
        
        UIView.animate(withDuration: duration, delay: 0.0, usingSpringWithDamping: 1.0, initialSpringVelocity: 0.0, options: .allowUserInteraction, animations: {
            
            presentedController.view.backgroundColor = presentedController.view.backgroundColor?.withAlphaComponent(1.0)
            presentedController.closeButton.center.x += self.offStage
            presentedController.actionButton?.center.x -= self.offStage
            presentedController.progressTrackView?.center.y -= self.offStage
            presentedController.captionView.center.y -= self.offStage
            presentedController.displayedImageView.transform = CGAffineTransform.identity
            
            }, completion: {(completed: Bool) -> Void in
                transitionContext.completeTransition(completed)
        })
    }
    
    internal func animateDismissalWithTransitionContext(_ transitionContext: UIViewControllerContextTransitioning, duration: TimeInterval) {
        let presentingController = transitionContext.viewController(forKey: UITransitionContextViewControllerKey.from) as! CollieGallery
        let presentingControllerView = transitionContext.view(forKey: UITransitionContextViewKey.from)!
        let containerView = transitionContext.containerView
        
        containerView.addSubview(presentingControllerView)
        
        let dismissView: UIView? = self.zoomTransitionDelegate.zoomTransitionViewToDismissForIndex(presentingController.currentPageIndex)
        
        UIView.animate(withDuration: duration, delay: 0.0, usingSpringWithDamping: 1.0, initialSpringVelocity: 0.0, options: .allowUserInteraction, animations: {
            
            presentingController.view.backgroundColor = presentingController.view.backgroundColor?.withAlphaComponent(0.0)
            presentingController.closeButton.center.x -= self.offStage
            presentingController.actionButton?.center.x += self.offStage
            presentingController.progressTrackView?.center.y += self.offStage
            presentingController.captionView.center.y += self.offStage
            
            let fromRect = presentingController.displayedImageView.frame
            let containerBounds = self.zoomTransitionDelegate.zoomTransitionContainerBounds()
            presentingController.displayedImageView.transform = self.generateTransformFromImageRect(fromRect, targetView: dismissView, containerBounds: containerBounds)
            
            }, completion: {(completed: Bool) -> Void in
                if(transitionContext.transitionWasCancelled){
                    transitionContext.completeTransition(false)
                    
                }
                else {
                    transitionContext.completeTransition(true)
                    
                }
        })
    }
    
    fileprivate func generateTransformFromImageRect(_ imageRect: CGRect, targetView: UIView?, containerBounds: CGRect?) -> CGAffineTransform {
        if let view = targetView {
            let rectInWindow =  self.fromView.superview?.convert(view.frame, to: nil)
    
            if let toRect = rectInWindow, let bounds = containerBounds {
                if bounds.contains(toRect) {
                    let scales = CGSize(width: toRect.size.width/imageRect.size.width, height: toRect.size.height/imageRect.size.height)
                    let offset = CGPoint(x: toRect.midX - imageRect.midX, y: toRect.midY - imageRect.midY)
                    return CGAffineTransform(a: scales.width, b: 0, c: 0, d: scales.height, tx: offset.x, ty: offset.y)
                }
            }
        }
        
        return CGAffineTransform(scaleX: 0.001, y: 0.001)
    }
}
