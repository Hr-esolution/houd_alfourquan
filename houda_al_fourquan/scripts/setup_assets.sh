#!/bin/bash

# Setup Assets Script for Flutter Quran App
# This script downloads all required JSON files from jsDelivr CDN

set -e

echo "🚀 Starting assets setup..."

# Create directories
mkdir -p assets/data
mkdir -p assets/images/reciters
mkdir -p assets/fonts

echo "📁 Created directories"

# Download Quran text (Arabic - Uthmani)
echo "📖 Downloading Quran Arabic text..."
curl -L "https://cdn.jsdelivr.net/npm/quran-json@3.1.2/dist/quran.json" \
     -o assets/data/quran_ar.json

# Download French translation
echo "🇫🇷 Downloading French translation..."
curl -L "https://cdn.jsdelivr.net/npm/quran-json@3.1.2/dist/translation.fr.hamidullah.json" \
     -o assets/data/quran_fr.json || echo "French translation not found, skipping..."

# Download English translation
echo "🇬🇧 Downloading English translation..."
curl -L "https://cdn.jsdelivr.net/npm/quran-json@3.1.2/dist/translation.en.sahihinternational.json" \
     -o assets/data/quran_en.json || echo "English translation not found, skipping..."

# Download chapters index (Arabic)
echo "📋 Downloading chapters index..."
curl -L "https://cdn.jsdelivr.net/npm/quran-json@3.1.2/dist/chapters/index.json" \
     -o assets/data/surahs.json

# Download chapters index (French)
curl -L "https://cdn.jsdelivr.net/npm/quran-json@3.1.2/dist/chapters/fr/index.json" \
     -o assets/data/surahs_fr.json || echo "French chapters not found, skipping..."

# Download chapters index (English)
curl -L "https://cdn.jsdelivr.net/npm/quran-json@3.1.2/dist/chapters/en/index.json" \
     -o assets/data/surahs_en.json || echo "English chapters not found, skipping..."

echo "✅ Assets setup complete!"
echo "📂 Files downloaded to assets/data/"
ls -la assets/data/
