package com.example

import android.os.Bundle
import androidx.activity.ComponentActivity
import androidx.activity.compose.BackHandler
import androidx.activity.compose.setContent
import androidx.activity.enableEdgeToEdge
import androidx.compose.foundation.layout.fillMaxSize
import androidx.compose.material3.Surface
import androidx.compose.runtime.*
import androidx.compose.ui.Modifier
import com.example.ui.screens.*
import com.example.ui.theme.MemoryWeaveTheme
import com.example.ui.theme.MwBackground

enum class AppScreen {
    LOGIN,
    PATIENT_HOME,
    INTERACTIVE_QUIZ,
    CAREGIVER_DASHBOARD,
    ADD_FAMILY_MEMORY,
    QUESTIONNAIRE_PREVIEW,
    MEMORY_DETAILS
}

class MainActivity : ComponentActivity() {
    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        enableEdgeToEdge()
        setContent {
            MemoryWeaveTheme {
                Surface(
                    modifier = Modifier.fillMaxSize(),
                    color = MwBackground
                ) {
                    var currentScreen by remember { mutableStateOf(AppScreen.LOGIN) }
                    var selectedMemory by remember { mutableStateOf<MemoryItemUi?>(null) }
                    val backStack = remember { mutableStateListOf<AppScreen>() }

                    fun navigateTo(screen: AppScreen) {
                        backStack.add(currentScreen)
                        currentScreen = screen
                    }

                    fun navigateBack() {
                        if (backStack.isNotEmpty()) {
                            currentScreen = backStack.removeAt(backStack.lastIndex)
                        }
                    }

                    BackHandler(enabled = backStack.isNotEmpty()) {
                        navigateBack()
                    }

                    when (currentScreen) {
                        AppScreen.LOGIN -> LoginScreen(
                            onLoginSuccess = {
                                backStack.clear()
                                currentScreen = AppScreen.PATIENT_HOME
                            }
                        )
                        AppScreen.PATIENT_HOME -> PatientHomeScreen(
                            onStartQuiz = { navigateTo(AppScreen.INTERACTIVE_QUIZ) },
                            onOpenCaregiverMode = { navigateTo(AppScreen.CAREGIVER_DASHBOARD) }
                        )
                        AppScreen.INTERACTIVE_QUIZ -> InteractiveQuizScreen(
                            onNavigateBack = { navigateBack() },
                            onReturnHome = {
                                backStack.clear()
                                currentScreen = AppScreen.PATIENT_HOME
                            }
                        )
                        AppScreen.CAREGIVER_DASHBOARD -> CaregiverDashboardScreen(
                            onNavigateBack = { navigateBack() },
                            onAddNewMemory = { navigateTo(AppScreen.ADD_FAMILY_MEMORY) },
                            onViewMemoryDetail = { memory ->
                                selectedMemory = memory
                                navigateTo(AppScreen.MEMORY_DETAILS)
                            }
                        )
                        AppScreen.ADD_FAMILY_MEMORY -> AddFamilyMemoryScreen(
                            onClose = { navigateBack() },
                            onQuestionsGenerated = { navigateTo(AppScreen.QUESTIONNAIRE_PREVIEW) }
                        )
                        AppScreen.QUESTIONNAIRE_PREVIEW -> QuestionnairePreviewScreen(
                            onNavigateBack = { navigateBack() },
                            onApproveQuiz = {
                                backStack.clear()
                                currentScreen = AppScreen.PATIENT_HOME
                            }
                        )
                        AppScreen.MEMORY_DETAILS -> MemoryDetailsScreen(
                            memory = selectedMemory,
                            onNavigateBack = { navigateBack() }
                        )
                    }
                }
            }
        }
    }
}
