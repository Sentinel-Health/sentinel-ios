import SwiftUI

struct CollectHealthGoalsView: View {
    @Environment(\.colorScheme) var colorScheme
    @EnvironmentObject var rootViewModel: RootViewModel
    @EnvironmentObject var onboardingViewModel: OnboardingViewModel

    @State private var isLoading: Bool = false
    @State private var showError: Bool = false
    @State private var errorMessage: String = ""

    @State private var manageWeight: Bool = false
    @State private var slowAging: Bool = false
    @State private var manageCondition: Bool = false
    @State private var navigateSystem: Bool = false
    @State private var answerHealthQuestions: Bool = false
    @State private var optimizeAthleticPerformance: Bool = false
    @State private var other: Bool = false
    @State private var otherReasonsText: String = ""

    var body: some View {
        VStack {
            GeometryReader { geometry in
                ScrollView {
                    VStack(alignment: .leading) {
                        VStack(alignment: .leading) {
                            Text("What are your goals?")
                                .font(.title)
                                .fontWeight(.semibold)
                        }
                        .padding(.bottom, 16)

                        VStack(alignment: .leading, spacing: 12) {
                            Text("What are your goals for joining Sentinal? Select all that apply.")
                                .opacity(0.9)
                        }
                        .padding(.bottom, 16)

                        VStack(alignment: .leading, spacing: 12) {
                            CheckboxView(checked: $manageCondition, label: "Manage health condition(s)", isDisabled: isLoading)
                            CheckboxView(checked: $manageWeight, label: "Manage weight", isDisabled: isLoading)
                            CheckboxView(checked: $slowAging, label: "Slow aging", isDisabled: isLoading)
                            CheckboxView(checked: $optimizeAthleticPerformance, label: "Optimize athletic performance", isDisabled: isLoading)
                            CheckboxView(checked: $navigateSystem, label: "Better navigate the healthcare system", isDisabled: isLoading)
                            CheckboxView(checked: $answerHealthQuestions, label: "Get answers to health related questions", isDisabled: isLoading)
                            CheckboxView(checked: $other, label: "Other", isDisabled: isLoading)

                            if other {
                                VStack {
                                    TextField("Care to share more?", text: $otherReasonsText, axis: .vertical)
                                        .lineLimit(4, reservesSpace: true)
                                        .padding(10)
                                        .disabled(isLoading)
                                }
                                .overlay(
                                    RoundedRectangle(cornerRadius: 10)
                                        .stroke(.secondary, lineWidth: 1)
                                )
                            }
                        }
                        .frame(maxWidth: .infinity, alignment: .leading)
                    }
                    .padding(.top, 40)
                    .padding(.horizontal)
                    Spacer()
                }
                .frame(minWidth: geometry.size.width, minHeight: geometry.size.height)
                .padding(.top, 1)
                .scrollBounceBehavior(.basedOnSize)
            }
            VStack {
                AppButton(
                    text: "Continue",
                    fullWidth: true,
                    isDisabled: !(manageWeight || manageCondition || navigateSystem || slowAging || answerHealthQuestions || optimizeAthleticPerformance || other),
                    isLoading: isLoading,
                    action: {
                        Task {
                            do {
                                try await onboardingViewModel.saveHealthGoals(data: [
                                    "manage_weight": manageWeight,
                                    "slow_aging": slowAging,
                                    "manage_condition": manageCondition,
                                    "navigate_system": navigateSystem,
                                    "answer_health_questions": answerHealthQuestions,
                                    "optimize_athletic_performance": optimizeAthleticPerformance,
                                    "other": other,
                                    "other_text": otherReasonsText
                                ])
                                withAnimation {
                                    if AppState.shared.hasAuthorizedHealthRecords {
                                        onboardingViewModel.nextView()
                                    } else {
                                        onboardingViewModel.changeView(index: ONBOARDING_ENABLE_NOTIFICATIONS_VIEW_INDEX)
                                    }
                                }
                            } catch {
                                isLoading = false
                                errorMessage = error.localizedDescription
                                showError = true
                            }
                        }
                    }
                )
            }
            .padding()
        }
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
    CollectHealthGoalsView()
}
