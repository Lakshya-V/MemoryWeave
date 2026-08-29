package com.example.ui.screens

import androidx.compose.foundation.background
import androidx.compose.foundation.border
import androidx.compose.foundation.layout.*
import androidx.compose.foundation.rememberScrollState
import androidx.compose.foundation.shape.RoundedCornerShape
import androidx.compose.foundation.text.KeyboardOptions
import androidx.compose.foundation.verticalScroll
import androidx.compose.material.icons.Icons
import androidx.compose.material.icons.automirrored.filled.Login
import androidx.compose.material.icons.filled.Lock
import androidx.compose.material.icons.filled.Person
import androidx.compose.material.icons.filled.Visibility
import androidx.compose.material.icons.filled.VisibilityOff
import androidx.compose.material3.*
import androidx.compose.runtime.*
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.platform.testTag
import androidx.compose.ui.text.font.FontWeight
import androidx.compose.ui.text.input.KeyboardType
import androidx.compose.ui.text.input.PasswordVisualTransformation
import androidx.compose.ui.text.input.VisualTransformation
import androidx.compose.ui.text.style.TextAlign
import androidx.compose.ui.unit.dp
import androidx.compose.ui.unit.sp
import com.example.ui.components.MwButton
import com.example.ui.components.MwCard
import com.example.ui.components.MwLogo
import com.example.ui.theme.*

@Composable
fun LoginScreen(
    onLoginSuccess: () -> Unit
) {
    var username by remember { mutableStateOf("eleanor_hart") }
    var password by remember { mutableStateOf("••••••••") }
    var isPasswordVisible by remember { mutableStateOf(false) }

    Box(
        modifier = Modifier
            .fillMaxSize()
            .background(MwBackground)
            .padding(24.dp),
        contentAlignment = Alignment.Center
    ) {
        Column(
            modifier = Modifier
                .fillMaxWidth()
                .widthIn(max = 440.dp)
                .verticalScroll(rememberScrollState()),
            horizontalAlignment = Alignment.CenterHorizontally
        ) {
            MwLogo(size = 90.dp)
            Spacer(modifier = Modifier.height(16.dp))
            Text(
                text = "Your Personal Memory Companion",
                style = MaterialTheme.typography.headlineMedium.copy(
                    fontSize = 28.sp,
                    fontWeight = FontWeight.Bold,
                    color = MwPrimary,
                    lineHeight = 36.sp
                ),
                textAlign = TextAlign.Center
            )
            Spacer(modifier = Modifier.height(32.dp))

            MwCard(
                modifier = Modifier.fillMaxWidth(),
                padding = PaddingValues(24.dp)
            ) {
                Text(
                    text = "Username",
                    style = MaterialTheme.typography.labelLarge.copy(
                        fontSize = 20.sp,
                        fontWeight = FontWeight.Bold,
                        color = MwOnSurface
                    )
                )
                Spacer(modifier = Modifier.height(8.dp))
                OutlinedTextField(
                    value = username,
                    onValueChange = { username = it },
                    modifier = Modifier
                        .fillMaxWidth()
                        .height(64.dp)
                        .testTag("username_input"),
                    leadingIcon = {
                        Icon(Icons.Default.Person, contentDescription = null, tint = MwOnSurfaceVariant)
                    },
                    shape = RoundedCornerShape(4.dp),
                    colors = OutlinedTextFieldDefaults.colors(
                        focusedContainerColor = MwSurfaceContainerLow,
                        unfocusedContainerColor = MwSurfaceContainerLow,
                        focusedBorderColor = MwPrimaryContainer,
                        unfocusedBorderColor = MwBorderBlack
                    ),
                    textStyle = MaterialTheme.typography.bodyLarge.copy(
                        fontSize = 20.sp,
                        color = MwOnSurface
                    )
                )

                Spacer(modifier = Modifier.height(20.dp))

                Text(
                    text = "Password",
                    style = MaterialTheme.typography.labelLarge.copy(
                        fontSize = 20.sp,
                        fontWeight = FontWeight.Bold,
                        color = MwOnSurface
                    )
                )
                Spacer(modifier = Modifier.height(8.dp))
                OutlinedTextField(
                    value = password,
                    onValueChange = { password = it },
                    modifier = Modifier
                        .fillMaxWidth()
                        .height(64.dp)
                        .testTag("password_input"),
                    visualTransformation = if (isPasswordVisible) VisualTransformation.None else PasswordVisualTransformation(),
                    keyboardOptions = KeyboardOptions(keyboardType = KeyboardType.Password),
                    leadingIcon = {
                        Icon(Icons.Default.Lock, contentDescription = null, tint = MwOnSurfaceVariant)
                    },
                    trailingIcon = {
                        IconButton(
                            onClick = { isPasswordVisible = !isPasswordVisible },
                            modifier = Modifier.testTag("toggle_password_button")
                        ) {
                            Icon(
                                if (isPasswordVisible) Icons.Default.VisibilityOff else Icons.Default.Visibility,
                                contentDescription = "Toggle password visibility",
                                tint = MwOnSurfaceVariant
                            )
                        }
                    },
                    shape = RoundedCornerShape(4.dp),
                    colors = OutlinedTextFieldDefaults.colors(
                        focusedContainerColor = MwSurfaceContainerLowest,
                        unfocusedContainerColor = MwSurfaceContainerLowest,
                        focusedBorderColor = MwPrimaryContainer,
                        unfocusedBorderColor = MwBorderBlack
                    ),
                    textStyle = MaterialTheme.typography.bodyLarge.copy(
                        fontSize = 20.sp,
                        color = MwOnSurface
                    )
                )

                Spacer(modifier = Modifier.height(28.dp))

                MwButton(
                    text = "Log In",
                    suffixIcon = Icons.AutoMirrored.Filled.Login,
                    onClick = onLoginSuccess,
                    testTag = "login_button"
                )
            }
        }
    }
}
