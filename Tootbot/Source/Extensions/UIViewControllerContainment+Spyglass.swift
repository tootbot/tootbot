//
// Copyright (C) 2017 Tootbot Contributors
//
// This program is free software: you can redistribute it and/or modify
// it under the terms of the GNU Affero General Public License as published
// by the Free Software Foundation, either version 3 of the License, or
// (at your option) any later version.
//
// This program is distributed in the hope that it will be useful,
// but WITHOUT ANY WARRANTY; without even the implied warranty of
// MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
// GNU Affero General Public License for more details.
//
// You should have received a copy of the GNU Affero General Public License
// along with this program.  If not, see <http://www.gnu.org/licenses/>.
//

import Spyglass
import UIKit

extension RootViewController: SpyglassTransitionSourceProvider, SpyglassTransitionDestinationProvider {
    public var transitionSource: SpyglassTransitionSource? {
        if let sourceProvider = childViewController as? SpyglassTransitionSourceProvider {
            return sourceProvider.transitionSource
        } else {
            return childViewController as? SpyglassTransitionSource
        }
    }

    public var transitionDestination: SpyglassTransitionDestination? {
        if let destinationProvider = childViewController as? SpyglassTransitionDestinationProvider {
            return destinationProvider.transitionDestination
        } else {
            return childViewController as? SpyglassTransitionDestination
        }
    }
}

extension UINavigationController: SpyglassTransitionSourceProvider, SpyglassTransitionDestinationProvider {
    public var transitionSource: SpyglassTransitionSource? {
        if let sourceProvider = topViewController as? SpyglassTransitionSourceProvider {
            return sourceProvider.transitionSource
        } else {
            return topViewController as? SpyglassTransitionSource
        }
    }

    public var transitionDestination: SpyglassTransitionDestination? {
        if let destinationProvider = topViewController as? SpyglassTransitionDestinationProvider {
            return destinationProvider.transitionDestination
        } else {
            return topViewController as? SpyglassTransitionDestination
        }
    }
}

extension UITabBarController: SpyglassTransitionSourceProvider, SpyglassTransitionDestinationProvider {
    public var transitionSource: SpyglassTransitionSource? {
        if let sourceProvider = selectedViewController as? SpyglassTransitionSourceProvider {
            return sourceProvider.transitionSource
        } else {
            return selectedViewController as? SpyglassTransitionSource
        }
    }

    public var transitionDestination: SpyglassTransitionDestination? {
        if let destinationProvider = selectedViewController as? SpyglassTransitionDestinationProvider {
            return destinationProvider.transitionDestination
        } else {
            return selectedViewController as? SpyglassTransitionDestination
        }
    }
}

