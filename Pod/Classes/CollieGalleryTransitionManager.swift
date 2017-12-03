//
//  CollieGalleryTransitionManager.swift
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

internal class CollieGalleryTransitionManager: UIPercentDrivenInteractiveTransition,
    UIViewControllerAnimatedTransitioning,
UIViewControllerTransitioningDelegate  {
    
    // MARK: - Private properties
    fileprivate var presenting = true
    fileprivate var interactive = false
    fileprivate var panGestureRecognizer: UIPanGestureRecognizer!
    
    // MARK: - Internal properties
    internal var enableInteractiveTransition: Bool = false
    internal var transitionType: CollieGalleryTransitionType!
    internal weak var sourceViewController: UIViewController!
    internal weak var targetViewController: CollieGallery! {
        didSet {
            self.panGestureRecognizer = UIPanGestureRecognizer()
            self.panGestureRecognizer.addTarget(self, action:#selector(CollieGalleryTransitionManager.handlePan(_:)))
            self.targetViewController.view.addGestureRecognizer(self.panGestureRecognizer)
        }
    }
    
    
    // MARK: - Internal functions
    @objc internal func handlePan(_ pan: UIPanGestureRecognizer){
        if transitionType.transition != nil {
            let translation = pan.translation(in: pan.view!)
            
            let max = targetViewController.view.bounds.size.height
            let d = abs(translation.y / max)
            
            switch (pan.state) {
                
            case .began:
                if enableInteractiveTransition && !targetViewController.displayedView.isZoomed {
                    interactive = true
                    targetViewController.dismiss(animated: true, completion: nil)
                }
                break
                
            case .changed:
                update(d)
                break
                
            default:
                if(d > 0.1){
                    self.finish()
                }
                else {
                    self.cancel()
                }
                
                self.interactive = false
            }
        }
    }
    
    
    // MARK: - UIViewControllerAnimatedTransitioning Delegate
    internal func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {
        if let transition = self.transitionType.transition {
            if self.presenting {
                transition.animatePresentationWithTransitionContext(transitionContext, duration: self.transitionDuration(using: transitionContext))
                
            } else {
                transition.animateDismissalWithTransitionContext(transitionContext,  duration: self.transitionDuration(using: transitionContext))
                
            }
            
        } else {
            transitionContext.completeTransition(true)
            
        }
    }
    
    internal func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval {
        return 0.5
    }
    
    
    // MARK: - UIViewControllerTransitioning Delegate
    internal func animationController(forPresented presented: UIViewController, presenting: UIViewController, source: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        self.presenting = true
        return self
    }
    
    internal func animationController(forDismissed dismissed: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        self.presenting = false
        return self
    }
    
    internal func interactionControllerForPresentation(using animator: UIViewControllerAnimatedTransitioning) -> UIViewControllerInteractiveTransitioning? {
        return nil
    }
    
    internal func interactionControllerForDismissal(using animator: UIViewControllerAnimatedTransitioning) -> UIViewControllerInteractiveTransitioning? {
        return self.interactive ? self : nil
    }
    
}
