//
//  File.swift
//  Reusable
//
//  Created by Anders Lassen on 12/07/2021.
//

import Foundation
import SwiftUI
import UIKit


extension View {
    
    public func configureNavigationBar<LeadingView1:View,TrailingView1:View,TrailingView2:View,TrailingView3:View>(
        leading:LeadingView1, trailing1:TrailingView1, trailing2:TrailingView2, trailing3:TrailingView3) -> some View {
    
        self
        .navigationBarTitleDisplayMode(.inline)
        .navigationBarBackButtonHidden(true)
        .toolbar {
            ToolbarItem(placement: .navigationBarLeading) {
                leading
            }
            ToolbarItem(placement: .navigationBarTrailing) {
                trailing1
            }
            ToolbarItem(placement: .navigationBarTrailing) {
                trailing2
            }
            ToolbarItem(placement: .navigationBarTrailing) {
                trailing3
            }
        }
    }
    
    public func configureNavigationBar<LeadingView1:View,TrailingView1:View>(leading:LeadingView1, trailing:TrailingView1) -> some View {
    
        self
        .navigationBarTitleDisplayMode(.inline)
        .navigationBarBackButtonHidden(true)
        .toolbar {
            ToolbarItem(placement: .navigationBarLeading) {
                leading
            }
            ToolbarItem(placement: .navigationBarTrailing) {
                trailing
            }
        }
    }
    
    public func configureNavigationBar<LeadingView1:View,CenterView1:View>(leading:LeadingView1, center:CenterView1) -> some View {
    
        self
        .navigationBarTitleDisplayMode(.inline)
        .navigationBarBackButtonHidden(true)
        .toolbar {
            ToolbarItem(placement: .navigationBarLeading) {
                leading
            }
            ToolbarItem(placement: .principal) {
                center
            }
        }
    }
    
    public func configureNavigationBar<LeadingView1:View,CenterView1:View,TrailingView1:View>(leading:LeadingView1, center:CenterView1, trailing:TrailingView1) -> some View {
    
        self
        .navigationBarTitleDisplayMode(.inline)
        .navigationBarBackButtonHidden(true)
        .toolbar {
            ToolbarItem(placement: .navigationBarLeading) {
                leading
            }
            ToolbarItem(placement: .principal) {
                center
            }
            ToolbarItem(placement: .navigationBarTrailing) {
                trailing
            }
        }
    }
}


/// https://github.com/globulus/swiftui-navigation-bar-styling#readme

public struct NavigationBarColorModifier: ViewModifier {
  var backgroundColor: UIColor
  var textColor: UIColor

  public init(backgroundColor: UIColor, textColor: UIColor) {
    self.backgroundColor = backgroundColor
    self.textColor = textColor
    let coloredAppearance = UINavigationBarAppearance()
    coloredAppearance.configureWithTransparentBackground()
    coloredAppearance.backgroundColor = .clear
    coloredAppearance.titleTextAttributes = [.foregroundColor: textColor]
    coloredAppearance.largeTitleTextAttributes = [.foregroundColor: textColor]

    UINavigationBar.appearance().standardAppearance = coloredAppearance
    UINavigationBar.appearance().compactAppearance = coloredAppearance
    UINavigationBar.appearance().scrollEdgeAppearance = coloredAppearance
    UINavigationBar.appearance().tintColor = textColor
  }

  public func body(content: Content) -> some View {
    ZStack {
       content
        VStack {
          GeometryReader { geometry in
             Color(self.backgroundColor)
                .frame(height: geometry.safeAreaInsets.top)
                .edgesIgnoringSafeArea(.top)
              Spacer()
          }
        }
     }
  }
}

@available(iOS 14.0, *)
public extension View {
  func navigationBarColor(_ backgroundColor: UIColor, textColor: UIColor) -> some View {
    self.modifier(NavigationBarColorModifier(backgroundColor: backgroundColor, textColor: textColor))
  }
    
    func navigationBarColor(_ backgroundColor: Color, textColor: Color) -> some View {
      self.modifier(NavigationBarColorModifier(backgroundColor: UIColor(backgroundColor), textColor: UIColor(textColor)))
    }
}

public class StyledHostingController<Content> : UIHostingController<Content> where Content : View {
    private var statusBarStyle: UIStatusBarStyle?
    
    public init(statusBarStyle: UIStatusBarStyle, rootView: Content) {
        self.statusBarStyle = statusBarStyle
        super.init(rootView: rootView)
    }
    
    @objc required dynamic init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
  @objc override dynamic open var preferredStatusBarStyle: UIStatusBarStyle {
    return statusBarStyle ?? .default
  }
}


