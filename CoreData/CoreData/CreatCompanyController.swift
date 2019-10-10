//
//  CreatCompanyController.swift
//  CoreData
//
//  Created by zijia on 10/10/19.
//  Copyright © 2019 zijia. All rights reserved.
//

import UIKit

class CreateCompanyController: UIViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationItem.title = "Create Company"
        
        navigationItem.leftBarButtonItem = UIBarButtonItem(title: "Cancel", style: .plain, target: self, action: #selector(handleCancel))
        
        view.backgroundColor = UIColor.darkBlue
    }
    
    @objc func handleCancel() {
        dismiss(animated: true, completion: nil)
    }
    
}
