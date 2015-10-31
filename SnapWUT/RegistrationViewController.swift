//
//  RegistrationViewController.swift
//  SnapWUT
//
//  Created by Daniel Sandoval on 10/31/15.
//  Copyright © 2015 Loop CE. All rights reserved.
//

import Foundation
import SwiftForms

class RegistrationViewController : FormViewController {
    override func viewDidLoad() {
        let form = FormDescriptor()
        form.title = "Edit Account Data"
        
        let section1 = FormSectionDescriptor()
        let row = FormRowDescriptor(tag: "username", rowType: .Text, title: "Username", placeholder: "chacal")
        section1.addRow(row)
        
        form.sections = [section1]
        self.form = form;
    }
}