package com.example.ui.screens

import androidx.compose.foundation.Canvas
import androidx.compose.foundation.background
import androidx.compose.foundation.border
import androidx.compose.foundation.layout.*
import androidx.compose.foundation.rememberScrollState
import androidx.compose.foundation.shape.RoundedCornerShape
import androidx.compose.foundation.verticalScroll
import androidx.compose.material.icons.Icons
import androidx.compose.material.icons.filled.*
import androidx.compose.material3.*
import androidx.compose.runtime.*
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.draw.clip
import androidx.compose.ui.geometry.Offset
import androidx.compose.ui.geometry.Size
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.graphics.vector.ImageVector
import androidx.compose.ui.platform.testTag
import androidx.compose.ui.text.font.FontWeight
import androidx.compose.ui.unit.dp
import androidx.compose.ui.unit.sp
import com.example.ui.components.MwButton
import com.example.ui.components.MwCard
import com.example.ui.components.MwTopAppBar
import com.example.ui.theme.*

@Composable
fun MemoryDetailsScreen(
    memory: MemoryItemUi?,
    onNavigateBack: () -> Unit
) {
    var isRecordingContext by remember { mutableStateOf(false) }

    Scaffold(
        topBar = {
            MwTopAppBar(
                title = "Memory Details...",
                onBackClick = onNavigateBack,
                actions = {
                    IconButton(onClick = {}) {
                        Icon(Icons.Default.MoreVert, contentDescription = "Options", tint = MwPrimary, modifier = Modifier.size(32.dp))
                    }
                }
            )
        },
        bottomBar = {
            Surface(
                modifier = Modifier
                    .fillMaxWidth()
                    .padding(20.dp),
                color = Color.Transparent
            ) {
                MwButton(
                    text = if (isRecordingContext) "Recording Audio..." else "Record Additional Context",
                    icon = if (isRecordingContext) Icons.Default.Stop else Icons.Default.Mic,
                    backgroundColor = MwSurfaceContainerLowest,
                    foregroundColor = MwOnSurface,
                    onClick = { isRecordingContext = !isRecordingContext },
                    testTag = "record_additional_context_button"
                )
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
            // Memory Photo
            Box(
                modifier = Modifier
                    .fillMaxWidth()
                    .height(220.dp)
                    .border(2.dp, MwBorderBlack, RoundedCornerShape(12.dp))
                    .clip(RoundedCornerShape(12.dp))
                    .background(Color(0xFF4FC3F7))
            ) {
                Canvas(modifier = Modifier.fillMaxSize()) {
                    val cx = size.width / 2
                    val cy = size.height * 0.55f

                    // Ocean & Sand
                    drawRect(Color(0xFF0288D1), topLeft = Offset(0f, size.height * 0.45f), size = Size(size.width, size.height * 0.2f))
                    drawRect(Color(0xFFFFD54F), topLeft = Offset(0f, size.height * 0.65f), size = Size(size.width, size.height * 0.35f))

                    // Sunita & Rohan & Child
                    drawCircle(Color(0xFFD7CCC8), radius = 20f, center = Offset(cx - 60f, cy - 20f))
                    drawRoundRect(Color(0xFF37474F), topLeft = Offset(cx - 80f, cy + 10f), size = Size(40f, 70f), cornerRadius = androidx.compose.ui.geometry.CornerRadius(8f))

                    drawCircle(Color(0xFFD7CCC8), radius = 20f, center = Offset(cx + 60f, cy - 20f))
                    drawRoundRect(Color(0xFF1976D2), topLeft = Offset(cx + 40f, cy + 10f), size = Size(40f, 70f), cornerRadius = androidx.compose.ui.geometry.CornerRadius(8f))

                    drawCircle(Color(0xFFD7CCC8), radius = 16f, center = Offset(cx, cy + 5f))
                    drawCircle(Color(0xFFD32F2F), radius = 14f, center = Offset(cx, cy + 50f))
                }
            }

            Spacer(modifier = Modifier.height(20.dp))

            Text(
                "Reka AI Ground Truth Context",
                style = MaterialTheme.typography.titleLarge.copy(fontSize = 24.sp, fontWeight = FontWeight.ExtraBold, color = MwOnSurface)
            )

            Spacer(modifier = Modifier.height(12.dp))

            // Ground Truth Quote Card
            MwCard(
                modifier = Modifier.fillMaxWidth(),
                padding = PaddingValues(20.dp)
            ) {
                Text(
                    text = "\"${memory?.contextDescription ?: "This photo shows Sunita and Rohan at Goa beach during the summer of 2018. Eleanor is holding the red beach ball."}\"",
                    style = MaterialTheme.typography.bodyLarge.copy(
                        fontSize = 20.sp,
                        fontWeight = FontWeight.Medium,
                        color = MwOnSurfaceVariant,
                        lineHeight = 30.sp
                    )
                )
            }

            Spacer(modifier = Modifier.height(20.dp))

            // Metadata info tiles
            MetadataChip(
                icon = Icons.Default.CalendarToday,
                text = "Date Uploaded: ${memory?.dateAdded ?: "Aug 12, 2026"}"
            )

            Spacer(modifier = Modifier.height(12.dp))

            MetadataChip(
                icon = Icons.Default.Repeat,
                text = "Times Prompted: 6 times"
            )

            Spacer(modifier = Modifier.height(12.dp))

            MetadataChip(
                icon = Icons.Default.CheckCircle,
                text = "Avg. Recall Accuracy: 92%",
                iconColor = MwSecondary
            )

            Spacer(modifier = Modifier.height(100.dp))
        }
    }
}

@Composable
fun MetadataChip(
    icon: ImageVector,
    text: String,
    iconColor: Color = MwPrimary
) {
    Row(
        modifier = Modifier
            .fillMaxWidth()
            .border(2.dp, MwBorderBlack, RoundedCornerShape(8.dp))
            .clip(RoundedCornerShape(8.dp))
            .background(MwSurface)
            .padding(horizontal = 16.dp, vertical = 14.dp),
        verticalAlignment = Alignment.CenterVertically
    ) {
        Icon(icon, contentDescription = null, tint = iconColor, modifier = Modifier.size(28.dp))
        Spacer(modifier = Modifier.width(14.dp))
        Text(
            text = text,
            style = MaterialTheme.typography.titleMedium.copy(
                fontSize = 20.sp,
                fontWeight = FontWeight.Bold,
                color = MwOnSurface
            )
        )
    }
}
