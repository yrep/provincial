export interface Festival {
  id: string;
  name: string;
  country: string;
  year_founded: number;
  about?: string;
  address?: string;
  awards?: string;
  city?: string;
  logo_url?: string;
  premiere_requirements?: string;
  rules?: string;
  short_description?: string;
  slug?: string;
  website?: string;
}

export interface Partner {
  id: string;
  name: string;
  type: string;
  country: string;
  city?: string;
  description?: string;
  summary?: string;
  image?: string;
  link?: string;
}

export interface Conference {
  id: string;
  external_id?: string;
  event_name: string;
  event_date: string;
  city: string;
  country: string;
  description?: string;
  contact?: string;
  organized?: string;
  email?: string;
  site?: string;
  url?: string;
  page?: number;
  created_at?: string;
  updated_at?: string;
}
