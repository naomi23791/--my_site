# 🎨 Recommandations Design UI/UX & Mockups – LinguaPlay

**Objectif** : Fournir directives design détaillées pour Figma + HTML mockups interactifs.

---

## 📐 Design System

### Palette de couleurs (validée ✅)

```
🔵 Primaire: #3A86FF (Bleu)
   Usage: Buttons principaux, headers, highlights,bouton de creer un compte,ou se connecter au cas ou le compte existe deja,une place pour le mot de passe oublie

🟢 Secondaire: #83C5BE (Vert)
   Usage: Succès, completion, progress bars

🟠 Accent: #FF8C42 (Orange)
   Usage: Notifications, CTAs secondaires, daily challenge

⚪ Fond: #F8F9FA (Blanc cassé)
   Usage: Backgrounds, surfaces

⚫ Texte primaire: #212529 (Gris foncé)
   Usage: Headings, primary text

⚫ Texte secondaire: #6C757D (Gris moyen)
   Usage: Subtitles, metadata

🔴 Erreur: #DC3545 (Rouge)
   Usage: Erreurs, validation

✅ Succès: #28A745 (Vert foncé)
   Usage: Confirmations
```

### Typographie

```
Headings:
- H1 (32px): Poppins Bold, #212529
  Usage: Page titles, hero sections

- H2 (24px): Poppins SemiBold, #212529
  Usage: Section headers

- H3 (20px): Poppins Medium, #212529
  Usage: Subsection headers

- H4 (16px): Poppins Medium, #212529
  Usage: Card titles

Body:
- Regular (16px): Open Sans Regular, #212529
  Usage: Primary content text

- Regular (14px): Open Sans Regular, #6C757D
  Usage: Secondary content, metadata

- Small (12px): Open Sans Regular, #999999
  Usage: Captions, timestamps

Buttons:
- Label (16px): Poppins SemiBold, uppercase
  Usage: Button text
```

### Spacing & Sizing

```
Padding: 8px, 12px, 16px, 20px, 24px, 32px (multiples of 4)
Border radius: 8px (cards), 12px (buttons), 16px (containers)
Icons: 24px (standard), 32px (large), 48px (hero)
Card elevation: 4px shadow, 0px on hover state
```

---

## 📱 Écrans Mobile (Portrait)

### 1️⃣ Splash Screen (1-2 secondes)

```
┌─────────────────────────────┐
│                             │
│                             │
│         🌍 LinguaPlay       │
│                             │
│     "Learn Languages        │
│      in a Fun Way!"         │
│                             │
│                             │
│    [Loading spinner...]     │
│                             │
└─────────────────────────────┘

Design specs:
- Centered logo (120x120px)
- Gradient BG: blue → green
- Animated spinner (Lottie)
- No navigation bar
```

### 2️⃣ Onboarding Screen 1 - Bienvenue

```
┌─────────────────────────────┐
│                             │
│   [Skip]              [>]   │ (Top)
│                             │
│                             │
│      🎮 LinguaPlay          │ (Logo, 100px)
│                             │
│  "Master New Languages"     │ (H2)
│                             │
│  Learn while playing fun    │ (Body, centered)
│  games with friends!        │
│                             │
│  ● ○ ○                      │ (Indicators)
│                             │
│  [Next]                     │ (Primary button)
│                             │
└─────────────────────────────┘

Key elements:
- Illustration de voyage (svg/image)
- PageView indicator dots
- Back/Next buttons
```

### 3️⃣ Onboarding Screen 2 - Language Selection

```
┌─────────────────────────────┐
│  [<]        Languages   [X] │ (AppBar)
│                             │
│  Select language(s)         │ (H3)
│  to learn                   │
│                             │
│  ┌──────────────────────┐   │
│  │ 🇬🇧 English     [✓]  │   │ (Checkbox)
│  └──────────────────────┘   │
│                             │
│  ┌──────────────────────┐   │
│  │ 🇪🇸 Español      [ ]  │   │
│  └──────────────────────┘   │
│                             │
│  ┌──────────────────────┐   │
│  │ 🇫🇷 Français      [ ]  │   │
│  └──────────────────────┘   │
│                             │
│  ○ ● ○                      │ (Indicators)
│                             │
│  [Continue]                 │ (Primary button)
│                             │
└─────────────────────────────┘

Features:
- ListView.builder avec checkboxes
- Flags emojis
- Multi-select possible
```

### 4️⃣ Home Screen / Dashboard

```
┌─────────────────────────────┐
│  LinguaPlay      🔔 ⚙️      │ (AppBar)
├─────────────────────────────┤
│                             │
│  ┌─────────────────────┐    │
│  │ 🏆 Daily Challenge  │    │ (Hero section)
│  │                     │    │
│  │ Translate 10        │    │
│  │ sentences           │    │
│  │                     │    │
│  │ [Start] [Info]      │    │
│  └─────────────────────┘    │
│                             │
│  📊 Your Progress           │ (Section header)
│  ┌──────────┐ ┌──────────┐ │
│  │ English  │ │ Spanish  │ │ (Progress cards)
│  │  65%     │ │   30%    │ │
│  └──────────┘ └──────────┘ │
│                             │
│  🎮 Play Games              │ (Section header)
│  ┌──────┐ ┌──────┐          │
│  │ Quiz │ │Memory│          │ (Game grid 2x2)
│  └──────┘ └──────┘          │
│  ┌──────┐ ┌──────┐          │
│  │Words │ │Listen│          │
│  └──────┘ └──────┘          │
│                             │
│ ┌───────────────────────┐   │
│ │ 🎯 Active Challenges  │   │
│ │ • Vocab: 8/10 done    │   │
│ │ • Speaking: Not done  │   │
│ └───────────────────────┘   │
│                             │
├─────────────────────────────┤
│ 🏠  🎮  📊  👤              │ (Bottom nav)
└─────────────────────────────┘

Responsive: Adjust grid columns on larger screens
```

### 5️⃣ Games List Screen

```
┌─────────────────────────────┐
│  <  Games                   │ (AppBar)
├─────────────────────────────┤
│                             │
│ 🎯 All Games  🔍           │
│ [Filter ▼]  [Search...]    │
│                             │
│ ┌──────────────────────┐    │
│ │ 📝 Quiz              │    │ (Game Card)
│ │ English - Easy       │    │
│ │ 100 players today    │    │
│ │ ★★★★★ (4.8)        │    │
│ └──────────────────────┘    │
│                             │
│ ┌──────────────────────┐    │
│ │ 🧠 Memory Game       │    │
│ │ Spanish - Medium     │    │
│ │ 45 players today     │    │
│ │ ★★★★☆ (4.2)        │    │
│ └──────────────────────┘    │
│                             │
│ ┌──────────────────────┐    │
│ │ 🔤 Word Search       │    │
│ │ French - Hard        │    │
│ │ 12 players today     │    │
│ │ ★★★★☆ (4.5)        │    │
│ └──────────────────────┘    │
│                             │
│ ┌──────────────────────┐    │
│ │ 👂 Listening         │    │
│ │ German - Medium      │    │
│ │ 67 players today     │    │
│ │ ★★★★★ (4.9)        │    │
│ └──────────────────────┘    │
│                             │
└─────────────────────────────┘

Features:
- Scroll ListView
- Tap = navigate to game detail/play
- Filter dialog
```

### 6️⃣ Quiz Screen (In-Game)

```
┌─────────────────────────────┐
│  <  Quiz - English  Exit    │ (AppBar)
├─────────────────────────────┤
│ ▓▓▓▓▓░░░ 5/10  60s ⏱      │ (Progress bar + timer)
│                             │
│                             │
│  What is the capital of     │ (Question, H3)
│  France?                    │
│                             │
│                             │
│  ┌──────────────────────┐   │
│  │ □ London             │   │ (Answer button)
│  └──────────────────────┘   │
│                             │
│  ┌──────────────────────┐   │
│  │ □ Paris              │   │
│  └──────────────────────┘   │
│                             │
│  ┌──────────────────────┐   │
│  │ □ Berlin             │   │
│  └──────────────────────┘   │
│                             │
│  ┌──────────────────────┐   │
│  │ □ Madrid             │   │
│  └──────────────────────┘   │
│                             │
│                             │
│  [Skip Question]            │ (Secondary button)
│                             │
└─────────────────────────────┘

After answer click:
- ✅ Green if correct + "Great!"
- ❌ Red if wrong + show correct answer
- Auto-advance after 2s
```

### 7️⃣ Game Result Screen

```
┌─────────────────────────────┐
│                             │
│   🎉 Awesome Job!           │ (Centered, large)
│                             │
│   Score: 8/10 ⭐⭐⭐       │ (Stars)
│                             │
│   +80 Points                │ (Highlight)
│   ✓ Daily Streak +1         │
│   🏆 Earned Badge!          │ (If applicable)
│                             │
│   ─────────────────         │
│                             │
│   📊 Performance:           │ (Stats section)
│   • Correct: 8              │
│   • Wrong: 2                │
│   • Time: 3m 20s            │
│   • Avg Speed: 20s/Q        │
│                             │
│   ─────────────────         │
│                             │
│  [Share on Social] [Next]   │ (Action buttons)
│                             │
│  [← Back to Games]          │ (Secondary)
│                             │
└─────────────────────────────┘

Features:
- Confetti animation on load
- Share intent support
- Next = new random game
```

### 8️⃣ Profile Screen

```
┌─────────────────────────────┐
│  Profile              ⚙️     │ (AppBar)
├─────────────────────────────┤
│                             │
│        [Avatar: 120x120]    │ (User photo)
│                             │
│      John Doe               │ (Username, H2)
│      Level 12 • 2,340 pts   │ (Metadata)
│                             │
│      7 🔥 Streak            │ (Streak highlight)
│                             │
│      [Edit Profile]         │ (Button)
│                             │
│ ─────────────────────────   │
│                             │
│  Languages Learning:        │ (Section)
│  🇬🇧 English 65%           │
│  🇪🇸 Spanish 30%           │
│  🇫🇷 French 15%            │
│                             │
│ ─────────────────────────   │
│                             │
│  Recent Games (6 max):      │ (Section)
│  📝 Quiz • English (Score)  │
│  🧠 Memory • Spanish        │
│  🔤 Word Search • French    │
│                             │
│ ─────────────────────────   │
│                             │
│  Achievements (3 locked):   │ (Section)
│  🏆 🏆 🏆 🔒 🔒            │
│                             │
└─────────────────────────────┘

Features:
- Tap edit = EditProfileScreen
- Tap achievement = modal detail
```

### 9️⃣ Leaderboard Screen

```
┌─────────────────────────────┐
│  Leaderboard           🔄   │ (AppBar)
├─────────────────────────────┤
│                             │
│  This Week    🏆 All Time  │ (Tabs)
│                             │
│  Your Rank: #42 • 850 pts   │ (Info bar)
│                             │
│  ┌─────────────────────┐    │
│  │ 1. 👑 Anna    2,340 │    │ (Gold bg)
│  │    🇬🇧 English     │    │
│  └─────────────────────┘    │
│                             │
│  ┌─────────────────────┐    │
│  │ 2. 🥈 Marco   1,850 │    │ (Silver bg)
│  │    🇪🇸 Spanish     │    │
│  └─────────────────────┘    │
│                             │
│  ┌─────────────────────┐    │
│  │ 3. 🥉 Sophie  1,620 │    │ (Bronze bg)
│  │    🇫🇷 French      │    │
│  └─────────────────────┘    │
│                             │
│  ┌─────────────────────┐    │
│  │ 4. Emma        980  │    │
│  │    🇩🇪 German      │    │
│  └─────────────────────┘    │
│                             │
│  ┌─────────────────────┐    │
│  │ 5. Lucas      850   │    │
│  │    🇳🇱 Dutch       │    │
│  └─────────────────────┘    │
│                             │
│  ... (scroll for more)      │
│                             │
│  42. 👤 You       850   ⭐  │ (Highlight row)
│                             │
└─────────────────────────────┘

Features:
- Two tabs (weekly/all-time)
- Medal icons for top 3
- Highlight own rank
- Swipe to refresh
```

---

## 🖥️ Responsive Desktop Layout

### Desktop Adaptation (Web/Tablet)

```
┌────────────────────────────────────────────┐
│                                            │
│  [Logo]  LinguaPlay    🔔  👤  ⚙️         │ (Header fixed)
│                                            │
├──────────┬────────────────────────┬────────┤
│          │                        │        │
│  Sidebar │   Main Content         │ Right  │
│  ────    │   (Games, Profile,     │ Panel  │
│  🏠 Home │    Challenges, etc)    │ ────   │
│  🎮 Games│                        │ Your   │
│  🏆 Daily│   [Responsive grid]    │ Stats  │
│  📊 Stats│                        │ ────   │
│  👥 Social                        │ Points:│
│  🎁 Rewards                       │ 2,340  │
│  ⚙️ Settings                      │        │
│          │                        │ Streak:│
│          │                        │ 7 🔥   │
│          │                        │        │
│          │                        │ Next   │
│          │                        │ Badge: │
│          │                        │ 150pts │
│          │                        │        │
│          │                        │ Weekly │
│          │                        │ Top 5: │
│          │                        │ 1. Anna│
│          │                        │ 2. Marco│
│          │                        │ ...    │
│          │                        │        │
└──────────┴────────────────────────┴────────┘
```

---

## 🎮 Memory Game Screen Example

```
┌─────────────────────────────┐
│  <  Memory Game  Score: 120 │ (AppBar)
├─────────────────────────────┤
│ ▓▓▓▓▓▓░░░ 6/12  120s ⏱    │ (Progress)
│                             │
│  ┌────┐ ┌────┐ ┌────┐ ┌────┐ │
│  │ 🎨 │ │    │ │ 🎵 │ │    │ │ (Cards grid 4x4)
│  └────┘ └────┘ └────┘ └────┘ │
│                             │
│  ┌────┐ ┌────┐ ┌────┐ ┌────┐ │
│  │    │ │ 🎭 │ │    │ │ 🎪 │ │
│  └────┘ └────┘ └────┘ └────┘ │
│                             │
│  ┌────┐ ┌────┐ ┌────┐ ┌────┐ │
│  │ 🎬 │ │    │ │    │ │ 🎤 │ │
│  └────┘ └────┘ └────┘ └────┘ │
│                             │
│  ┌────┐ ┌────┐ ┌────┐ ┌────┐ │
│  │    │ │    │ │ 🎸 │ │    │ │
│  └────┘ └────┘ └────┘ └────┘ │
│                             │
│  [Hint]                     │
│                             │
└─────────────────────────────┘

Features:
- Tap card = flip animation
- Match = remove and highlight green
- Wrong match = shake animation, auto-flip
- Timer countdown
```

---

## 🎨 Component Library (Figma Components)

```
Colors/
├── Primary
├── Secondary
├── Accent
├── Neutral
└── Status

Typography/
├── H1-H4
├── Body
├── Button
└── Caption

Buttons/
├── Primary (enabled/disabled/loading)
├── Secondary
├── Outline
└── Icon buttons

Cards/
├── Game Card
├── Achievement Card
├── Leaderboard Entry
└── Challenge Card

Forms/
├── Text Input
├── Dropdown
├── Checkbox
└── Radio

Progress/
├── Linear Progress Bar
├── Circular Progress
└── Streaks

Badges/
├── Points badge
├── Rank badge
└── Achievement badge

Navigation/
├── Bottom nav bar
├── Top app bar
└── Sidebar
```

---

## 🎬 Animations & Interactions

### Micro-interactions

```
Button Press:
- Scale: 95% on press
- Ripple effect (Material)
- Color change
- Feedback haptic (light)

Card Hover (Desktop):
- Elevation increase (shadow)
- Scale: 102%
- Color tint
- Smooth transition (300ms)

Page Transition:
- Fade In / Slide from bottom
- Duration: 300ms
- Curve: easeInOut

Game Card Match:
- Flip animation (3D)
- Pulse on success
- Shake on failure
- Sound effect (sfx)

Score Popup:
- Scale: 0 → 1.2 → 1
- Float up
- Fade out
- Duration: 1s
- Easing: easeOutBounce

Confetti (Achievement):
- Random particles
- Physics: gravity + wind
- Duration: 2-3s
- Colors: brand palette
```

---

## 📐 Breakpoints (Responsive)

```
Mobile Small: 320px - 479px
Mobile: 480px - 599px
Tablet: 600px - 1023px
Desktop: 1024px+

Example MediaQuery usage:

if (context.width < 600) {
  // Mobile layout
} else if (context.width < 1024) {
  // Tablet layout
} else {
  // Desktop layout
}
```

---

## ✅ Accessibility Checklist

```
Colors:
✅ Contrast ratio ≥ 4.5:1 for text
✅ Not relying on color alone

Text:
✅ Min font size: 12px
✅ Line height: 1.5x
✅ Letter spacing: 0.5px for headings

Interaction:
✅ Touch targets: min 48x48px
✅ Keyboard navigation support
✅ Focus indicators (outline)

Content:
✅ Alternative text for images
✅ Captions for audio/video
✅ Skip navigation links

Dark Mode:
✅ Support if time allows
✅ Use OLED-safe colors
```

---

## 🔗 Figma Setup Steps

1. **Create Design File**
   - File → New
   - Set up frames (375x667 for mobile mockup)

2. **Setup Components**
   - Create buttons, cards, inputs as components
   - Use variants for states (enabled/disabled/loading)

3. **Create Screens**
   - Duplicate frame for each screen
   - Use components from library
   - Add interactions (prototype)

4. **Add Interactions**
   - Select element
   - Prototype tab
   - Add interaction → trigger
   - Link to destination frame

5. **Share with Team**
   - Share link
   - Enable comments
   - Export assets (SVG/PNG)

6. **Dev Handoff**
   - Export specs: margins, colors, fonts
   - Use Figma dev mode for code snippets

---

## 🎨 HTML Mockup Prototype (Quick Demo)

```html
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>LinguaPlay - UI Mockup</title>
    <style>
        * { margin: 0; padding: 0; box-sizing: border-box; }
        
        body {
            font-family: 'Open Sans', sans-serif;
            background: #f8f9fa;
            padding: 20px;
        }
        
        .container {
            max-width: 375px;
            margin: 0 auto;
            background: white;
            border-radius: 16px;
            box-shadow: 0 4px 12px rgba(0,0,0,0.1);
            overflow: hidden;
        }
        
        .header {
            background: #3A86FF;
            color: white;
            padding: 16px 20px;
            display: flex;
            justify-content: space-between;
            align-items: center;
            font-size: 18px;
            font-weight: 600;
        }
        
        .daily-challenge {
            background: linear-gradient(135deg, #3A86FF 0%, #83C5BE 100%);
            color: white;
            padding: 20px;
            margin: 16px;
            border-radius: 12px;
            text-align: center;
        }
        
        .daily-challenge h2 { font-size: 24px; margin-bottom: 8px; }
        .daily-challenge p { font-size: 14px; margin-bottom: 16px; }
        .daily-challenge button {
            background: white;
            color: #3A86FF;
            border: none;
            padding: 10px 20px;
            border-radius: 8px;
            font-weight: 600;
            cursor: pointer;
        }
        
        .game-grid {
            display: grid;
            grid-template-columns: 1fr 1fr;
            gap: 12px;
            padding: 0 16px 16px;
        }
        
        .game-card {
            background: white;
            border: 1px solid #e0e0e0;
            border-radius: 12px;
            padding: 16px;
            text-align: center;
            cursor: pointer;
            transition: all 0.3s;
        }
        
        .game-card:hover {
            box-shadow: 0 4px 12px rgba(58, 134, 255, 0.2);
            transform: translateY(-2px);
        }
        
        .game-card-icon { font-size: 40px; margin-bottom: 8px; }
        .game-card-title { font-weight: 600; font-size: 14px; }
        .game-card-subtitle { font-size: 12px; color: #6c757d; }
        
        .bottom-nav {
            display: flex;
            justify-content: space-around;
            border-top: 1px solid #e0e0e0;
            padding: 12px 0;
            background: white;
        }
        
        .nav-item {
            flex: 1;
            text-align: center;
            color: #6c757d;
            font-size: 24px;
            cursor: pointer;
        }
        
        .nav-item.active { color: #3A86FF; }
    </style>
</head>
<body>
    <div class="container">
        <div class="header">
            <span>LinguaPlay</span>
            <div>🔔 ⚙️</div>
        </div>
        
        <div class="daily-challenge">
            <h2>🏆 Daily Challenge</h2>
            <p>Translate 10 sentences</p>
            <button>Start Challenge</button>
        </div>
        
        <h3 style="padding: 0 16px; margin-top: 16px; font-size: 16px;">Play Games</h3>
        
        <div class="game-grid">
            <div class="game-card">
                <div class="game-card-icon">📝</div>
                <div class="game-card-title">Quiz</div>
                <div class="game-card-subtitle">English</div>
            </div>
            <div class="game-card">
                <div class="game-card-icon">🧠</div>
                <div class="game-card-title">Memory</div>
                <div class="game-card-subtitle">Spanish</div>
            </div>
            <div class="game-card">
                <div class="game-card-icon">🔤</div>
                <div class="game-card-title">Word Search</div>
                <div class="game-card-subtitle">French</div>
            </div>
            <div class="game-card">
                <div class="game-card-icon">👂</div>
                <div class="game-card-title">Listening</div>
                <div class="game-card-subtitle">German</div>
            </div>
        </div>
        
        <div style="height: 20px;"></div>
        
        <div class="bottom-nav">
            <div class="nav-item active">🏠</div>
            <div class="nav-item">🎮</div>
            <div class="nav-item">📊</div>
            <div class="nav-item">👤</div>
        </div>
    </div>
</body>
</html>
```

---

## 🎯 Next Steps

1. **Week 1**: Import design assets into Figma
2. **Week 2**: Create high-fidelity mockups for all screens
3. **Week 3**: Dev team reviews designs + feedback
4. **Week 4**: Hand-off specs to Flutter dev team

---

