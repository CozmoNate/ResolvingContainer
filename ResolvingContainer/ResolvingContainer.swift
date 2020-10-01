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

open class ResolvingContainer {
    
    private class Item {
        
        enum Stance {
            case resolution
            case instantiation
        }
        
        let stance: Stance
        let produce: () -> Any
        
        var instance: Any? = nil
        
        init(stance: Stance, resolver: @escaping () -> Any) {
            self.stance = stance
            self.produce = resolver
        }
        
        func resolve<T>(as class: T.Type = T.self) -> T? {
            switch stance {
            case .resolution:
                return produce() as? T
            case .instantiation:
                if instance == nil { instance = produce() }
                return instance as? T
            }
        }
        
        func discard<T>(as class: T.Type = T.self) -> T? {
            switch stance {
            case .resolution:
                return nil
            case .instantiation:
                guard let instance = instance else { return nil }
                self.instance = nil
                return instance as? T
            }
        }
    }
    
    private var registry: [ObjectIdentifier: Item]
    private var syncQueue: DispatchQueue
    
    
    public init(qos: DispatchQoS = .default) {
        registry = [:]
        syncQueue = DispatchQueue(label: "ResolvingContainer.SyncQueue", qos: qos)
    }
    
    /// Registers resolver of of the objects of specified type in the container
    /// - Parameter resolver: The resolver closure
    open func register<T>(resolver: @escaping () -> T) {
        sync { registry[ObjectIdentifier(T.self)] = Item(stance: .resolution, resolver: resolver) }
    }
    
    /// Registers instance of the object in the container
    /// - Parameter resolver: The instance of the object
    open func register<T>(instance resolver: @escaping @autoclosure () -> T) {
        sync { registry[ObjectIdentifier(T.self)] = Item(stance: .instantiation, resolver: resolver) }
    }
    
    /// Unregisters objects of specified type from the container
    /// - Parameter type: The type of the objects to unregister
    open func unregister<T>(_ type: T.Type) {
        sync { registry.removeValue(forKey: ObjectIdentifier(T.self)) }
    }
    
    /// Unregisters all types from the container
    open func unregisterAll() {
        sync { registry.removeAll() }
    }
    
    /// Resolves type into the instance
    /// - Parameter type: The type of the objects to resolve
    /// - Returns: The instance of the object or nil if wasn't registered before
    open func resolve<T>(_ type: T.Type = T.self) -> T? {
        sync {
            guard let item = registry[ObjectIdentifier(T.self)] else {
                return nil
            }
            return item.resolve()
        }
    }
    
    /// Discard the instance of the object if registered before as a singleton
    /// - Parameter instance: The type of the object to discard its instance from the container
    /// - Returns: The discarded instance of the object or nil
    @discardableResult open func discard<T>(_ instance: T.Type = T.self) -> T? {
        sync {
            guard let item = registry[ObjectIdentifier(T.self)] else {
                return nil
            }
            return item.discard()
        }
    }
    
    @discardableResult open func sync<T>(_ block: () -> T) -> T {
        if DispatchQueue.isRunning(on: syncQueue) {
            return block()
        } else {
            return syncQueue.sync(execute: block)
        }
    }
}

internal let ResolvingContainerQueueIdentifierKey = DispatchSpecificKey<UUID>()

internal extension DispatchQueue {
    
    static func isRunning(on queue: DispatchQueue) -> Bool {
        var identifier: UUID! = queue.getSpecific(key: ResolvingContainerQueueIdentifierKey)
        if identifier == nil {
            identifier = UUID()
            queue.setSpecific(key: ResolvingContainerQueueIdentifierKey, value: identifier)
        }
        return DispatchQueue.getSpecific(key: ResolvingContainerQueueIdentifierKey) == identifier
    }
}
