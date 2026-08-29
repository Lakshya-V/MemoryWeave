package com.example.ui.components

import androidx.compose.foundation.BorderStroke
import androidx.compose.foundation.Canvas
import androidx.compose.foundation.background
import androidx.compose.foundation.border
import androidx.compose.foundation.clickable
import androidx.compose.foundation.layout.*
import androidx.compose.foundation.shape.CircleShape
import androidx.compose.foundation.shape.RoundedCornerShape
import androidx.compose.material.icons.Icons
import androidx.compose.material.icons.automirrored.filled.ArrowBack
import androidx.compose.material3.*
import androidx.compose.runtime.Composable
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.draw.clip
import androidx.compose.ui.geometry.Offset
import androidx.compose.ui.geometry.Rect
import androidx.compose.ui.geometry.Size
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.graphics.Path
import androidx.compose.ui.graphics.drawscope.Stroke
import androidx.compose.ui.graphics.vector.ImageVector
import androidx.compose.ui.platform.testTag
import androidx.compose.ui.text.font.FontWeight
import androidx.compose.ui.text.style.TextAlign
import androidx.compose.ui.unit.Dp
import androidx.compose.ui.unit.dp
import androidx.compose.ui.unit.sp
import com.example.ui.theme.*

@Composable
fun MwCard(
    modifier: Modifier = Modifier,
    backgroundColor: Color = MwSurfaceContainerLowest,
    borderColor: Color = MwBorderBlack,
    borderWidth: Dp = 2.dp,
    cornerRadius: Dp = 12.dp,
    padding: PaddingValues = PaddingValues(16.dp),
    onClick: (() -> Unit)? = null,
    content: @Composable ColumnScope.() -> Unit
) {
    val shape = RoundedCornerShape(cornerRadius)
    val cardModifier = if (onClick != null) {
        modifier
            .border(borderWidth, borderColor, shape)
            .clip(shape)
            .background(backgroundColor)
            .clickable { onClick() }
            .padding(padding)
    } else {
        modifier
            .border(borderWidth, borderColor, shape)
            .clip(shape)
            .background(backgroundColor)
            .padding(padding)
    }

    Column(
        modifier = cardModifier,
        content = content
    )
}

@Composable
fun MwButton(
    text: String,
    onClick: () -> Unit,
    modifier: Modifier = Modifier,
    icon: ImageVector? = null,
    suffixIcon: ImageVector? = null,
    backgroundColor: Color = MwPrimaryContainer,
    foregroundColor: Color = MwOnPrimary,
    borderColor: Color = MwBorderBlack,
    height: Dp = 64.dp,
    testTag: String = "action_button"
) {
    Button(
        onClick = onClick,
        modifier = modifier
            .fillMaxWidth()
            .height(height)
            .testTag(testTag),
        colors = ButtonDefaults.buttonColors(
            containerColor = backgroundColor,
            contentColor = foregroundColor
        ),
        shape = RoundedCornerShape(8.dp),
        border = BorderStroke(2.dp, borderColor)
    ) {
        Row(
            verticalAlignment = Alignment.CenterVertically,
            horizontalArrangement = Arrangement.Center
        ) {
            if (icon != null) {
                Icon(icon, contentDescription = null, modifier = Modifier.size(28.dp))
                Spacer(modifier = Modifier.width(10.dp))
            }
            Text(
                text = text,
                style = MaterialTheme.typography.labelLarge.copy(
                    fontSize = 20.sp,
                    fontWeight = FontWeight.Bold,
                    color = foregroundColor
                )
            )
            if (suffixIcon != null) {
                Spacer(modifier = Modifier.width(10.dp))
                Icon(suffixIcon, contentDescription = null, modifier = Modifier.size(28.dp))
            }
        }
    }
}

@Composable
fun MwTopAppBar(
    title: String,
    onBackClick: (() -> Unit)? = null,
    actions: @Composable (RowScope.() -> Unit)? = null
) {
    Surface(
        modifier = Modifier
            .fillMaxWidth()
            .height(72.dp),
        color = MwSurface,
        border = BorderStroke(2.dp, MwBorderBlack)
    ) {
        Row(
            modifier = Modifier
                .fillMaxSize()
                .padding(horizontal = 12.dp),
            verticalAlignment = Alignment.CenterVertically
        ) {
            if (onBackClick != null) {
                IconButton(
                    onClick = onBackClick,
                    modifier = Modifier.size(48.dp)
                ) {
                    Icon(
                        Icons.AutoMirrored.Filled.ArrowBack,
                        contentDescription = "Back",
                        tint = MwPrimary,
                        modifier = Modifier.size(32.dp)
                    )
                }
            } else {
                Spacer(modifier = Modifier.width(48.dp))
            }

            Text(
                text = title,
                style = MaterialTheme.typography.titleLarge.copy(
                    fontSize = 24.sp,
                    fontWeight = FontWeight.Bold,
                    color = MwPrimary
                ),
                textAlign = TextAlign.Center,
                modifier = Modifier.weight(1f)
            )

            if (actions != null) {
                Row(content = actions)
            } else {
                Spacer(modifier = Modifier.width(48.dp))
            }
        }
    }
}

@Composable
fun MwLogo(modifier: Modifier = Modifier, size: Dp = 100.dp) {
    Column(
        modifier = modifier,
        horizontalAlignment = Alignment.CenterHorizontally
    ) {
        Canvas(modifier = Modifier.size(size)) {
            val strokeWidth = 6.dp.toPx()
            val centerOffset = Offset(this.size.width / 2, this.size.height / 2)
            val radius = this.size.width * 0.22f

            drawCircle(
                color = MwPrimaryContainer,
                radius = radius,
                center = Offset(centerOffset.x - radius * 0.7f, centerOffset.y),
                style = Stroke(strokeWidth)
            )
            drawCircle(
                color = MwPrimaryContainer,
                radius = radius,
                center = Offset(centerOffset.x + radius * 0.7f, centerOffset.y),
                style = Stroke(strokeWidth)
            )
            drawCircle(
                color = MwSecondary,
                radius = 5.dp.toPx(),
                center = centerOffset
            )
        }
        Spacer(modifier = Modifier.height(4.dp))
        Text(
            text = "MemoryWeave",
            style = MaterialTheme.typography.titleLarge.copy(
                fontSize = 24.sp,
                fontWeight = FontWeight.ExtraBold,
                color = MwPrimary
            )
        )
    }
}
