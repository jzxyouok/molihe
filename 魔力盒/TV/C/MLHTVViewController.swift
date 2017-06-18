//
//  MLHTVViewController.swift
//  魔力盒
//
//  Created by Haitang on 17/6/4.
//  Copyright © 2017年 Haitang. All rights reserved.
//

import UIKit

class MLHTVViewController: MLHBaseViewController {
    var VM:MLHTVVM = MLHTVVM()
 

    var tableView:UITableView = {
        let tab = UITableView(frame: CGRect(x: 0, y: 0, width: 320, height: 568-64), style: UITableViewStyle.plain)
        tab.register(UINib(nibName: "MLHTVTableViewCell", bundle: nil), forCellReuseIdentifier: "MLHTVTableViewCell")
        return tab
    }()
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        tableView.delegate = self
        tableView.dataSource = self
        view.addSubview(self.tableView)
        print(getTimeNow())
        DispatchQueue.main.asyncAfter(deadline: 0.3) {
            print(self.getTimeNow())
            self.loadVM()
        }
    }
    
    func getTimeNow() -> String{
        let formatter = DateFormatter()
        formatter.dateFormat = "YYYY-MM-dd hh:mm:ss:SSS"
        let date = formatter.string(from: Date())
        return date
    }
    fileprivate func loadVM(){
        VM.loadTVData()
        VM.reloadSignal.observe {[weak self] (reload) in
            if reload {
                self?.tableView.reloadData()
            }
        }
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}

extension MLHTVViewController:UITableViewDelegate,UITableViewDataSource{
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 211
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        guard self.VM.whc != nil else {
            return 0
        }
        return self.VM.whc!.data!.posts!.count
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell:MLHTVTableViewCell = tableView.dequeueReusableCell(withIdentifier: "MLHTVTableViewCell", for: indexPath) as! MLHTVTableViewCell
        cell.reloadDataWith(data: (self.VM.whc!.data!.posts?[indexPath.row])!)
        return cell
    }
}
