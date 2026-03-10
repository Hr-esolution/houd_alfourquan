#!/usr/bin/env python3
"""
Download Quran translations from Quran.com API (official & legal source)
French: Translation ID 131 (Muhammad Hamidullah)
English: Translation ID 131 (Saheeh International)
"""

import json
import requests
import os

# Create assets/data directory if not exists
os.makedirs('assets/data', exist_ok=True)

def download_translation(language_code, resource_id, resource_name):
    """Download translation for all 114 surahs"""
    print(f"📖 Downloading {language_code.upper()} translation ({resource_name})...")
    
    all_surahs = []
    
    for surah_num in range(1, 115):
        try:
            # Get all verses with pagination
            all_verses = []
            page = 1
            
            while True:
                url = f"https://api.quran.com/api/v4/verses/by_chapter/{surah_num}"
                params = {
                    'language': language_code,
                    'words': 'false',
                    'translations': resource_id,
                    'fields': 'text_uthmani',
                    'page': page,
                    'per_page': 50  # Max per page
                }
                
                response = requests.get(url, params=params, timeout=30)
                response.raise_for_status()
                data = response.json()
                
                verses_data = data.get('verses', [])
                if not verses_data:
                    break
                    
                for verse in verses_data:
                    # Get translation text
                    translation_text = ''
                    if 'translations' in verse and len(verse['translations']) > 0:
                        translation_text = verse['translations'][0].get('text', '')
                    
                    all_verses.append({
                        'id': verse['id'],
                        'text': translation_text,
                        'verse_key': verse['verse_key']
                    })
                
                # Check if there are more pages
                pagination = data.get('pagination', {})
                if pagination.get('next_page') is None:
                    break
                    
                page += 1
            
            # Get surah info
            surah_info_url = f"https://api.quran.com/api/v4/chapters/{surah_num}"
            surah_response = requests.get(surah_info_url, params={'language': language_code}, timeout=10)
            surah_data = surah_response.json()
            chapter = surah_data.get('chapter', {})
            
            surah_obj = {
                'number': surah_num,
                'name': chapter.get('name_simple', ''),
                'name_arabic': chapter.get('name_arabic', ''),
                'verses_count': chapter.get('verses_count', 0),
                'revelation_place': chapter.get('revelation_place', 'makkah'),
                'verses': all_verses
            }
            
            all_surahs.append(surah_obj)
            print(f"  ✓ Surah {surah_num}: {len(all_verses)} verses")
            
        except Exception as e:
            print(f"  ✗ Error downloading Surah {surah_num}: {e}")
            # Add empty surah placeholder
            all_surahs.append({
                'number': surah_num,
                'name': '',
                'name_arabic': '',
                'verses_count': 0,
                'revelation_place': '',
                'verses': []
            })
    
    # Save to file
    output_file = f'assets/data/quran_{language_code}.json'
    with open(output_file, 'w', encoding='utf-8') as f:
        json.dump(all_surahs, f, ensure_ascii=False, indent=2)
    
    print(f"✅ Saved {output_file}")
    return len(all_surahs)

def main():
    print("🕌 Quran Translation Downloader")
    print("Source: Quran.com API (Official & Legal)")
    print("=" * 50)
    
    # Download French translation (Muhammad Hamidullah - ID 31)
    download_translation('fr', 31, 'Muhammad Hamidullah')
    
    print()
    
    # Download English translation (Saheeh International - ID 20)
    download_translation('en', 20, 'Saheeh International')
    
    print()
    print("=" * 50)
    print("✅ All translations downloaded successfully!")
    print("Files created:")
    print("  - assets/data/quran_fr.json")
    print("  - assets/data/quran_en.json")

if __name__ == '__main__':
    main()
