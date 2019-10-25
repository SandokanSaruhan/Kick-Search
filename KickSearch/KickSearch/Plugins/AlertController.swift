//
//  AlertController.swift
//  KickSearch
//
//  Created by Saruhan Kole on 28.06.2019.
//  Copyright © 2019 Peartree Developers. All rights reserved.
//

import UIKit
class SharedClass: NSObject {//This is shared class
    static let sharedInstance = SharedClass()
    
    //Set Up Alert View
    func alert(view: UIViewController, title: String, message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let defaultAction = UIAlertAction(title: "OK", style: .default, handler: { action in
        })
        alert.addAction(defaultAction)
        DispatchQueue.main.async(execute: {
            view.present(alert, animated: true)
        })
    }
    
    private override init() {
    }
}
