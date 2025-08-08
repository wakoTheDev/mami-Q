import 'dart:convert';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/article.dart';

// Repository provider
final expertContentRepositoryProvider = Provider<ExpertContentRepository>((ref) {
  return ExpertContentRepository();
});

// Articles provider
final articlesProvider = AsyncNotifierProvider<ArticlesNotifier, List<Article>>(
  () => ArticlesNotifier(),
);

class ArticlesNotifier extends AsyncNotifier<List<Article>> {
  @override
  Future<List<Article>> build() async {
    final repository = ref.watch(expertContentRepositoryProvider);
    return await repository.getArticles();
  }

  Future<void> refreshArticles() async {
    state = const AsyncValue.loading();
    
    try {
      final repository = ref.read(expertContentRepositoryProvider);
      final articles = await repository.getArticles();
      state = AsyncValue.data(articles);
    } catch (error, stackTrace) {
      state = AsyncValue.error(error, stackTrace);
    }
  }
  
  Future<void> filterByCategory(String category) async {
    state = const AsyncValue.loading();
    
    try {
      final repository = ref.read(expertContentRepositoryProvider);
      final articles = await repository.getArticlesByCategory(category);
      state = AsyncValue.data(articles);
    } catch (error, stackTrace) {
      state = AsyncValue.error(error, stackTrace);
    }
  }
  
  Future<void> search(String query) async {
    state = const AsyncValue.loading();
    
    try {
      final repository = ref.read(expertContentRepositoryProvider);
      final allArticles = await repository.getArticles();
      
      if (query.isEmpty) {
        state = AsyncValue.data(allArticles);
        return;
      }
      
      final searchLower = query.toLowerCase();
      final filteredArticles = allArticles.where((article) {
        return article.title.toLowerCase().contains(searchLower) ||
               article.summary.toLowerCase().contains(searchLower) ||
               article.content.toLowerCase().contains(searchLower) ||
               article.tags.any((tag) => tag.toLowerCase().contains(searchLower)) ||
               article.author.toLowerCase().contains(searchLower) ||
               article.category.toLowerCase().contains(searchLower);
      }).toList();
      
      state = AsyncValue.data(filteredArticles);
    } catch (error, stackTrace) {
      state = AsyncValue.error(error, stackTrace);
    }
  }
}

// Bookmarked articles provider
final bookmarkedArticlesProvider = AsyncNotifierProvider<BookmarkedArticlesNotifier, List<String>>(
  () => BookmarkedArticlesNotifier(),
);

class BookmarkedArticlesNotifier extends AsyncNotifier<List<String>> {
  @override
  Future<List<String>> build() async {
    final repository = ref.watch(expertContentRepositoryProvider);
    return await repository.getBookmarkedArticleIds();
  }

  Future<void> addBookmark(String articleId) async {
    state = const AsyncValue.loading();
    
    try {
      final repository = ref.read(expertContentRepositoryProvider);
      await repository.addBookmark(articleId);
      
      // Refresh the list
      final bookmarks = await repository.getBookmarkedArticleIds();
      state = AsyncValue.data(bookmarks);
    } catch (error, stackTrace) {
      state = AsyncValue.error(error, stackTrace);
    }
  }

  Future<void> removeBookmark(String articleId) async {
    state = const AsyncValue.loading();
    
    try {
      final repository = ref.read(expertContentRepositoryProvider);
      await repository.removeBookmark(articleId);
      
      // Refresh the list
      final bookmarks = await repository.getBookmarkedArticleIds();
      state = AsyncValue.data(bookmarks);
    } catch (error, stackTrace) {
      state = AsyncValue.error(error, stackTrace);
    }
  }

  Future<void> clearAllBookmarks() async {
    state = const AsyncValue.loading();
    
    try {
      final repository = ref.read(expertContentRepositoryProvider);
      await repository.clearAllBookmarks();
      state = AsyncValue.data([]);
    } catch (error, stackTrace) {
      state = AsyncValue.error(error, stackTrace);
    }
  }
}

class ExpertContentRepository {
  static const String _articlesKey = 'expert_articles';
  static const String _bookmarksKey = 'bookmarked_articles';
  static const String _readArticlesKey = 'read_articles';
  static const String _categoriesKey = 'article_categories';

  // Get all articles
  Future<List<Article>> getArticles() async {
    final prefs = await SharedPreferences.getInstance();
    final articlesJson = prefs.getStringList(_articlesKey) ?? [];
    
    if (articlesJson.isEmpty) {
      // Return sample data if no articles exist
      final sampleArticles = _getSampleArticles();
      await _saveArticles(sampleArticles);
      return sampleArticles;
    }
    
    try {
      return articlesJson
          .map((jsonString) => Article.fromJson(json.decode(jsonString)))
          .toList();
    } catch (e) {
      // Return sample data if there's an error parsing the stored data
      print('Error loading articles: $e');
      final sampleArticles = _getSampleArticles();
      await _saveArticles(sampleArticles);
      return sampleArticles;
    }
  }

  // Get article by ID
  Future<Article?> getArticleById(String id) async {
    final articles = await getArticles();
    try {
      return articles.firstWhere((article) => article.id == id);
    } catch (e) {
      return null;
    }
  }

  // Get articles by category
  Future<List<Article>> getArticlesByCategory(String category) async {
    final allArticles = await getArticles();
    return allArticles.where((article) => article.category == category).toList();
  }

  // Save articles (internal use)
  Future<void> _saveArticles(List<Article> articles) async {
    final prefs = await SharedPreferences.getInstance();
    final articlesJson = articles
        .map((article) => json.encode(article.toJson()))
        .toList();
    await prefs.setStringList(_articlesKey, articlesJson);
  }

  // Get bookmarked article IDs
  Future<List<String>> getBookmarkedArticleIds() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getStringList(_bookmarksKey) ?? [];
  }

  // Get bookmarked articles
  Future<List<Article>> getBookmarkedArticles() async {
    final bookmarkIds = await getBookmarkedArticleIds();
    final allArticles = await getArticles();
    
    return allArticles.where((article) => bookmarkIds.contains(article.id)).toList();
  }

  // Add bookmark
  Future<void> addBookmark(String articleId) async {
    final prefs = await SharedPreferences.getInstance();
    final bookmarkIds = prefs.getStringList(_bookmarksKey) ?? [];
    
    if (!bookmarkIds.contains(articleId)) {
      bookmarkIds.add(articleId);
      await prefs.setStringList(_bookmarksKey, bookmarkIds);
    }
  }

  // Remove bookmark
  Future<void> removeBookmark(String articleId) async {
    final prefs = await SharedPreferences.getInstance();
    final bookmarkIds = prefs.getStringList(_bookmarksKey) ?? [];
    
    bookmarkIds.remove(articleId);
    await prefs.setStringList(_bookmarksKey, bookmarkIds);
  }

  // Clear all bookmarks
  Future<void> clearAllBookmarks() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList(_bookmarksKey, []);
  }

  // Mark article as read
  Future<void> markArticleAsRead(String articleId) async {
    final prefs = await SharedPreferences.getInstance();
    final readIds = prefs.getStringList(_readArticlesKey) ?? [];
    
    if (!readIds.contains(articleId)) {
      readIds.add(articleId);
      await prefs.setStringList(_readArticlesKey, readIds);
    }
  }

  // Get read article IDs
  Future<List<String>> getReadArticleIds() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getStringList(_readArticlesKey) ?? [];
  }

  // Check if article is read
  Future<bool> isArticleRead(String articleId) async {
    final readIds = await getReadArticleIds();
    return readIds.contains(articleId);
  }

  // Get available categories
  Future<List<String>> getCategories() async {
    final prefs = await SharedPreferences.getInstance();
    final categories = prefs.getStringList(_categoriesKey);
    
    if (categories != null && categories.isNotEmpty) {
      return categories;
    }
    
    // Extract categories from articles
    final articles = await getArticles();
    final extractedCategories = articles
        .map((article) => article.category)
        .toSet()
        .toList();
    
    // Save extracted categories
    await prefs.setStringList(_categoriesKey, extractedCategories);
    return extractedCategories;
  }

  // Sample articles
  List<Article> _getSampleArticles() {
    return [
      Article(
        id: 'article-1',
        title: 'First Trimester Essentials: Navigating the Early Months',
        summary: 'Learn about the key changes and important health considerations during the first three months of pregnancy.',
        content: '''
<h1>First Trimester Essentials: Navigating the Early Months</h1>

<p>The first trimester of pregnancy spans from week 1 to week 12, and it's a time of rapid development for your baby and significant changes for you. During these early weeks, your baby's major organs and structures begin to form, making this a critical period for development.</p>

<h2>Physical Changes to Expect</h2>

<p>While you may not look pregnant yet, your body is undergoing numerous changes. Hormone levels surge, particularly human chorionic gonadotropin (hCG), estrogen, and progesterone. These hormonal shifts contribute to many early pregnancy symptoms:</p>

<ul>
  <li><strong>Morning sickness:</strong> Despite its name, nausea and vomiting can occur at any time of day. About 70-80% of pregnant women experience some form of morning sickness.</li>
  <li><strong>Fatigue:</strong> Feeling exceptionally tired is common as your body works hard to support your developing baby.</li>
  <li><strong>Breast tenderness:</strong> Your breasts may become swollen, tender, and heavier.</li>
  <li><strong>Frequent urination:</strong> Your kidneys are working harder, processing extra fluid.</li>
  <li><strong>Food aversions and cravings:</strong> You might suddenly dislike foods you normally enjoy or crave unusual combinations.</li>
</ul>

<h2>Nutritional Needs</h2>

<p>Good nutrition is particularly important during the first trimester when your baby's neural tube develops into the brain and spinal cord.</p>

<ul>
  <li><strong>Folic acid:</strong> Take at least 400-600 micrograms daily to prevent neural tube defects.</li>
  <li><strong>Iron:</strong> Supports the increased blood volume and prevents anemia.</li>
  <li><strong>Calcium:</strong> Essential for developing your baby's bones and teeth.</li>
  <li><strong>Protein:</strong> Crucial for your baby's growth.</li>
</ul>

<p>Focus on eating small, frequent meals that combine protein and complex carbohydrates to help manage nausea and maintain energy levels.</p>

<h2>Important Health Considerations</h2>

<h3>Prenatal Care</h3>
<p>Schedule your first prenatal visit as soon as you know you're pregnant. This visit typically includes:</p>
<ul>
  <li>Confirmation of pregnancy</li>
  <li>Medical history review</li>
  <li>Physical examination</li>
  <li>Dating the pregnancy</li>
  <li>Initial screening tests</li>
</ul>

<h3>Medications and Supplements</h3>
<p>Always consult with your healthcare provider before taking any medication, including over-the-counter products. Begin taking a prenatal vitamin with folic acid if you haven't already started.</p>

<h3>Activities to Avoid</h3>
<ul>
  <li>Alcohol consumption</li>
  <li>Smoking or secondhand smoke exposure</li>
  <li>Raw or undercooked meat, eggs, and seafood</li>
  <li>Unpasteurized dairy products</li>
  <li>Excessive caffeine (limit to 200mg per day)</li>
  <li>Hot tubs and saunas</li>
</ul>

<h2>Emotional Wellbeing</h2>

<p>The first trimester can be emotionally challenging. Hormonal changes may cause mood swings, and you might feel anxious about the pregnancy, especially if you've experienced pregnancy loss before. It's important to:</p>

<ul>
  <li>Communicate openly with your partner about your feelings</li>
  <li>Connect with other expectant mothers or join prenatal groups</li>
  <li>Rest when you need to and don't overcommit yourself</li>
  <li>Practice relaxation techniques like prenatal yoga or meditation</li>
</ul>

<h2>When to Call Your Doctor</h2>

<p>While many symptoms are normal during the first trimester, certain signs warrant immediate medical attention:</p>

<ul>
  <li>Severe abdominal pain or cramping</li>
  <li>Heavy vaginal bleeding</li>
  <li>Severe dizziness or fainting</li>
  <li>Severe vomiting that prevents keeping any food or fluids down</li>
  <li>High fever</li>
  <li>Painful urination</li>
</ul>

<p>Remember, every pregnancy is different, and what's normal can vary widely from woman to woman. Trust your instincts and don't hesitate to contact your healthcare provider with any concerns.</p>
        ''',
        author: 'Dr. Amina Okonkwo',
        authorTitle: 'Senior Obstetrician',
        category: 'Pregnancy Basics',
        tags: ['first trimester', 'prenatal care', 'nutrition', 'morning sickness'],
        publishedDate: DateTime(2025, 3, 15),
        imageUrl: 'https://images.unsplash.com/photo-1584582396689-5995f9c72cc1?ixlib=rb-1.2.1&auto=format&fit=crop&w=1000&q=80',
        estimatedReadTime: 7,
        sources: [
          'American College of Obstetricians and Gynecologists. (2024). Your Pregnancy and Childbirth: Month to Month, 7th Edition.',
          'Mayo Clinic. (2025). First Trimester Pregnancy: What to Expect.',
        ],
        relatedArticleIds: ['article-2', 'article-3'],
      ),
      Article(
        id: 'article-2',
        title: 'Nutrition During Pregnancy: Eating for Two Responsibly',
        summary: 'A comprehensive guide to maintaining proper nutrition throughout pregnancy for both maternal and fetal health.',
        content: '''
<h1>Nutrition During Pregnancy: Eating for Two Responsibly</h1>

<p>Proper nutrition during pregnancy is critical for both maternal health and fetal development. While the old saying "eating for two" exists, it's more about quality than quantity. This guide outlines essential nutritional considerations for pregnant women.</p>

<h2>Caloric Needs During Pregnancy</h2>

<p>Contrary to popular belief, pregnancy only requires about 300-500 extra calories per day, and mainly in the second and third trimesters. The breakdown:</p>

<ul>
  <li><strong>First trimester:</strong> Generally no additional calories needed</li>
  <li><strong>Second trimester:</strong> Approximately 340 extra calories per day</li>
  <li><strong>Third trimester:</strong> Approximately 450 extra calories per day</li>
</ul>

<p>These extra calories should come from nutrient-dense foods rather than empty calories from processed foods or sweets.</p>

<h2>Essential Nutrients for Pregnancy</h2>

<h3>Folate/Folic Acid (600 mcg daily)</h3>
<p>Critical for preventing neural tube defects, particularly in the first 28 days after conception. Sources include:</p>
<ul>
  <li>Leafy green vegetables</li>
  <li>Fortified cereals</li>
  <li>Legumes</li>
  <li>Oranges</li>
</ul>

<h3>Iron (27 mg daily)</h3>
<p>Required for increased blood production and to prevent anemia. Good sources include:</p>
<ul>
  <li>Lean red meat</li>
  <li>Poultry</li>
  <li>Fish</li>
  <li>Iron-fortified cereals</li>
  <li>Beans and lentils</li>
  <li>Spinach</li>
</ul>
<p>Pair iron-rich foods with vitamin C for better absorption.</p>

<h3>Calcium (1,000 mg daily)</h3>
<p>Essential for developing your baby's bones, teeth, and general growth. Sources include:</p>
<ul>
  <li>Dairy products (milk, yogurt, cheese)</li>
  <li>Calcium-fortified plant milks and juices</li>
  <li>Canned fish with bones (salmon, sardines)</li>
  <li>Leafy greens</li>
  <li>Tofu made with calcium sulfate</li>
</ul>

<h3>Protein (75-100g daily)</h3>
<p>The building block for your baby's cells and tissues. Good sources include:</p>
<ul>
  <li>Lean meats</li>
  <li>Poultry</li>
  <li>Fish (low in mercury)</li>
  <li>Eggs</li>
  <li>Dairy products</li>
  <li>Legumes, nuts, and seeds</li>
  <li>Tofu and other soy products</li>
</ul>

<h3>Omega-3 Fatty Acids (DHA)</h3>
<p>Important for your baby's brain and eye development. Sources include:</p>
<ul>
  <li>Fatty fish low in mercury (salmon, trout, sardines)</li>
  <li>Walnuts</li>
  <li>Flaxseeds and chia seeds</li>
  <li>DHA-fortified foods</li>
  <li>Algae oil supplements (for vegetarians)</li>
</ul>

<h2>Meal Planning Strategies</h2>

<p>Proper meal planning can help manage common pregnancy issues like nausea, heartburn, and constipation.</p>

<h3>First Trimester (Managing Nausea)</h3>
<ul>
  <li>Eat small, frequent meals</li>
  <li>Keep simple snacks like crackers by your bed</li>
  <li>Stay hydrated between meals rather than with meals</li>
  <li>Focus on bland, easy-to-digest foods when nauseous</li>
  <li>Try ginger tea or ginger candies for natural nausea relief</li>
</ul>

<h3>Second and Third Trimesters</h3>
<ul>
  <li>Include fiber-rich foods to prevent constipation</li>
  <li>Eat smaller, more frequent meals to prevent heartburn</li>
  <li>Avoid lying down immediately after eating</li>
  <li>Stay well-hydrated (aim for 8-10 cups of water daily)</li>
</ul>

<h2>Foods and Substances to Avoid</h2>

<h3>Completely Avoid:</h3>
<ul>
  <li>Alcohol</li>
  <li>Raw or undercooked meat, fish, and eggs</li>
  <li>Unpasteurized dairy products and juices</li>
  <li>Raw sprouts</li>
  <li>High-mercury fish (shark, swordfish, king mackerel, tilefish)</li>
  <li>Excess caffeine (limit to 200mg per day, about one 12oz cup of coffee)</li>
  <li>Herbal teas (unless approved by your healthcare provider)</li>
</ul>

<h3>Limit:</h3>
<ul>
  <li>Processed foods high in sodium, fat, and sugar</li>
  <li>Artificial sweeteners</li>
</ul>

<h2>Special Dietary Considerations</h2>

<h3>Vegetarian and Vegan Diets</h3>
<p>Can be healthy during pregnancy but require careful planning to ensure adequate:</p>
<ul>
  <li>Protein (beans, lentils, nuts, seeds, whole grains)</li>
  <li>Vitamin B12 (supplements or fortified foods)</li>
  <li>Iron (legumes, tofu, fortified cereals)</li>
  <li>Zinc (whole grains, legumes, nuts)</li>
  <li>Calcium (fortified plant milks, tofu, leafy greens)</li>
  <li>Omega-3s (flaxseeds, walnuts, algae supplements)</li>
</ul>

<h3>Gestational Diabetes</h3>
<p>If diagnosed, work with a registered dietitian to create a meal plan that:</p>
<ul>
  <li>Controls carbohydrate intake</li>
  <li>Emphasizes complex carbohydrates over simple sugars</li>
  <li>Pairs carbohydrates with protein and healthy fats</li>
  <li>Includes regular, timed meals and snacks</li>
</ul>

<h2>Conclusion</h2>

<p>Remember that prenatal vitamins supplement but don't replace a healthy diet. Focus on whole, nutrient-dense foods, stay hydrated, and listen to your body's needs. Always consult with your healthcare provider about your specific nutritional requirements, especially if you have special dietary needs or medical conditions.</p>
        ''',
        author: 'Njeri Wanjiku',
        authorTitle: 'Registered Nutritionist, MScN',
        category: 'Nutrition',
        tags: ['nutrition', 'pregnancy diet', 'healthy eating', 'prenatal vitamins'],
        publishedDate: DateTime(2025, 2, 8),
        imageUrl: 'https://images.unsplash.com/photo-1490818387583-1baba5e638af?ixlib=rb-1.2.1&auto=format&fit=crop&w=1000&q=80',
        estimatedReadTime: 9,
        sources: [
          'Academy of Nutrition and Dietetics. (2024). Nutrition During Pregnancy.',
          'World Health Organization. (2025). Healthy Eating During Pregnancy and Breastfeeding.',
        ],
        relatedArticleIds: ['article-1', 'article-3'],
      ),
      Article(
        id: 'article-3',
        title: 'Understanding Prenatal Tests and Screenings',
        summary: 'A guide to the various tests and screenings offered during pregnancy, their purpose, and what to expect.',
        content: '''
<h1>Understanding Prenatal Tests and Screenings</h1>

<p>Prenatal testing provides valuable information about your baby's health and development. While the variety of tests can seem overwhelming, understanding their purpose and timing can help you make informed decisions about your prenatal care.</p>

<h2>First Trimester Tests (Weeks 1-12)</h2>

<h3>Initial Prenatal Blood Work</h3>
<p><strong>When:</strong> First prenatal visit</p>
<p><strong>Purpose:</strong> To determine blood type, Rh factor, immunity to certain infections, screen for sexually transmitted infections, and check for anemia.</p>
<p><strong>What to expect:</strong> Standard blood draw from your arm.</p>

<h3>Urine Test</h3>
<p><strong>When:</strong> Every prenatal visit</p>
<p><strong>Purpose:</strong> To check for urinary tract infections, protein (potential sign of preeclampsia), and glucose (potential sign of gestational diabetes).</p>
<p><strong>What to expect:</strong> You'll provide a urine sample at each visit.</p>

<h3>Ultrasound</h3>
<p><strong>When:</strong> 6-9 weeks for dating/viability; 11-13 weeks for nuchal translucency</p>
<p><strong>Purpose:</strong> Early ultrasounds confirm pregnancy, check the heartbeat, determine due date, and check for multiple pregnancies. The nuchal translucency ultrasound measures fluid at the back of the baby's neck, which can indicate risk for chromosomal abnormalities.</p>
<p><strong>What to expect:</strong> For early pregnancy, often a transvaginal ultrasound is used. For the nuchal translucency, an abdominal ultrasound is performed.</p>

<h3>Cell-Free DNA Screening (NIPT)</h3>
<p><strong>When:</strong> After 10 weeks</p>
<p><strong>Purpose:</strong> Screens for chromosomal abnormalities including Down syndrome (trisomy 21), Edwards syndrome (trisomy 18), and Patau syndrome (trisomy 13).</p>
<p><strong>What to expect:</strong> A simple blood draw from your arm.</p>
<p><strong>Note:</strong> This is a screening test, not diagnostic. A positive result would need confirmation with diagnostic testing.</p>

<h3>First Trimester Combined Screening</h3>
<p><strong>When:</strong> 11-13 weeks</p>
<p><strong>Purpose:</strong> Assesses risk for chromosomal abnormalities by combining results from nuchal translucency ultrasound, maternal blood tests for hCG and PAPP-A, and maternal age.</p>
<p><strong>What to expect:</strong> Blood draw plus ultrasound.</p>

<h2>Second Trimester Tests (Weeks 13-26)</h2>

<h3>Quad Screen or Triple Screen</h3>
<p><strong>When:</strong> 15-20 weeks</p>
<p><strong>Purpose:</strong> Screens for neural tube defects and chromosomal abnormalities by measuring levels of specific substances in maternal blood.</p>
<p><strong>What to expect:</strong> Standard blood draw.</p>

<h3>Anatomy Scan Ultrasound</h3>
<p><strong>When:</strong> 18-22 weeks</p>
<p><strong>Purpose:</strong> Comprehensive check of baby's development, including brain, heart, spine, limbs, organs, and placenta placement. Often when parents can learn baby's sex if desired.</p>
<p><strong>What to expect:</strong> Abdominal ultrasound lasting 30-60 minutes.</p>

<h3>Glucose Challenge Test</h3>
<p><strong>When:</strong> 24-28 weeks</p>
<p><strong>Purpose:</strong> Screens for gestational diabetes.</p>
<p><strong>What to expect:</strong> Drink a sweet glucose solution, wait one hour, then have blood drawn to measure blood sugar levels. If results are elevated, a follow-up 3-hour glucose tolerance test may be needed.</p>

<h3>Diagnostic Tests (If Recommended)</h3>

<p><strong>Chorionic Villus Sampling (CVS)</strong></p>
<p>When: 10-13 weeks</p>
<p>Purpose: Diagnoses chromosomal abnormalities and certain genetic disorders by analyzing cells from the placenta.</p>
<p>What to expect: A needle is inserted through the abdomen or a catheter through the cervix to collect placental tissue. Carries a small risk of miscarriage (about 1%).</p>

<p><strong>Amniocentesis</strong></p>
<p>When: 15-20 weeks</p>
<p>Purpose: Diagnoses chromosomal abnormalities, neural tube defects, and certain genetic disorders by analyzing amniotic fluid.</p>
<p>What to expect: A needle is inserted through the abdomen into the uterus to collect amniotic fluid. Carries a small risk of miscarriage (about 0.1-0.3%).</p>

<h2>Third Trimester Tests (Weeks 27-40+)</h2>

<h3>Group B Strep Test</h3>
<p><strong>When:</strong> 36-37 weeks</p>
<p><strong>Purpose:</strong> Screens for group B streptococcus bacteria, which can cause serious infections in newborns if present during delivery.</p>
<p><strong>What to expect:</strong> A swab of the vagina and rectum.</p>

<h3>Non-Stress Test (NST)</h3>
<p><strong>When:</strong> As needed in later pregnancy, particularly for high-risk pregnancies</p>
<p><strong>Purpose:</strong> Monitors how baby's heart rate responds to movement to ensure adequate oxygen supply.</p>
<p><strong>What to expect:</strong> Sensors are placed on your abdomen to monitor baby's heart rate and movement for 20-30 minutes.</p>

<h3>Biophysical Profile (BPP)</h3>
<p><strong>When:</strong> As needed in later pregnancy</p>
<p><strong>Purpose:</strong> Combines an NST with ultrasound to assess baby's heart rate, movement, muscle tone, breathing, and amniotic fluid level.</p>
<p><strong>What to expect:</strong> NST monitoring plus ultrasound.</p>

<h2>Making Informed Decisions About Testing</h2>

<p>When considering prenatal tests, especially optional screening or diagnostic tests, consider:</p>

<ul>
  <li>What information will this test provide?</li>
  <li>How accurate is this test?</li>
  <li>What are the risks associated with this test?</li>
  <li>What would I do with the information from this test?</li>
  <li>Is this test covered by my insurance or healthcare system?</li>
</ul>

<p>Discuss all testing options with your healthcare provider. Remember that most tests are optional, and you have the right to choose which tests are right for you and your pregnancy.</p>

<h2>Conclusion</h2>

<p>Prenatal testing can provide reassurance and important information about your baby's health. Understanding the purpose and process of each test can help reduce anxiety and allow you to make choices that align with your values and needs during pregnancy.</p>

<p>Always discuss any concerns or questions about prenatal testing with your healthcare provider, who can provide personalized guidance based on your specific situation and medical history.</p>
        ''',
        author: 'Dr. Samson Kipchoge',
        authorTitle: 'Maternal-Fetal Medicine Specialist',
        category: 'Medical Care',
        tags: ['prenatal testing', 'ultrasound', 'genetic screening', 'blood tests'],
        publishedDate: DateTime(2025, 4, 22),
        imageUrl: 'https://images.unsplash.com/photo-1579154204601-01588f351e67?ixlib=rb-1.2.1&auto=format&fit=crop&w=1000&q=80',
        estimatedReadTime: 8,
        sources: [
          'American College of Obstetricians and Gynecologists. (2024). Prenatal Genetic Screening Tests.',
          'National Health Service. (2025). Screening Tests in Pregnancy.',
        ],
        relatedArticleIds: ['article-1', 'article-2'],
      ),
    ];
  }
}
