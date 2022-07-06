//
//  FFsDetailViewController.swift
//  ticticAddtionals
//
//  Created by Naqash Ali on 31/05/2021.
//

import UIKit
import XLPagerTabStrip

class FFsDetailViewController: UIViewController,IndicatorInfoProvider {

    //MARK:- Outlets
    
    @IBOutlet weak var viewFollowing: UIView!
    @IBOutlet weak var viewFollowers: UIView!
    @IBOutlet weak var viewSuggestion: UIView!
    var itemInfo:IndicatorInfo = "View"
    var selectedIndex =  1
    
    //MARK:- API Handler
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    //MARK:-ViewWillAppear
    override func viewWillAppear(_ animated: Bool) {
        if selectedIndex == 1 {
            itemInfo.userInfo = "Followers"
            itemInfo.title = "Followers"
        }
            if itemInfo.title == "Following"{
                print("Followers")
                viewFollowing.isHidden = false
                viewFollowers.isHidden = true
                viewSuggestion.isHidden =  true
            } else if itemInfo.title == "Followers"{
                print("Following")
                viewFollowing.isHidden = true
                viewFollowers.isHidden = false
                viewSuggestion.isHidden =  true
            }else if itemInfo.title == "Suggestion"{
                viewFollowing.isHidden = true
                viewFollowers.isHidden = true
                viewSuggestion.isHidden =  false
            }
    
    }
   

    func indicatorInfo(for pagerTabStripController: PagerTabStripViewController) -> IndicatorInfo {
        return itemInfo
    }

}
