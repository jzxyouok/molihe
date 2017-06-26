//
//  MLHMainViewController.swift
//  魔力盒
//
//  Created by Haitang on 17/6/4.
//  Copyright © 2017年 Haitang. All rights reserved.
//

import UIKit

class MLHMainViewController: MLHBaseViewController {
    var hs:String?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let v = UIView(frame: CGRect(x: 100, y: 100, width: 100, height: 100))
        v.backgroundColor = UIColor(0xff0033)
        self.view.addSubview(v)
        // Do any additional setup after loading the view.
     }
 
    @IBAction func pushAction(_ sender: Any) {
        let vc = MLHTestViewController()
        vc.hidesBottomBarWhenPushed = true
        navigationController?.pushViewController(vc, animated: true)
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
