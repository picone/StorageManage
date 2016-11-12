//
//  MemoryBlock.swift
//  StorageManage
//
//  Created by 何成健 on 16/11/12.
//  Copyright © 2016年 何成健. All rights reserved.
//

struct MemoryBlock {
    var startIndex: Int
    var size: Int
    var job: JOB? = nil
    
    init(_ start: Int, _ size: Int){
        self.startIndex = start
        self.size = size
    }
    
    init(_ start: Int, _ size: Int, _ job: JOB){
        self.startIndex = start
        self.size = size
        self.job = job
    }
}
