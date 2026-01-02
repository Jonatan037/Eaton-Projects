# 🎨 Calibration Dashboard - Visual Design Reference

## Dashboard Layout Preview

```
┏━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━┓
┃ 🏢 Eaton YPO INTERNAL | Test Engineering              ☀️/🌙 Theme Toggle    ┃
┗━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━┛

┏━━━━━━━━━━━━━┓  ┏━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━┓
┃  SIDEBAR    ┃  ┃  CALIBRATION DASHBOARD                    [🔗 Full View]  ┃
┃             ┃  ┃  Real-time insights and upcoming calibrations             ┃
┃   👤 User   ┃  ┣━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━┫
┃   John Doe  ┃  ┃                                                            ┃
┃   Admin     ┃  ┃  ┏━━━━━━━━━━━━┓ ┏━━━━━━━━━━━━┓ ┏━━━━━━━━━━━━┓ ┏━━━━━━━┓ ┃
┃             ┃  ┃  ┃ 🔴 OVERDUE ┃ ┃ 🟡 DUE     ┃ ┃ 🟢 ON-TIME ┃ ┃ OOT   ┃ ┃
┃ 📊 Dashboard┃  ┃  ┃            ┃ ┃ NEXT 30    ┃ ┃ RATE       ┃ ┃       ┃ ┃
┃ 📈 Analytics┃  ┃  ┃     3      ┃ ┃     12     ┃ ┃   96.5%    ┃ ┃ 2.1%  ┃ ┃
┃             ┃  ┃  ┃            ┃ ┃            ┃ ┃            ┃ ┃       ┃ ┃
┃ TEST ENG.   ┃  ┃  ┃ Immediate  ┃ ┃ Schedule   ┃ ┃ 243 of 252 ┃ ┃ 5 inc ┃ ┃
┃ ━━━━━━━━━━  ┃  ┃  ┗━━━━━━━━━━━━┛ ┗━━━━━━━━━━━━┛ ┗━━━━━━━━━━━━┛ ┗━━━━━━━┛ ┃
┃ 🏭 Equipment┃  ┃                                                            ┃
┃ ⚖️ Calibrtn ┃  ┃  ┏━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━┓ ┃
┃ 🔧 Prev.Mnt ┃  ┃  ┃ 📊 Monthly Calibration Volume (12 months)            ┃ ┃
┃ 🔍 Troublsh ┃  ┃  ┃                                                       ┃ ┃
┃ 📋 Test Crt ┃  ┃  ┃    ╱╲                                                ┃ ┃
┃ 🏢 Stations ┃  ┃  ┃   ╱  ╲          ╱╲                                   ┃ ┃
┃ 📊 Metrics  ┃  ┃  ┃  ╱    ╲    ╱╲  ╱  ╲    ╱╲                           ┃ ┃
┃             ┃  ┃  ┃ ╱      ╲  ╱  ╲╱    ╲  ╱  ╲                          ┃ ┃
┃ QUALITY     ┃  ┃  ┃╱        ╲╱          ╲╱    ╲                         ┃ ┃
┃ ━━━━━━━━━━  ┃  ┃  ┗━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━┛ ┃
┃ 🎯 FPY      ┃  ┃                                                            ┃
┃ 📈 Yield    ┃  ┃  ┏━━━━━━━━━━━━━━━━━━━━━━━━┓ ┏━━━━━━━━━━━━━━━━━━━━━━━━┓ ┃
┃ 📜 History  ┃  ┃  ┃ 🍩 Equipment Type      ┃ ┃ 🥧 Method              ┃ ┃
┃ ⚠️ Failures ┃  ┃  ┃                        ┃ ┃                        ┃ ┃
┃             ┃  ┃  ┃      ╭─────╮           ┃ ┃     ╭──────╮          ┃ ┃
┃ OTHER       ┃  ┃  ┃     ╱       ╲          ┃ ┃    ╱        ╲         ┃ ┃
┃ ━━━━━━━━━━  ┃  ┃  ┃    │   45%   │         ┃ ┃   │  Internal │       ┃ ┃
┃ ⚙️ Settings ┃  ┃  ┃     ╲       ╱          ┃ ┃    ╲   68%  ╱         ┃ ┃
┃ 💬 Help     ┃  ┃  ┃      ╰─────╯           ┃ ┃     ╰──────╯          ┃ ┃
┃ 👤 Admin    ┃  ┃  ┃                        ┃ ┃                        ┃ ┃
┃ 🚪 Logout   ┃  ┃  ┗━━━━━━━━━━━━━━━━━━━━━━━━┛ ┗━━━━━━━━━━━━━━━━━━━━━━━━┛ ┃
┗━━━━━━━━━━━━━┛  ┃                                                            ┃
                 ┃  ┏━━━━━━━━━━━━━━━━━━━━━━━━┓ ┏━━━━━━━━━━━━━━━━━━━━━━━━┓ ┃
                 ┃  ┃ 📊 Vendor Performance  ┃ ┃ 📊 Result Distribution ┃ ┃
                 ┃  ┃                        ┃ ┃                        ┃ ┃
                 ┃  ┃ Vendor A ▓▓▓▓░░░  12d  ┃ ┃  ▄▄                   ┃ ┃
                 ┃  ┃ Vendor B ▓▓▓▓▓░░  15d  ┃ ┃  ██  ▄▄  ▄▄  ▄▄       ┃ ┃
                 ┃  ┃ Vendor C ▓▓▓▓▓▓░  18d  ┃ ┃  ██  ██  ██  ██       ┃ ┃
                 ┃  ┃ Vendor D ▓▓▓▓▓▓▓  21d  ┃ ┃ Pass Adj OOT Fail     ┃ ┃
                 ┃  ┗━━━━━━━━━━━━━━━━━━━━━━━━┛ ┗━━━━━━━━━━━━━━━━━━━━━━━━┛ ┃
                 ┃                                                            ┃
                 ┃  ┏━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━┓ ┃
                 ┃  ┃ 📅 Upcoming Calibrations (Next 90 Days)     [View All]┃ ┃
                 ┃  ┣━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━┫ ┃
                 ┃  ┃ EQ-00123 │ Oscilloscope XYZ     │ SCOPE │ 🔴 Oct 20  ┃ ┃
                 ┃  ┃ EQ-00456 │ Multimeter ABC       │ DMM   │ 🔴 Oct 22  ┃ ┃
                 ┃  ┃ EQ-00789 │ Power Supply 100W    │ PSU   │ 🟡 Nov 05  ┃ ┃
                 ┃  ┃ EQ-01012 │ Function Generator   │ FG    │ 🟡 Nov 12  ┃ ┃
                 ┃  ┃ EQ-01345 │ Spectrum Analyzer    │ SA    │ 🟢 Dec 01  ┃ ┃
                 ┃  ┃ EQ-01678 │ Network Analyzer     │ NA    │ 🟢 Dec 15  ┃ ┃
                 ┃  ┗━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━┛ ┃
                 ┗━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━┛
```

---

## Color Scheme

### Dark Mode (Default)
```
Background Colors:
├─ Primary Panel:     rgba(25, 29, 37, 0.52) with blur
├─ Sidebar:           rgba(25, 29, 37, 0.55) with blur
├─ Cards/Charts:      rgba(25, 29, 37, 0.52) with blur
└─ Glass Effect:      backdrop-filter: blur(28-40px)

Status Colors:
├─ 🔴 Red/Danger:     #fca5a5 (Light Red)
├─ 🟡 Amber/Warning:  #fcd34d (Light Amber)
├─ 🟢 Green/Success:  #6ee7b7 (Light Green)
└─ 🔵 Blue/Info:      #93c5fd (Light Blue)

Text Colors:
├─ Primary Text:      rgba(255, 255, 255, 0.85)
├─ Secondary Text:    rgba(255, 255, 255, 0.65)
└─ Muted Text:        rgba(255, 255, 255, 0.45)

Borders & Lines:
├─ Panel Borders:     rgba(255, 255, 255, 0.08)
├─ Dividers:          rgba(255, 255, 255, 0.06)
└─ Grid Lines:        rgba(255, 255, 255, 0.06)
```

### Light Mode
```
Background Colors:
├─ Primary Panel:     #ffffff
├─ Sidebar:           rgba(255, 255, 255, 0.7) with blur
├─ Cards/Charts:      #ffffff
└─ Alternating Rows:  #fafbfc

Status Colors:
├─ 🔴 Red/Danger:     #dc2626 (Dark Red)
├─ 🟡 Amber/Warning:  #d97706 (Dark Amber)
├─ 🟢 Green/Success:  #059669 (Dark Green)
└─ 🔵 Blue/Info:      #2563eb (Dark Blue)

Text Colors:
├─ Primary Text:      rgba(0, 0, 0, 0.75)
├─ Secondary Text:    rgba(0, 0, 0, 0.55)
└─ Muted Text:        rgba(0, 0, 0, 0.35)

Borders & Lines:
├─ Panel Borders:     rgba(0, 0, 0, 0.08)
├─ Dividers:          rgba(0, 0, 0, 0.06)
└─ Grid Lines:        rgba(0, 0, 0, 0.06)
```

---

## Typography

```
Font Family: 'Poppins', -apple-system, BlinkMacSystemFont, 'Segoe UI', sans-serif

Page Title:          24px / 800 weight / 0.2px letter-spacing
Page Subtitle:       12px / 400 weight / 0.7 opacity
KPI Label:           11px / 600 weight / 0.3px letter-spacing / UPPERCASE
KPI Value:           32px / 800 weight / 1.0 line-height
KPI Footer:          10px / 400 weight / 0.65 opacity
Chart Title:         14px / 700 weight / 0.2px letter-spacing
Chart Subtitle:      10px / 400 weight / 0.65 opacity
List Items:          12px / 500 weight
Equipment ID:        11px / 700 weight / monospace / 0.85 opacity
```

---

## Component Spacing

```
Grid Gaps:
├─ KPI Grid:          12px between cards
├─ Chart Grid:        16px between charts
└─ Page Sections:     16px vertical spacing

Card Padding:
├─ KPI Cards:         16px all sides
├─ Chart Panels:      18px horizontal, 20px vertical
├─ List Container:    18px horizontal, 20px vertical
└─ List Items:        10px vertical, 12px horizontal

Border Radius:
├─ KPI Cards:         14px
├─ Chart Panels:      16px
├─ List Items:        10px
├─ Buttons:           8-10px
└─ Sidebar:           18px
```

---

## Responsive Breakpoints

```
Desktop (1440px+):
├─ KPI Grid:          5 columns
├─ Chart Grid:        2 columns
├─ Sidebar:           280px fixed
└─ Content:           Remaining space

Laptop (1024-1439px):
├─ KPI Grid:          3 columns
├─ Chart Grid:        2 columns
├─ Sidebar:           280px fixed
└─ Content:           Adjusted

Tablet (768-1023px):
├─ KPI Grid:          2 columns
├─ Chart Grid:        1 column
├─ Sidebar:           Collapsed/Hidden
└─ Content:           Full width

Mobile (<768px):
├─ KPI Grid:          2 columns (stacked)
├─ Chart Grid:        1 column
├─ Sidebar:           Hidden (menu button)
└─ Content:           Full width
```

---

## Chart Specifications

### Monthly Volume (Line Chart)
```
Type:           Line with area fill
Height:         320px
Data Points:    12 (last 12 months)
Line:           2px width, smooth curve (tension: 0.4)
Points:         4px radius, 6px on hover
Area Fill:      10% opacity
Grid:           Horizontal only, subtle color
Legend:         Hidden (single dataset)
```

### Equipment Type (Doughnut Chart)
```
Type:           Doughnut
Height:         320px
Segments:       Up to 10 types
Cutout:         60% (default)
Colors:         7 distinct colors cycling
Legend:         Bottom, horizontal, compact labels
Hover:          8px offset
```

### Method Distribution (Pie Chart)
```
Type:           Pie
Height:         320px
Segments:       2-3 methods (Internal/External)
Colors:         3 distinct colors
Legend:         Bottom, horizontal
Hover:          8px offset
```

### Vendor Performance (Horizontal Bar)
```
Type:           Horizontal Bar
Height:         320px
Bars:           Top 5 vendors
Bar Height:     20px each
Corner Radius:  6px
Colors:         Single purple color
Axis:           Y-axis (labels), X-axis (days)
Grid:           X-axis only
```

### Result Distribution (Vertical Bar)
```
Type:           Vertical Bar
Height:         320px
Bars:           4-5 result types
Bar Width:      32px
Corner Radius:  6px (top only)
Colors:         Multi-color (status-based)
Axis:           Y-axis (count), X-axis (labels)
Grid:           Y-axis only
```

---

## Interactive States

### Hover Effects
```
KPI Cards:
├─ Transform:         translateY(-2px)
├─ Shadow:            Enhanced depth
└─ Duration:          200ms ease

Chart Tooltips:
├─ Background:        rgba(0,0,0,0.9) / rgba(255,255,255,0.95)
├─ Border:            1px solid
├─ Padding:           10px
└─ Border Radius:     6px

List Items:
├─ Background:        Slightly lighter
├─ Border:            Enhanced visibility
└─ Duration:          200ms ease

Buttons:
├─ Transform:         translateY(-1px)
├─ Shadow:            Enhanced
└─ Duration:          200ms ease
```

### Active States
```
Navigation Links:
├─ Background:        Blue tint (rgba)
├─ Border:            Blue border
├─ Color:             Light blue text
└─ Indicator:         Left border accent

Selected Items:
├─ Background:        Highlighted
├─ Border:            Accent color
└─ Icon:              Filled/Colored
```

---

## Accessibility Features

```
Color Contrast:
├─ Text on Dark:      4.5:1 minimum
├─ Text on Light:     4.5:1 minimum
└─ Status Colors:     AAA compliant

Keyboard Navigation:
├─ Tab Order:         Logical flow
├─ Focus Indicators:  Visible outline
└─ Skip Links:        Implemented

Screen Readers:
├─ Semantic HTML:     Proper tags
├─ ARIA Labels:       Descriptive
├─ Alt Text:          All images
└─ Role Attributes:   Navigation, Main, etc.

Font Sizes:
├─ Minimum:           10px (metadata)
├─ Body:              12-13px
├─ Headings:          14-24px
└─ Scalable:          Relative units (rem/em)
```

---

## Animation & Motion

```
Page Load:
├─ Fade In:           300ms opacity transition
├─ Slide Up:          Card entrance animation
└─ Stagger:           50ms delay between cards

Chart Animations:
├─ Draw:              400ms chart render
├─ Ease:              easeInOutQuart
└─ Delay:             Sequential by dataset

Hover Transitions:
├─ Transform:         200ms ease
├─ Color:             250ms ease
└─ Shadow:            200ms ease

Theme Switch:
├─ Color Transition:  300ms ease
├─ Background:        300ms ease
└─ Chart Redraw:      400ms with animation
```

---

## Browser Compatibility Notes

```
Modern Features Used:
├─ CSS Grid:          Full support (IE11+)
├─ CSS Custom Props:  Full support (IE11 polyfill)
├─ Flexbox:           Full support (IE10+)
├─ backdrop-filter:   Limited support (Safari, Chrome, Edge)
└─ Canvas (Charts):   Full support (IE9+)

Fallbacks:
├─ backdrop-filter:   Solid background if not supported
├─ Grid:              Flexbox fallback for IE
├─ Custom Props:      Inline styles for IE
└─ ES6 JavaScript:    Transpiled to ES5 if needed
```

---

## Performance Optimizations

```
Page Load:
├─ Critical CSS:      Inline in <head>
├─ Deferred JS:       Non-blocking load
└─ Lazy Loading:      Charts load after DOM ready

Chart Rendering:
├─ Canvas:            Hardware accelerated
├─ Data Caching:      Server-side view caching
└─ Throttling:        Resize event debounced

Database:
├─ Indexed Queries:   All date filters indexed
├─ Aggregated Views:  Pre-calculated KPIs
└─ Query Limits:      TOP N for charts

Network:
├─ CDN Assets:        Chart.js from CDN
├─ Gzip:              Enabled for text files
└─ Caching:           Static resources cached
```

---

## Design Inspiration Sources

This dashboard design was inspired by:

1. **Apple Design Guidelines** - Clean, minimalist interface
2. **Dribbble Analytics Dashboards** - Card-based layouts
3. **Material Design** - Elevation and depth
4. **Tailwind CSS** - Color palette and spacing scale
5. **Glassmorphism Trend** - Frosted glass effects
6. **Modern SaaS Platforms** - Stripe, Vercel, Linear

Key Design Principles:
- **Clarity over complexity** - Easy to scan and understand
- **Data-first approach** - Information takes precedence
- **Status-driven design** - Colors guide decision-making
- **Minimalist aesthetic** - Remove unnecessary elements
- **Professional polish** - Attention to micro-interactions

---

**Visual Design Version:** 1.0.0  
**Design Language:** Modern Glassmorphism + Minimalism  
**Primary Colors:** Blue, Green, Amber, Red  
**Font:** Poppins (Google Fonts)  
**Icons:** Custom SVG line icons
