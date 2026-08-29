package com.example.ui.screens

import androidx.compose.foundation.Canvas
import androidx.compose.foundation.background
import androidx.compose.foundation.border
import androidx.compose.foundation.clickable
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
import androidx.compose.ui.geometry.Rect
import androidx.compose.ui.geometry.Size
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.platform.testTag
import androidx.compose.ui.text.font.FontWeight
import androidx.compose.ui.unit.dp
import androidx.compose.ui.unit.sp
import com.example.ui.components.MwButton
import com.example.ui.components.MwCard
import com.example.ui.theme.*
import kotlinx.coroutines.launch

@OptIn(ExperimentalMaterial3Api::class)
@Composable
fun PatientHomeScreen(
    onStartQuiz: () -> Unit,
    onOpenCaregiverMode: () -> Unit
) {
    val drawerState = rememberDrawerState(initialValue = DrawerValue.Closed)
    val scope = rememberCoroutineScope()
    var isMedicationTaken by remember { mutableStateOf(false) }

    ModalNavigationDrawer(
        drawerState = drawerState,
        drawerContent = {
            ModalDrawerSheet(
                drawerContainerColor = MwSurface,
                modifier = Modifier
                    .width(300.dp)
                    .fillMaxHeight()
                    .border(2.dp, MwBorderBlack)
            ) {
                Spacer(modifier = Modifier.height(24.dp))
                // Drawer Header / Items
                NavigationDrawerItem(
                    icon = { Icon(Icons.Default.Home, contentDescription = null, tint = MwOnPrimary, modifier = Modifier.size(32.dp)) },
                    label = { Text("Home", fontSize = 24.sp, fontWeight = FontWeight.Bold, color = MwOnPrimary) },
                    selected = true,
                    onClick = { scope.launch { drawerState.close() } },
                    modifier = Modifier
                        .padding(horizontal = 16.dp, vertical = 6.dp)
                        .border(2.dp, MwBorderBlack, RoundedCornerShape(12.dp)),
                    colors = NavigationDrawerItemDefaults.colors(
                        selectedContainerColor = MwPrimaryContainer,
                        unselectedContainerColor = Color.Transparent
                    )
                )

                NavigationDrawerItem(
                    icon = { Icon(Icons.Default.Psychology, contentDescription = null, tint = MwOnSurface, modifier = Modifier.size(32.dp)) },
                    label = { Text("Quiz", fontSize = 24.sp, fontWeight = FontWeight.Bold, color = MwOnSurface) },
                    selected = false,
                    onClick = {
                        scope.launch {
                            drawerState.close()
                            onStartQuiz()
                        }
                    },
                    modifier = Modifier
                        .padding(horizontal = 16.dp, vertical = 6.dp),
                    colors = NavigationDrawerItemDefaults.colors(
                        unselectedContainerColor = Color.Transparent
                    )
                )

                Spacer(modifier = Modifier.weight(1f))

                NavigationDrawerItem(
                    icon = { Icon(Icons.Default.Settings, contentDescription = null, tint = MwOnSurface, modifier = Modifier.size(32.dp)) },
                    label = { Text("Settings", fontSize = 24.sp, fontWeight = FontWeight.Bold, color = MwOnSurface) },
                    selected = false,
                    onClick = {
                        scope.launch {
                            drawerState.close()
                            onOpenCaregiverMode()
                        }
                    },
                    modifier = Modifier
                        .padding(horizontal = 16.dp, vertical = 16.dp),
                    colors = NavigationDrawerItemDefaults.colors(
                        unselectedContainerColor = Color.Transparent
                    )
                )
            }
        }
    ) {
        Scaffold(
            topBar = {
                Surface(
                    modifier = Modifier
                        .fillMaxWidth()
                        .height(72.dp),
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
                            onClick = { scope.launch { drawerState.open() } },
                            modifier = Modifier.testTag("drawer_menu_button")
                        ) {
                            Icon(Icons.Default.Menu, contentDescription = "Menu", tint = MwPrimary, modifier = Modifier.size(32.dp))
                        }
                        Spacer(modifier = Modifier.width(8.dp))
                        Text(
                            text = "Welcome back, Eleanor!",
                            style = MaterialTheme.typography.titleLarge.copy(
                                fontSize = 22.sp,
                                fontWeight = FontWeight.Bold,
                                color = MwPrimary
                            ),
                            modifier = Modifier.weight(1f)
                        )
                        Row(
                            modifier = Modifier
                                .border(1.5.dp, MwBorderBlack, RoundedCornerShape(8.dp))
                                .clip(RoundedCornerShape(8.dp))
                                .background(MwSurfaceContainerLow)
                                .clickable { onOpenCaregiverMode() }
                                .padding(horizontal = 10.dp, vertical = 6.dp)
                                .testTag("caregiver_mode_button"),
                            verticalAlignment = Alignment.CenterVertically
                        ) {
                            Icon(Icons.Default.Settings, contentDescription = null, tint = MwPrimary, modifier = Modifier.size(22.dp))
                            Spacer(modifier = Modifier.width(4.dp))
                            Text(
                                text = "Caregiver",
                                style = MaterialTheme.typography.labelMedium.copy(
                                    fontWeight = FontWeight.Bold,
                                    color = MwPrimary
                                )
                            )
                        }
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
                // Medication Pill Reminder Card
                if (isMedicationTaken) {
                    MwCard(
                        backgroundColor = MwSecondaryContainer,
                        borderColor = MwBorderBlack,
                        modifier = Modifier.fillMaxWidth()
                    ) {
                        Row(verticalAlignment = Alignment.CenterVertically) {
                            Icon(Icons.Default.CheckCircle, contentDescription = null, tint = MwSecondary, modifier = Modifier.size(36.dp))
                            Spacer(modifier = Modifier.width(16.dp))
                            Text(
                                text = "Morning medicine marked as taken! Well done.",
                                style = MaterialTheme.typography.titleMedium.copy(
                                    fontSize = 18.sp,
                                    fontWeight = FontWeight.Bold,
                                    color = MwOnSecondaryContainer
                                ),
                                modifier = Modifier.weight(1f)
                            )
                        }
                    }
                } else {
                    MwCard(
                        backgroundColor = MwWarningContainer,
                        borderColor = MwBorderBlack,
                        modifier = Modifier.fillMaxWidth(),
                        padding = PaddingValues(20.dp)
                    ) {
                        Row(
                            verticalAlignment = Alignment.Top,
                            modifier = Modifier.fillMaxWidth()
                        ) {
                            Icon(
                                Icons.Default.Medication,
                                contentDescription = null,
                                tint = MwPrimary,
                                modifier = Modifier.size(38.dp)
                            )
                            Spacer(modifier = Modifier.width(14.dp))
                            Text(
                                text = "Pill Reminder: Please take your morning medicine.",
                                style = MaterialTheme.typography.headlineMedium.copy(
                                    fontSize = 24.sp,
                                    fontWeight = FontWeight.ExtraBold,
                                    color = MwPrimary,
                                    lineHeight = 32.sp
                                ),
                                modifier = Modifier.weight(1f)
                            )
                        }
                        Spacer(modifier = Modifier.height(18.dp))
                        MwButton(
                            text = "I Took It",
                            icon = Icons.Default.CheckCircle,
                            backgroundColor = MwSecondary,
                            foregroundColor = MwOnSecondary,
                            onClick = { isMedicationTaken = true },
                            testTag = "medication_taken_button"
                        )
                    }
                }

                Spacer(modifier = Modifier.height(24.dp))

                // Memory Quiz Hero Tile
                MwCard(
                    backgroundColor = MwPrimaryContainer,
                    borderColor = MwBorderBlack,
                    modifier = Modifier.fillMaxWidth(),
                    padding = PaddingValues(24.dp)
                ) {
                    // Hero Image Canvas
                    Box(
                        modifier = Modifier
                            .fillMaxWidth()
                            .height(190.dp)
                            .border(2.dp, MwBorderBlack, RoundedCornerShape(8.dp))
                            .clip(RoundedCornerShape(8.dp))
                            .background(Color(0xFFF7F3E9))
                    ) {
                        Canvas(modifier = Modifier.fillMaxSize()) {
                            val cx = size.width / 2
                            val cy = size.height * 0.55f

                            // Backdrop circles
                            drawCircle(Color(0xFF88D982).copy(alpha = 0.5f), radius = 80f, center = Offset(size.width * 0.2f, size.height * 0.7f))
                            drawCircle(Color(0xFF88D982).copy(alpha = 0.5f), radius = 90f, center = Offset(size.width * 0.8f, size.height * 0.6f))

                            // Person 1 (Navy)
                            drawCircle(Color(0xFFE2C4A2), radius = 22f, center = Offset(cx - 50f, cy - 30f))
                            drawRoundRect(Color(0xFF001F3F), topLeft = Offset(cx - 70f, cy), size = Size(40f, 70f), cornerRadius = androidx.compose.ui.geometry.CornerRadius(10f))

                            // Person 2 (Emerald)
                            drawCircle(Color(0xFFE2C4A2), radius = 22f, center = Offset(cx + 50f, cy - 30f))
                            drawRoundRect(Color(0xFF1B6D24), topLeft = Offset(cx + 30f, cy), size = Size(40f, 70f), cornerRadius = androidx.compose.ui.geometry.CornerRadius(10f))

                            // Child in middle (Light Blue)
                            drawCircle(Color(0xFFE2C4A2), radius = 16f, center = Offset(cx, cy - 8f))
                            drawRoundRect(Color(0xFFD4E3FF), topLeft = Offset(cx - 15f, cy + 12f), size = Size(30f, 50f), cornerRadius = androidx.compose.ui.geometry.CornerRadius(8f))
                        }
                    }

                    Spacer(modifier = Modifier.height(20.dp))

                    Text(
                        text = "Today's Memory Quiz",
                        style = MaterialTheme.typography.headlineMedium.copy(
                            fontSize = 28.sp,
                            fontWeight = FontWeight.ExtraBold,
                            color = MwOnPrimary
                        )
                    )

                    Spacer(modifier = Modifier.height(20.dp))

                    MwButton(
                        text = "Start Quiz Now",
                        icon = Icons.Default.PlayCircle,
                        backgroundColor = MwSurfaceContainerLowest,
                        foregroundColor = MwPrimary,
                        height = 72.dp,
                        onClick = onStartQuiz,
                        testTag = "start_quiz_hero_button"
                    )
                }
            }
        }
    }
}
