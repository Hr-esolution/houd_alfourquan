# Adhan Audio Files

This directory contains the MP3 files used for prayer notifications.

## Available Files

The app uses the following adhan files from `assets/audio/adhan/`:

| File | ID | Name | Usage |
|------|-----|------|-------|
| `adhan1.mp3` | 1 | Adhan 1 | Default for Fajr |
| `adhan2.mp3` | 2 | Adhan 2 | Default for Dhuhr |
| `adhan3.mp3` | 3 | Adhan 3 | Default for Asr |
| `adhan4.mp3` | 4 | Adhan 4 | Default for Maghrib |
| `adhan5.mp3` | 5 | Adhan 5 | Default for Isha |
| `adhan6.mp3` | 6 | Adhan 6 | Alternative |

## Configuration

Users can select any adhan for each prayer time through the settings:
- **Settings** → **Notifications** → **Adhan Sound** → **Adhan Settings**

Each prayer can have a different adhan selected from the 6 available options.

## File Requirements

- Format: MP3
- Recommended bitrate: 128 kbps
- Typical file size: 1-2 MB per file
- Duration: ~3-5 minutes (full adhan)

## Adding Custom Adhan Files

To add custom adhan files:

1. Add the MP3 file to this directory
2. Update `lib/modules/prayer/controllers/adhan_controller.dart`:
   ```dart
   static const List<Map<String, String>> localAdhans = [
     // ... existing entries
     {
       'id': '7',
       'name': 'Adhan 7',
       'name_ar': 'أذان 7',
       'file': 'adhan7.mp3',
     },
   ];
   ```
3. Run `flutter pub get`

## Notes

- All files are bundled with the app (no download required)
- Files are played using the `just_audio` package
- Total assets size consideration: ~6-10 MB for all 6 adhans
