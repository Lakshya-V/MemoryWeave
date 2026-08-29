package com.example.ui.screens

import androidx.compose.animation.core.*
import androidx.compose.foundation.BorderStroke
import androidx.compose.foundation.Canvas
import androidx.compose.foundation.background
import androidx.compose.foundation.border
import androidx.compose.foundation.clickable
import androidx.compose.foundation.layout.*
import androidx.compose.foundation.rememberScrollState
import androidx.compose.foundation.shape.CircleShape
import androidx.compose.foundation.shape.RoundedCornerShape
import androidx.compose.foundation.verticalScroll
import androidx.compose.material.icons.Icons
import androidx.compose.material.icons.filled.Celebration
import androidx.compose.material.icons.filled.Home
import androidx.compose.material.icons.filled.Mic
import androidx.compose.material.icons.filled.MicNone
import androidx.compose.material3.*
import androidx.compose.runtime.*
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.draw.clip
import androidx.compose.ui.draw.scale
import androidx.compose.ui.geometry.Offset
import androidx.compose.ui.geometry.Size
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.graphics.Path
import androidx.compose.ui.platform.testTag
import androidx.compose.ui.text.font.FontWeight
import androidx.compose.ui.text.style.TextAlign
import androidx.compose.ui.unit.dp
import androidx.compose.ui.unit.sp
import androidx.compose.ui.window.Dialog
import com.example.ui.components.MwButton
import com.example.ui.components.MwTopAppBar
import com.example.ui.theme.*
import kotlinx.coroutines.delay

@Composable
fun InteractiveQuizScreen(
    onNavigateBack: () -> Unit,
    onReturnHome: () -> Unit
) {
    var isRecording by remember { mutableStateOf(false) }
    var statusText by remember { mutableStateOf("Tap to Speak your answer") }
    var showCompletionDialog by remember { mutableStateOf(false) }

    val infiniteTransition = rememberInfiniteTransition(label = "pulse")
    val pulseScale by infiniteTransition.animateFloat(
        initialValue = 1f,
        targetValue = 1.15f,
        animationSpec = infiniteRepeatable(
            animation = tween(1200, easing = FastOutSlowInEasing),
            repeatMode = RepeatMode.Reverse
        ),
        label = "pulse_scale"
    )

    LaunchedEffect(isRecording) {
        if (isRecording) {
            statusText = "Listening... Tap to stop"
            delay(3000)
            if (isRecording) {
                isRecording = false
                statusText = "Processing answer..."
                delay(1200)
                statusText = "Answer recorded!"
                showCompletionDialog = true
            }
        }
    }

    if (showCompletionDialog) {
        Dialog(onDismissRequest = { showCompletionDialog = false }) {
            Surface(
                shape = RoundedCornerShape(16.dp),
                color = MwSurfaceContainerLowest,
                border = BorderStroke(4.dp, MwBorderBlack),
                modifier = Modifier
                    .fillMaxWidth()
                    .padding(16.dp)
            ) {
                Column(
                    modifier = Modifier.padding(24.dp),
                    horizontalAlignment = Alignment.CenterHorizontally
                ) {
                    Box(
                        modifier = Modifier
                            .size(90.dp)
                            .clip(CircleShape)
                            .background(MwSecondaryContainer)
                            .border(2.dp, MwBorderBlack, CircleShape),
                        contentAlignment = Alignment.Center
                    ) {
                        Icon(
                            Icons.Default.Celebration,
                            contentDescription = null,
                            tint = MwOnSecondaryContainer,
                            modifier = Modifier.size(52.dp)
                        )
                    }

                    Spacer(modifier = Modifier.height(20.dp))

                    Text(
                        text = "Great Job, Eleanor!",
                        style = MaterialTheme.typography.headlineMedium.copy(
                            fontSize = 28.sp,
                            fontWeight = FontWeight.ExtraBold,
                            color = MwOnSurface
                        ),
                        textAlign = TextAlign.Center
                    )

                    Spacer(modifier = Modifier.height(12.dp))

                    Text(
                        text = "You've finished today's quiz. Your memories are carefully woven and safely stored.",
                        style = MaterialTheme.typography.bodyLarge.copy(
                            fontSize = 18.sp,
                            color = MwOnSurfaceVariant
                        ),
                        textAlign = TextAlign.Center
                    )

                    Spacer(modifier = Modifier.height(24.dp))

                    MwButton(
                        text = "Return Home",
                        icon = Icons.Default.Home,
                        onClick = {
                            showCompletionDialog = false
                            onReturnHome()
                        },
                        testTag = "quiz_return_home_button"
                    )
                }
            }
        }
    }

    Scaffold(
        topBar = {
            MwTopAppBar(
                title = "MemoryWeave",
                onBackClick = onNavigateBack
            )
        },
        containerColor = MwBackground
    ) { paddingValues ->
        Column(
            modifier = Modifier
                .fillMaxSize()
                .padding(paddingValues)
                .verticalScroll(rememberScrollState())
                .padding(24.dp),
            horizontalAlignment = Alignment.CenterHorizontally
        ) {
            Text(
                text = "Question 2 of 5",
                style = MaterialTheme.typography.titleMedium.copy(
                    fontSize = 22.sp,
                    fontWeight = FontWeight.Bold,
                    color = MwOnSurface
                )
            )

            Spacer(modifier = Modifier.height(10.dp))

            // Progress bar
            Box(
                modifier = Modifier
                    .fillMaxWidth()
                    .height(16.dp)
                    .clip(RoundedCornerShape(8.dp))
                    .background(MwSurfaceContainerHighest)
                    .border(2.dp, MwBorderBlack, RoundedCornerShape(8.dp))
            ) {
                Box(
                    modifier = Modifier
                        .fillMaxHeight()
                        .fillMaxWidth(0.4f)
                        .clip(RoundedCornerShape(8.dp))
                        .background(MwPrimary)
                )
            }

            Spacer(modifier = Modifier.height(20.dp))

            // Image Container with 4px border
            Box(
                modifier = Modifier
                    .fillMaxWidth()
                    .height(230.dp)
                    .border(4.dp, MwBorderBlack, RoundedCornerShape(12.dp))
                    .clip(RoundedCornerShape(12.dp))
                    .background(Color(0xFFE8E5DF))
            ) {
                Canvas(modifier = Modifier.fillMaxSize()) {
                    val cx = size.width / 2
                    val cy = size.height * 0.52f

                    // Vintage wedding illustration
                    drawRect(Color(0xFFE8E5DF), size = size)

                    // Bride veil
                    val veil = Path().apply {
                        moveTo(cx - 60f, cy - 40f)
                        quadraticTo(cx - 90f, cy + 50f, cx - 70f, cy + 100f)
                        lineTo(cx - 10f, cy + 100f)
                        close()
                    }
                    drawPath(veil, Color.White)

                    // Groom suit
                    drawRoundRect(
                        color = Color(0xFF2C2C2C),
                        topLeft = Offset(cx + 10f, cy - 10f),
                        size = Size(70f, 110f),
                        cornerRadius = androidx.compose.ui.geometry.CornerRadius(10f)
                    )

                    // Heads
                    drawCircle(Color(0xFFD3CECA), radius = 26f, center = Offset(cx - 40f, cy - 30f))
                    drawCircle(Color(0xFFD3CECA), radius = 26f, center = Offset(cx + 45f, cy - 30f))

                    // Bouquet
                    drawCircle(Color.White, radius = 20f, center = Offset(cx - 20f, cy + 45f))
                }
            }

            Spacer(modifier = Modifier.height(16.dp))

            // Question speech bubble
            Box(
                modifier = Modifier
                    .fillMaxWidth()
                    .border(2.dp, MwBorderBlack, RoundedCornerShape(12.dp))
                    .clip(RoundedCornerShape(12.dp))
                    .background(MwSurfaceContainerLowest)
                    .padding(22.dp),
                contentAlignment = Alignment.Center
            ) {
                Text(
                    text = "Who is standing next to you in this wedding photo?",
                    style = MaterialTheme.typography.titleLarge.copy(
                        fontSize = 24.sp,
                        fontWeight = FontWeight.Bold,
                        color = MwOnSurface,
                        lineHeight = 32.sp
                    ),
                    textAlign = TextAlign.Center
                )
            }

            Spacer(modifier = Modifier.height(32.dp))

            // Microphone Button
            Box(
                modifier = Modifier
                    .size(120.dp)
                    .scale(if (isRecording) pulseScale else 1f)
                    .clip(CircleShape)
                    .background(if (isRecording) MwError else MwPrimaryContainer)
                    .border(4.dp, if (isRecording) MwError else MwBorderBlack, CircleShape)
                    .clickable { isRecording = !isRecording }
                    .testTag("voice_record_button"),
                contentAlignment = Alignment.Center
            ) {
                Icon(
                    if (isRecording) Icons.Default.Mic else Icons.Default.MicNone,
                    contentDescription = "Speak answer",
                    tint = if (isRecording) MwOnError else MwOnPrimary,
                    modifier = Modifier.size(64.dp)
                )
            }

            Spacer(modifier = Modifier.height(16.dp))

            Text(
                text = statusText,
                style = MaterialTheme.typography.labelLarge.copy(
                    fontSize = 20.sp,
                    fontWeight = FontWeight.Bold,
                    color = if (isRecording) MwError else MwOnSurfaceVariant
                ),
                textAlign = TextAlign.Center
            )
        }
    }
}
