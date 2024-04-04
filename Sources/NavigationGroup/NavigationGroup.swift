//
//  NavigationGroup.swift
//  NavigationGroup
//
//  Created by Brianna Zamora on 3/31/24.
//

import SwiftUI

public protocol Screen: RawRepresentable, CaseIterable, Hashable, Identifiable where AllCases: RandomAccessCollection {

    var title: String { get }
    var icon: String { get }

    @ViewBuilder
    var label: Label<Text, Image> { get }
}

public extension Screen {
    var id: RawValue { rawValue }

    var label: Label<Text, Image> {
        Label(title, systemImage: icon)
    }
}

public struct NavigationGroup<S: Screen, Detail: View, Sidebar: View>: View {

    @Binding var currentScreen: S

    @ViewBuilder
    var sidebar: (_ allScreens: S.AllCases) -> Sidebar

    @ViewBuilder
    var detail: (_ screen: S) -> Detail

    public init(
        currentScreen: Binding<S>,
        sidebar: @escaping (_ allScreens: S.AllCases) -> Sidebar,
        detail: @escaping (_ screen: S) -> Detail
    ) {
        _currentScreen = currentScreen
        self.sidebar = sidebar
        self.detail = detail
    }

    var style: Style {
#if os(watchOS)
        .tabBar
#elseif canImport(UIKit)
        switch UIDevice.current.userInterfaceIdiom {
        case .unspecified, .phone, .carPlay, .vision:
            return Style.tabBar
        case .pad, .tv, .mac:
            return Style.splitNavigation
        @unknown default:
            return Style.tabBar
        }
#else
        .tabBar
#endif
    }

    public var body: some View {
        switch style {
        case .splitNavigation:
            NavigationSplitView {
                sidebar(S.allCases)
            } detail: {
                detail(currentScreen)
            }
        case .tabBar:
            TabView(selection: $currentScreen) {
                ForEach(S.allCases) { screen in
                    detail(screen)
                        .tabItem { screen.label }
                        .tag(screen.id)
                }
            }
        }
    }

    enum Style {
        case splitNavigation
        case tabBar
    }
}

extension NavigationGroup where Sidebar == List<Never, ForEach<S.AllCases, S.ID, NavigationLink<Label<Text, Image>, Detail>>> {
    public init(
        _ sidebarTitle: String? = nil,
        currentScreen: Binding<S>,
        @ViewBuilder detail: @escaping (_ screen: S) -> Detail
    ) {
        _currentScreen = currentScreen
        self.sidebar = { allScreens in
            List(allScreens) { screen in
                NavigationLink {
                    detail(screen)
                } label: {
                    screen.label
                }
            }
        }
        self.detail = detail
    }
}

#Preview {
    enum DemoScreen: String, Screen {
        case meow
        case meowAgain
        var title: String {
            switch self {
            case .meow:
                return "Meow"
            case .meowAgain:
                return "Meow again"
            }
        }
        var icon: String {
            switch self {
            case .meow:
                return "1.circle"
            case .meowAgain:
                return "2.circle"
            }
        }
    }
    @State var currentScreen: DemoScreen = .meow
    return NavigationGroup(currentScreen: $currentScreen) { screen in
        switch screen {
        case .meow:
            List {
                Text("This is meowing!!")
            }
        case .meowAgain:
            List {
                Text("And meowing more again!!!")
            }
        }
    }
}
