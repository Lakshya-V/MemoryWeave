package com.example.ui.screens

import androidx.compose.foundation.Canvas
import androidx.compose.foundation.background
import androidx.compose.foundation.border
import androidx.compose.foundation.layout.*
import androidx.compose.foundation.rememberScrollState
import androidx.compose.foundation.shape.CircleShape
import androidx.compose.foundation.shape.RoundedCornerShape
import androidx.compose.foundation.verticalScroll
import androidx.compose.material.icons.Icons
import androidx.compose.material.icons.filled.CheckCircle
import androidx.compose.material.icons.filled.Delete
import androidx.compose.material.icons.filled.Edit
import androidx.compose.material.icons.filled.Refresh
import androidx.compose.material3.*
import androidx.compose.runtime.*
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.draw.clip
import androidx.compose.ui.geometry.Offset
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.platform.testTag
import androidx.compose.ui.text.font.FontWeight
import androidx.compose.ui.unit.dp
import androidx.compose.ui.unit.sp
import com.example.ui.components.MwButton
import com.example.ui.components.MwCard
import com.example.ui.components.MwTopAppBar
import com.example.ui.theme.*

data class PreviewQuestion(val id: Int, val number: Int, val text: String)

@Composable
fun QuestionnairePreviewScreen(
    onNavigateBack: () -> Unit,
    onApproveQuiz: () -> Unit
) {
    var questions by remember {
        mutableStateOf(
            listOf(
                PreviewQuestion(1, 1, "Who is holding the red beach ball?"),
                PreviewQuestion(2, 2, "What year was this photo taken?"),
                PreviewQuestion(3, 3, "Where was the family vacationing?"),
                PreviewQuestion(4, 4, "What color is the striped towel on the sand?")
            )
        )
    }

    Scaffold(
        topBar = {
            MwTopAppBar(
                title = "CareConnect",
                onBackClick = onNavigateBack
            )
        },
        bottomBar = {
            Surface(
                modifier = Modifier
                    .fillMaxWidth()
                    .padding(20.dp),
                color = Color.Transparent
            ) {
                Column(verticalArrangement = Arrangement.spacedBy(12.dp)) {
                    MwButton(
                        text = "Approve & Add to Quiz",
                        icon = Icons.Default.CheckCircle,
                        onClick = onApproveQuiz,
                        testTag = "approve_quiz_button"
                    )
                    MwButton(
                        text = "Regenerate Questions",
                        icon = Icons.Default.Refresh,
                        backgroundColor = MwSurfaceContainerLowest,
                        foregroundColor = MwOnSurface,
                        onClick = {
                            questions = listOf(
                                PreviewQuestion(1, 1, "Who is smiling next to Eleanor on the shore?"),
                                PreviewQuestion(2, 2, "What season was this trip taken in?"),
                                PreviewQuestion(3, 3, "What game were you playing with the beach ball?"),
                                PreviewQuestion(4, 4, "Who booked the beachside cottage?")
                            )
                        },
                        testTag = "regenerate_questions_button"
                    )
                }
            }
        },
        containerColor = MwBackground
    ) { paddingValues ->
        Column(
            modifier = Modifier
                .fillMaxSize()
                .padding(paddingValues)
                .verticalScroll(rememberScrollState())
                .padding(24.dp)
        ) {
            Text(
                text = "Questionnaire Preview",
                style = MaterialTheme.typography.headlineMedium.copy(
                    fontSize = 28.sp,
                    fontWeight = FontWeight.ExtraBold,
                    color = MwOnSurface
                )
            )

            Spacer(modifier = Modifier.height(16.dp))

            // Reference Memory Card
            MwCard(modifier = Modifier.fillMaxWidth()) {
                Row(verticalAlignment = Alignment.Top) {
                    Box(
                        modifier = Modifier
                            .size(84.dp)
                            .border(2.dp, MwBorderBlack, RoundedCornerShape(8.dp))
                            .clip(RoundedCornerShape(8.dp))
                            .background(Color(0xFF81D4FA))
                    ) {
                        Canvas(modifier = Modifier.fillMaxSize()) {
                            drawRect(Color(0xFFFFE082), topLeft = Offset(0f, size.height * 0.55f))
                            drawCircle(Color(0xFFD32F2F), radius = 10f, center = Offset(size.width * 0.5f, size.height * 0.7f))
                        }
                    }
                    Spacer(modifier = Modifier.width(16.dp))
                    Column {
                        Text("Family Beach Vacation", style = MaterialTheme.typography.titleMedium.copy(fontSize = 20.sp, fontWeight = FontWeight.Bold))
                        Spacer(modifier = Modifier.height(4.dp))
                        Text("10 questions generated based on this memory.", style = MaterialTheme.typography.bodyMedium.copy(color = MwOnSurfaceVariant))
                    }
                }
            }

            Spacer(modifier = Modifier.height(20.dp))

            // Question tiles
            questions.forEach { q ->
                MwCard(
                    modifier = Modifier
                        .fillMaxWidth()
                        .padding(bottom = 16.dp)
                ) {
                    Row(
                        modifier = Modifier.fillMaxWidth(),
                        horizontalArrangement = Arrangement.SpaceBetween,
                        verticalAlignment = Alignment.Top
                    ) {
                        Column(modifier = Modifier.weight(1f)) {
                            Text("Question ${q.number}", style = MaterialTheme.typography.labelMedium.copy(color = MwOnSurfaceVariant, fontSize = 18.sp, fontWeight = FontWeight.Bold))
                            Spacer(modifier = Modifier.height(6.dp))
                            Text(q.text, style = MaterialTheme.typography.titleMedium.copy(fontSize = 22.sp, fontWeight = FontWeight.Bold, color = MwOnSurface, lineHeight = 28.sp))
                        }
                        Spacer(modifier = Modifier.width(16.dp))
                        Column(verticalArrangement = Arrangement.spacedBy(8.dp)) {
                            IconButton(
                                onClick = {},
                                modifier = Modifier
                                    .border(2.dp, MwBorderBlack, CircleShape)
                                    .size(48.dp)
                            ) {
                                Icon(Icons.Default.Edit, contentDescription = "Edit Question", tint = MwOnSurface)
                            }
                            IconButton(
                                onClick = { questions = questions.filter { it.id != q.id } },
                                modifier = Modifier
                                    .border(2.dp, MwBorderBlack, CircleShape)
                                    .size(48.dp)
                            ) {
                                Icon(Icons.Default.Delete, contentDescription = "Delete Question", tint = MwError)
                            }
                        }
                    }
                }
            }

            Spacer(modifier = Modifier.height(100.dp))
        }
    }
}
