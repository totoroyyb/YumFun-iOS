//
//  Timer.swift
//  YumFun
//
//  Created by Admin on 3/9/21.
//

import Foundation




class TimerObject {
    init(){
        fullTime = 0
        timeRemaining = 0
        timer = Timer()
        isOn = false
    }
    var fullTime: Int
    var timeRemaining: Int
    var timer: Timer
    var isOn: Bool
}
