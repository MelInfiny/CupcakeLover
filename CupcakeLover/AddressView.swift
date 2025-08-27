//
//  AddressView.swift
//  CupcakeLover
//
//  Created by Emilie NOLBAS on 20/08/2025.
//

import SwiftUI

struct AddressView: View {
    @Environment(\.dismiss) private var dismiss
    @Bindable var order: Order
    
    var onConfirm: (() -> Void)? = nil
    
    @State private var showConfirmAlert = false

    var body: some View {
        Form {
            Section {
                TextField("Name", text: $order.name)
                TextField("Street Address", text: $order.streetAddress)
                TextField("City", text: $order.city)
                TextField("Zip", text: $order.zip)
            }
            
            Section {
                NavigationLink("Check out") {
                    CheckoutView(order: order)
                }
            }
            .disabled(order.hasValidAddress == false)
            
            Section {
                Button {
                    showConfirmAlert = true
                } label: {
                    Label("Place Order", systemImage: "paperplane.fill")
                        .font(.headline)
                }
                .buttonStyle(.borderedProminent)
                .frame(maxWidth: .infinity, alignment: .center)
            }
        }
        .navigationTitle("Delivery details")
        .navigationBarTitleDisplayMode(.inline)
        .alert("Confirmer la commande ?", isPresented: $showConfirmAlert) {
            Button("Modifier", role: .cancel) {
                // Ne rien faire -> l’utilisateur revient au formulaire
            }
            Button("Confirmer") {
                onConfirm?()   // informe le CartView (vider le panier, etc.)
                dismiss()
            }
        } message: {
            Text("Vos cupcakes seront envoyés à :\n\(order.name)\n\(order.streetAddress)\n\(order.city) \(order.zip)")
        }
    }
}

#Preview {
    AddressView(order: Order())
}
