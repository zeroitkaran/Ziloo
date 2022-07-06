//
//  phoneNoViewController.swift
//  TIK TIK
//
//  Created by Mac on 12/10/2020.
//  Copyright © 2020 Mac. All rights reserved.
//

import UIKit
import PhoneNumberKit
import ContactsUI
import SKCountryPicker

class phoneNoViewController: UIViewController,UITextFieldDelegate,CNContactPickerDelegate {
    
//    @IBOutlet var phoneNoTxtField: PhoneNumberTextField!
    
    @IBOutlet weak var titleLbl: UILabel!
    @IBOutlet var phoneNoTxtField: UITextField!
    @IBOutlet weak var emailContainerVIEW: UIView!
    @IBOutlet weak var emailSignupContainerVIEW: UIView!
    @IBOutlet weak var btnSendCode: UIButton!
    @IBOutlet weak var btnPhone: UIButton!
    @IBOutlet weak var btnEmail: UIButton!
    @IBOutlet weak var btnPhoneBottomView: UIView!
    @IBOutlet weak var btnEmailBottomView: UIView!
    @IBOutlet weak var btnCountryCode: UIButton!
    
    var sign_loginType = ""
    var dialCode = "+91"
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        emailContainerVIEW.isHidden =  true
        emailSignupContainerVIEW.isHidden = true
        
        btnSendCode.backgroundColor = #colorLiteral(red: 0.9528577924, green: 0.9529947639, blue: 0.9528278708, alpha: 1)
        btnSendCode.setTitleColor(#colorLiteral(red: 0.6437677741, green: 0.6631219387, blue: 0.6758852601, alpha: 1), for: .normal)
        btnSendCode.isUserInteractionEnabled = false
        btnEmailBottomView.isHidden = true
        
//        phoneNoTxtFieldSetup()
        phoneNoTxtField.addTarget(self, action: #selector(phoneNoViewController.textFieldDidChange(_:)), for: .editingChanged)        // Do any additional setup after loading the view.
        
        NotificationCenter.default.addObserver(self, selector: #selector(self.countryDataNoti(_:)), name: NSNotification.Name(rawValue: "countryDataNoti"), object: nil)
        NotificationCenter.default.post(name: Notification.Name("pauseSongNoti"), object: nil)

        if sign_loginType == "signUp" {
            self.titleLbl.text = "Sign Up"
            
        } else {
            self.titleLbl.text = "Login"
            btnSendCode.setTitle("Login", for: .normal)
        }
        
        
        
    }
    
    @objc func countryDataNoti(_ notification: NSNotification) { 
//      if let image = notification.userInfo?["image"] as? UIImage {
//      // do something with your image
//      }
        
        print("notification.userInfo: ",notification.userInfo?["name"] )
        
        let newDialCode = notification.userInfo?["dial_code"] as! String
        let code = notification.userInfo?["code"] as! String
        
        self.dialCode = newDialCode
        btnCountryCode.setTitle("\(code) \(newDialCode)", for: .normal)
    }
    
    @objc func textFieldDidChange(_ textField: UITextField) {
        
        let textCount = textField.text?.count
        
        print("change textCount: ",textCount)
        if textCount! > 0 {
            btnSendCode.backgroundColor = UIColor(named: "theme")
            btnSendCode.setTitleColor(#colorLiteral(red: 1, green: 1, blue: 1, alpha: 1), for: .normal)
            btnSendCode.isUserInteractionEnabled = true
        }else{
            btnSendCode.backgroundColor = #colorLiteral(red: 0.9528577924, green: 0.9529947639, blue: 0.9528278708, alpha: 1)
            btnSendCode.setTitleColor(#colorLiteral(red: 0.6437677741, green: 0.6631219387, blue: 0.6758852601, alpha: 1), for: .normal)
            btnSendCode.isUserInteractionEnabled = false
        }
    }
    
    /*
    func phoneNoTxtFieldSetup(){
//        self.phoneNoTxtField.becomeFirstResponder()
//        self.phoneNoTxtField.text = "+92000000000"
        self.phoneNoTxtField.placeholder = "+92000000000"
        self.phoneNoTxtField.withPrefix = true
        self.phoneNoTxtField.withFlag = true
        self.phoneNoTxtField.withExamplePlaceholder = true
//        self.phoneNoTxtField.i
        if #available(iOS 11.0, *) {
            self.phoneNoTxtField.withDefaultPickerUI = true
        }
        

    }
    
    */
    
    
    @IBAction func btnSendCodeAction(_ sender: Any) {
        if sign_loginType == "signUp"{
            //UserDefaults.standard.set("phoneSignup", forKey: "signUpType")
            print("phone no. ",self.dialCode+phoneNoTxtField.text!)
            if AppUtility?.isValidPhoneNumber(strPhone: self.dialCode+phoneNoTxtField.text!) == true{
                self.verifyPhoneFunc()
            }else{
                showToast(message: "Invalid Number", font: .systemFont(ofSize: 12))
            }
        }else{
            if AppUtility?.isValidPhoneNumber(strPhone: self.dialCode+phoneNoTxtField.text!) == true{
              //self.showToast(message: "Comming soon..", font: .systemFont(ofSize: 12))
                self.loginPhone()
            }else{
                showToast(message: "Invalid Number", font: .systemFont(ofSize: 12))
            }
        }
        
        /*
        if phoneNoTxtField.isValidNumber == true {
            verifyPhoneFunc()
        }else{
            showToast(message: "Invalid Number", font: .systemFont(ofSize: 12))
        }
         */
    }
    
    //    MARK:- Login Phone API func
        func loginPhone(){
            let phoneNo = self.dialCode+phoneNoTxtField.text!
            print("phoneNo: ",phoneNo)
            AppUtility?.startLoader(view: self.view)
            ApiHandler.sharedInstance.phonelogin(phone: phoneNo) { (isSuccess, response) in
                if isSuccess{
                    if response?.value(forKey: "code") as! NSNumber == 200 {
                        AppUtility?.stopLoader(view: self.view)
                        self.showToast(message: "Signin" as! String, font: .systemFont(ofSize: 12))
                        sleep(1)                          
                        let msgObj = response?.value(forKey: "msg") as! NSDictionary
                        let userObj = msgObj.value(forKey: "User") as! NSDictionary
                        print("user obj: ",userObj)
                        //if user already registered code it
                        let user = User()
                        user.id = userObj.value(forKey: "id") as? String
                        user.active = userObj.value(forKey: "active") as? String
                        user.city = userObj.value(forKey: "city") as? String
                        
                        UserDefaults.standard.set(userObj.value(forKey: "id") as? String, forKey: "userID")
                        UserDefaults.standard.set(userObj.value(forKey: "auth_token") as? String, forKey: "authToken")
                        
                        print("userdefault: ",UserDefaults.standard.string(forKey: "userID"))
                        user.country = userObj.value(forKey: "country") as? String
                        user.created = userObj.value(forKey: "created") as? String
                        user.device = userObj.value(forKey: "device") as? String
                        user.dob = userObj.value(forKey: "dob") as? String
                        
                        user.email = userObj.value(forKey: "email") as? String
                        user.fb_id = userObj.value(forKey: "fb_id") as? String
                        
                        user.first_name = userObj.value(forKey: "first_name") as? String
                        user.gender = userObj.value(forKey: "gender") as? String
                        user.last_name = userObj.value(forKey: "last_name") as? String
                        user.ip = userObj.value(forKey: "ip") as? String
                        user.lat = userObj.value(forKey: "lat") as? String
                        user.long = userObj.value(forKey: "long") as? String
                        user.online = userObj.value(forKey: "online") as? String
                        user.password = userObj.value(forKey: "password") as? String
                        user.phone = userObj.value(forKey: "phone") as? String
                        user.bio = userObj.value(forKey: "bio") as? String

                        user.profile_pic = userObj.value(forKey: "profile_pic") as? String
                        user.role = userObj.value(forKey: "role") as? String
                        user.social = userObj.value(forKey: "social") as? String
                        user.social_id = userObj.value(forKey: "social_id") as? String
                        user.username = userObj.value(forKey: "username") as? String
                        user.verified = userObj.value(forKey: "verified") as? String
                        user.version = userObj.value(forKey: "version") as? String
                        user.website = userObj.value(forKey: "website") as? String
                        user.wallet = userObj.value(forKey: "wallet") as? String
                        user.comments = userObj.value(forKey: "comments") as? String
                        user.direct_messages = userObj.value(forKey: "direct_messages") as? String
                        
                        user.likes = userObj.value(forKey: "likes") as? String
                        user.mentions = userObj.value(forKey: "mentions") as? String
                        user.new_followers = userObj.value(forKey: "new_followers") as? String
                        user.video_updates = userObj.value(forKey: "video_updates") as? String
                        user.direct_message = userObj.value(forKey: "direct_message") as? String
                        
                        user.duet = userObj.value(forKey: "duet") as? String
                        user.liked_videos = userObj.value(forKey: "liked_videos") as? String
                        user.video_comment = userObj.value(forKey: "video_comment") as? String
                        user.videos_download = userObj.value(forKey: "videos_download") as? String
                        
                        if User.saveUserToArchive(user: [user]){
                            self.view.window?.rootViewController?.dismiss(animated: true, completion: nil)
                        }
                        
                    }else{
                        AppUtility?.stopLoader(view: self.view)
                        self.alertModule(title: NSLocalizedString("alert_app_name", comment: ""), msg: response?.value(forKey: "msg") as! String)
                    }
                }else{
                    self.alertModule(title: NSLocalizedString("alert_app_name", comment: ""), msg: response?.value(forKey: "msg") as! String)
                }
            }
        }
    
    
    
    
    
    @IBAction func btnPhoneAction(_ sender: Any) {
        btnEmailBottomView.isHidden = true
        btnEmail.setTitleColor(.black, for: .normal)
        emailContainerVIEW.isHidden = true
        emailSignupContainerVIEW.isHidden = true
        btnPhoneBottomView.isHidden = false
        btnPhone.setTitleColor(UIColor(named: "theme"), for: .normal)
        
        
    }
    
    @IBAction func btnEmailAction(_ sender: Any) {
        btnPhoneBottomView.isHidden = true
        btnPhone.setTitleColor(.black, for: .normal)
//        print(UserDefaults.standard.string(forKey: "signUpType"))
        if sign_loginType == "signUp"{
            emailSignupContainerVIEW.isHidden = false
        }else if sign_loginType == "signIn"{
            emailContainerVIEW.isHidden = false            
        }
        
        btnEmailBottomView.isHidden = false
        btnEmail.setTitleColor(UIColor(named: "theme"), for: .normal)
        
    }
    
//    MARK:- BTN COUNTRY CODE ACTION
    @IBAction func btnCountryCode(_ sender: Any) {
        let vc = self.storyboard?.instantiateViewController(withIdentifier: "countryCodeVC") as! countryCodeViewController
        present(vc, animated: true, completion: nil)
        
    }
    
    func verifyPhoneFunc(){
        let phoneNo = self.dialCode+phoneNoTxtField.text!
        print("phoneNo: ",phoneNo)
        AppUtility?.startLoader(view: self.view)
        ApiHandler.sharedInstance.verifyPhoneNo(phone: phoneNo, verify: "0") { (isSuccess, response) in
            if isSuccess{
                if response?.value(forKey: "code") as! NSNumber == 200 {
                    AppUtility?.stopLoader(view: self.view)
                  //  self.alertModule(title: NSLocalizedString("alert_app_name", comment: ""), msg: response?.value(forKey: "msg") as! String )
                    print("respone: ",response?.value(forKey: "msg") as! String)
                    if #available(iOS 13.0, *) {
                        let vc = self.storyboard?.instantiateViewController(withIdentifier: "otpVC") as! otpViewController
                        vc.phoneNo = self.dialCode+self.phoneNoTxtField.text!
                        self.navigationController?.pushViewController(vc, animated: true)
                    } else {
                        // Fallback on earlier versions
                        print("iOS is not 12.0, *")
                    }
                    
                }else{
                    AppUtility?.stopLoader(view: self.view)
                    self.alertModule(title: NSLocalizedString("alert_app_name", comment: ""), msg: response?.value(forKey: "msg") as! String)
                }
            }else{
                AppUtility?.stopLoader(view: self.view)
                self.showToast(message: response?.value(forKey: "msg") as! String, font: .systemFont(ofSize: 12.0))
            }
        }
    }
    
        //    MARK:- Terms & privacy
        @IBAction func privacy(_ sender: Any) {
            
            let vc = storyboard?.instantiateViewController(withIdentifier: "termsCondVC") as! termsCondViewController
            vc.privacyDoc = true
            vc.modalPresentationStyle = .fullScreen
            present(vc, animated: true, completion: nil)
    //        guard let url = URL(string: "https://termsfeed.com/privacy-policy/9a03bedc2f642faf5b4a91c68643b1ae") else { return }
    //        UIApplication.shared.open(url)
        }
        
        @IBAction func terms(_ sender: Any) {
            
            let vc = storyboard?.instantiateViewController(withIdentifier: "termsCondVC") as! termsCondViewController
            vc.privacyDoc = false
            vc.modalPresentationStyle = .fullScreen
            present(vc, animated: true, completion: nil)
            
    //        guard let url = URL(string: "https://termsfeed.com/terms-conditions/72b8fed5b38e082d48c9889e4d1276a9") else { return }
    //        UIApplication.shared.open(url)
            
        }
    
    @IBAction func btnBack(_ sender: Any) {
        navigationController?.popViewController(animated: true)
    }
    
    @IBAction func btnTest(_ sender: Any) {
       let countryController = CountryPickerWithSectionViewController.presentController(on: self)
       { [weak self] (country: Country) in
           
           if let self = self
           {
//               self.countryImage.image = country.flag
//               self.lblCountryCode.text = "\(country.dialingCode!)"
            
            print("country.dialingCode!: ",country.dialingCode!)
           }
           else
           {
               return
           }
           
       }
       // can customize the countryPicker here e.g font and color
       countryController.detailColor = #colorLiteral(red: 0.9568627451, green: 0.5490196078, blue: 0.01960784314, alpha: 1)
        countryController.detailFont.withSize(9.0)
        countryController.labelFont.withSize(9.0)
        countryController.flagStyle = .circular
    }
    
    //    MARK:- ALERT MODULE
    func alertModule(title:String,msg:String){
        
        let alertController = UIAlertController(title: title, message: msg, preferredStyle: .alert)
        
        let alertAction = UIAlertAction(title: "OK", style: UIAlertAction.Style.destructive, handler: {(alert : UIAlertAction!) in
            alertController.dismiss(animated: true, completion: nil)
        })
        
        alertController.addAction(alertAction)
        
        present(alertController, animated: true, completion: nil)
        
    }      
    
}
