class HadithService {
  // In a real app with more time, we would parse large JSONs or use an API.
  // For this upgrade, we'll use a robust local dataset to avoid rate limits and ensure offline access.

  Future<List<Map<String, dynamic>>> getHadiths(String book) async {
    // Simulating a delay to mimic async data loading
    await Future.delayed(const Duration(milliseconds: 500));

    // Mock data for demonstration - replace with actual JSON asset parsing
    if (book == 'bukhari') {
      return [
        {
          "hadith_number": 1,
          "text_en":
              "The reward of deeds depends upon the intentions and every person will get the reward according to what he has intended.",
          "text_ar":
              "إِنَّمَا الأَعْمَالُ بِالنِّيَّاتِ، وَإِنَّمَا لِكُلِّ امْرِئٍ مَا نَوَى",
          "narrator": "Umar bin Al-Khattab",
        },
        {
          "hadith_number": 2,
          "text_en":
              "A Muslim is the one from whose tongue and hands the Muslims are safe; and a Muhajir (Emigrant) is the one who leaves (abandons) what Allah has forbidden.",
          "text_ar":
              "الْمُسْلِمُ مَنْ سَلِمَ الْمُسْلِمُونَ مِنْ لِسَانِهِ وَيَدِهِ وَالْمُهَاجِرُ مَنْ هَجَرَ مَا نَهَى اللَّهُ عَنْهُ",
          "narrator": "Abdullah bin Amr",
        },
      ];
    }
    return [];
  }

  Future<Map<String, dynamic>> getRandomHadith() async {
    // Return a random hadith for the "Daily Inspiration"
    final hadiths = await getHadiths('bukhari');
    return hadiths.first; // Simplified for now
  }
}
