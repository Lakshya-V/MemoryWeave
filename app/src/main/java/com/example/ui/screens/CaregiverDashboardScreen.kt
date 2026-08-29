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
import androidx.compose.material.icons.filled.*
import androidx.compose.material3.*
import androidx.compose.runtime.*
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.draw.clip
import androidx.compose.ui.geometry.Offset
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.graphics.Path
import androidx.compose.ui.graphics.drawscope.Stroke
import androidx.compose.ui.platform.testTag
import androidx.compose.ui.text.font.FontWeight
import androidx.compose.ui.unit.dp
import androidx.compose.ui.unit.sp
import com.example.ui.components.MwButton
import com.example.ui.components.MwCard
import com.example.ui.components.MwTopAppBar
import com.example.ui.theme.*

data class MemoryItemUi(
    val id: String,
    val title: String,
    val dateAdded: String,
    val contextDescription: String
)

@Composable
fun CaregiverDashboardScreen(
    onNavigateBack: () -> Unit,
    onAddNewMemory: () -> Unit,
    onViewMemoryDetail: (MemoryItemUi) -> Unit
) {
    var selectedTab by remember { mutableStateOf("Daily") }

    val memories = listOf(
        MemoryItemUi("1", "Goa Vacation 1998", "Oct 12, 2023", "This photo shows Sunita and Rohan at Goa beach during the summer of 2018. Eleanor is holding the red beach ball."),
        MemoryItemUi("2", "Buster in the Yard", "Oct 05, 2023", "Golden retriever Buster on the lawn in sunny afternoon."),
        MemoryItemUi("3", "Sarah's Wedding", "Sep 28, 2023", "Vintage family wedding photograph in upstate New York.")
    )

    Scaffold(
        topBar = {
            MwTopAppBar(
                title = "Eleanor",
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
                MwButton(
                    text = "+ Add New Memory Images",
                    icon = Icons.Default.AddPhotoAlternate,
                    onClick = onAddNewMemory,
                    testTag = "add_new_memory_button"
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
                .padding(horizontal = 24.dp, vertical = 12.dp)
        ) {
            Text(
                text = "Eleanor's Overview",
                style = MaterialTheme.typography.headlineMedium.copy(
                    fontSize = 28.sp,
                    fontWeight = FontWeight.ExtraBold,
                    color = MwPrimary
                )
            )

            Spacer(modifier = Modifier.height(16.dp))

            // Time Filter Tabs
            Row(
                modifier = Modifier
                    .border(2.dp, MwBorderBlack, RoundedCornerShape(12.dp))
                    .clip(RoundedCornerShape(12.dp))
                    .background(MwSurfaceContainerLow)
                    .padding(4.dp)
            ) {
                listOf("Daily", "Weekly", "Monthly").forEach { tab ->
                    val isSelected = selectedTab == tab
                    Box(
                        modifier = Modifier
                            .border(
                                if (isSelected) 2.dp else 0.dp,
                                if (isSelected) MwBorderBlack else Color.Transparent,
                                RoundedCornerShape(8.dp)
                            )
                            .clip(RoundedCornerShape(8.dp))
                            .background(if (isSelected) MwSurface else Color.Transparent)
                            .clickable { selectedTab = tab }
                            .padding(horizontal = 20.dp, vertical = 10.dp)
                    ) {
                        Text(
                            text = tab,
                            style = MaterialTheme.typography.labelMedium.copy(
                                fontSize = 18.sp,
                                fontWeight = if (isSelected) FontWeight.Bold else FontWeight.Medium,
                                color = if (isSelected) MwOnSurface else MwOnSurfaceVariant
                            )
                        )
                    }
                }
            }

            Spacer(modifier = Modifier.height(20.dp))

            // Metric 1: Avg Accuracy
            MwCard(
                modifier = Modifier.fillMaxWidth(),
                backgroundColor = MwSurface
            ) {
                Row(
                    modifier = Modifier.fillMaxWidth(),
                    horizontalArrangement = Arrangement.SpaceBetween,
                    verticalAlignment = Alignment.CenterVertically
                ) {
                    Text("Avg. Accuracy", style = MaterialTheme.typography.titleMedium.copy(color = MwOnSurfaceVariant, fontSize = 20.sp))
                    Icon(Icons.Default.CheckCircle, contentDescription = null, tint = MwOutline, modifier = Modifier.size(24.dp))
                }
                Spacer(modifier = Modifier.height(12.dp))
                Row(verticalAlignment = Alignment.Bottom) {
                    Text("88%", style = MaterialTheme.typography.headlineLarge.copy(fontSize = 44.sp, fontWeight = FontWeight.ExtraBold, color = MwPrimary))
                    Spacer(modifier = Modifier.width(14.dp))
                    Row(
                        modifier = Modifier
                            .border(1.5.dp, MwBorderBlack, RoundedCornerShape(16.dp))
                            .clip(RoundedCornerShape(16.dp))
                            .background(MwSecondary)
                            .padding(horizontal = 10.dp, vertical = 4.dp),
                        verticalAlignment = Alignment.CenterVertically
                    ) {
                        Icon(Icons.Default.TrendingUp, contentDescription = null, tint = MwOnSecondary, modifier = Modifier.size(16.dp))
                        Spacer(modifier = Modifier.width(4.dp))
                        Text("+3% vs baseline", style = MaterialTheme.typography.labelSmall.copy(fontWeight = FontWeight.Bold, color = MwOnSecondary))
                    }
                }
            }

            Spacer(modifier = Modifier.height(16.dp))

            // Metric 2: Response Speed
            MwCard(
                modifier = Modifier.fillMaxWidth(),
                backgroundColor = MwSurface
            ) {
                Row(
                    modifier = Modifier.fillMaxWidth(),
                    horizontalArrangement = Arrangement.SpaceBetween,
                    verticalAlignment = Alignment.CenterVertically
                ) {
                    Text("Avg. Response Speed", style = MaterialTheme.typography.titleMedium.copy(color = MwOnSurfaceVariant, fontSize = 20.sp))
                    Icon(Icons.Default.Timer, contentDescription = null, tint = MwOutline, modifier = Modifier.size(24.dp))
                }
                Spacer(modifier = Modifier.height(12.dp))
                Row(verticalAlignment = Alignment.Bottom) {
                    Text("2.4s", style = MaterialTheme.typography.headlineLarge.copy(fontSize = 44.sp, fontWeight = FontWeight.ExtraBold, color = MwPrimary))
                    Spacer(modifier = Modifier.width(14.dp))
                    Row(
                        modifier = Modifier
                            .border(1.5.dp, MwBorderBlack, RoundedCornerShape(16.dp))
                            .clip(RoundedCornerShape(16.dp))
                            .background(MwSurfaceContainer)
                            .padding(horizontal = 10.dp, vertical = 4.dp),
                        verticalAlignment = Alignment.CenterVertically
                    ) {
                        Icon(Icons.Default.Info, contentDescription = null, tint = MwOnSurfaceVariant, modifier = Modifier.size(16.dp))
                        Spacer(modifier = Modifier.width(4.dp))
                        Text("Normal Response Pace", style = MaterialTheme.typography.labelSmall.copy(fontWeight = FontWeight.Bold, color = MwOnSurfaceVariant))
                    }
                }
            }

            Spacer(modifier = Modifier.height(20.dp))

            // Cognitive Trend Graph
            MwCard(
                modifier = Modifier.fillMaxWidth(),
                backgroundColor = MwSurface
            ) {
                Text("Response Time vs Accuracy Trend", style = MaterialTheme.typography.titleMedium.copy(fontSize = 20.sp, fontWeight = FontWeight.Bold))
                Spacer(modifier = Modifier.height(12.dp))
                Box(
                    modifier = Modifier
                        .fillMaxWidth()
                        .height(220.dp)
                        .border(2.dp, MwBorderBlack, RoundedCornerShape(8.dp))
                        .clip(RoundedCornerShape(8.dp))
                        .background(MwSurfaceContainerLowest)
                ) {
                    Canvas(modifier = Modifier.fillMaxSize()) {
                        val w = size.width
                        val h = size.height

                        // Baseline dashed line
                        drawLine(
                            color = MwOutlineVariant,
                            start = Offset(0f, h * 0.4f),
                            end = Offset(w, h * 0.4f),
                            strokeWidth = 3f
                        )

                        // Path
                        val path = Path().apply {
                            moveTo(16f, h * 0.7f)
                            quadraticTo(w * 0.25f, h * 0.65f, w * 0.4f, h * 0.68f)
                            quadraticTo(w * 0.55f, h * 0.65f, w * 0.7f, h * 0.35f)
                            quadraticTo(w * 0.85f, h * 0.45f, w - 16f, h * 0.5f)
                        }
                        drawPath(path, MwPrimaryContainer, style = Stroke(width = 8f))
                        drawCircle(MwError, radius = 12f, center = Offset(w * 0.7f, h * 0.35f))
                    }

                    // Alert Badge
                    Row(
                        modifier = Modifier
                            .align(Alignment.TopCenter)
                            .padding(top = 16.dp)
                            .border(2.dp, MwError, RoundedCornerShape(8.dp))
                            .clip(RoundedCornerShape(8.dp))
                            .background(MwErrorContainer)
                            .padding(horizontal = 10.dp, vertical = 6.dp),
                        verticalAlignment = Alignment.CenterVertically
                    ) {
                        Icon(Icons.Default.Warning, contentDescription = null, tint = MwOnErrorContainer, modifier = Modifier.size(18.dp))
                        Spacer(modifier = Modifier.width(4.dp))
                        Text(
                            "Cognitive Drift Alert: +1.2s delay",
                            style = MaterialTheme.typography.labelSmall.copy(fontWeight = FontWeight.Bold, color = MwOnErrorContainer)
                        )
                    }

                    // Days
                    Row(
                        modifier = Modifier
                            .align(Alignment.BottomCenter)
                            .fillMaxWidth()
                            .padding(horizontal = 12.dp, vertical = 8.dp),
                        horizontalArrangement = Arrangement.SpaceBetween
                    ) {
                        listOf("Mon", "Tue", "Wed", "Thu", "Fri", "Sat", "Sun").forEach { day ->
                            Text(day, style = MaterialTheme.typography.labelSmall.copy(fontWeight = FontWeight.Bold, color = MwOutline))
                        }
                    }
                }
            }

            Spacer(modifier = Modifier.height(24.dp))

            // Active Memory Library
            Row(verticalAlignment = Alignment.CenterVertically) {
                Text(
                    "Active Memory Library",
                    style = MaterialTheme.typography.titleLarge.copy(fontSize = 24.sp, fontWeight = FontWeight.Bold)
                )
                Spacer(modifier = Modifier.width(6.dp))
                Text("(12 Photos)", style = MaterialTheme.typography.bodyMedium.copy(color = MwOnSurfaceVariant))
            }

            Spacer(modifier = Modifier.height(14.dp))

            memories.forEach { memory ->
                MwCard(
                    modifier = Modifier
                        .fillMaxWidth()
                        .padding(bottom = 12.dp),
                    backgroundColor = MwSurface,
                    onClick = { onViewMemoryDetail(memory) }
                ) {
                    Row(verticalAlignment = Alignment.CenterVertically) {
                        Box(
                            modifier = Modifier
                                .size(72.dp)
                                .border(2.dp, MwBorderBlack, RoundedCornerShape(8.dp))
                                .clip(RoundedCornerShape(8.dp))
                                .background(MwSurfaceContainerHigh),
                            contentAlignment = Alignment.Center
                        ) {
                            Icon(Icons.Default.Image, contentDescription = null, tint = MwPrimary, modifier = Modifier.size(36.dp))
                        }
                        Spacer(modifier = Modifier.width(14.dp))
                        Column(modifier = Modifier.weight(1f)) {
                            Text(memory.title, style = MaterialTheme.typography.titleMedium.copy(fontSize = 18.sp, fontWeight = FontWeight.Bold))
                            Spacer(modifier = Modifier.height(4.dp))
                            Row(verticalAlignment = Alignment.CenterVertically) {
                                Icon(Icons.Default.Event, contentDescription = null, tint = MwOnSurfaceVariant, modifier = Modifier.size(16.dp))
                                Spacer(modifier = Modifier.width(4.dp))
                                Text("Added: ${memory.dateAdded}", style = MaterialTheme.typography.bodyMedium.copy(fontSize = 14.sp, color = MwOnSurfaceVariant))
                            }
                        }
                        IconButton(
                            onClick = { onViewMemoryDetail(memory) },
                            modifier = Modifier
                                .border(2.dp, MwBorderBlack, RoundedCornerShape(8.dp))
                                .size(44.dp)
                        ) {
                            Icon(Icons.Default.Info, contentDescription = "Show Context", tint = MwPrimary)
                        }
                    }
                }
            }

            Spacer(modifier = Modifier.height(12.dp))

            OutlinedButton(
                onClick = {},
                modifier = Modifier
                    .fillMaxWidth()
                    .height(56.dp),
                shape = RoundedCornerShape(12.dp),
                border = androidx.compose.foundation.BorderStroke(2.dp, MwBorderBlack),
                colors = ButtonDefaults.outlinedButtonColors(containerColor = MwSurfaceContainer)
            ) {
                Text("Load More Memories", style = MaterialTheme.typography.labelLarge.copy(fontSize = 18.sp, fontWeight = FontWeight.Bold, color = MwOnSurface))
            }

            Spacer(modifier = Modifier.height(80.dp))
        }
    }
}
