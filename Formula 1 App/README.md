# ApexGrid AI 🏎️

A modern, scalable web application for managing F1 2025 game leagues. Built with Next.js 15, Supabase, Prisma, and AI-powered features.

![ApexGrid AI](https://img.shields.io/badge/ApexGrid-AI-E10600?style=for-the-badge&logo=f1&logoColor=white)
![Next.js](https://img.shields.io/badge/Next.js-15-black?style=for-the-badge&logo=next.js&logoColor=white)
![TypeScript](https://img.shields.io/badge/TypeScript-5.0-3178C6?style=for-the-badge&logo=typescript&logoColor=white)
![Supabase](https://img.shields.io/badge/Supabase-Auth%20%26%20DB-3FCF8E?style=for-the-badge&logo=supabase&logoColor=white)

## ✨ Features

### Core Features
- **🏆 League Management** - Create and manage F1 leagues with custom rules
- **📊 Standings & Statistics** - Automatic calculation with F1-style tiebreakers
- **📅 Race Calendar** - Full season management with support for sprints
- **👥 Team & Driver Management** - Complete roster management
- **📈 Results Entry** - Manual entry or CSV import
- **🎨 Custom Scoring** - Configurable points systems

### Advanced Features
- **🤖 AI Assistant** - Ask questions about standings, predictions, and rules
- **🔔 Discord Webhooks** - Automated notifications for results and updates
- **🌐 Internationalization** - English and Spanish support
- **🌙 Dark/Light Mode** - Beautiful F1-themed interface
- **📱 Responsive Design** - Works on all devices

## 🚀 Quick Start

### Prerequisites

- Node.js 20+
- pnpm (recommended) or npm
- Supabase account
- PostgreSQL with pgvector extension (provided by Supabase)
- OpenAI API key (for AI features)

### Installation

1. **Clone the repository**
   ```bash
   git clone https://github.com/yourusername/apexgrid-ai.git
   cd apexgrid-ai
   ```

2. **Install dependencies**
   ```bash
   pnpm install
   ```

3. **Set up environment variables**
   ```bash
   cp .env.example .env.local
   ```
   Fill in your environment variables (see [Environment Variables](#environment-variables))

4. **Set up the database**
   ```bash
   pnpm prisma generate
   pnpm prisma db push
   ```

5. **Seed the database** (see [Database Seeding](#database-seeding) for details)
   ```bash
   pnpm prisma db seed
   ```

6. **Run the development server**
   ```bash
   pnpm dev
   ```

7. **Open your browser**
   Navigate to [http://localhost:3000](http://localhost:3000)

---

## 🌱 Database Seeding

The seed script (`prisma/seed.ts`) populates the database with demo data for development and testing.

### What Gets Seeded

| Entity | Count | Description |
|--------|-------|-------------|
| Admin User | 1 | JonatanAriasGonzalez@Gmail.com with admin role |
| Tracks | 10 | Official F1 2025 circuits with metadata |
| Demo League | 1 | "Apex Championship 2025" - PUBLIC league |
| Teams | 10 | All F1 2025 constructors with colors |
| Drivers | 22 | 20 regular + 2 reserve drivers |
| Rounds | 6 | Mixed calendar with sprints |
| Scoring | 1 | Custom F1-style points system |

### Seed Commands

```bash
# Run the seed script
pnpm prisma db seed

# Reset database and re-seed (warning: deletes all data!)
pnpm prisma migrate reset

# View seeded data in Prisma Studio
pnpm prisma studio
```

### Customizing the Seed

Edit `prisma/seed.ts` to modify:

- **Admin email**: Change `ADMIN_EMAIL` constant
- **Tracks**: Add/remove tracks in `TRACKS_SEED` array
- **Teams**: Modify `TEAMS_SEED` with custom teams
- **Drivers**: Update `DRIVERS_SEED` for different drivers
- **Scoring**: Adjust `DEFAULT_SCORING` for custom points

### CSV Import Template

A CSV template for importing race results is available at:
- `/public/templates/results-import-template.csv`
- `/public/templates/CSV-IMPORT-README.md`

The template includes columns for:
- position, driverGamertag, teamShortName
- sessionType (QUALIFYING, SPRINT, RACE)
- status (FINISHED, DNF, DNS, DSQ)
- fastestLap, gapToLeader

---

## 🔧 Environment Variables

Create a `.env.local` file with the following variables:

```env
# Supabase
NEXT_PUBLIC_SUPABASE_URL=your_supabase_url
NEXT_PUBLIC_SUPABASE_ANON_KEY=your_supabase_anon_key
SUPABASE_SERVICE_ROLE_KEY=your_service_role_key


# Database (from Supabase)
DATABASE_URL=postgresql://postgres:[PASSWORD]@[HOST]:5432/postgres

# OpenAI (for AI features)
OPENAI_API_KEY=sk-your-openai-key

# App
NEXT_PUBLIC_APP_URL=http://localhost:3000
```

## 📁 Project Structure

```
src/
├── app/                    # Next.js App Router
│   ├── api/               # API routes
│   │   ├── chat/         # AI chat endpoint
│   │   ├── leagues/      # League API
│   │   ├── results/      # Results import
│   │   ├── tracks/       # Tracks API
│   │   └── webhooks/     # Discord webhooks
│   ├── auth/             # Authentication pages
│   ├── leagues/          # League pages
│   │   ├── [slug]/       # League detail & admin
│   │   └── page.tsx      # Leagues list
│   ├── actions.ts        # Server actions
│   ├── layout.tsx        # Root layout
│   └── page.tsx          # Home page
├── components/            # React components
│   ├── layout/           # Header, Footer
│   ├── ui/               # shadcn/ui components
│   ├── ai-chat.tsx       # AI chat interface
│   ├── locale-toggle.tsx # Language switcher
│   └── theme-toggle.tsx  # Theme switcher
├── i18n/                 # Internationalization
│   ├── messages/         # Translation files
│   └── request.ts        # i18n config
├── lib/                  # Utility libraries
│   ├── supabase/         # Supabase clients
│   ├── csv-parser.ts     # CSV import
│   ├── date-utils.ts     # Date formatting
│   ├── db.ts             # Prisma client
│   ├── predictions.ts    # AI predictions
│   ├── standings.ts      # Standings calculator
│   └── utils.ts          # General utilities
├── schemas/              # Zod validation schemas
└── styles/               # Global styles
    └── globals.css       # Tailwind + F1 theme

prisma/
├── schema.prisma         # Database schema
└── seed.ts              # Seed script

tests/
├── e2e/                  # Playwright tests
└── unit/                 # Vitest tests
```

## 📊 Database Schema

The application uses PostgreSQL with the following main models:

- **User** - Authentication and profile
- **League** - F1 leagues with settings
- **Team** - Constructor teams
- **Driver** - Individual drivers
- **Track** - Racing circuits
- **Round** - Calendar events
- **Result** - Race/sprint/quali results
- **Scoring** - Points configuration
- **Membership** - User-league relationships
- **AuditLog** - Activity tracking

## 📝 CSV Import Format

Import race results using CSV files with the following columns:

| Column | Required | Description | Example |
|--------|----------|-------------|---------|
| Position | ✅ | Finishing position or DNF/NC | 1, 2, DNF |
| Driver | ✅ | Driver name or gamertag | Max Verstappen |
| Team | ❌ | Team name | Red Bull |
| Gap | ❌ | Gap to leader | +5.123 |
| FastestLap | ❌ | Fastest lap (true/false) | true |
| DNF | ❌ | Did not finish | false |
| DSQ | ❌ | Disqualified | false |

### Example CSV

```csv
Position,Driver,Team,Gap,FastestLap,DNF
1,Max Verstappen,Red Bull,,true,false
2,Lewis Hamilton,Mercedes,+5.123,false,false
3,Charles Leclerc,Ferrari,+12.456,false,false
DNF,Carlos Sainz,Ferrari,,false,true
```

## 🎨 Theming

The app uses a custom F1-inspired color palette:

| Color | Hex | Usage |
|-------|-----|-------|
| Brand Red | `#E10600` | Primary actions, F1 branding |
| Brand Black | `#0A0A0A` | Dark backgrounds |
| Papaya | `#FF8700` | Accents, sprint badges |
| Racing Green | `#00D4AA` | Success states |

## 🧪 Testing

### Unit Tests (Vitest)
```bash
pnpm test        # Run all tests
pnpm test:watch  # Watch mode
pnpm test:coverage # Coverage report
```

### E2E Tests (Playwright)
```bash
pnpm e2e         # Run e2e tests
pnpm e2e:ui      # Interactive UI mode
```

## 🚢 Deployment

### Netlify (Recommended)

The app is pre-configured for Netlify deployment with the `@netlify/plugin-nextjs` plugin which handles:
- ✅ Next.js App Router
- ✅ Server Actions
- ✅ API Routes (as Netlify Functions)
- ✅ Edge Functions
- ✅ ISR and Static Generation

#### Deployment Steps

1. **Push to GitHub**
   ```bash
   git add .
   git commit -m "Ready for deployment"
   git push origin main
   ```

2. **Connect to Netlify**
   - Go to [Netlify Dashboard](https://app.netlify.com)
   - Click "Add new site" → "Import an existing project"
   - Select your GitHub repository
   - Netlify auto-detects the `netlify.toml` configuration

3. **Set Environment Variables**
   
   Go to Site Settings → Build & Deploy → Environment variables:

   | Variable | Required | Description |
   |----------|----------|-------------|
   | `DATABASE_URL` | ✅ | Supabase PostgreSQL pooler URL |
   | `DIRECT_URL` | ✅ | Direct database URL (for migrations) |
   | `NEXT_PUBLIC_SUPABASE_URL` | ✅ | Your Supabase project URL |
   | `NEXT_PUBLIC_SUPABASE_ANON_KEY` | ✅ | Supabase anonymous key |
   | `SUPABASE_SERVICE_ROLE_KEY` | ✅ | Service role key (server-side) |
   | `NEXT_PUBLIC_APP_URL` | ✅ | Your Netlify URL (https://your-site.netlify.app) |
   | `OPENAI_API_KEY` | ❌ | For AI chat and embeddings |
   | `STRIPE_SECRET_KEY` | ❌ | For subscription billing (future) |
   | `STRIPE_WEBHOOK_SECRET` | ❌ | Stripe webhook verification |

4. **Deploy**
   - Netlify will automatically build and deploy
   - Build command: `pnpm build`
   - Publish directory: `.next`

5. **Set up Database**
   ```bash
   # Generate Prisma client (runs during build)
   pnpm prisma generate
   
   # Push schema to production database
   DATABASE_URL="your-prod-url" pnpm prisma db push
   
   # Seed production database (optional)
   DATABASE_URL="your-prod-url" pnpm prisma db seed
   ```

#### Troubleshooting

| Issue | Solution |
|-------|----------|
| Build fails with memory error | Increase build memory in Netlify settings |
| Prisma client not found | Ensure `prisma generate` runs in build |
| API routes timeout | Upgrade to Netlify Pro for 60s timeout |
| Database connection errors | Check `DATABASE_URL` uses pooler connection |

### Vercel (Alternative)

```bash
pnpm vercel
```

---

## 💰 Subscription Tiers

ApexGrid AI offers two subscription tiers:

### Free Tier
- **1 League** maximum
- **20 Members** per league
- Basic features:
  - League management
  - Standings calculation
  - Race calendar
  - Results entry
  - Discord webhooks

### Pro Tier ($9.99/month)
- **10 Leagues** maximum
- **200 Members** per league
- All Free features plus:
  - 🤖 **AI Assistant** - Ask questions, get predictions
  - 📊 **Advanced Analytics** - Deep insights and statistics
  - 🔮 **Race Predictions** - AI-powered predictions
  - 📈 **Export Data** - CSV/Excel exports
  - 🎨 **Custom Branding** - League logos and themes
  - ⚡ **Priority Support** - Faster response times

### Feature Comparison

| Feature | Free | Pro |
|---------|:----:|:---:|
| Leagues | 1 | 10 |
| Members per League | 20 | 200 |
| League Management | ✅ | ✅ |
| Standings & Results | ✅ | ✅ |
| Race Calendar | ✅ | ✅ |
| CSV Import | ✅ | ✅ |
| Discord Webhooks | ✅ | ✅ |
| AI Chat Assistant | ❌ | ✅ |
| AI Predictions | ❌ | ✅ |
| Advanced Analytics | ❌ | ✅ |
| Data Export | ❌ | ✅ |
| Custom Branding | ❌ | ✅ |
| Priority Support | ❌ | ✅ |

---

## 🛠️ Development

### Commands

```bash
pnpm dev          # Start development server
pnpm build        # Build for production
pnpm start        # Start production server
pnpm lint         # Run ESLint
pnpm format       # Format with Prettier
pnpm prisma studio # Open Prisma Studio
```

### Database Migrations

```bash
pnpm prisma migrate dev    # Create migration
pnpm prisma db push        # Push schema changes
pnpm prisma generate       # Generate client
pnpm prisma db seed        # Seed database
```

## 🤖 AI Features

The AI assistant uses OpenAI's GPT-4 to answer questions about:

- Championship standings
- Driver/team statistics
- Race predictions
- League rules and scoring
- Recent results

The assistant has context about your league's data and can provide personalized insights.

## 📱 API Reference

### Authentication
- `POST /api/auth/callback` - Auth callback handler

### Leagues
- `GET /api/leagues/[slug]/standings` - Get standings

### Results
- `POST /api/results/import` - Import CSV results

### AI
- `POST /api/chat` - AI chat endpoint

### Webhooks
- `POST /api/webhooks/discord` - Send Discord notification

## 🔐 Security

- All routes are protected with Supabase Auth
- Row Level Security (RLS) enabled in Supabase
- Server actions validate user permissions
- Input validation with Zod schemas

## 🤝 Contributing

1. Fork the repository
2. Create a feature branch
3. Commit your changes
4. Push to the branch
5. Open a Pull Request

## 📄 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## 🙏 Acknowledgments

- F1 and Formula 1 are trademarks of Formula One Licensing BV
- Built with [Next.js](https://nextjs.org/)
- UI components from [shadcn/ui](https://ui.shadcn.com/)
- Hosted on [Netlify](https://netlify.com/)
- Database by [Supabase](https://supabase.com/)

---

**Platform Admin:** JonatanAriasGonzalez@Gmail.com

Made with ❤️ for the F1 gaming community
