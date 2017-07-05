
//
//  SwifterSwift.swift
//  MLH
//
//  Created by Haitang on 17/6/24.
//  Copyright © 2017年 Haitang. All rights reserved.
//

import Foundation
import UIKit
public struct SwifterSwift{
    public static var screenWidth:CGFloat{
        return UIScreen.main.bounds.width
    }
    public static var screenHeight:CGFloat{
        return UIScreen.main.bounds.height
    }
    public static var keyWindow: UIView? {
        return UIApplication.shared.keyWindow
    }
    public static var mostTopViewController:UIViewController?{
        get {
            return UIApplication.shared.keyWindow?.rootViewController
        }
        set {
            UIApplication.shared.keyWindow?.rootViewController = newValue
        }
    }
}
