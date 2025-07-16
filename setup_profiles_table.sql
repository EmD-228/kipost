-- Script SQL pour créer la table profiles dans Supabase
-- À exécuter dans l'éditeur SQL de votre dashboard Supabase

-- Créer la table profiles
CREATE TABLE IF NOT EXISTS profiles (
    id UUID REFERENCES auth.users ON DELETE CASCADE PRIMARY KEY,
    email TEXT UNIQUE NOT NULL,
    first_name TEXT NOT NULL,
    last_name TEXT NOT NULL,
    phone TEXT,
    avatar_url TEXT,
    location JSONB DEFAULT '{}',
    description TEXT,
    skills TEXT[] DEFAULT '{}',
    portfolio_images TEXT[] DEFAULT '{}',
    is_verified BOOLEAN DEFAULT false,
    rating DECIMAL(3,2) DEFAULT 0.0,
    completed_contracts INTEGER DEFAULT 0,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Créer un index sur l'email pour les recherches rapides
CREATE INDEX IF NOT EXISTS profiles_email_idx ON profiles(email);

-- Créer un index sur la localisation (GIN pour JSONB)
CREATE INDEX IF NOT EXISTS profiles_location_idx ON profiles USING GIN(location);

-- Activer Row Level Security (RLS)
ALTER TABLE profiles ENABLE ROW LEVEL SECURITY;

-- Politique pour que les utilisateurs puissent voir leur propre profil
CREATE POLICY "Users can view own profile" ON profiles
    FOR SELECT USING (auth.uid() = id);

-- Politique pour que les utilisateurs puissent créer leur propre profil
CREATE POLICY "Users can create own profile" ON profiles
    FOR INSERT WITH CHECK (auth.uid() = id);

-- Politique pour que les utilisateurs puissent modifier leur propre profil
CREATE POLICY "Users can update own profile" ON profiles
    FOR UPDATE USING (auth.uid() = id);

-- Politique pour que tout le monde puisse voir les profils publics
CREATE POLICY "Anyone can view public profiles" ON profiles
    FOR SELECT USING (true);

-- Fonction pour mettre à jour automatiquement updated_at
CREATE OR REPLACE FUNCTION update_updated_at_column()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = NOW();
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Trigger pour mettre à jour automatiquement updated_at
CREATE TRIGGER update_profiles_updated_at
    BEFORE UPDATE ON profiles
    FOR EACH ROW
    EXECUTE FUNCTION update_updated_at_column();

-- Fonction pour créer automatiquement un profil lors de l'inscription
CREATE OR REPLACE FUNCTION public.handle_new_user()
RETURNS TRIGGER AS $$
BEGIN
    INSERT INTO public.profiles (id, email, first_name, last_name)
    VALUES (
        NEW.id,
        NEW.email,
        COALESCE(NEW.raw_user_meta_data->>'first_name', ''),
        COALESCE(NEW.raw_user_meta_data->>'last_name', '')
    );
    RETURN NEW;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- Trigger pour créer automatiquement le profil
CREATE TRIGGER on_auth_user_created
    AFTER INSERT ON auth.users
    FOR EACH ROW EXECUTE FUNCTION public.handle_new_user();
