//
//  HomeView.swift
//  CupcakeLover
//

import SwiftUI

struct HomeView: View {
    @State private var showOrder = false

    var body: some View {
        GeometryReader { proxy in
            NavigationStack {
                VStack(spacing: 20) {
                    Spacer()
                    
                    Image("cupcake-pink")
                        .resizable()
                        .scaledToFill()
                        .frame(width: proxy.size.width,
                               height: proxy.size.height * 0.55)
                        .clipShape(WaveShape())
                        .ignoresSafeArea(edges: .top)
                    
                    
                    // Contenu
                    VStack(spacing: 24) {
                        Text("Sweet Moments,\nFreshly Baked.")
                            .font(.system(size: 32, weight: .bold, design: .rounded))
                            .multilineTextAlignment(.center)
                        
                        NavigationLink(destination: OrderView()) {
                            Text("Order Now")
                                .font(.headline)
                                .padding()
                                .frame(maxWidth: .infinity)
                                .background(
                                    LinearGradient(colors: [.pink, .brown],
                                                   startPoint: .leading,
                                                   endPoint: .trailing)
                                )
                                .foregroundStyle(.white)
                                .clipShape(Capsule())
                                .shadow(radius: 5)
                        }
                        .padding(.horizontal, 50)
                        
                        Spacer()
                    }
                    .padding(.top, 24)
                }
                .background(LinearGradient(
                    gradient: Gradient(stops: [
                        .init(color: .white, location: 0.0),
                        .init(color: .white, location: 0.3), // blanc jusqu'à mi-écran
                        .init(color: Color(.systemGroupedBackground), location: 0.5),
                        .init(color: Color(.systemGroupedBackground), location: 1.0)
                    ]),
                    startPoint: .top,
                    endPoint: .bottom
                ))
            }
        }
    }
}

struct WaveShape: Shape {
    func path(in rect: CGRect) -> Path {
        var p = Path()
        p.move(to: .zero)
        p.addLine(to: CGPoint(x: rect.width, y: 0))
        p.addLine(to: CGPoint(x: rect.width, y: rect.height - 50))
        p.addCurve(
            to: CGPoint(x: 0, y: rect.height - 50),
            control1: CGPoint(x: rect.width * 0.75, y: rect.height + 30),
            control2: CGPoint(x: rect.width * 0.25, y: rect.height - 80)
        )
        p.closeSubpath()
        return p
    }
}

#Preview {
    HomeView()
}
