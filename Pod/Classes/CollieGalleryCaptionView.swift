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
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(CollieGalleryCaptionView.viewTapped(_:)))
        addGestureRecognizer(tapGesture)
    }
    
    func setupView() {
        backgroundColor = UIColor(white: 0.0, alpha: 0.7)
        
        titleLabel = UILabel()
        titleLabel.font = UIFont(name: "HelveticaNeue-Bold", size: 15)
        titleLabel.textColor = UIColor.whiteColor()
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        titleLabel.userInteractionEnabled = false
        
        addSubview(titleLabel)
        
        captionLabel = UILabel()
        captionLabel.font = UIFont(name: "HelveticaNeue", size: 13)
        captionLabel.textColor = UIColor.grayColor()
        captionLabel.numberOfLines = 1
        captionLabel.lineBreakMode = NSLineBreakMode.ByTruncatingTail
        captionLabel.translatesAutoresizingMaskIntoConstraints = false
        captionLabel.userInteractionEnabled = false
        
        addSubview(captionLabel)
        
        addLayoutConstraints()
    }
    
    func addLayoutConstraints() {
        NSLayoutConstraint(item: titleLabel, attribute: NSLayoutAttribute.Leading, relatedBy: NSLayoutRelation.Equal, toItem: self, attribute: NSLayoutAttribute.LeadingMargin, multiplier: 1.0, constant: 5.0).active = true
        
        NSLayoutConstraint(item: titleLabel, attribute: NSLayoutAttribute.Trailing, relatedBy: NSLayoutRelation.Equal, toItem: self, attribute: NSLayoutAttribute.TrailingMargin, multiplier: 1.0, constant: -5.0).active = true
        
        NSLayoutConstraint(item: titleLabel, attribute: NSLayoutAttribute.Top, relatedBy: NSLayoutRelation.Equal, toItem: self, attribute: NSLayoutAttribute.TopMargin, multiplier: 1.0, constant: 5.0).active = true
        
        NSLayoutConstraint(item: titleLabel, attribute: NSLayoutAttribute.Height, relatedBy: NSLayoutRelation.Equal, toItem: nil, attribute: NSLayoutAttribute.NotAnAttribute, multiplier: 1, constant: 25).active = true
        
        NSLayoutConstraint(item: captionLabel, attribute: NSLayoutAttribute.Top, relatedBy: NSLayoutRelation.Equal, toItem: titleLabel, attribute: NSLayoutAttribute.BottomMargin, multiplier: 1.0, constant: 10.0).active = true
        
        NSLayoutConstraint(item: captionLabel, attribute: NSLayoutAttribute.Leading, relatedBy: NSLayoutRelation.Equal, toItem: self, attribute: NSLayoutAttribute.LeadingMargin, multiplier: 1.0, constant: 5.0).active = true
        
        NSLayoutConstraint(item: captionLabel, attribute: NSLayoutAttribute.Trailing, relatedBy: NSLayoutRelation.Equal, toItem: self, attribute: NSLayoutAttribute.TrailingMargin, multiplier: 1.0, constant: -5.0).active = true
    }
    
    func viewTapped(recognizer: UITapGestureRecognizer) {
        if !isExpanded {
            isExpanded = true
            captionLabel.numberOfLines = 0
        } else {
            isExpanded = false
            captionLabel.numberOfLines = 1
            captionLabel.lineBreakMode = NSLineBreakMode.ByTruncatingTail
        }
        adjustViewSize()
    }
    
    public func adjustView() {
        isExpanded = false
        captionLabel.numberOfLines = 1
        
        hidden = titleLabel.text == nil && captionLabel.text == nil
        
        adjustViewSize()
    }
    
    public func adjustViewSize() {
        captionLabel.sizeToFit()
        let screenSize = UIScreen.mainScreen().bounds.size
        let contentSize: CGFloat = titleLabel.frame.size.height
                                        + captionLabel.frame.size.height + 30.0
        UIView.animateWithDuration(0.5, delay: 0.0,
                                   options: UIViewAnimationOptions.CurveEaseInOut,
                                   animations: { [weak self] in
                                        guard let this = self else { return }
                                        this.frame = CGRectMake(this.frame.origin.x,
                                                                screenSize.height - contentSize,
                                                                screenSize.width,
                                                                contentSize);
        }) { _ in}
    }
}
