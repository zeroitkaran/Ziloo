//
//  HomeVideoViewController.swift
//  MusicTok
//
//  Created by Mac on 05/08/2021.
//  Copyright © 2021 Mac. All rights reserved.
//

import UIKit
import EFInternetIndicator


@available(iOS 13.0, *)
class HomeVideoViewController: UIViewController,videoLikeDelegate,UICollectionViewDataSource,UICollectionViewDelegate,UICollectionViewDelegateFlowLayout{ 
    //MARK:- Outlets
    @IBOutlet weak var videoCollectionView: UICollectionView!
    @IBOutlet weak var btnBack: UIButton!
    @IBOutlet weak var btnLiveUser: UIButton!
    @IBOutlet weak var btnFollowing: UIButton!
    @IBOutlet weak var btnRelated: UIButton!
    @IBOutlet weak var viewOptions: UIView!   // Following , Related , Live Users
    
    let spinner = UIActivityIndicatorView(style: .gray)
    
    //MARK:- Variables
    
    var videosMainArr = [videoMainMVC]()
    var isFollowing = false
    var startPoint = 0
    var videoEmpty = false
    var isOtherController =  false             //Coming from other controller
    var currentIndex : IndexPath?             //Coming from other controller
    
    lazy var refresher: UIRefreshControl = {
        let refreshControl = UIRefreshControl()
        refreshControl.tintColor = .white
        refreshControl.addTarget(self, action: #selector(requestData), for: .valueChanged)
        
        return refreshControl
    }()
    //MARK:- viewDidLoad
    
    override func viewDidLoad() {
        super.viewDidLoad()
        NotificationCenter.default.addObserver(self, selector: #selector(self.methodOfReceivedNotification(notification:)), name: Notification.Name("errInPlay"), object: nil)
        self.relatedButton()
        self.setupView()
        self.btnLiveUser.isHidden = true
    }
    
    // MARK:- viewWillDisappear
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        let visiblePaths = self.videoCollectionView.indexPathsForVisibleItems
        for i in visiblePaths  {
            let cell = videoCollectionView.cellForItem(at: i) as? HomeVideoCollectionViewCell
            cell?.pause()
            
        }
       
    }
    
    // MARK:- viewWillAppear
    
    override func viewWillAppear(_ animated: Bool) {
        
        let visiblePaths = self.videoCollectionView.indexPathsForVisibleItems
        for i in visiblePaths  {
            let cell = videoCollectionView.cellForItem(at: i) as? HomeVideoCollectionViewCell
            cell?.play()
        }
        
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .vertical
        layout.minimumInteritemSpacing = 0
        layout.minimumLineSpacing = 0
        videoCollectionView.isPagingEnabled = true
        videoCollectionView.setCollectionViewLayout(layout, animated: true)
    }
    
    // MARK:- NotificationCenter
    
    @objc func methodOfReceivedNotification(notification: Notification) {
        if let err = notification.userInfo?["err"] as? String {
            showToast(message: err, font: .systemFont(ofSize: 14.0))
        }
    }
    

    //MARK:- Deniet Notification
    
    deinit {
        NotificationCenter.default.removeObserver(self, name: Notification.Name("errInPlay"), object: nil)
    }
    //MARK:- SetupView
    
    func setupView(){
     
        spinner.color = UIColor.white
        spinner.hidesWhenStopped = true
        videoCollectionView.refreshControl = refresher

        self.getDataForFeeds()

    }
    
    //MARK:- Refresher Controller
    
    @objc func requestData() {
        print("requesting data")
        self.startPoint = 0
        if isFollowing == true{
            getFollowingVideos(startPoint: "\(startPoint)")
        }else{
            self.getAllVideos(startPoint: "\(startPoint)")
        }
        let deadline = DispatchTime.now() + .milliseconds(700)
        DispatchQueue.main.asyncAfter(deadline: deadline) {
            self.refresher.endRefreshing()
        }
    }
    
    //MARK:- Button Action
    @IBAction func btnBack(_ sender: Any) {
        navigationController?.popViewController(animated: true)
    }
    
    @IBAction func btnSelection(_ sender: AnyObject) {
        self.btnLayoutDesign(sender: sender.tag)
    }
    
    @IBAction func btnLiveUsers(_ sender: Any) {
        let vc = storyboard?.instantiateViewController(withIdentifier: "liveUsersVC") as! liveUsersViewController
        vc.hidesBottomBarWhenPushed = true
        navigationController?.pushViewController(vc, animated: true)
    }
    //MARK: collectionView
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.videosMainArr.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "HomeVideoCollectionViewCell", for: indexPath) as! HomeVideoCollectionViewCell
        cell.configure(post: self.videosMainArr[indexPath.row])
        cell.likeBtn.tag = indexPath.row
        cell.commentBtn.tag = indexPath.row
        cell.delegate = self
        cell.delegateHomeVideoVC = self
        return cell
    }
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        return CGSize(width:collectionView.layer.bounds.width , height: collectionView.layer.bounds.height)
        
    }
    func collectionView(_ collectionView: UICollectionView, didEndDisplaying cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        if let cell = cell as? HomeVideoCollectionViewCell {
            cell.pause()
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        if let cell = cell as? HomeVideoCollectionViewCell {
            cell.play()
        }
        self.pagination(index: indexPath.row)
        
    }
    
    
  
    //MARK:- Delegate
    
    func updateObj(obj: videoMainMVC, index: Int,islike:Bool) {
        self.videosMainArr.remove(at: index)
        self.videosMainArr.insert(obj, at: index)
        if islike{
            self.likeVideo(uid: UserDefaults.standard.string(forKey: "userID") as? String ?? "" , videoID: obj.videoID)
        }
    }
    
    //MARK:- Pagination
    
    
    func pagination(index:Int){
        let vidObj = videosMainArr[index]
        self.WatchVideo(video_id: vidObj.videoID)
        print("index@row: ",index)
        print("videoID: \( vidObj.videoID), videoURL: \( vidObj.videoURL)")
        if index == videosMainArr.count-1{
            if self.videosMainArr.count == 0 {
                self.videoCollectionView.scrollToItem(at: IndexPath(row: 0, section: 0), at: .top, animated: true)
                
            }
        }
        if self.videosMainArr.count != 0{
            if index == videosMainArr.count - 4{
                print("Pagination start")
                self.startPoint+=1
                print("StartPoint: ",startPoint)
                if isOtherController ==  false{
                    if isFollowing == true{
                        self.getFollowingVideos(startPoint: "\(self.startPoint)")
                    }else{
                        self.getAllVideos(startPoint: "\(self.startPoint)")
                    }
                }
            }
        }
    }
    
    //MARK:- API handler
    
    func getAllVideos(startPoint:String){
        
        var userID = UserDefaults.standard.string(forKey: "userID")
        
        if userID == "" || userID == nil{
            userID = ""
        }
        let startingPoint = startPoint
        let deviceID = UserDefaults.standard.string(forKey: "deviceID")
        print("deviceid: ",deviceID)
        
        ApiHandler.sharedInstance.showRelatedVideos(device_id: deviceID!, user_id: userID!, starting_point: startingPoint) { (isSuccess, response) in
            print("res Related video : ",response!)
            print("isSuccess : ",isSuccess)
          //  self.showToast(message: "Loading ...", font: .systemFont(ofSize: 12))
            if isSuccess {
                self.spinner.startAnimating()

                if response?.value(forKey: "code") as! NSNumber == 200 {
                    if startPoint == "0"{
                        self.videosMainArr.removeAll()
                    }
                   self.videoResponse(startPoint:startPoint, resMsg: response as! [String : Any])
                }else{
         
                   // self.showToast(message: (response?.value(forKey: "msg") as? String)!, font: .systemFont(ofSize: 12))
                }
            }else{
                print("response failed getAllVideos : ",response!)
                self.showToast(message: (response?.value(forKey: "msg") as? String)!, font: .systemFont(ofSize: 12))
            }
        }
    }
    func getFollowingVideos(startPoint:String){
                
        let startingPoint = startPoint
        
        let userID = UserDefaults.standard.string(forKey: "userID")
        let deviceID = UserDefaults.standard.string(forKey: "deviceID")
        self.showToast(message: "Loading ...", font: .systemFont(ofSize: 12))
        ApiHandler.sharedInstance.showFollowingVideos(user_id: userID!, device_id: deviceID!, starting_point: startingPoint) { (isSuccess, response) in
            print("res following videos: ",response!)
                self.showToast(message: "Loading ...", font: .systemFont(ofSize: 12.0))
            if isSuccess {
                self.showToast(message: "Loading ...", font: .systemFont(ofSize: 12.0))
                if response?.value(forKey: "code") as! NSNumber == 200 {
                    if startPoint == "0"{
                        self.videosMainArr.removeAll()
                    }
                    self.videoResponse(startPoint: startPoint, resMsg: response as! [String : Any])
                    
                }else{
                    self.btnRelated.setTitleColor(#colorLiteral(red: 0.6000000238, green: 0.6000000238, blue: 0.6000000238, alpha: 1), for: .normal)
                    self.btnFollowing.setTitleColor(UIColor.white, for: .normal)
                    
                    self.showToast(message: "Please Follow Someone", font: .systemFont(ofSize: 12))
                }
            }else{
                print("response failed getFollowingVideos : ",response!)
                self.showToast(message: response?.value(forKey: "msg") as! String, font: .systemFont(ofSize: 12))
            }
        }
    }
    
    
    func WatchVideo(video_id:String){
    
        var userID = UserDefaults.standard.string(forKey: "userID")
        
        if userID == "" || userID == nil{
            userID = ""
        }
        let deviceID = UserDefaults.standard.string(forKey: "deviceID")
        
        print("deviceid: ",deviceID)
        ApiHandler.sharedInstance.watchVideo(device_id: deviceID!, user_id: userID!,video_id:video_id) { (isSuccess, response) in
            if isSuccess {
                if response?.value(forKey: "code") as! NSNumber == 200 {
                  //  print(" WatchVideo response@200: ",response!)
                }
                else{
                    //print("WatchVideo response@201: ",response!)
                }
            }
        }
    }
    func likeVideo(uid:String,videoID:String){
   
        ApiHandler.sharedInstance.likeVideo(user_id: uid, video_id: videoID) { (isSuccess, response) in
       
            if isSuccess{
                if response?.value(forKey: "code") as! NSNumber == 200 {
                    //print("likeVideo response msg: ",response?.value(forKey: "msg"))
                }else{
                    //print("likeVideo response msg: ",response?.value(forKey: "msg"))
                }
            }
        }
    }

    
    //MARK:- API Response
    func videoResponse(startPoint:String,resMsg:[String:Any]){
        
        
        let resMsg = resMsg["msg"] as! [[String:Any]]
        for dic in resMsg{
            let videoDic = dic["Video"] as! NSDictionary
            let userDic = dic["User"] as! NSDictionary
            let soundDic = dic["Sound"] as! NSDictionary
            
            print("videoDic: ",videoDic)
            print("userDic: ",userDic)
            print("soundDic: ",soundDic)
            
            let videoURL = videoDic.value(forKey: "video") as? String
            let desc = videoDic.value(forKey: "description") as? String
            let allowComments = videoDic.value(forKey: "allow_comments")
            let videoUserID = videoDic.value(forKey: "user_id")
            let videoID = videoDic.value(forKey: "id") as! String
            let allowDuet = videoDic.value(forKey: "allow_duet")
            let duetVidID = videoDic.value(forKey: "duet_video_id")
            
            //not strings
            let commentCount = videoDic.value(forKey: "comment_count")
            let likeCount = videoDic.value(forKey: "like_count")
            
            let userImgPath = userDic.value(forKey: "profile_pic") as? String
            let userName = userDic.value(forKey: "username") as? String
            let followBtn = userDic.value(forKey: "button") as? String
            let uid = userDic.value(forKey: "id") as? String
            let verified = userDic.value(forKey: "verified")
            
            let soundName = soundDic.value(forKey: "name")
            let cdPlayer = soundDic.value(forKey: "thum") as? String ?? ""
       
                let videoObj = videoMainMVC(videoID: videoID, videoUserID: "\(videoUserID!)", fb_id: "", description: desc ?? "", videoURL: videoURL ?? "", videoTHUM: "", videoGIF: "", view: "", section: "", sound_id: "", privacy_type: "", allow_comments: "\(allowComments!)", allow_duet: "\(allowDuet!)", block: "", duet_video_id: "", old_video_id: "", created: "", like: "", favourite: "", comment_count: "\(commentCount!)", like_count: "\(likeCount!)", followBtn: followBtn ?? "", duetVideoID: "\(duetVidID!)", userID: uid ?? "", first_name: "", last_name: "", gender: "", bio: "", website: "", dob: "", social_id: "", userEmail: "", userPhone: "", password: "", userProfile_pic: userImgPath  ?? "", role: "", username: userName  ?? "", social: "", device_token: "", videoCount: "", verified: "\(verified)", soundName: "\(soundName)", CDPlayer: cdPlayer)
                self.videosMainArr.append(videoObj)
         
        }
      
        self.videoCollectionView.reloadData()
    }
    //MARK:- function
    
    func getDataForFeeds(){
        if isOtherController == true{
            self.viewOptions.isHidden =  true
            btnBack.isHidden = false
            btnLiveUser.isHidden = true
            self.videoCollectionView.performBatchUpdates(nil, completion: {
                (result) in
                self.videoCollectionView.scrollToItem(at:self.currentIndex!, at: .bottom, animated: false)
            })
        }else{
            self.videosMainArr = videoArr
            if self.videosMainArr.count != 0 {
                self.videoEmpty =  false
            }
            self.viewOptions.isHidden =  false
            btnBack.isHidden = true
        }
    }
    
    func btnLayoutDesign(sender:Int){
        self.startPoint = 1
        if sender == 0 {
            print("Select 0")
            let userID = UserDefaults.standard.string(forKey: "userID")
            if userID == nil || userID == ""{
                loginScreenAppear()
            }else{
                self.followingButton()
            }
        }else{
            self.relatedButton()
            getAllVideos(startPoint: "\(startPoint)")
        }
    }
    
    func relatedButton(){
        self.btnRelated.setTitleColor(UIColor.white, for: .normal)
        self.btnFollowing.setTitleColor(#colorLiteral(red: 0.6000000238, green: 0.6000000238, blue: 0.6000000238, alpha: 1), for: .normal)
        self.btnRelated.layer.shadowColor = #colorLiteral(red: 1, green: 1, blue: 1, alpha: 1)
        self.btnRelated.layer.shadowOffset = CGSize(width: 0.2, height: 0.2)
        self.btnRelated.layer.shadowRadius = 2
        self.btnRelated.layer.shadowOpacity = 1.0
        
        self.btnFollowing.layer.shadowOffset = CGSize(width: 0, height: 0)
        self.btnFollowing.layer.shadowRadius = 0
        self.btnFollowing.layer.shadowOpacity = 0
        
        print("Select 1")
        self.isFollowing = false
    }
    
    
    func followingButton(){
        print("device key: ",UserDefaults.standard.string(forKey: "deviceKey")!)
        self.btnRelated.setTitleColor(#colorLiteral(red: 0.6000000238, green: 0.6000000238, blue: 0.6000000238, alpha: 1), for: .normal)
        self.btnFollowing.setTitleColor(UIColor.white, for: .normal)
        self.btnFollowing.layer.shadowColor = #colorLiteral(red: 1, green: 1, blue: 1, alpha: 1)
        self.btnFollowing.layer.shadowOffset = CGSize(width: 0.2, height: 0.2)
        self.btnFollowing.layer.shadowRadius = 2
        self.btnFollowing.layer.shadowOpacity = 1.0
        
        self.btnRelated.layer.shadowOffset = CGSize(width: 0, height: 0)
        self.btnRelated.layer.shadowRadius = 0
        self.btnRelated.layer.shadowOpacity = 0
        
        self.isFollowing = true
        getFollowingVideos(startPoint: "\(startPoint)")
    }
    //MARK:- LoginScreen
    
    func loginScreenAppear(){
        let navController = UINavigationController.init(rootViewController: self.storyboard!.instantiateViewController(withIdentifier: "newLoginVC"))
        navController.navigationBar.isHidden = true
        navController.modalPresentationStyle = .overFullScreen

        self.present(navController, animated: true, completion: nil)
    }
}
