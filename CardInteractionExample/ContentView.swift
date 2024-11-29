//
//  ContentView.swift
//  CardInteractionExample
//
//  Created by Zeno on 2024/11/29.
//

import SwiftUI

struct ContentView: View {
    // MARK: - 常量和变量
    /// 卡片的颜色数组，使用同一个蓝色系的不同色调
    private let cardColors: [Color] = [
        Color(hue: 0.6, saturation: 0.6, brightness: 0.9),
        Color(hue: 0.6, saturation: 0.7, brightness: 0.8),
        Color(hue: 0.6, saturation: 0.8, brightness: 0.7),
        Color(hue: 0.6, saturation: 0.9, brightness: 0.6),
        Color(hue: 0.6, saturation: 1.0, brightness: 0.5),
    ]
    
    /// 卡片的总数量
    private let totalCards = 30
    
    // MARK: - 屏幕尺寸相关计算
    /// 获取屏幕宽度
    private var screenWidth: CGFloat {
        UIScreen.main.bounds.width
    }
    
    /// 获取屏幕高度
    private var screenHeight: CGFloat {
        UIScreen.main.bounds.height
    }
    
    // MARK: - 布局相关计算
    /// 计算左侧间距（基于iPhone 16 Pro的屏幕宽度430）
    private var cardStackLeftPadding: CGFloat {
        return -240 * (screenWidth / 430)
    }
    
    /// 计算底部间距（基于iPhone 16 Pro的屏幕高度932）
    private var cardStackBottomPadding: CGFloat {
        return -360 * (screenHeight / 932)
    }
    
    /// 计算右侧间距
    private var cardStackRightPadding: CGFloat {
        return screenWidth - (180 * (screenWidth / 430))
    }
    
    // MARK: - 主视图
    var body: some View {
        ZStack {
            // 背景色
            Color.black.ignoresSafeArea()
            
            // 卡片堆叠滚动视图
            ScrollView(.horizontal) {
                cardStackView
            }
            .scrollClipDisabled()
        }
    }
    
    // MARK: - 子视图
    /// 卡片堆叠视图
    private var cardStackView: some View {
        HStack(spacing: -260) {
            ForEach((0..<totalCards), id: \.self) { index in
                cardView(for: index)
            }
        }
        .padding(.leading, cardStackLeftPadding)
        .padding(.bottom, cardStackBottomPadding)
        .padding(.trailing, cardStackRightPadding)
        .frame(maxHeight: .infinity, alignment: .center)
    }
    
    /// 创建单个卡片视图
    private func cardView(for index: Int) -> some View {
        RoundedRectangle(cornerRadius: 5)
            .fill(.ultraThinMaterial)
            .background {
                cardColors[index % cardColors.count]
                    .opacity(0.3)
                    .blur(radius: 3)
            }
            .frame(width: 300, height: 500)
            .scrollTransition(.interactive, axis: .horizontal) { view, phase in
                view
                    .rotation3DEffect(
                        .degrees(calculateCardRotation(phase: phase, index: index)),
                        axis: (x: 0.5, y: 1.8, z: 1.2),
                        anchor: .topTrailing,
                        anchorZ: 0,
                        perspective: 0.5
                    )
                    .scaleEffect(calculateCardScale(phase: phase), anchor: .bottomTrailing)
            }
            .zIndex(-Double(index))
    }
    
    // MARK: - 辅助方法
    /// 计算卡片缩放比例
    private func calculateCardScale(phase: ScrollTransitionPhase) -> CGFloat {
        switch phase {
        case .bottomTrailing: return 1.0  // 最小缩放
        case .topLeading: return 1.9      // 最大缩放
        case .identity: return 1.4        // 正常大小
        }
    }
    
    /// 计算卡片旋转角度
    private func calculateCardRotation(phase: ScrollTransitionPhase, index: Int) -> Double {
        let maxRotation = -10.0  // 最大旋转角度
        
        // 计算每张卡片的初始角度（-45度到-55度之间）
        let initialAngle = (Double(index) / Double(totalCards - 1)) * maxRotation - 45
        
        // 根据滚动阶段调整角度
        return initialAngle * (1 + phase.value)
    }
}

// MARK: - 预览
#Preview {
    ContentView()
}
