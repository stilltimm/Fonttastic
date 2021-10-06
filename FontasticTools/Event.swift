//
//  Event.swift
//  Fontastic
//
//  Created by Timofey Surkov on 26.09.2021.
//

import Foundation

public protocol Disposable {

    func dispose()
}

public class Event<T> {

    // MARK: - Nested Types

    public typealias EventHandler = (T) -> Void

    public class EventSubscription: Disposable {
        fileprivate let object: WeakBox<AnyObject>
        private weak var event: Event<T>?
        private let handler: EventHandler

        fileprivate init(
            object: AnyObject,
            event: Event<T>,
            handler: @escaping EventHandler
        ) {
            self.object = .init(object)
            self.handler = handler
        }

        fileprivate func onNext(_ data: T) {
            guard object.value != nil else {
                dispose()
                return
            }
            self.handler(data)
        }

        public func dispose() {
            event?.removeSubscription(self)
        }
    }

    // MARK: - Private Instance Properties

    private var subscriptions: [EventSubscription] = []

    // MARK: - Initializers

    public init() {}

    // MARK: - Instance Methods

    @discardableResult
    final public func subscribe(
        _ object: AnyObject,
        handler: @escaping EventHandler
    ) -> Disposable {
        return _subscribe(object, handler: handler) as Disposable
    }

    public func onNext(_ data: T) {
        subscriptions.forEach { $0.onNext(data) }
    }

    // MARK: - Private Instanc Methods

    fileprivate func _subscribe(
        _ object: AnyObject,
        handler: @escaping EventHandler
    ) -> EventSubscription {
        if let index = subscriptions.firstIndex(where: { $0.object.value === object }) {
            subscriptions.remove(at: index)
        }

        let subscription = EventSubscription(object: object, event: self, handler: handler)
        subscriptions.append(subscription)

        return subscription
    }

    private func removeSubscription(_ subscription: EventSubscription) {
        guard let index = subscriptions.firstIndex(where: { $0 === subscription }) else {
            return
        }

        subscriptions.remove(at: index)
    }
}

public class HotEvent<T>: Event<T> {

    // MARK: - Private Instance Properties

    private var value: T

    // MARK: - Initializers

    public init(value: T) {
        self.value = value
        super.init()
    }

    // MARK: - Public Instance Methods

    override fileprivate func _subscribe(
        _ object: AnyObject,
        handler: @escaping Event<T>.EventHandler
    ) -> EventSubscription {
        let subscription = super._subscribe(object, handler: handler)
        subscription.onNext(value)
        return subscription
    }

    override public func onNext(_ data: T) {
        super.onNext(data)
    }
}
