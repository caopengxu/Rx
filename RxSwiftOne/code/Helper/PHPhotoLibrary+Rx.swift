//
//  PHPhotoLibrary+Rx.swift
//  RxSwiftOne
//
//  Created by caopengxu on 2018/3/15.
//  Copyright © 2018年 caopengxu. All rights reserved.
//

import UIKit
import Photos
import RxSwift

extension PHPhotoLibrary
{
    static var isAuthorized: Observable<Bool> {
        return Observable.create { observer in
            DispatchQueue.main.async {
                if authorizationStatus() == .authorized
                {
                    observer.onNext(true)
                    observer.onCompleted()
                }
                else
                {
                    requestAuthorization {
                        observer.onNext($0 == .authorized)
                        observer.onCompleted()
                    }
                }
            }
            return Disposables.create()
        }
    }
}


