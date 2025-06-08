campaigns/{campaignId} {
  clinic_id: "clinic_001",
  name: "Scaling Gigi & Pembersihan Karang Gigi",
  objective: "CONVERSIONS",

  // Spesialisasi Campaign
  specialty_type: "dental",
  service_category: "dental_cleaning",

  targeting: {
    location: {
      lat: -6.2088,
      lng: 106.8456,
      radius: 5
    },
    demographics: {
      age_min: 18,
      age_max: 55,
      genders: ["all"]
    },

    // Targeting khusus untuk layanan gigi
    interests: [
      "Oral hygiene",
      "Dental health",
      "Health and wellness",
      "Cosmetic dentistry"
    ],

    behaviors: [
      "Mobile device users",
      "Frequent online shoppers",
      "Health and wellness enthusiasts"
    ],

    custom_audiences: ["website_visitors", "dental_page_engagers"]
  },

  ad_creative: {
    headline: "Scaling Gigi Profesional - Gigi Bersih & Sehat",
    description: "Bersihkan karang gigi dengan teknologi modern. Dokter gigi berpengalaman, hasil maksimal.",
    image_url: "https://storage.googleapis.com/dental-images/scaling.jpg",
    cta_text: "Book Appointment",
    landing_url: "https://klinikgigi.com/scaling-gigi"
  },

  budget: {
    daily_budget: 150000, // IDR - Higher untuk dental
    total_budget: 4500000, // IDR
    currency: "IDR"
  },

  // Meta Ads IDs (setelah dibuat via Direct API)
  meta_ids: {
    campaign_id: "123456789",
    adset_id: "987654321",
    ad_id: "456789123"
  },

  status: "active",
  performance: {
    impressions: 15000,
    clicks: 320,
    ctr: 2.13,
    cpc: 469, // IDR
    conversions: 18,
    cost_per_conversion: 8333 // IDR
  },

  created_at: "2025-06-07T10:00:00Z"
}