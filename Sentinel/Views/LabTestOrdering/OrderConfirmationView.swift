import SwiftUI
import MarkdownUI

struct OrderConfirmationView: View {
    @EnvironmentObject var viewModel: OrderLabTestsViewModel

    let labTest: LabTest

    @State private var showError: Bool = false
    @State private var errorMessage: String = ""

    var body: some View {
        VStack {
            GeometryReader { geometry in
                ScrollView {
                    VStack {
                        VStack(spacing: 16) {
                            Image(systemName: "checkmark.circle")
                                .resizable()
                                .aspectRatio(contentMode: .fit)
                                .frame(width: 75, height: 75)
                                .foregroundColor(.green)

                            Text("Order Confirmed!")
                                .font(.title)
                                .bold()

                            VStack(spacing: 8) {
                                Text("Your order's details are below.")
                                    .font(.subheadline)
                                    .multilineTextAlignment(.center)
                                    .opacity(0.9)
                            }
                            .padding(.horizontal)
                        }

                        Divider()
                            .padding(.vertical)

                        VStack(alignment: .leading, spacing: 16) {
                            VStack(alignment: .leading, spacing: 6) {
                                Text("Lab Test Ordered")
                                    .font(.headline)

                                Text(labTest.name)
                            }

                            VStack(alignment: .leading, spacing: 6) {
                                Text("Requires Fasting")
                                    .font(.headline)

                                if labTest.isFastingRequired {
                                    if let fastingInstructions = labTest.fastingInstructions {
                                        Text(fastingInstructions)
                                            .font(.subheadline)
                                    }
                                } else {
                                    Text("No")
                                }
                            }

                            if labTest.hasAdditionalPreparationInstructions, let additionalPreparationInstructions = labTest.additionalPreparationInstructions {
                                VStack(alignment: .leading, spacing: 6) {
                                    Text("Additional Note")
                                        .font(.headline)

                                    Text(additionalPreparationInstructions)
                                        .font(.subheadline)
                                }
                            }

                            if let afterOrderInstructions = labTest.afterOrderInstructions {
                                VStack(alignment: .leading, spacing: 6) {
                                    Text("Next Steps")
                                        .font(.headline)

                                    Markdown(afterOrderInstructions)
                                }
                            }
                        }
                        .frame(maxWidth: .infinity, alignment: .leading)
                    }
                    .padding(.top, 10)
                    .padding(.horizontal)

                    Spacer()
                }
                .frame(minWidth: geometry.size.width, minHeight: geometry.size.height)
            }

            if let appointmentUrl = labTest.appointmentUrl {
                VStack(spacing: 20) {
                    AppButton(
                        text: "Book an Appointment",
                        fullWidth: true,
                        action: {
                            UIApplication.shared.open(URL(string: appointmentUrl)!)
                        }
                    )
                }
                .padding(.horizontal)
            } else {
                VStack(spacing: 20) {
                    AppButton(
                        text: "Done",
                        fullWidth: true,
                        action: {
                            viewModel.dismissLabTestOrderModal()
                        }
                    )
                }
                .padding(.horizontal)
            }
        }
        .navigationBarBackButtonHidden()
        .alert("Error", isPresented: $showError) {
            Button("Ok") {
                showError = false
                errorMessage = ""
            }
        } message: {
            Text(errorMessage)
        }
    }
}

 #Preview {
     OrderConfirmationView(labTest:
        LabTest(
            id: "d33e2de8-5eef-4cf2-95a5-cbdc28a7334d",
            name: "General Wellness",
            shortDescription: "This is a short description.",
            markdownDescription: "## Things to know\nThis is a markdown description.",
            category: "standard",
            price: "$50",
            collectionInstructions: "**Where to go**\n\nYour lab must be done at Quest. You can book an appointment [here](https://appointment.questdiagnostics.com/as-home) or just bring the emailed order form with you to one of their locations.\n\nIf you are asked about payment information or any other financial information when trying to book an appointment, choose \"I have already paid or someone else is responsible\".\n\n**What to bring**\n- Bring the lab order form that has been emailed to you. You do not have to print it.\n- A photo ID\n\n**When at the lab**\n- You do NOT need to show proof of insurance\n- You do NOT have to make any payments",
            appointmentUrl: "https://www.labcorp.com/labs-and-appointments-advanced-search",
            isFastingRequired: true,
            fastingInstructions: "This draw requires fasting for 12 hours before your appointment. \"Fasting\" means no food or drink other than water. We recommend drinking water so you show up to the blood draw hydrated.",
            hasAdditionalPreparationInstructions: true,
            additionalPreparationInstructions: "Biotin supplements (also called vitamin B7 or B8, vitamin H, or coenzyme R) can potentially interfere with the results of this test. It is recommended that if you are taking a biotin supplement, you stop taking it at least 72 hours before your blood draw.",
            labName: "Quest",
            createdAt: "2024-03-13 22:43:24 UTC",
            updatedAt: "2024-03-13 22:43:24 UTC",
            order: 0
        )
     )
     .environmentObject(OrderLabTestsViewModel())
 }
