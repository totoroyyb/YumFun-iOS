//
//  PaginationDelegate.swift
//  YumFun
//
//  Created by Yibo Yan on 2021/3/14.
//

protocol PaginationDelegate: class {
    /**
     Triggered when fetching new batch start.
     */
    func startFetchBatch()
    
    /***
     Triggered when fetching new batch end.*/
    func endFetchBatch()
}
