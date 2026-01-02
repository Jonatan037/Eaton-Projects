'use client';

import { motion } from 'framer-motion';
import Link from 'next/link';
import Image from 'next/image';
import { 
  Flag, 
  Trophy, 
  Users, 
  Zap, 
  BarChart3, 
  Calendar,
  ArrowRight,
  Sparkles,
  Timer,
  Target
} from 'lucide-react';

// Animation variants
const fadeInUp = {
  hidden: { opacity: 0, y: 40 },
  visible: { opacity: 1, y: 0 }
};

const stagger = {
  visible: {
    transition: {
      staggerChildren: 0.15
    }
  }
};

// Stats data
const stats = [
  { value: '2025', label: 'Season Ready', icon: Calendar },
  { value: '24+', label: 'Official Tracks', icon: Flag },
  { value: 'AI', label: 'Powered Insights', icon: Sparkles },
  { value: '∞', label: 'Leagues Supported', icon: Users },
];

// Features data
const features = [
  {
    icon: Trophy,
    title: 'Championship Management',
    description: 'Full season tracking with customizable points systems, sprint races, and penalties. Everything you need to run a professional league.',
    gradient: 'from-yellow-500 to-orange-500',
  },
  {
    icon: BarChart3,
    title: 'Real-Time Analytics',
    description: 'AI-powered performance analysis, driver comparisons, and predictive insights to help you understand every aspect of your league.',
    gradient: 'from-blue-500 to-purple-500',
  },
  {
    icon: Users,
    title: 'Team & Driver Profiles',
    description: 'Beautiful driver cards, team standings, and detailed statistics. Track form, consistency, and head-to-head records.',
    gradient: 'from-green-500 to-teal-500',
  },
  {
    icon: Timer,
    title: 'Race Day Integration',
    description: 'Seamless race result entry, fastest lap tracking, and automatic points calculation. Less admin, more racing.',
    gradient: 'from-red-500 to-pink-500',
  },
  {
    icon: Target,
    title: 'Fantasy League Mode',
    description: 'Optional fantasy integration where league members can predict results and compete for bragging rights.',
    gradient: 'from-purple-500 to-indigo-500',
  },
  {
    icon: Zap,
    title: 'Instant Notifications',
    description: 'Stay updated with race reminders, result notifications, and league announcements. Never miss a race weekend.',
    gradient: 'from-amber-500 to-red-500',
  },
];

// Official F1 2025 Teams
const f1Teams = [
  { id: 'red-bull', name: 'Oracle Red Bull Racing', shortName: 'Red Bull', color: '#3671C6', secondaryColor: '#FFD700', logo: '/images/teams/red-bull/logo.avif', car: '/images/teams/red-bull/car.avif' },
  { id: 'ferrari', name: 'Scuderia Ferrari', shortName: 'Ferrari', color: '#E8002D', secondaryColor: '#FFEB3B', logo: '/images/teams/ferrari/logo.avif', car: '/images/teams/ferrari/car.avif' },
  { id: 'mclaren', name: 'McLaren F1 Team', shortName: 'McLaren', color: '#FF8000', secondaryColor: '#000000', logo: '/images/teams/mclaren/logo.avif', car: '/images/teams/mclaren/car.avif' },
  { id: 'mercedes', name: 'Mercedes-AMG Petronas', shortName: 'Mercedes', color: '#27F4D2', secondaryColor: '#000000', logo: '/images/teams/mercedes/logo.avif', car: '/images/teams/mercedes/car.avif' },
  { id: 'aston-martin', name: 'Aston Martin Aramco', shortName: 'Aston Martin', color: '#229971', secondaryColor: '#FFFFFF', logo: '/images/teams/aston-martin/logo.avif', car: '/images/teams/aston-martin/car.avif' },
  { id: 'alpine', name: 'BWT Alpine F1 Team', shortName: 'Alpine', color: '#FF87BC', secondaryColor: '#0093CC', logo: '/images/teams/alpine/logo.avif', car: '/images/teams/alpine/car.avif' },
  { id: 'williams', name: 'Williams Racing', shortName: 'Williams', color: '#64C4FF', secondaryColor: '#FFFFFF', logo: '/images/teams/williams/logo.avif', car: '/images/teams/williams/car.avif' },
  { id: 'rb', name: 'Visa Cash App RB', shortName: 'Racing Bulls', color: '#6692FF', secondaryColor: '#FFFFFF', logo: '/images/teams/rb/logo.avif', car: '/images/teams/rb/car.avif' },
  { id: 'kick-sauber', name: 'Stake F1 Team Kick Sauber', shortName: 'Kick Sauber', color: '#52E252', secondaryColor: '#000000', logo: '/images/teams/kick-sauber/logo.avif', car: '/images/teams/kick-sauber/car.avif' },
  { id: 'haas', name: 'MoneyGram Haas F1 Team', shortName: 'Haas F1 Team', color: '#B6BABD', secondaryColor: '#E10600', logo: '/images/teams/haas/logo.avif', car: '/images/teams/haas/car.avif' },
];

export default function HomePage() {
  return (
    <div className="min-h-screen bg-brand-black text-white overflow-hidden">
      {/* Navigation */}
      <nav className="nav-modern">
        <div className="max-w-7xl mx-auto px-6 py-3 flex items-center justify-between">
          <Link href="/" className="flex items-center gap-3">
            <Image 
              src="/images/logo.png" 
              alt="ApexGrid AI" 
              width={280} 
              height={70}
              className="h-14 md:h-16 w-auto"
              priority
            />
          </Link>
          
          <div className="hidden md:flex items-center gap-8">
            <Link href="/features" className="nav-link">Features</Link>
            <Link href="/leagues" className="nav-link">Leagues</Link>
            <Link href="/pricing" className="nav-link">Pricing</Link>
            <Link href="/about" className="nav-link">About</Link>
          </div>
          
          <div className="flex items-center gap-4">
            <Link href="/login" className="btn-secondary !px-6 !py-2.5 text-sm">
              Sign In
            </Link>
            <Link href="/register" className="btn-primary !px-6 !py-2.5 text-sm hidden sm:inline-flex">
              Get Started
            </Link>
          </div>
        </div>
      </nav>

      {/* Hero Section */}
      <section className="relative min-h-screen flex items-center justify-center pt-20">
        {/* Background Effects */}
        <div className="absolute inset-0 bg-grid-pattern" />
        <div className="absolute inset-0 bg-radial-glow" />
        
        {/* Decorative elements */}
        <div className="absolute top-1/4 -left-20 w-96 h-96 bg-[#2ECC71]/20 rounded-full blur-[120px] animate-pulse" />
        <div className="absolute bottom-1/4 -right-20 w-96 h-96 bg-[#58D68D]/15 rounded-full blur-[120px] animate-pulse" style={{ animationDelay: '1s' }} />
        
        {/* Floating racing elements */}
        <div className="absolute top-32 right-[15%] animate-float opacity-30">
          <Flag className="w-12 h-12 text-[#2ECC71]" />
        </div>
        <div className="absolute bottom-40 left-[10%] animate-float opacity-20" style={{ animationDelay: '2s' }}>
          <Trophy className="w-16 h-16 text-[#58D68D]" />
        </div>

        <div className="relative z-10 max-w-7xl mx-auto px-6 text-center">
          <motion.div
            initial="hidden"
            animate="visible"
            variants={stagger}
            className="space-y-8"
          >
            {/* Badge */}
            <motion.div variants={fadeInUp} className="flex justify-center">
              <div className="hero-badge">
                <Sparkles className="w-4 h-4" />
                <span>Powered by AI • Built for Champions</span>
              </div>
            </motion.div>

            {/* Main Title */}
            <motion.h1 variants={fadeInUp} className="hero-title">
              <span className="block text-white">Your League.</span>
              <span className="block gradient-text-animated">Your Rules.</span>
              <span className="block text-white">Your Legacy.</span>
            </motion.h1>

            {/* Subtitle */}
            <motion.p variants={fadeInUp} className="hero-subtitle mx-auto">
              The ultimate F1 league management platform. Track championships, 
              analyze performance, and compete with friends — all powered by 
              cutting-edge AI.
            </motion.p>

            {/* CTA Buttons */}
            <motion.div variants={fadeInUp} className="flex flex-col sm:flex-row gap-4 justify-center pt-4">
              <Link href="/register" className="btn-primary group">
                <span>Start Your League</span>
                <ArrowRight className="w-5 h-5 ml-2 group-hover:translate-x-1 transition-transform" />
              </Link>
              <Link href="/demo" className="btn-secondary">
                <span>Watch Demo</span>
              </Link>
            </motion.div>

            {/* Stats Row */}
            <motion.div 
              variants={fadeInUp}
              className="grid grid-cols-2 md:grid-cols-4 gap-6 pt-16 max-w-4xl mx-auto"
            >
              {stats.map((stat, index) => (
                <div key={index} className="card-stat">
                  <stat.icon className="w-6 h-6 mx-auto mb-3 text-[#2ECC71]" />
                  <div className="stat-number">{stat.value}</div>
                  <div className="stat-label">{stat.label}</div>
                </div>
              ))}
            </motion.div>
          </motion.div>
        </div>

        {/* Scroll indicator */}
        <div className="absolute bottom-8 left-1/2 -translate-x-1/2 animate-bounce">
          <div className="w-6 h-10 rounded-full border-2 border-white/30 flex items-start justify-center p-2">
            <div className="w-1.5 h-3 bg-white/50 rounded-full animate-pulse" />
          </div>
        </div>
      </section>

      {/* Features Section */}
      <section className="section-dark">
        <div className="absolute inset-0 bg-radial-glow-bottom" />
        
        <div className="relative z-10 max-w-7xl mx-auto px-6">
          <motion.div
            initial={{ opacity: 0, y: 30 }}
            whileInView={{ opacity: 1, y: 0 }}
            viewport={{ once: true }}
            transition={{ duration: 0.6 }}
            className="text-center mb-20"
          >
            <h2 className="section-heading">
              Everything You Need to <span className="gradient-text">Dominate</span>
            </h2>
            <p className="section-subheading">
              From casual leagues with friends to competitive championships, 
              ApexGrid AI has the tools to make every race count.
            </p>
          </motion.div>

          <div className="grid md:grid-cols-2 lg:grid-cols-3 gap-6">
            {features.map((feature, index) => (
              <motion.div
                key={index}
                initial={{ opacity: 0, y: 40 }}
                whileInView={{ opacity: 1, y: 0 }}
                viewport={{ once: true }}
                transition={{ duration: 0.5, delay: index * 0.1 }}
                className="card-feature group"
              >
                <div className={`w-14 h-14 rounded-2xl bg-gradient-to-br ${feature.gradient} flex items-center justify-center mb-6 group-hover:scale-110 transition-transform duration-300`}>
                  <feature.icon className="w-7 h-7 text-white" />
                </div>
                <h3 className="text-xl font-semibold mb-3">{feature.title}</h3>
                <p className="text-white/60 leading-relaxed">{feature.description}</p>
              </motion.div>
            ))}
          </div>
        </div>
      </section>

      {/* F1 Teams Showcase Section - Like Official F1 Site */}
      <section className="section-dark border-t border-white/5">
        <div className="relative z-10 max-w-7xl mx-auto px-6">
          <motion.div
            initial={{ opacity: 0, y: 30 }}
            whileInView={{ opacity: 1, y: 0 }}
            viewport={{ once: true }}
            className="text-center mb-16"
          >
            <h2 className="section-heading">
              All <span className="gradient-text">10 F1 Teams</span>
            </h2>
            <p className="section-subheading">
              Create your league with the official 2025 Formula 1 teams. Assign drivers and compete!
            </p>
          </motion.div>

          <div className="grid grid-cols-1 sm:grid-cols-2 lg:grid-cols-4 gap-4">
            {f1Teams.map((team, index) => (
              <motion.div
                key={team.id}
                initial={{ opacity: 0, y: 20 }}
                whileInView={{ opacity: 1, y: 0 }}
                viewport={{ once: true }}
                transition={{ duration: 0.4, delay: index * 0.05 }}
                className="group relative overflow-hidden rounded-xl cursor-pointer"
                style={{ 
                  background: `linear-gradient(135deg, ${team.color}25 0%, ${team.color}08 100%)`,
                }}
              >
                {/* Header with logo and team name */}
                <div className="flex items-center gap-3 p-4 pb-2">
                  <div 
                    className="w-10 h-10 rounded-full overflow-hidden flex items-center justify-center flex-shrink-0"
                    style={{ backgroundColor: team.color }}
                  >
                    <Image 
                      src={team.logo}
                      alt={`${team.shortName} logo`}
                      width={40}
                      height={40}
                      className="w-7 h-7 object-contain"
                    />
                  </div>
                  <h3 className="font-semibold text-white text-base">
                    {team.shortName}
                  </h3>
                </div>
                
                {/* Car image */}
                <div className="relative h-24 overflow-hidden px-2">
                  <Image 
                    src={team.car}
                    alt={`${team.shortName} car`}
                    width={400}
                    height={120}
                    className="w-full h-full object-contain object-center transform group-hover:scale-105 transition-transform duration-500"
                  />
                </div>

                {/* Color accent bar at bottom */}
                <div 
                  className="h-1 w-full"
                  style={{ backgroundColor: team.color }} 
                />

                {/* Hover glow effect */}
                <div 
                  className="absolute inset-0 opacity-0 group-hover:opacity-100 transition-opacity duration-300 pointer-events-none"
                  style={{ 
                    background: `radial-gradient(ellipse at bottom, ${team.color}15 0%, transparent 70%)`
                  }}
                />
              </motion.div>
            ))}
          </div>
          
          {/* Additional info */}
          <motion.p 
            initial={{ opacity: 0 }}
            whileInView={{ opacity: 1 }}
            viewport={{ once: true }}
            className="text-center text-white/40 text-sm mt-8"
          >
            Full 2025 FIA Formula 1 World Championship grid • Real teams, your drivers
          </motion.p>
        </div>
      </section>

      {/* CTA Section */}
      <section className="section-dark border-t border-white/5">
        <div className="relative z-10 max-w-4xl mx-auto px-6 text-center">
          <motion.div
            initial={{ opacity: 0, y: 30 }}
            whileInView={{ opacity: 1, y: 0 }}
            viewport={{ once: true }}
            className="glass-card p-12 md:p-16"
          >
            <div className="hero-badge mx-auto mb-6">
              <Zap className="w-4 h-4" />
              <span>Ready to Race?</span>
            </div>
            <h2 className="text-3xl md:text-4xl lg:text-5xl font-bold mb-6">
              Start Your Championship <span className="gradient-text">Today</span>
            </h2>
            <p className="text-lg text-white/60 mb-10 max-w-xl mx-auto">
              Join thousands of league managers who trust ApexGrid AI 
              to power their racing seasons.
            </p>
            <div className="flex flex-col sm:flex-row gap-4 justify-center">
              <Link href="/register" className="btn-primary group">
                <span>Create Free Account</span>
                <ArrowRight className="w-5 h-5 ml-2 group-hover:translate-x-1 transition-transform" />
              </Link>
              <Link href="/contact" className="btn-secondary">
                <span>Contact Sales</span>
              </Link>
            </div>
          </motion.div>
        </div>
      </section>

      {/* Footer */}
      <footer className="border-t border-white/10 py-16">
        <div className="max-w-7xl mx-auto px-6">
          <div className="grid md:grid-cols-4 gap-12">
            <div className="md:col-span-2">
              <Link href="/" className="flex items-center gap-3 mb-6">
                <Image 
                  src="/images/logo.png" 
                  alt="ApexGrid AI" 
                  width={240} 
                  height={60}
                  className="h-12 w-auto"
                />
              </Link>
              <p className="text-white/50 max-w-md leading-relaxed">
                The ultimate platform for managing F1 sim racing leagues. 
                Built by racing enthusiasts, for racing enthusiasts.
              </p>
            </div>
            <div>
              <h4 className="font-semibold mb-4">Product</h4>
              <ul className="space-y-3 text-white/50">
                <li><Link href="/features" className="hover:text-white transition-colors">Features</Link></li>
                <li><Link href="/pricing" className="hover:text-white transition-colors">Pricing</Link></li>
                <li><Link href="/demo" className="hover:text-white transition-colors">Demo</Link></li>
                <li><Link href="/changelog" className="hover:text-white transition-colors">Changelog</Link></li>
              </ul>
            </div>
            <div>
              <h4 className="font-semibold mb-4">Company</h4>
              <ul className="space-y-3 text-white/50">
                <li><Link href="/about" className="hover:text-white transition-colors">About</Link></li>
                <li><Link href="/blog" className="hover:text-white transition-colors">Blog</Link></li>
                <li><Link href="/contact" className="hover:text-white transition-colors">Contact</Link></li>
                <li><Link href="/privacy" className="hover:text-white transition-colors">Privacy</Link></li>
              </ul>
            </div>
          </div>
          <div className="border-t border-white/10 mt-12 pt-8 flex flex-col md:flex-row justify-between items-center gap-4">
            <p className="text-white/40 text-sm">
              © 2025 ApexGrid AI. All rights reserved.
            </p>
            <p className="text-white/40 text-sm">
              Made with ❤️ for the racing community
            </p>
          </div>
        </div>
      </footer>
    </div>
  );
}
