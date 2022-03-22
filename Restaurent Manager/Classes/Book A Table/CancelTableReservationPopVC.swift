//
//  CancelTableReservationPopVC.swift
//  Restaurent Manager
//
//  Created by Mahajan on 26/08/21.
//  Copyright © 2021 com.Coder2. All rights reserved.
//

import UIKit
import EzPopup

protocol CancelDelegate : NSObjectProtocol {
    func cancelDelegateReason(_ id: String , _ msg: String)
}

class CancelTableReservationPopVC: Main {

    //MARK: Instantiate Methods
    static func instantiate() -> CancelTableReservationPopVC? {
        return UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "CancelTableReservationPopVC") as? CancelTableReservationPopVC
    }
    
    
    @IBOutlet weak var consTvMessageHeight: NSLayoutConstraint!
    @IBOutlet weak var tfRejectMessage: CustomTextField!
    @IBOutlet weak var tvMessage: KMTextView!
    @IBOutlet weak var btnReject: CustomButton!
    weak var cancelDelegate: CancelDelegate?
    @IBOutlet weak var lblWriteReservation: UILabel!
    @IBOutlet weak var lblRejectTblReservation: UILabel!
    
    var id = ""
    var reject_reason = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tfRejectMessage.text = Language.SELECT
        btnReject.setTitle(Language.REJECTS, for: .normal)
        lblWriteReservation.text = Language.WRITE_TBL_REJECTION_MSG
        lblRejectTblReservation.text = Language.REJECT_TBL_RESERVATION
        tvMessage.placeholder = Language.WRITE_QUERY_HERE

    }
    
    @IBAction func btnReject_Action(_ sender: UIButton) {
        self.view.endEditing(true)
        if reject_reason != ""{
            self.dismiss(animated: true) {
                var rejectReason = ""
                if self.reject_reason == Language.OTHER {
                    rejectReason = self.tvMessage.text!
                }else {
                    rejectReason = self.reject_reason
                }
                
                self.cancelDelegate?.cancelDelegateReason(self.id , rejectReason)
            }
        }
    }
    
    func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
        if textField == tfRejectMessage {
            let arrOptions = [Language.PRODUCT_NOT_AVAILABLE, Language.EXTRA_CLOSURE, Language.TECH_PROBLEM, Language.OTHER]
            ActionSheetStringPicker.show(withTitle: "", rows: arrOptions as [Any], initialSelection: 0, doneBlock: {
                picker, indexes, values in
                if values != nil{
                    if let strValue = values as? String {
                        self.reject_reason = strValue
                        self.tfRejectMessage.text = strValue
                        if strValue == Language.OTHER {
                            self.tvMessage.isHidden = false
                            self.consTvMessageHeight.constant = 120.0
                        }else {
                            self.tvMessage.isHidden = true
                            self.consTvMessageHeight.constant = 0.0
                        }
                     }
                }
                return
            }, cancel: { ActionStringCancelBlock in
                return
            }, origin: tfRejectMessage)
            
            return false
        }
        return false
    }
    
}
