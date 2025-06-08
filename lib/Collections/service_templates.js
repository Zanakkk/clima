service_templates/{templateId} {
  name: "Scaling Gigi & Pembersihan",
  category: "dental_cleaning",
  specialty: "dental",

  template: {
    headlines: [
      "Scaling Gigi Profesional di {{clinic_name}}",
      "Bersihkan Karang Gigi - {{clinic_name}}",
      "Gigi Bersih & Sehat di {{clinic_name}}"
    ],
    descriptions: [
      "Hilangkan karang gigi dengan teknologi ultrasonik. Dokter gigi berpengalaman, hasil maksimal.",
      "Scaling gigi rutin untuk kesehatan mulut optimal. Perawatan nyaman dan aman.",
      "Dapatkan gigi bersih bebas karang gigi. Konsultasi gratis dengan dokter gigi."
    ],
    images: [
      "dental_scaling_1.jpg",
      "clean_teeth.jpg",
      "dental_hygiene.jpg"
    ],
    suggested_cta: [
      "Book Appointment",
      "Konsultasi Gratis",
      "Jadwalkan Sekarang"
    ]
  },

  targeting_suggestions: {
    age_range: {min: 18, max: 55},
    interests: ["Oral hygiene", "Dental health", "Health and wellness"],
    behaviors: ["Health conscious", "Regular dental visitors"]
  },

  budget_recommendations: {
    daily_min: 100000,
    daily_max: 300000,
    suggested: 150000
  },

  usage_count: 145,
  rating: 4.8,
  performance_avg: {
    ctr: 2.1,
    conversion_rate: 5.6
  }
}

// Template untuk Cabut Gigi
service_templates/tooth_extraction {
  name: "Cabut Gigi Tanpa Sakit",
  category: "tooth_extraction",
  specialty: "dental",

  template: {
    headlines: [
      "Cabut Gigi Tanpa Sakit di {{clinic_name}}",
      "Pencabutan Gigi Aman & Nyaman",
      "Solusi Gigi Bermasalah di {{clinic_name}}"
    ],
    descriptions: [
      "Cabut gigi dengan teknologi modern & anastesi lokal. Dokter gigi berpengalaman, prosedur aman.",
      "Pencabutan gigi tanpa rasa sakit. Konsultasi lengkap sebelum tindakan.",
      "Atasi masalah gigi berlubang atau rusak. Tindakan cepat dan profesional."
    ]
  }
}

// Template untuk General Health
service_templates/general_checkup {
  name: "Medical Check Up Lengkap",
  category: "general_checkup",
  specialty: "general",

  template: {
    headlines: [
      "Medical Check Up Lengkap di {{clinic_name}}",
      "Cek Kesehatan Rutin - {{clinic_name}}",
      "Deteksi Dini Penyakit di {{clinic_name}}"
    ],
    descriptions: [
      "Pemeriksaan kesehatan menyeluruh dengan peralatan modern. Dokter berpengalaman, hasil akurat.",
      "Paket medical check up lengkap dengan harga terjangkau. Investasi terbaik untuk kesehatan."
    ]
  }
}