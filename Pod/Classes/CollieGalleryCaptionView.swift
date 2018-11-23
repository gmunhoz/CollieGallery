//
//  CollieGalleryCaptionView.swift
//  Pods
//
//  Created by Guilherme Munhoz on 5/11/16.
//
//

import UIKit

/// View used to show a caption for the picture
open class CollieGalleryCaptionView: UIView {
    
    fileprivate var isExpanded = false
    
    /// The title label
    var titleLabel: UILabel!
    
    /// The caption label
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
    
    /// Toggle the visibility and adjusts the view size
    open func adjustView() {
        isExpanded = false
        captionLabel.numberOfLines = 1
        
        isHidden = titleLabel.text == nil && captionLabel.text == nil
        
        adjustViewSize()
    }
    
    fileprivate func setupGestures() {
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(CollieGalleryCaptionView.viewTapped(_:)))
        addGestureRecognizer(tapGesture)
    }
    
    fileprivate func setupView() {
        backgroundColor = UIColor(white: 0.0, alpha: 0.7)
        
        titleLabel = UILabel()
        titleLabel.font = UIFont(name: "HelveticaNeue-Bold", size: 15)
        titleLabel.textColor = UIColor.white
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        titleLabel.isUserInteractionEnabled = false
        
        addSubview(titleLabel)
        
        captionLabel = UILabel()
        captionLabel.font = UIFont(name: "HelveticaNeue", size: 13)
        captionLabel.textColor = UIColor.gray
        captionLabel.numberOfLines = 1
        captionLabel.lineBreakMode = NSLineBreakMode.byTruncatingTail
        captionLabel.translatesAutoresizingMaskIntoConstraints = false
        captionLabel.isUserInteractionEnabled = false
        
        addSubview(captionLabel)
        
        addLayoutConstraints()
    }
    
    fileprivate func addLayoutConstraints() {
        NSLayoutConstraint(item: titleLabel, attribute: NSLayoutConstraint.Attribute.leading, relatedBy: NSLayoutConstraint.Relation.equal, toItem: self, attribute: NSLayoutConstraint.Attribute.leadingMargin, multiplier: 1.0, constant: 5.0).isActive = true
        
        NSLayoutConstraint(item: titleLabel, attribute: NSLayoutConstraint.Attribute.trailing, relatedBy: NSLayoutConstraint.Relation.equal, toItem: self, attribute: NSLayoutConstraint.Attribute.trailingMargin, multiplier: 1.0, constant: -5.0).isActive = true
        
        NSLayoutConstraint(item: titleLabel, attribute: NSLayoutConstraint.Attribute.top, relatedBy: NSLayoutConstraint.Relation.equal, toItem: self, attribute: NSLayoutConstraint.Attribute.topMargin, multiplier: 1.0, constant: 5.0).isActive = true
        
        NSLayoutConstraint(item: titleLabel, attribute: NSLayoutConstraint.Attribute.height, relatedBy: NSLayoutConstraint.Relation.equal, toItem: nil, attribute: NSLayoutConstraint.Attribute.notAnAttribute, multiplier: 1, constant: 25).isActive = true
        
        NSLayoutConstraint(item: captionLabel, attribute: NSLayoutConstraint.Attribute.top, relatedBy: NSLayoutConstraint.Relation.equal, toItem: titleLabel, attribute: NSLayoutConstraint.Attribute.bottomMargin, multiplier: 1.0, constant: 10.0).isActive = true
        
        NSLayoutConstraint(item: captionLabel, attribute: NSLayoutConstraint.Attribute.leading, relatedBy: NSLayoutConstraint.Relation.equal, toItem: self, attribute: NSLayoutConstraint.Attribute.leadingMargin, multiplier: 1.0, constant: 5.0).isActive = true
        
        NSLayoutConstraint(item: captionLabel, attribute: NSLayoutConstraint.Attribute.trailing, relatedBy: NSLayoutConstraint.Relation.equal, toItem: self, attribute: NSLayoutConstraint.Attribute.trailingMargin, multiplier: 1.0, constant: -5.0).isActive = true
    }
    
    /// Called when the caption view is tapped
    @objc func viewTapped(_ recognizer: UITapGestureRecognizer) {
        if !isExpanded {
            isExpanded = true
            captionLabel.numberOfLines = 0
        } else {
            isExpanded = false
            captionLabel.numberOfLines = 1
            captionLabel.lineBreakMode = NSLineBreakMode.byTruncatingTail
        }
        adjustViewSize()
    }
    
    fileprivate func adjustViewSize() {
        captionLabel.sizeToFit()
        let screenSize = UIScreen.main.bounds.size
        let contentSize: CGFloat = titleLabel.frame.size.height
                                        + captionLabel.frame.size.height + 30.0
        UIView.animate(withDuration: 0.5, delay: 0.0,
                       options: UIView.AnimationOptions(),
                                   animations: { [weak self] in
                                        guard let this = self else { return }
                                        this.frame = CGRect(x: this.frame.origin.x,
                                                                y: screenSize.height - contentSize,
                                                                width: screenSize.width,
                                                                height: contentSize);
        }) { _ in}
    }
}
