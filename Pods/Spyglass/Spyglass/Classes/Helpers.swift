//
//  Helpers.swift
//  Spyglass
//
//  Created by Alexsander Akers on 9/3/2016.
//  Copyright © 2016 Pandamonia LLC. All rights reserved.
//

import UIKit

func findTransitionSource(for viewController: UIViewController) -> SpyglassTransitionSource? {
    if let sourceProvider = viewController as? SpyglassTransitionSourceProvider, let source = sourceProvider.transitionSource {
        return source
    } else if let source = viewController as? SpyglassTransitionSource {
        return source
    } else {
        return nil
    }
}

func findTransitionDestination(for viewController: UIViewController) -> SpyglassTransitionDestination? {
    if let destinationProvider = viewController as? SpyglassTransitionDestinationProvider, let destination = destinationProvider.transitionDestination {
        return destination
    } else if let destination = viewController as? SpyglassTransitionDestination {
        return destination
    } else {
        return nil
    }
}
