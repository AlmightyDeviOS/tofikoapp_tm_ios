//
//  ReviewVC.swift
//  Restaurent Manager
//
//  Created by APPLE on 21/09/19.
//  Copyright © 2019 com.Coder2. All rights reserved.
//

import UIKit
import HCSStarRatingView

class ReviewCell: UITableViewCell {
    
    @IBOutlet weak var lblDate: UILabel!
    @IBOutlet weak var lblUserName: UILabel!
    @IBOutlet weak var vwRating: HCSStarRatingView!
    @IBOutlet weak var lblReview: UILabel!
    @IBOutlet weak var cnsReplyBtnHeight: NSLayoutConstraint!
    @IBOutlet weak var lblManagerComment: UILabel!
    @IBOutlet weak var btnReply: CustomButton!
}

class ReviewVC: Main {

    //MARK:- Outlets
    @IBOutlet weak var tblReview: UITableView!
    @IBOutlet weak var imgBlur: UIImageView!
    @IBOutlet var vwFeedback: CustomUIView!
    @IBOutlet weak var tvReply: KMTextView!
    @IBOutlet weak var btnMenu: UIButton!
    @IBOutlet weak var consTblHeight: NSLayoutConstraint!
    @IBOutlet weak var lblNodata: UILabel!
    
    @IBOutlet weak var lblFeedbackTitle: UILabel!
    @IBOutlet weak var lblReview: UILabel!
    @IBOutlet weak var btnSubmit: CustomButton!
    //MARK:- Variables
    var arrReview = [[String:String]]()
    var lastTappedReview = -1
    
    var isNotification = false
    
    //Pagination Variables
    var pageNumber = 0
    var isNewDataLoading = true
    var totalCount = 10
    
    //MARK:- View Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        btnSubmit.setTitle(Language.SUBMIT, for: .normal)
        lblReview.text = Language.REVIEW
        lblFeedbackTitle.text = Language.WRITE_FEEDBACK
        tvReply.placeholder = Language.TYPE_REPLY
        
        lblNodata.isHidden = false
        tblReview.isHidden = true
        
        lblNodata.text = Language.NO_REVIEW_FOUND
        
        tblReview.tableFooterView = UIView()
        callRestaurentReviewAPI()
        self.tblReview.addObserver(self, forKeyPath: "contentSize", options: NSKeyValueObservingOptions.new, context: nil)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        
        if isNotification{
            navigationController?.isNavigationBarHidden = true
            btnMenu.setImage(UIImage(named: "back"), for: .normal)
        }
    }
    
    override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        tblReview.layer.removeAllAnimations()
        consTblHeight.constant = tblReview.contentSize.height
        self.updateViewConstraints()
        self.view.layoutIfNeeded()
    }
    
    @IBAction func btnSubmitFeedback_Action(_ sender: UIButton) {
        if tvReply.text != ""{
            callAddRestaurentReviewAPI( (arrReview[lastTappedReview])["id"]!, lastTappedReview)
        }
    }
    
    @IBAction func btnCloseFeedback_Action(_ sender: UIButton) {
        self.vwFeedback.isHidden = true
        self.imgBlur.isHidden = true
    }
    
    @IBAction func btnMenu_Action(_ sender: UIButton) {
        if isNotification{
            (UIApplication.shared.delegate as! AppDelegate).ChangeRoot()
        }else{
            toggleSideMenuView()
        }
    }
    
    @objc func btnReply_Action(_ sender: UIButton) {
        self.vwFeedback.frame.size.width = self.view.frame.size.width - 30.0
        self.vwFeedback.center = self.view.center
        self.view.addSubview(self.vwFeedback)
        self.imgBlur.isHidden = false
        self.vwFeedback.isHidden = false
        lastTappedReview = sender.tag
    }
    
    //MARK:- WebService Calling
    func callRestaurentReviewAPI() {
        guard NetworkManager.shared.isConnectedToNetwork() else {
            self.showWarning(Language.CHECK_INTERNET)
            return
        }
        
        let serviceURL = Constant.WEBURL + Constant.API.GET_REVIEW_LIST
        let params = "?res_id=\(UserModel.sharedInstance().user_id!)&auth_token=\(UserModel.sharedInstance().auth_token!)&start=\(pageNumber)&lang_id=\(UserModel.sharedInstance().app_language!)"
        
        APIManager.shared.requestGETURL(serviceURL + params, success: { (response) in
            if let jsonObject = response.result.value as? [String:AnyObject] {
                if let status = jsonObject["status"] as? String{
                    if status == "0"{
                        print("Failed")
                        self.tblReview.tableFooterView = UIView()
                        self.lblNodata.isHidden = false
                        self.tblReview.isHidden = true
                        //CommonFunctions.shared.showToast(self.view, jsonObject["message"] as! String)
                    }else{
                        self.lblNodata.isHidden = true
                        self.tblReview.isHidden = false
                        print(jsonObject)
                        if let responseData = jsonObject["responsedata"] as? [[String:String]] {
                            
                            if responseData.count == 0{
                                self.isNewDataLoading = true
                            }else{
                                for i in 0..<responseData.count{
                                    self.arrReview.append(responseData[i])
                                }
                                self.tblReview.reloadData()
                                self.isNewDataLoading = false
                            }
                            //CommonFunctions.shared.showToast(self.view, jsonObject["message"] as! String)
                            
                        } else {
                            //CommonFunctions.shared.showToast(self.view, "Something went wrong")
                        }
                        self.tblReview.tableFooterView = UIView()
                    }
                }
            }
            
        }) { (error) in
            print(error)
        }
    }
    
    func callAddRestaurentReviewAPI(_ review_id : String, _ pos: Int) {
        guard NetworkManager.shared.isConnectedToNetwork() else {
            self.showWarning(Language.CHECK_INTERNET)
            return
        }
     
        let serviceURL = Constant.WEBURL + Constant.API.REPLY_OF_REVIEW
        let params = "?res_id=\(UserModel.sharedInstance().user_id!)&auth_token=\(UserModel.sharedInstance().auth_token!)&review_id=\(review_id)&reply_text=\(tvReply.text!)&lang_id=\(UserModel.sharedInstance().app_language!)"
        
        APIManager.shared.requestGETURL(serviceURL + params, success: { (response) in
            if let jsonObject = response.result.value as? [String:AnyObject] {
                if let status = jsonObject["status"] as? String{
                    if status == "0"{
                        print("Failed")
                        //CommonFunctions.shared.showToast(self.view, jsonObject["message"] as! String)
                    }else{
                        print(jsonObject)
                        //CommonFunctions.shared.showToast(self.view, jsonObject["message"] as! String)
//                        self.callRestaurentReviewAPI()
                        
                        self.arrReview[pos]["reply_text"] = self.tvReply.text!
                        self.tblReview.reloadRows(at: [IndexPath(row: pos, section: 0)], with: .none)
                        
                        self.tvReply.text = ""
                        self.vwFeedback.isHidden = true
                        self.imgBlur.isHidden = true
                    }
                }
            }
            
        }) { (error) in
            print(error)
        }
    }
    
}

extension ReviewVC: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return arrReview.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "ReviewCell", for: indexPath) as! ReviewCell

        
        cell.lblUserName.text = (arrReview[indexPath.row])["user_name"]
        cell.lblDate.text = (arrReview[indexPath.row])["added_date"]
        cell.lblReview.text = (arrReview[indexPath.row])["review_text"]
        
        let reply_text = "\((arrReview[indexPath.row])["reply_text"]!)"
        
        if reply_text != ""{
            cell.btnReply.isHidden = true
            cell.cnsReplyBtnHeight.constant = 0
            cell.lblManagerComment.isHidden = false
            cell.lblManagerComment.text = "- \(reply_text)"
        }else{
            cell.btnReply.isHidden = false
            cell.cnsReplyBtnHeight.constant = 40
            cell.lblManagerComment.isHidden = true
        }
        
        if let ratings = arrReview[indexPath.row]["rating"], ratings != "" {
            cell.vwRating.value = CGFloat(Double(ratings)!)
        }else {
            cell.vwRating.value = 0.0
        }
        
        cell.btnReply.setTitle(Language.REPLY, for: .normal)
        
        cell.btnReply.tag = indexPath.row
        cell.btnReply.addTarget(self, action: #selector(btnReply_Action), for: .touchUpInside)
        
        return cell
    }
}
extension ReviewVC: UIScrollViewDelegate {
    func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        
        if ((scrollView.contentOffset.y + scrollView.frame.size.height) >= scrollView.contentSize.height) {
            if !isNewDataLoading{
                pageNumber += totalCount
                print("pagenumber : \(pageNumber)")
                isNewDataLoading = true
                self.callRestaurentReviewAPI()
                
                let spinner = UIActivityIndicatorView(activityIndicatorStyle: .gray)
                spinner.startAnimating()
                spinner.frame = CGRect(x: CGFloat(0), y: CGFloat(0), width: self.tblReview.bounds.width, height: CGFloat(44))
                
                self.tblReview.tableFooterView = spinner
                self.tblReview.tableFooterView?.isHidden = false
            }
        }else{
            print("Scroll Error")
        }
        //}
    }
}

