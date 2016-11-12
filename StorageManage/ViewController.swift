//
//  ViewController.swift
//  StorageManage
//
//  Created by 何成健 on 16/11/11.
//  Copyright © 2016年 何成健. All rights reserved.
//

import Cocoa

class ViewController: NSViewController {

    @IBOutlet weak var storageSegmented: NSSegmentedControl!
    @IBOutlet weak var memoryLabel: NSTextField!
    @IBOutlet weak var dispatchType: NSPopUpButton!
    @IBOutlet weak var recoverBtn: NSButton!
    
    var memory: Memory = Memory(128)
    var memoryBlock: [MemoryBlock] = []
    var segmentedMaxWidth: CGFloat = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        segmentedMaxWidth = storageSegmented.width(forSegment: 0)//获取最大宽度
        self.memoryBlock = memory.getMemory()
        NotificationCenter.default.addObserver(self, selector: #selector(self.addJob(notification:)), name:NSNotification.Name(rawValue: "receiveJob"), object: nil)
    }
    
    override func prepare(for segue: NSStoryboardSegue, sender: Any?) {
        let dstView: LoadJobViewController! = segue.destinationController as! LoadJobViewController
        dstView.memory = self.memory
    }
    
    @IBAction func onResetBtnClick(_ sender: NSButton) {
        memory.release()
        refreshSegment()
    }
    
    @IBAction func onDispatchTypeChange(_ sender: NSPopUpButton) {
        memory.dispatchType = sender.indexOfSelectedItem
    }
    
    @IBAction func onRecoverBtnClick(_ sender: NSButton) {
        let block = self.memoryBlock[self.storageSegmented.selectedSegment]
        if block.job != nil {
            self.memory.release(name: (block.job?.name)!)
            refreshSegment()
        }
    }

    @IBAction func onStorageSegmentedSelected(_ sender: NSSegmentedControl) {
        let block = self.memoryBlock[sender.selectedSegment]
        if block.job == nil {
            memoryLabel.stringValue = "块大小:\(block.size),起始地址:\(block.startIndex),未被分配"
            recoverBtn.isHidden = true
        }else{
            memoryLabel.stringValue = "块大小:\(block.size),起始地址:\(block.startIndex),作业名称:\((block.job?.name)!),作业大小:\((block.job?.memory)!)"
            recoverBtn.isHidden = false
        }
    }

    func addJob(notification: NSNotification){
        self.refreshSegment()
    }

    private func refreshSegment(){
        self.memoryBlock = self.memory.getMemory()
        self.storageSegmented.segmentCount = self.memoryBlock.count
        for (i, item) in self.memoryBlock.enumerated() {
            self.storageSegmented.setWidth(self.segmentedMaxWidth * CGFloat(Float(item.size) / Float(self.memory.size)), forSegment: i)
            self.storageSegmented.setLabel(item.job != nil ? (item.job?.name)! : "", forSegment: i)
        }
    }
}
