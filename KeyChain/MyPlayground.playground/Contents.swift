//: Playground - noun: a place where people can play

import UIKit

var filename = "Hello.zip"


let index = filename.index(filename.endIndex, offsetBy: -5 )
let appName = String(filename[...index])


