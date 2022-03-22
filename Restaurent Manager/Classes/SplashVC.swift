//
//  SplashVC.swift
//  Restaurent Manager
//
//  Created by APPLE on 21/09/19.
//  Copyright © 2019 com.Coder2. All rights reserved.
//

import UIKit

class SplashVC: Main {
        
    //MARK:- View Life Cycle Method
    override func viewDidLoad() {
        super.viewDidLoad()
        
        DispatchQueue.main.asyncAfter(wallDeadline: .now() + 3.0) {
            if UserModel.sharedInstance().user_id != nil && UserModel.sharedInstance().user_id! != "" {
                
                (UIApplication.shared.delegate as! AppDelegate).ChangeRoot()
                
            }else{
                (UIApplication.shared.delegate as! AppDelegate).changeLoginRoot()
            }
        }
    }
    
    
}
