//
//  CollieGalleryCaptionView.swift
//  Pods
//
//  Created by Guilherme Munhoz on 5/11/16.
//
//

import UIKit

public class CollieGalleryCaptionView: UIView {
    
    private var isExpanded = false
    
    var titleLabel: UILabel!
    var captionLabel: UILabel!
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        setupGestures()
        setupView()
    }

    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
        setupGestures()
        setupView()
    }
    
    func setupGestures() {
        let tapGesture = UITapGestureRecognizer(target: self, action: "viewTapped:")
        self.addGestureRecognizer(tapGesture)
    }
    
    func setupView() {
        self.backgroundColor = UIColor(white: 0.0, alpha: 0.7)
        
        self.titleLabel = UILabel()
        self.titleLabel.font = UIFont(name: "HelveticaNeue-Bold", size: 15)
        self.titleLabel.textColor = UIColor.whiteColor()
        self.titleLabel.translatesAutoresizingMaskIntoConstraints = false
        self.titleLabel.userInteractionEnabled = false
        
        self.addSubview(self.titleLabel)
        
        self.captionLabel = UILabel()
        self.captionLabel.font = UIFont(name: "HelveticaNeue", size: 13)
        self.captionLabel.textColor = UIColor.grayColor()
        self.captionLabel.numberOfLines = 1
        self.captionLabel.lineBreakMode = NSLineBreakMode.ByTruncatingTail
        self.captionLabel.translatesAutoresizingMaskIntoConstraints = false
        self.captionLabel.userInteractionEnabled = false
        
        self.addSubview(self.captionLabel)
        
        self.addLayoutConstraints()
    }
    
    func addLayoutConstraints() {
        NSLayoutConstraint(item: self.titleLabel, attribute: NSLayoutAttribute.Leading, relatedBy: NSLayoutRelation.Equal, toItem: self, attribute: NSLayoutAttribute.LeadingMargin, multiplier: 1.0, constant: 5.0).active = true
        
        NSLayoutConstraint(item: self.titleLabel, attribute: NSLayoutAttribute.Trailing, relatedBy: NSLayoutRelation.Equal, toItem: self, attribute: NSLayoutAttribute.TrailingMargin, multiplier: 1.0, constant: -5.0).active = true
        
        NSLayoutConstraint(item: self.titleLabel, attribute: NSLayoutAttribute.Top, relatedBy: NSLayoutRelation.Equal, toItem: self, attribute: NSLayoutAttribute.TopMargin, multiplier: 1.0, constant: 5.0).active = true
        
        NSLayoutConstraint(item: self.titleLabel, attribute: NSLayoutAttribute.Height, relatedBy: NSLayoutRelation.Equal, toItem: nil, attribute: NSLayoutAttribute.NotAnAttribute, multiplier: 1, constant: 25).active = true
        
        NSLayoutConstraint(item: self.captionLabel, attribute: NSLayoutAttribute.Top, relatedBy: NSLayoutRelation.Equal, toItem: self.titleLabel, attribute: NSLayoutAttribute.BottomMargin, multiplier: 1.0, constant: 10.0).active = true
        
        NSLayoutConstraint(item: self.captionLabel, attribute: NSLayoutAttribute.Leading, relatedBy: NSLayoutRelation.Equal, toItem: self, attribute: NSLayoutAttribute.LeadingMargin, multiplier: 1.0, constant: 5.0).active = true
        
        NSLayoutConstraint(item: self.captionLabel, attribute: NSLayoutAttribute.Trailing, relatedBy: NSLayoutRelation.Equal, toItem: self, attribute: NSLayoutAttribute.TrailingMargin, multiplier: 1.0, constant: -5.0).active = true

    }
    
    func viewTapped(recognizer: UITapGestureRecognizer) {
        if !isExpanded {
            isExpanded = true
            self.captionLabel.numberOfLines = 0
            
            
        } else {
            isExpanded = false
            self.captionLabel.numberOfLines = 1
            self.captionLabel.lineBreakMode = NSLineBreakMode.ByTruncatingTail
            
            
        }
        
        adjustViewSize()
        
    }
    
    public func adjustView() {
        self.isExpanded = false
        self.captionLabel.numberOfLines = 1
        
        self.hidden = self.titleLabel.text == nil && self.captionLabel.text == nil
        
        adjustViewSize()
    }
    
    public func adjustViewSize() {
        self.captionLabel.sizeToFit()
        
        let screenSize = UIScreen.mainScreen().bounds.size
        
        let contentSize: CGFloat = self.titleLabel.frame.size.height + self.captionLabel.frame.size.height + 30.0
        
        UIView.animateWithDuration(0.5, delay: 0.0, options: UIViewAnimationOptions.CurveEaseInOut, animations: { () -> Void in
            
            self.frame = CGRectMake(self.frame.origin.x, screenSize.height - contentSize, screenSize.width, contentSize);
            
            
            }) { (finished: Bool) -> Void in
                
        }
    }
}
