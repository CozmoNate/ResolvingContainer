//
//  ResolvingContainer.swift
//  ResolvingContainer
//
//  Created by Natan Zalkin on 15/08/2020.
//  Copyright © 2020 Natan Zalkin. All rights reserved.
//

/*
 * Copyright (c) 2020 Natan Zalkin
 *
 * Permission is hereby granted, free of charge, to any person obtaining a copy
 * of this software and associated documentation files (the "Software"), to deal
 * in the Software without restriction, including without limitation the rights
 * to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
 * copies of the Software, and to permit persons to whom the Software is
 * furnished to do so, subject to the following conditions:
 *
 * The above copyright notice and this permission notice shall be included in all
 * copies or substantial portions of the Software.
 *
 * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 * IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 * FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
 * AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 * LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
 * OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
 * SOFTWARE.
 *
 */

import Foundation

public class ResolvingContainer {
    
    private var entries: [ObjectIdentifier: () -> Any]
    private var syncQueue: DispatchQueue
    
    public init(qos: DispatchQoS = .default) {
        entries = [:]
        syncQueue = DispatchQueue(label: "ResolvingContainer.SyncQueue", qos: qos, attributes: .concurrent)
    }
    
    public func register<T>(resolver: @escaping () -> T) {
        syncQueue.sync { entries[ObjectIdentifier(T.self)] = resolver }
    }
    
    public func register<T>(instance resolver: @escaping @autoclosure () -> T) {
        syncQueue.sync(flags: .barrier) {
            entries[ObjectIdentifier(T.self)] = { [unowned self] in
                let instance = resolver()
                self.syncQueue.async(flags: .barrier) {
                    self.entries[ObjectIdentifier(T.self)] = { instance }
                }
                return instance
            }
        }
    }

    @discardableResult
    public func unregister<T>(_ type: T.Type) -> T? {
        return syncQueue.sync(flags: .barrier) {
            if let resolve = entries.removeValue(forKey: ObjectIdentifier(T.self)) {
                return resolve() as? T
            }
            return nil
        }
    }

    public func unregisterAll() {
        syncQueue.sync(flags: .barrier) { entries.removeAll() }
    }
    
    public func resolve<T>(_ type: T.Type = T.self) -> T? {
        guard let resolver = syncQueue.sync(execute: { entries[ObjectIdentifier(T.self)] }) else {
            return nil
        }
        return resolver() as? T
    }
}
