clinics/{clinicId} {
  name: "Klinik Gigi Senyum Sehat",
  email: "admin@klinikgigi.com",
  phone: "08123456789",
  address: "Jl. Sudirman No. 123, Jakarta",

  // Spesialisasi Klinik
  specialty: {
    type: "dental", // general, dental, specialty
    services: [
      "general_checkup",
      "dental_cleaning",
      "tooth_extraction",
      "dental_filling",
      "root_canal",
      "dental_implant",
      "orthodontics",
      "pediatric_dentistry"
    ],
    primary_focus: "dental_care" // general_health, dental_care, specialist_care
  },

  location: {
    lat: -6.2088,
    lng: 106.8456,
    radius: 5, // km
    city: "Jakarta",
    province: "DKI Jakarta"
  },

  // Meta Ads Integration (Direct API)
  meta_integration: {
    ad_account_id: "act_123456789",
    pixel_id: "987654321",
    page_id: "clinic_page_123",
    access_token: "encrypted_token", // Encrypted
    app_id: "your_app_id",
    app_secret: "encrypted_app_secret", // Encrypted
    status: "connected" // connected/disconnected/pending
  },

  // Default Targeting berdasarkan Spesialisasi
  default_targeting: {
    demographics: {
      age_min: 18,
      age_max: 65,
      genders: ["all"],
      languages: ["id"]
    },

    // Targeting untuk Dental
    dental_interests: [
      "Oral hygiene",
      "Dental health",
      "Cosmetic dentistry",
      "Pediatric care",
      "Health and wellness",
      "Family and relationships"
    ],

    // Targeting untuk General Health
    health_interests: [
      "Health and wellness",
      "Medical professionals",
      "Physical fitness",
      "Parenting",
      "Family and relationships"
    ],

    behaviors: [
      "Frequent online shoppers",
      "Small business owners",
      "Mobile device users",
      "Parents with children"
    ],

    // Custom Audiences
    custom_audiences: [
      "website_visitors",
      "page_engagers",
      "lookalike_patients"
    ]
  },

  subscription: {
    plan: "basic", // basic, pro, enterprise
    status: "active",
    expires_at: "2025-12-31T00:00:00Z",
    features: {
      max_campaigns: 5,
      max_ad_accounts: 1,
      advanced_targeting: false,
      white_label: false
    }
  },

  created_at: "2025-06-07T10:00:00Z",
  updated_at: "2025-06-07T10:00:00Z"
}