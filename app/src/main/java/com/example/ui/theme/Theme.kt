package com.example.ui.theme

import androidx.compose.material3.MaterialTheme
import androidx.compose.material3.lightColorScheme
import androidx.compose.runtime.Composable

private val MemoryWeaveColorScheme = lightColorScheme(
    primary = MwPrimary,
    onPrimary = MwOnPrimary,
    primaryContainer = MwPrimaryContainer,
    onPrimaryContainer = MwOnPrimaryContainer,
    secondary = MwSecondary,
    onSecondary = MwOnSecondary,
    secondaryContainer = MwSecondaryContainer,
    onSecondaryContainer = MwOnSecondaryContainer,
    surface = MwSurface,
    onSurface = MwOnSurface,
    surfaceVariant = MwSurfaceContainerHighest,
    onSurfaceVariant = MwOnSurfaceVariant,
    background = MwBackground,
    onBackground = MwOnSurface,
    error = MwError,
    onError = MwOnError,
    errorContainer = MwErrorContainer,
    onErrorContainer = MwOnErrorContainer,
    outline = MwOutline,
    outlineVariant = MwOutlineVariant
)

@Composable
fun MemoryWeaveTheme(
    content: @Composable () -> Unit
) {
    MaterialTheme(
        colorScheme = MemoryWeaveColorScheme,
        typography = Typography,
        content = content
    )
}
