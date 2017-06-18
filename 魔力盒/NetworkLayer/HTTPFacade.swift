//
//  HTTPFacade.swift
//  魔力盒
//
//  Created by Haitang on 17/6/9.
//  Copyright © 2017年 Haitang. All rights reserved.
//

import Foundation
import Alamofire
import SwiftyJSON
struct HTTPFacade {
    static let shareInstance = HTTPFacade()
    func loadMagicTVData(_ finished:@escaping(_ response:DataResponse<Any>) -> ())  {
        //https://magicapi.vmovier.cc/magicapiv2/find/magictv
            Alamofire.request(URL(string: "https://magicapi.vmovier.cc/magicapiv2/find/magictv")!, method: .post, parameters: nil, encoding: JSONEncoding.default, headers: [:]).responseJSON(completionHandler: { (response) in
                finished(response)
            })
     }
}



//
// typealias CompleteBlock = (_ error:NSError?, _ resultObejct:Any?) -> ()
// struct HTTPFacade {
// static let shareInstance = HTTPFacade()
// 
// 
// func loadMagicTVData(_ finished:@escaping CompleteBlock)  {
// 
//         Alamofire.request(URL(string: findmagictv)!, method: .post, parameters: nil, encoding: JSONEncoding.default, headers: [:]).responseJSON(completionHandler: { (response) in
//         finished(NSError(),response)
//         })
// }
// 
// 
// private func doHttpRequest(params:[String:Any] , url:String){
// 
// }
// 
// }

