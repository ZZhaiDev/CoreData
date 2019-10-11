//
//  UIViewController+Helper.swift
//  CoreDataPractice
//
//  Created by zijia on 10/11/19.
//  Copyright © 2019 zijia. All rights reserved.
//

import UIKit

class CreateEmployeeController: UIViewController {
    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationItem.title = "Create Employee"
        
        setupCancelButton()
        
        view.backgroundColor = .darkBlue
    }
}
