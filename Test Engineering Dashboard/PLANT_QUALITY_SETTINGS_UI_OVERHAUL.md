# PlantQualitySettings UI Overhaul Summary

## Date: January 2025

## Changes Implemented

### 1. Toast Notifications
- Replaced static status panel with animated toast notifications
- Slide-in from right with smooth animation
- Auto-dismisses after 4 seconds
- Manual close button included
- Success (green) and Error (red) variants

### 2. YTD (Year-To-Date) Columns
Added calculated YTD columns to all three sections:

| Section | YTD Calculation | Display Format |
|---------|-----------------|----------------|
| **Yield** | Average of non-zero values | `XX.XX%` |
| **Scrap** | Sum of all 12 months | `$X,XXX.XX` |
| **NCM** | Sum of all 12 months | `$X,XXX.XX` |

- YTD values are calculated client-side via JavaScript
- Updates automatically when any input value changes
- Styled with indigo/purple background to distinguish from editable cells

### 3. Separate Ledger Tables for Scrap
Replaced single scrap table with ledger grouped layout:
- **SPD Ledger** - Contains SPD line
- **D-IT Ledger** - Contains 9PXM/Switch, ePDU, Battery, Shazam, TAA, Ferrups, BladeUPS
- **Energy Transition Ledger** - Contains Phoenix

Each ledger table includes:
- Individual line rows with editable inputs
- YTD sum column per line
- **Ledger Total row** (non-editable, auto-calculated)
  - Monthly totals for each month
  - Grand total in YTD column

### 4. Colored Section Headers
Gradient backgrounds for easy visual identification:

| Section | Background Colors |
|---------|-------------------|
| **Yield** | Green gradient (`#10b981` → `#059669`) |
| **Scrap** | Orange gradient (`#f59e0b` → `#d97706`) |
| **NCM** | Red gradient (`#ef4444` → `#dc2626`) |

Headers now feature:
- White text with text shadow
- White-tinted icons in rounded boxes
- White pill badges for scope and unit type

### 5. Improved Badge Styling
- Badges now use frosted glass effect (`rgba(255,255,255,0.2)`)
- Uppercase text with letter-spacing
- Consistent padding and border-radius

### 6. Ledger Subsection Styling
- Each ledger has titled subsection bar
- Orange accent color for scrap ledger headers
- Clean separation between ledger tables

## Technical Details

### ASPX Changes
- Added toast notification HTML structure
- Added hidden fields for server-to-client toast messages
- Restructured scrap section with 3 separate ledger subsections
- Added YTD columns to all table headers
- Updated JavaScript for:
  - Toast show/hide animations
  - YTD calculation on page load and input blur
  - Ledger total row calculations

### Code-Behind Changes
- `GenerateYieldGoalRowsWithYTD()` - Adds YTD cell to yield rows
- `GenerateScrapLedgerTables()` - Populates 3 separate literal controls
- `GenerateScrapRowsForLedger()` - Creates line rows + ledger total row
- `GenerateNCMGoalRowsWithYTD()` - Adds YTD cell to NCM row
- `btnSave_Click()` - Uses hidden fields for toast instead of panel

### New Literal Controls
```
litScrapSPDRows - SPD Ledger lines
litScrapDITRows - D-IT Ledger lines  
litScrapETRows  - Energy Transition Ledger lines
```

### Hidden Fields for Toast
```
hfToastMessage - Message text
hfToastType    - "success" or "error"
```

## Responsive Design
Maintains responsive adjustments for:
- < 1200px: Smaller inputs, reduced padding
- > 1600px: Larger inputs, more spacing

## Dark Mode Support
All new styles include dark mode variants using:
```css
html:not(.theme-light):not([data-theme='light']) { ... }
```
