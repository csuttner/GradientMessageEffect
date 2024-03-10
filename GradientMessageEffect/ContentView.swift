//
//  ContentView.swift
//  GradientMessageEffect
//
//  Created by Clay Suttner on 3/10/24.
//

import SwiftUI

struct Message: Identifiable {
    let id = UUID().uuidString
    let text: String
    let isUser: Bool
}

struct ContentView: View {
    var body: some View {
        CustomScrollView(
            scrollEnd: Color.white,
            background: LinearGradient(
                colors: [.mint, Color("Purple")],
                startPoint: .top,
                endPoint: .bottom
            )
        ) {
            LazyVStack(spacing: 0) {
                ForEach(messages) { message in
                    MaskedBubbleView(
                        bubblePadding: 8,
                        contentPadding: 8,
                        isUser: message.isUser
                    ) {
                        Text(message.text)
                            .foregroundStyle(.white)
                    }
                }
            }
        }
        .ignoresSafeArea()
    }
}

struct CustomScrollView<Background: View, ScrollEnd: View, Content: View>: View {
    let scrollEnd: ScrollEnd
    let background: Background
    let content: () -> Content
    
    @State private var offset: CGFloat = .zero
    @State private var contentHeight: CGFloat = .zero

    var body: some View {
        ScrollView {
            ZStack {
                content()
            
                GeometryReader { proxy in
                    let offset = proxy.frame(in: .named("scroll")).minY
                    let contentHeight = proxy.size.height
                    Color.clear.preference(key: ScrollViewOffsetPreferenceKey.self, value: offset)
                    Color.clear.preference(key: ContentHeightPreferenceKey.self, value: contentHeight)
                }
            }
        }
        .coordinateSpace(name: "scroll")
        .onPreferenceChange(ScrollViewOffsetPreferenceKey.self) { value in
            offset = value
        }
        .onPreferenceChange(ContentHeightPreferenceKey.self) { value in
            contentHeight = value
        }
        .background(
            VStack(spacing: 0) {
                scrollEnd
                    .frame(
                        height: max(offset, 0),
                        alignment: .top
                    )
                
                background
                
                scrollEnd
                    .frame(
                        height: max(-(contentHeight - UIScreen.main.bounds.height + offset), 0),
                        alignment: .bottom
                    )
            }
//            .ignoresSafeArea()
        )
    }
}

private struct ScrollViewOffsetPreferenceKey: PreferenceKey {
    static var defaultValue: CGFloat = .zero

    static func reduce(value: inout CGFloat, nextValue: () -> CGFloat) {
        value = nextValue()
    }
}

private struct ContentHeightPreferenceKey: PreferenceKey {
    static var defaultValue: CGFloat = .zero

    static func reduce(value: inout CGFloat, nextValue: () -> CGFloat) {
        value = nextValue()
    }
}

struct MaskedBubbleView<Content: View>: View {
    let bubblePadding: CGFloat
    let contentPadding: CGFloat
    let isUser: Bool
    let content: () -> Content
    
    var body: some View {
        if isUser {
            HStack(spacing: 0) {
                Spacer()

                content()
                    .padding(contentPadding)
            }
            .padding(bubblePadding)
            .background(.white)
            .reverseMask {
                HStack(spacing: 0) {
                    Spacer()
                    
                    content()
                        .padding(contentPadding)
                        .background(.white)
                        .clipShape(
                            .rect(cornerRadii: .init(
                                topLeading: 18,
                                bottomLeading: 18,
                                topTrailing: 18
                            ))
                        )
                }
                .padding(bubblePadding)
            }
            .overlay {
                HStack(spacing: 0) {
                    Spacer()
                    
                    content()
                        .padding(contentPadding)
                }
                .padding(bubblePadding)
            }

        } else {
            HStack(spacing: 0) {
                content()
                    .padding(contentPadding)
                    .background(.gray)
                    .clipShape(
                        .rect(cornerRadii: .init(
                            topLeading: 18,
                            bottomTrailing: 18,
                            topTrailing: 18
                        ))
                    )
                    .padding(bubblePadding)
                
                Spacer()
            }
            .background(.white)
        }
    }
}

extension View {
  func reverseMask<Mask: View>(
    alignment: Alignment = .center,
    @ViewBuilder _ mask: () -> Mask
  ) -> some View {
    self.mask {
      Rectangle()
        .overlay(alignment: alignment) {
          mask()
            .blendMode(.destinationOut)
        }
    }
  }
}

#Preview {
    ContentView()
}

let messages = (0...20).map { index in Message(text: String("Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua. Ut enim ad minim veniam, quis nostrud exercitation ullamco laboris nisi ut aliquip ex ea commodo consequat. Duis aute irure dolor in reprehenderit in voluptate velit esse cillum dolore eu fugiat nulla pariatur. Excepteur sint occaecat cupidatat non proident, sunt in culpa qui officia deserunt mollit anim id est laborum.".prefix(Int.random(in: 0...200))), isUser: index % 2 == 0) }
