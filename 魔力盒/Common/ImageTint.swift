//
//  ImageTint.swift
//  MLH
//
//  Created by Haitang on 17/7/4.
//  Copyright © 2017年 Haitang. All rights reserved.
//
// copy by 王 巍
import Foundation
import UIKit
extension UIImage{
    func getImage(tintColor:UIColor) -> UIImage {
        return getImage(tintColor: tintColor, blendModel: .destinationIn)
    }
    func getImage(gradientTintColor:UIColor) -> UIImage{
        return getImage(tintColor: gradientTintColor, blendModel: .overlay)
    }
    func getImage(tintColor:UIColor,blendModel:CGBlendMode) -> UIImage {
        UIGraphicsBeginImageContextWithOptions(self.size, false, 0.0)
        tintColor.setFill()
        let bounds : CGRect = CGRect(x: 0, y: 0, width: self.size.width, height: self.size.height)
        UIRectFill(bounds)
        
        self.draw(in: bounds, blendMode: blendModel, alpha: 1.0)
        if  blendModel != .destinationIn {
            self.draw(in: bounds, blendMode: .destinationIn, alpha: 1.0)
        }
        let tintedImage:UIImage = UIGraphicsGetImageFromCurrentImageContext()!
        UIGraphicsEndImageContext()
        return tintedImage
    }
}
