//
//  CardView.swift
//  open-weather
//
//  Created by Manoj Kumar on 16/05/23.
//

import Foundation
import UIKit

@IBDesignable class CardView: UIView {
    @IBInspectable var cornnerRadius : CGFloat = 2
    var shadowOfSetWidth : CGFloat = 0
    var shadowOfSetHeight : CGFloat = 5
    
    @IBInspectable var shadowColour : UIColor!
    var shadowOpacity : CGFloat = 0.5
    
    override func layoutSubviews() {
        layer.cornerRadius = cornnerRadius
        layer.shadowColor = shadowColour.cgColor
        layer.shadowOffset = CGSize(width: shadowOfSetWidth, height: shadowOfSetHeight)
        let shadowPath = UIBezierPath(roundedRect: bounds, cornerRadius: cornnerRadius)
        layer.shadowPath = shadowPath.cgPath
        layer.shadowOpacity = Float(shadowOpacity)
    }
}
