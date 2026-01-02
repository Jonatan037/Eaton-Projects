// ApexGrid AI - Internationalization System
// Supports English (en) and Spanish (es) with full UI coverage

export type Locale = 'en' | 'es';

export const SUPPORTED_LOCALES: Locale[] = ['en', 'es'];
export const DEFAULT_LOCALE: Locale = 'en';

// Cookie/localStorage key for persisting locale
export const LOCALE_STORAGE_KEY = 'apexgrid-locale';

// ============================================
// TRANSLATIONS
// ============================================

export const translations = {
  en: {
    // Common
    common: {
      loading: 'Loading...',
      save: 'Save',
      cancel: 'Cancel',
      delete: 'Delete',
      edit: 'Edit',
      create: 'Create',
      update: 'Update',
      confirm: 'Confirm',
      back: 'Back',
      next: 'Next',
      submit: 'Submit',
      search: 'Search',
      filter: 'Filter',
      reset: 'Reset',
      close: 'Close',
      yes: 'Yes',
      no: 'No',
      or: 'or',
      and: 'and',
      all: 'All',
      none: 'None',
      required: 'Required',
      optional: 'Optional',
      success: 'Success',
      error: 'Error',
      warning: 'Warning',
      info: 'Info',
      actions: 'Actions',
      status: 'Status',
      details: 'Details',
      settings: 'Settings',
      more: 'More',
      less: 'Less',
      viewAll: 'View All',
      seeMore: 'See More',
      comingSoon: 'Coming Soon',
    },
    
    // Navigation
    nav: {
      home: 'Home',
      leagues: 'Leagues',
      standings: 'Standings',
      calendar: 'Calendar',
      teams: 'Teams',
      drivers: 'Drivers',
      admin: 'Admin',
      profile: 'Profile',
      signIn: 'Sign In',
      signUp: 'Sign Up',
      signOut: 'Sign Out',
      dashboard: 'Dashboard',
      analytics: 'Analytics',
      aiAssistant: 'AI Assistant',
    },
    
    // Auth
    auth: {
      signIn: 'Sign In',
      signUp: 'Sign Up',
      signOut: 'Sign Out',
      email: 'Email',
      password: 'Password',
      confirmPassword: 'Confirm Password',
      forgotPassword: 'Forgot Password?',
      resetPassword: 'Reset Password',
      noAccount: "Don't have an account?",
      hasAccount: 'Already have an account?',
      createAccount: 'Create Account',
      welcomeBack: 'Welcome Back',
      signInToContinue: 'Sign in to continue to ApexGrid AI',
      signUpToJoin: 'Create your account to join the racing community',
      invalidCredentials: 'Invalid email or password',
      emailRequired: 'Email is required',
      passwordRequired: 'Password is required',
      passwordMismatch: 'Passwords do not match',
      checkEmail: 'Check your email for a confirmation link',
    },
    
    // Leagues
    leagues: {
      title: 'Leagues',
      subtitle: 'Join or create a racing league',
      myLeagues: 'My Leagues',
      publicLeagues: 'Public Leagues',
      createLeague: 'Create League',
      joinLeague: 'Join League',
      leagueSettings: 'League Settings',
      leagueName: 'League Name',
      leagueDescription: 'Description',
      visibility: 'Visibility',
      public: 'Public',
      private: 'Private',
      timezone: 'Timezone',
      members: 'Members',
      member: 'Member',
      noLeagues: 'No leagues found',
      createFirst: 'Create your first league to get started',
      joined: 'Joined',
      owner: 'Owner',
      admin: 'Admin',
      rules: 'Rules',
      scoring: 'Scoring',
    },
    
    // Teams
    teams: {
      title: 'Teams',
      subtitle: 'Constructors competing in this league',
      createTeam: 'Create Team',
      teamName: 'Team Name',
      shortName: 'Short Name',
      primaryColor: 'Primary Color',
      secondaryColor: 'Secondary Color',
      country: 'Country',
      noTeams: 'No teams yet',
      addTeam: 'Add the first team',
      activeTeams: 'Active Teams',
      constructor: 'Constructor',
      points: 'Points',
      wins: 'Wins',
      podiums: 'Podiums',
    },
    
    // Drivers
    drivers: {
      title: 'Drivers',
      subtitle: 'Racers competing for glory',
      createDriver: 'Create Driver',
      fullName: 'Full Name',
      shortName: 'Short Name',
      gamertag: 'Gamertag',
      number: 'Number',
      team: 'Team',
      country: 'Country',
      isReserve: 'Reserve Driver',
      noDrivers: 'No drivers yet',
      addDriver: 'Add the first driver',
      activeDrivers: 'Active Drivers',
      reserveDrivers: 'Reserve Drivers',
      driverStandings: 'Driver Standings',
      position: 'Position',
    },
    
    // Calendar & Rounds
    calendar: {
      title: 'Calendar',
      subtitle: 'Race schedule and results',
      nextRace: 'Next Race',
      previousRaces: 'Previous Races',
      upcomingRaces: 'Upcoming Races',
      noRaces: 'No races scheduled',
      round: 'Round',
      date: 'Date',
      time: 'Time',
      track: 'Track',
      scheduled: 'Scheduled',
      completed: 'Completed',
      annulled: 'Annulled',
      grandPrix: 'Grand Prix',
      qualifying: 'Qualifying',
      sprint: 'Sprint',
      race: 'Race',
      laps: 'Laps',
      length: 'Length',
    },
    
    // Results
    results: {
      title: 'Results',
      subtitle: 'Session results and standings',
      enterResults: 'Enter Results',
      editResults: 'Edit Results',
      importCSV: 'Import CSV',
      exportCSV: 'Export CSV',
      position: 'Position',
      driver: 'Driver',
      team: 'Team',
      time: 'Time',
      points: 'Points',
      fastestLap: 'Fastest Lap',
      status: 'Status',
      finished: 'Finished',
      dnf: 'DNF',
      dns: 'DNS',
      dsq: 'DSQ',
      noResults: 'No results yet',
      gap: 'Gap',
      interval: 'Interval',
    },
    
    // Standings
    standings: {
      title: 'Standings',
      driverStandings: 'Driver Standings',
      constructorStandings: 'Constructor Standings',
      position: 'Pos',
      driver: 'Driver',
      team: 'Team',
      points: 'Points',
      wins: 'Wins',
      podiums: 'Podiums',
      poles: 'Poles',
      fastestLaps: 'Fastest Laps',
      dnfs: 'DNFs',
      change: 'Change',
      noStandings: 'No standings data available',
    },
    
    // Admin Dashboard
    admin: {
      title: 'Admin Dashboard',
      overview: 'Overview',
      manageTeams: 'Manage Teams',
      manageDrivers: 'Manage Drivers',
      manageCalendar: 'Manage Calendar',
      enterResults: 'Enter Results',
      leagueSettings: 'League Settings',
      webhooks: 'Webhooks',
      importExport: 'Import/Export',
      analytics: 'Analytics',
      predictions: 'Predictions',
      totalMembers: 'Total Members',
      totalTeams: 'Total Teams',
      totalDrivers: 'Total Drivers',
      completedRounds: 'Completed Rounds',
      upcomingRounds: 'Upcoming Rounds',
    },
    
    // AI Assistant
    ai: {
      title: 'AI Assistant',
      placeholder: 'Ask about standings, predictions, rules...',
      askMe: 'Ask me about your league',
      helpText: 'I can help with standings, statistics, predictions, and league information.',
      indexData: 'Index Data',
      indexSuccess: 'League data indexed successfully!',
      sources: 'Sources',
      thinking: 'Thinking...',
      suggestions: [
        'Who is leading the championship?',
        'Which driver has the most wins?',
        'When is the next race?',
        'Show me the constructor standings',
      ],
    },
    
    // Discord Webhooks
    discord: {
      title: 'Discord Webhooks',
      subtitle: 'Send race notifications to your Discord server',
      webhookUrl: 'Webhook URL',
      notifyRaces: 'Notify on race schedule',
      notifyResults: 'Notify on results',
      testWebhook: 'Test Webhook',
      testSent: 'Test notification sent!',
      testFailed: 'Failed to send test notification',
      connected: 'Connected',
      notConnected: 'Not connected',
    },
    
    // Analytics
    analytics: {
      title: 'Analytics',
      subtitle: 'Performance insights and trends',
      driverPerformance: 'Driver Performance',
      teamPerformance: 'Team Performance',
      pointsProgression: 'Points Progression',
      winDistribution: 'Win Distribution',
      consistencyScore: 'Consistency Score',
      avgPosition: 'Average Position',
      avgPoints: 'Average Points',
      finishRate: 'Finish Rate',
      headToHead: 'Head to Head',
      seasonComparison: 'Season Comparison',
    },
    
    // Subscription
    subscription: {
      title: 'Subscription',
      free: 'Free',
      pro: 'Pro',
      currentPlan: 'Current Plan',
      upgradeToPro: 'Upgrade to Pro',
      perMonth: 'per month',
      features: 'Features',
      limits: 'Limits',
      leagues: 'Leagues',
      membersPerLeague: 'Members per League',
      aiFeatures: 'AI Features',
      discordWebhooks: 'Discord Webhooks',
      dataExport: 'Data Export',
      prioritySupport: 'Priority Support',
      unlimitedLeagues: 'Unlimited Leagues',
      upgradePrompt: 'Upgrade to Pro to unlock this feature',
    },
    
    // Validation & Errors
    validation: {
      required: 'This field is required',
      invalidEmail: 'Invalid email address',
      minLength: 'Minimum {min} characters',
      maxLength: 'Maximum {max} characters',
      invalidUrl: 'Invalid URL',
      invalidNumber: 'Invalid number',
      mustBePositive: 'Must be a positive number',
    },
    
    errors: {
      generic: 'Something went wrong. Please try again.',
      notFound: 'Not found',
      unauthorized: 'Unauthorized access',
      forbidden: 'Access denied',
      networkError: 'Network error. Please check your connection.',
      serverError: 'Server error. Please try again later.',
      rateLimited: 'Too many requests. Please wait a moment.',
    },
    
    // Date & Time
    datetime: {
      today: 'Today',
      yesterday: 'Yesterday',
      tomorrow: 'Tomorrow',
      days: 'days',
      hours: 'hours',
      minutes: 'minutes',
      ago: 'ago',
      in: 'in',
      at: 'at',
    },
    
    // Footer
    footer: {
      copyright: '© {year} ApexGrid AI. All rights reserved.',
      terms: 'Terms of Service',
      privacy: 'Privacy Policy',
      contact: 'Contact Us',
    },
  },
  
  es: {
    // Common
    common: {
      loading: 'Cargando...',
      save: 'Guardar',
      cancel: 'Cancelar',
      delete: 'Eliminar',
      edit: 'Editar',
      create: 'Crear',
      update: 'Actualizar',
      confirm: 'Confirmar',
      back: 'Atrás',
      next: 'Siguiente',
      submit: 'Enviar',
      search: 'Buscar',
      filter: 'Filtrar',
      reset: 'Restablecer',
      close: 'Cerrar',
      yes: 'Sí',
      no: 'No',
      or: 'o',
      and: 'y',
      all: 'Todos',
      none: 'Ninguno',
      required: 'Requerido',
      optional: 'Opcional',
      success: 'Éxito',
      error: 'Error',
      warning: 'Advertencia',
      info: 'Info',
      actions: 'Acciones',
      status: 'Estado',
      details: 'Detalles',
      settings: 'Configuración',
      more: 'Más',
      less: 'Menos',
      viewAll: 'Ver Todo',
      seeMore: 'Ver Más',
      comingSoon: 'Próximamente',
    },
    
    // Navigation
    nav: {
      home: 'Inicio',
      leagues: 'Ligas',
      standings: 'Clasificaciones',
      calendar: 'Calendario',
      teams: 'Equipos',
      drivers: 'Pilotos',
      admin: 'Admin',
      profile: 'Perfil',
      signIn: 'Iniciar Sesión',
      signUp: 'Registrarse',
      signOut: 'Cerrar Sesión',
      dashboard: 'Panel',
      analytics: 'Analíticas',
      aiAssistant: 'Asistente IA',
    },
    
    // Auth
    auth: {
      signIn: 'Iniciar Sesión',
      signUp: 'Registrarse',
      signOut: 'Cerrar Sesión',
      email: 'Correo Electrónico',
      password: 'Contraseña',
      confirmPassword: 'Confirmar Contraseña',
      forgotPassword: '¿Olvidaste tu contraseña?',
      resetPassword: 'Restablecer Contraseña',
      noAccount: '¿No tienes una cuenta?',
      hasAccount: '¿Ya tienes una cuenta?',
      createAccount: 'Crear Cuenta',
      welcomeBack: 'Bienvenido de Nuevo',
      signInToContinue: 'Inicia sesión para continuar a ApexGrid AI',
      signUpToJoin: 'Crea tu cuenta para unirte a la comunidad de carreras',
      invalidCredentials: 'Correo o contraseña inválidos',
      emailRequired: 'El correo electrónico es requerido',
      passwordRequired: 'La contraseña es requerida',
      passwordMismatch: 'Las contraseñas no coinciden',
      checkEmail: 'Revisa tu correo para un enlace de confirmación',
    },
    
    // Leagues
    leagues: {
      title: 'Ligas',
      subtitle: 'Únete o crea una liga de carreras',
      myLeagues: 'Mis Ligas',
      publicLeagues: 'Ligas Públicas',
      createLeague: 'Crear Liga',
      joinLeague: 'Unirse a Liga',
      leagueSettings: 'Configuración de Liga',
      leagueName: 'Nombre de Liga',
      leagueDescription: 'Descripción',
      visibility: 'Visibilidad',
      public: 'Pública',
      private: 'Privada',
      timezone: 'Zona Horaria',
      members: 'Miembros',
      member: 'Miembro',
      noLeagues: 'No se encontraron ligas',
      createFirst: 'Crea tu primera liga para comenzar',
      joined: 'Unido',
      owner: 'Propietario',
      admin: 'Admin',
      rules: 'Reglas',
      scoring: 'Puntuación',
    },
    
    // Teams
    teams: {
      title: 'Equipos',
      subtitle: 'Constructores compitiendo en esta liga',
      createTeam: 'Crear Equipo',
      teamName: 'Nombre del Equipo',
      shortName: 'Nombre Corto',
      primaryColor: 'Color Primario',
      secondaryColor: 'Color Secundario',
      country: 'País',
      noTeams: 'Aún no hay equipos',
      addTeam: 'Añade el primer equipo',
      activeTeams: 'Equipos Activos',
      constructor: 'Constructor',
      points: 'Puntos',
      wins: 'Victorias',
      podiums: 'Podios',
    },
    
    // Drivers
    drivers: {
      title: 'Pilotos',
      subtitle: 'Corredores compitiendo por la gloria',
      createDriver: 'Crear Piloto',
      fullName: 'Nombre Completo',
      shortName: 'Nombre Corto',
      gamertag: 'Gamertag',
      number: 'Número',
      team: 'Equipo',
      country: 'País',
      isReserve: 'Piloto de Reserva',
      noDrivers: 'Aún no hay pilotos',
      addDriver: 'Añade el primer piloto',
      activeDrivers: 'Pilotos Activos',
      reserveDrivers: 'Pilotos de Reserva',
      driverStandings: 'Clasificación de Pilotos',
      position: 'Posición',
    },
    
    // Calendar & Rounds
    calendar: {
      title: 'Calendario',
      subtitle: 'Programa de carreras y resultados',
      nextRace: 'Próxima Carrera',
      previousRaces: 'Carreras Anteriores',
      upcomingRaces: 'Próximas Carreras',
      noRaces: 'No hay carreras programadas',
      round: 'Ronda',
      date: 'Fecha',
      time: 'Hora',
      track: 'Circuito',
      scheduled: 'Programado',
      completed: 'Completado',
      annulled: 'Anulado',
      grandPrix: 'Gran Premio',
      qualifying: 'Clasificación',
      sprint: 'Sprint',
      race: 'Carrera',
      laps: 'Vueltas',
      length: 'Longitud',
    },
    
    // Results
    results: {
      title: 'Resultados',
      subtitle: 'Resultados de sesiones y clasificaciones',
      enterResults: 'Ingresar Resultados',
      editResults: 'Editar Resultados',
      importCSV: 'Importar CSV',
      exportCSV: 'Exportar CSV',
      position: 'Posición',
      driver: 'Piloto',
      team: 'Equipo',
      time: 'Tiempo',
      points: 'Puntos',
      fastestLap: 'Vuelta Rápida',
      status: 'Estado',
      finished: 'Terminado',
      dnf: 'DNF',
      dns: 'DNS',
      dsq: 'DSQ',
      noResults: 'Aún no hay resultados',
      gap: 'Diferencia',
      interval: 'Intervalo',
    },
    
    // Standings
    standings: {
      title: 'Clasificaciones',
      driverStandings: 'Clasificación de Pilotos',
      constructorStandings: 'Clasificación de Constructores',
      position: 'Pos',
      driver: 'Piloto',
      team: 'Equipo',
      points: 'Puntos',
      wins: 'Victorias',
      podiums: 'Podios',
      poles: 'Poles',
      fastestLaps: 'Vueltas Rápidas',
      dnfs: 'DNFs',
      change: 'Cambio',
      noStandings: 'No hay datos de clasificación disponibles',
    },
    
    // Admin Dashboard
    admin: {
      title: 'Panel de Admin',
      overview: 'Resumen',
      manageTeams: 'Gestionar Equipos',
      manageDrivers: 'Gestionar Pilotos',
      manageCalendar: 'Gestionar Calendario',
      enterResults: 'Ingresar Resultados',
      leagueSettings: 'Configuración de Liga',
      webhooks: 'Webhooks',
      importExport: 'Importar/Exportar',
      analytics: 'Analíticas',
      predictions: 'Predicciones',
      totalMembers: 'Total de Miembros',
      totalTeams: 'Total de Equipos',
      totalDrivers: 'Total de Pilotos',
      completedRounds: 'Rondas Completadas',
      upcomingRounds: 'Próximas Rondas',
    },
    
    // AI Assistant
    ai: {
      title: 'Asistente IA',
      placeholder: 'Pregunta sobre clasificaciones, predicciones, reglas...',
      askMe: 'Pregúntame sobre tu liga',
      helpText: 'Puedo ayudarte con clasificaciones, estadísticas, predicciones e información de la liga.',
      indexData: 'Indexar Datos',
      indexSuccess: '¡Datos de la liga indexados exitosamente!',
      sources: 'Fuentes',
      thinking: 'Pensando...',
      suggestions: [
        '¿Quién lidera el campeonato?',
        '¿Qué piloto tiene más victorias?',
        '¿Cuándo es la próxima carrera?',
        'Muéstrame la clasificación de constructores',
      ],
    },
    
    // Discord Webhooks
    discord: {
      title: 'Webhooks de Discord',
      subtitle: 'Envía notificaciones de carreras a tu servidor de Discord',
      webhookUrl: 'URL del Webhook',
      notifyRaces: 'Notificar en programación de carreras',
      notifyResults: 'Notificar en resultados',
      testWebhook: 'Probar Webhook',
      testSent: '¡Notificación de prueba enviada!',
      testFailed: 'Error al enviar notificación de prueba',
      connected: 'Conectado',
      notConnected: 'No conectado',
    },
    
    // Analytics
    analytics: {
      title: 'Analíticas',
      subtitle: 'Insights de rendimiento y tendencias',
      driverPerformance: 'Rendimiento de Pilotos',
      teamPerformance: 'Rendimiento de Equipos',
      pointsProgression: 'Progresión de Puntos',
      winDistribution: 'Distribución de Victorias',
      consistencyScore: 'Puntuación de Consistencia',
      avgPosition: 'Posición Promedio',
      avgPoints: 'Puntos Promedio',
      finishRate: 'Tasa de Finalización',
      headToHead: 'Cara a Cara',
      seasonComparison: 'Comparación de Temporadas',
    },
    
    // Subscription
    subscription: {
      title: 'Suscripción',
      free: 'Gratis',
      pro: 'Pro',
      currentPlan: 'Plan Actual',
      upgradeToPro: 'Mejorar a Pro',
      perMonth: 'por mes',
      features: 'Características',
      limits: 'Límites',
      leagues: 'Ligas',
      membersPerLeague: 'Miembros por Liga',
      aiFeatures: 'Funciones de IA',
      discordWebhooks: 'Webhooks de Discord',
      dataExport: 'Exportar Datos',
      prioritySupport: 'Soporte Prioritario',
      unlimitedLeagues: 'Ligas Ilimitadas',
      upgradePrompt: 'Mejora a Pro para desbloquear esta función',
    },
    
    // Validation & Errors
    validation: {
      required: 'Este campo es requerido',
      invalidEmail: 'Dirección de correo inválida',
      minLength: 'Mínimo {min} caracteres',
      maxLength: 'Máximo {max} caracteres',
      invalidUrl: 'URL inválida',
      invalidNumber: 'Número inválido',
      mustBePositive: 'Debe ser un número positivo',
    },
    
    errors: {
      generic: 'Algo salió mal. Por favor intenta de nuevo.',
      notFound: 'No encontrado',
      unauthorized: 'Acceso no autorizado',
      forbidden: 'Acceso denegado',
      networkError: 'Error de red. Por favor verifica tu conexión.',
      serverError: 'Error del servidor. Por favor intenta más tarde.',
      rateLimited: 'Demasiadas solicitudes. Por favor espera un momento.',
    },
    
    // Date & Time
    datetime: {
      today: 'Hoy',
      yesterday: 'Ayer',
      tomorrow: 'Mañana',
      days: 'días',
      hours: 'horas',
      minutes: 'minutos',
      ago: 'hace',
      in: 'en',
      at: 'a las',
    },
    
    // Footer
    footer: {
      copyright: '© {year} ApexGrid AI. Todos los derechos reservados.',
      terms: 'Términos de Servicio',
      privacy: 'Política de Privacidad',
      contact: 'Contáctanos',
    },
  },
} as const;

// ============================================
// UTILITY FUNCTIONS
// ============================================

export type TranslationKey = keyof typeof translations.en;
export type Translations = typeof translations.en;

/**
 * Get translations for a specific locale
 */
export function getTranslations(locale: Locale): Translations {
  return translations[locale] ?? translations[DEFAULT_LOCALE];
}

/**
 * Get a specific translation string with optional interpolation
 */
export function t(
  locale: Locale,
  path: string,
  params?: Record<string, string | number>
): string {
  const keys = path.split('.');
  let value: unknown = translations[locale] ?? translations[DEFAULT_LOCALE];
  
  for (const key of keys) {
    if (value && typeof value === 'object' && key in value) {
      value = (value as Record<string, unknown>)[key];
    } else {
      console.warn(`Translation not found: ${path}`);
      return path;
    }
  }
  
  if (typeof value !== 'string') {
    console.warn(`Translation is not a string: ${path}`);
    return path;
  }
  
  // Interpolate parameters
  if (params) {
    return value.replace(/\{(\w+)\}/g, (_, key) => 
      String(params[key] ?? `{${key}}`)
    );
  }
  
  return value;
}

/**
 * Detect user's preferred locale from browser
 */
export function detectLocale(): Locale {
  if (typeof window === 'undefined') return DEFAULT_LOCALE;
  
  // Check localStorage first
  const stored = localStorage.getItem(LOCALE_STORAGE_KEY);
  if (stored && SUPPORTED_LOCALES.includes(stored as Locale)) {
    return stored as Locale;
  }
  
  // Check browser language
  const browserLang = navigator.language.split('-')[0];
  if (SUPPORTED_LOCALES.includes(browserLang as Locale)) {
    return browserLang as Locale;
  }
  
  return DEFAULT_LOCALE;
}

/**
 * Persist locale preference
 */
export function persistLocale(locale: Locale): void {
  if (typeof window !== 'undefined') {
    localStorage.setItem(LOCALE_STORAGE_KEY, locale);
  }
}

/**
 * Get locale display name
 */
export function getLocaleDisplayName(locale: Locale): string {
  const names: Record<Locale, string> = {
    en: 'English',
    es: 'Español',
  };
  return names[locale];
}

/**
 * Get locale flag emoji
 */
export function getLocaleFlag(locale: Locale): string {
  const flags: Record<Locale, string> = {
    en: '🇺🇸',
    es: '🇪🇸',
  };
  return flags[locale];
}
