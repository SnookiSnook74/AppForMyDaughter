//
//  ViewController.swift
//  AppForMyDaughter
//
//  Created by DonHalab on 19.05.2024.
//

import UIKit

class StartViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .green
        
        CoreDataManager.shared.addMessages(text: "Hello", sender: "user")
    }


}

