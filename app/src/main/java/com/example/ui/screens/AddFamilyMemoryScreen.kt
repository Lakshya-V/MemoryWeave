package com.example.ui.screens

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
import androidx.compose.material.icons.filled.Add
import androidx.compose.material.icons.filled.AddAPhoto
import androidx.compose.material.icons.filled.Close
import androidx.compose.material.icons.filled.Psychology
import androidx.compose.material3.*
import androidx.compose.runtime.*
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.draw.clip
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.graphics.PathEffect
import androidx.compose.ui.graphics.drawscope.Stroke
import androidx.compose.ui.platform.testTag
import androidx.compose.ui.text.font.FontWeight
import androidx.compose.ui.text.style.TextAlign
import androidx.compose.ui.unit.dp
import androidx.compose.ui.unit.sp
import com.example.ui.components.MwButton
import com.example.ui.components.MwCard
import com.example.ui.theme.*
import kotlinx.coroutines.delay

@Composable
fun AddFamilyMemoryScreen(
    onClose: () -> Unit,
    onQuestionsGenerated: () -> Unit
) {
    var isGenerating by remember { mutableStateOf(false) }

    LaunchedEffect(isGenerating) {
        if (isGenerating) {
            delay(2000)
            isGenerating = false
            onQuestionsGenerated()
        }
    }

    Scaffold(
        topBar = {
            Surface(
                modifier = Modifier
                    .fillMaxWidth()
                    .height(76.dp),
                color = MwSurface,
                border = androidx.compose.foundation.BorderStroke(2.dp, MwBorderBlack)
            ) {
                Row(
                    modifier = Modifier
                        .fillMaxSize()
                        .padding(horizontal = 16.dp),
                    verticalAlignment = Alignment.CenterVertically
                ) {
                    IconButton(
                        onClick = onClose,
                        modifier = Modifier.size(48.dp)
                    ) {
                        Icon(Icons.Default.Close, contentDescription = "Close", tint = MwPrimary, modifier = Modifier.size(32.dp))
                    }
                    Text(
                        text = "Add Family Memory",
                        style = MaterialTheme.typography.titleLarge.copy(fontSize = 24.sp, fontWeight = FontWeight.Bold, color = MwPrimary),
                        textAlign = TextAlign.Center,
                        modifier = Modifier.weight(1f)
                    )
                    Spacer(modifier = Modifier.width(48.dp))
                }
            }
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
                        text = "Add More Photos",
                        icon = Icons.Default.Add,
                        backgroundColor = MwSurfaceContainerLowest,
                        foregroundColor = MwOnSurface,
                        onClick = { isGenerating = true },
                        testTag = "add_more_photos_button"
                    )
                    MwButton(
                        text = "Save & Generate Memory Cards",
                        onClick = { isGenerating = true },
                        testTag = "save_generate_button"
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
                .padding(24.dp),
            horizontalAlignment = Alignment.CenterHorizontally
        ) {
            // Dashed Dropzone
            Box(
                modifier = Modifier
                    .fillMaxWidth()
                    .height(220.dp)
                    .clip(RoundedCornerShape(12.dp))
                    .background(MwSurfaceContainerLowest)
                    .clickable { isGenerating = true }
                    .testTag("photo_dropzone_box"),
                contentAlignment = Alignment.Center
            ) {
                Canvas(modifier = Modifier.fillMaxSize()) {
                    drawRoundRect(
                        color = MwBorderBlack,
                        style = Stroke(
                            width = 4f,
                            pathEffect = PathEffect.dashPathEffect(floatArrayOf(20f, 15f), 0f)
                        ),
                        cornerRadius = androidx.compose.ui.geometry.CornerRadius(24f)
                    )
                }

                Column(horizontalAlignment = Alignment.CenterHorizontally) {
                    Box(
                        modifier = Modifier
                            .size(72.dp)
                            .clip(CircleShape)
                            .background(MwPrimaryContainer)
                            .border(2.dp, MwBorderBlack, CircleShape),
                        contentAlignment = Alignment.Center
                    ) {
                        Icon(Icons.Default.AddAPhoto, contentDescription = null, tint = MwOnPrimary, modifier = Modifier.size(36.dp))
                    }
                    Spacer(modifier = Modifier.height(16.dp))
                    Text(
                        text = "Tap to Select Photo from Gallery",
                        style = MaterialTheme.typography.titleLarge.copy(fontSize = 22.sp, fontWeight = FontWeight.Bold, color = MwOnSurface),
                        textAlign = TextAlign.Center,
                        modifier = Modifier.padding(horizontal = 24.dp)
                    )
                }
            }

            Spacer(modifier = Modifier.height(24.dp))

            // Questionnaire Generation Status Card
            MwCard(
                modifier = Modifier.fillMaxWidth(),
                padding = PaddingValues(28.dp)
            ) {
                Column(
                    modifier = Modifier.fillMaxWidth(),
                    horizontalAlignment = Alignment.CenterHorizontally
                ) {
                    if (isGenerating) {
                        CircularProgressIndicator(
                            color = MwPrimary,
                            strokeWidth = 4.dp,
                            modifier = Modifier.size(48.dp)
                        )
                    } else {
                        Box(
                            modifier = Modifier
                                .size(56.dp)
                                .border(3.dp, MwBorderBlack, CircleShape),
                            contentAlignment = Alignment.Center
                        ) {
                            Icon(Icons.Default.Psychology, contentDescription = null, tint = MwPrimary, modifier = Modifier.size(32.dp))
                        }
                    }
                    Spacer(modifier = Modifier.height(18.dp))
                    Text(
                        text = if (isGenerating) "Analyzing Image with Reka AI..." else "Creating Questionnaire...",
                        style = MaterialTheme.typography.titleLarge.copy(fontSize = 24.sp, fontWeight = FontWeight.Bold, color = MwOnSurface),
                        textAlign = TextAlign.Center
                    )
                }
            }
        }
    }
}
