//
//  Memory.swift
//  StorageManage
//
//  Created by 何成健 on 16/11/12.
//  Copyright © 2016年 何成健. All rights reserved.
//

import Cocoa

class Memory {
    
    var size: Int
    var dispatchType: Int = 0
    var freeMemory: [MemoryBlock]
    var useMemory: [MemoryBlock] = []
    private var nfIndex: Int = 0
    
    init(_ size: Int){
        self.size = size
        self.freeMemory = [MemoryBlock(0, size)]
    }
    
    public func getMemory()->[MemoryBlock]{
        var memory: [MemoryBlock] = self.freeMemory
        memory.append(contentsOf: self.useMemory)
        memory.sort { (mb1, mb2) -> Bool in
            return mb1.startIndex < mb2.startIndex
        }
        return memory
    }

    public func existJob(name: String)->Bool{
        for (_, item) in self.useMemory.enumerated() {
            if item.job?.name == name {
                return true
            }
        }
        return false
    }
    
    public func load(_ job: JOB)->Bool{
        switch(dispatchType){
        case 0://首次适应
            self.freeMemory.sort(by: { (mb1, mb2) -> Bool in
                return mb1.startIndex < mb2.startIndex
            })
            for (i, item) in self.freeMemory.enumerated() {
                if partitionMemory(i, item, job) {
                    return true
                }
            }
            break
        case 1://循环首次适应
            self.freeMemory.sort(by: { (mb1, mb2) -> Bool in
                return mb1.startIndex < mb2.startIndex
            })
            for i in 0...self.freeMemory.count - 1 {
                let index = (i + self.nfIndex) % self.freeMemory.count
                if partitionMemory(index, self.freeMemory[index], job) {
                    return true
                }
            }
            break
        case 2://最佳适应
            self.freeMemory.sort(by: { (mb1, mb2) -> Bool in
                return mb1.size < mb2.size
            })
            for (i, item) in self.freeMemory.enumerated() {
                if partitionMemory(i, item, job) {
                    return true
                }
            }
            break
        case 3://最坏适应
            self.freeMemory.sort(by: { (mb1, mb2) -> Bool in
                return mb1.size > mb2.size
            })
            for (i, item) in self.freeMemory.enumerated() {
                if partitionMemory(i, item, job) {
                    return true
                }
            }
            break
        default:
            break
        }
        return false
    }
    
    public func release(name: String){
        var targetIndex = -1
        for (i, item) in self.useMemory.enumerated() {
            if item.job?.name == name {
                targetIndex = i
                break
            }
        }
        if targetIndex >= 0 {
            self.release(at: targetIndex)
        }
    }
    
    public func release(at: Int){
        var block = self.useMemory[at]
        var beforeIndex = -1, afterIndex = -1
        for (i, item) in self.freeMemory.enumerated() {
            if item.startIndex + item.size == block.startIndex {//若前面有空闲分区
                beforeIndex = i
            }else if item.startIndex == block.startIndex + block.size {//若后面有空闲分区
                afterIndex = i
            }
        }
        if beforeIndex >= 0 && afterIndex >= 0 {//如果前面后面都有空闲分区,则合并三块
            self.freeMemory[beforeIndex].size += block.size + self.freeMemory[afterIndex].size
            self.freeMemory.remove(at: afterIndex)
        }else if beforeIndex >= 0 {//前面有,则合并前面
            self.freeMemory[beforeIndex].size += block.size
        }else if afterIndex >= 0 {//后面有,则合并后面
            self.freeMemory[afterIndex].startIndex -= block.size
            self.freeMemory[afterIndex].size += block.size
        }else{//前后都有,新增空闲块
            block.job = nil
            self.freeMemory.append(block)
        }
        self.useMemory.remove(at: at)
    }
    
    public func release(){
        self.freeMemory = [MemoryBlock(0, size)]
        self.useMemory.removeAll()
        self.nfIndex = 0
    }
    
    private func partitionMemory(_ i: Int, _ item: MemoryBlock,_ job: JOB)->Bool{
        if item.size > job.memory {//从这块空闲分区中划分
            self.useMemory.append(MemoryBlock(item.startIndex, job.memory, job))
            self.freeMemory[i].startIndex += job.memory
            self.freeMemory[i].size -= job.memory
            return true
        }else if item.size == job.memory {//把这块空闲分区使用
            self.useMemory.append(MemoryBlock(item.startIndex, job.memory, job))
            self.freeMemory.remove(at: i)
            return true
        }
        return false
    }
}
