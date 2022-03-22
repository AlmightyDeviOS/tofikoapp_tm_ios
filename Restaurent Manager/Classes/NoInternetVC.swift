//
//  NoInternetVC.swift
//  Restaurent Manager
//
//  Created by Kinjal Sojitra on 22/04/21.
//  Copyright © 2021 com.Coder2. All rights reserved.
//

import UIKit

class NoInternetVC: Main {

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        setStatusBarColor(AppColors.light_Brown)
    }

    @IBAction func btnBack_Action(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
