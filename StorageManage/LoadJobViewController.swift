//
//  LoadJobViewController.swift
//  StorageManage
//
//  Created by 何成健 on 16/11/12.
//  Copyright © 2016年 何成健. All rights reserved.
//

import Cocoa

class LoadJobViewController: NSViewController {
    
    var memory: Memory?
    
    @IBOutlet weak var jobName: NSTextField!
    @IBOutlet weak var coastMemory: NSTextField!
    
    @IBAction func onLoadBtnClick(_ sender: NSButton) {
        let name: String = self.jobName.stringValue
        let size: Int = self.coastMemory.integerValue
        if name.isEmpty {
            return alert("请输入作业名")
        }
        if (self.memory?.existJob(name: name))! {
            return alert("作业名已存在")
        }
        if size <= 0 {
            return alert("请输入正确的内存大小")
        }
        let job: JOB = JOB(name, size)
        if !(self.memory?.load(job))! {
            return alert("分配失败")
        }
        NotificationCenter.default.post(name: NSNotification.Name(rawValue: "receiveJob"), object: nil, userInfo: nil)
        self.dismiss(nil)
    }
    
    func alert(_ msg: String) {
        let alert: NSAlert = NSAlert()
        alert.messageText = "前面有怪兽"
        alert.informativeText = msg
        alert.alertStyle = NSAlertStyle.warning
        alert.addButton(withTitle: "知道了")
        alert.runModal()
    }
}
