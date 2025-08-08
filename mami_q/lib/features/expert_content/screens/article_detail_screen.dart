import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:share_plus/share_plus.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_text_styles.dart';
import '../models/article.dart';
import '../providers/expert_content_provider.dart';

class ArticleDetailScreen extends ConsumerWidget {
  final String articleId;
  
  const ArticleDetailScreen({
    super.key, 
    required this.articleId,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final articlesAsync = ref.watch(articlesProvider);
    final bookmarksAsync = ref.watch(bookmarkedArticlesProvider);
    
    return Scaffold(
      appBar: AppBar(
        title: Text('Article', style: AppTextStyles.headlineSmall.copyWith(color: Colors.white)),
        backgroundColor: AppColors.primary,
      ),
      body: articlesAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stackTrace) => Center(
          child: Text(
            'Error loading article: $error',
            style: AppTextStyles.bodyLarge.copyWith(color: AppColors.error),
          ),
        ),
        data: (articles) {
          final article = articles.firstWhere(
            (a) => a.id == articleId,
            orElse: () => Article(
              id: 'not-found',
              title: 'Article Not Found',
              summary: 'The requested article could not be found.',
              content: 'This article is not available. Please try another one.',
              author: 'Unknown',
              authorTitle: 'Unknown',
              category: 'Unknown',
              tags: const [],
              publishedDate: DateTime.now(),
              imageUrl: null,
              estimatedReadTime: 0,
              sources: const [],
              relatedArticleIds: const [],
            ),
          );
          
          if (article.id == 'not-found') {
            return Center(
              child: Text(
                'Article not found',
                style: AppTextStyles.headlineSmall.copyWith(color: AppColors.error),
              ),
            );
          }
          
          final isBookmarked = bookmarksAsync.maybeWhen(
            data: (bookmarks) => bookmarks.contains(articleId),
            orElse: () => false,
          );
          
          return Stack(
            children: [
              SingleChildScrollView(
                padding: const EdgeInsets.only(bottom: 80),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Featured Image
                    if (article.imageUrl != null)
                      SizedBox(
                        width: double.infinity,
                        height: 200,
                        child: Image.network(
                          article.imageUrl!,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) => Container(
                            color: AppColors.surfaceVariant,
                            child: const Center(
                              child: Icon(Icons.image_not_supported, size: 48, color: AppColors.textTertiary),
                            ),
                          ),
                        ),
                      ),
                    
                    Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Title
                          Text(
                            article.title,
                            style: AppTextStyles.headlineMedium,
                          ),
                          const SizedBox(height: 8),
                          
                          // Author & Date Info
                          Row(
                            children: [
                              const CircleAvatar(
                                radius: 16,
                                backgroundColor: AppColors.primary,
                                child: Icon(Icons.person, color: Colors.white, size: 16),
                              ),
                              const SizedBox(width: 8),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    article.author,
                                    style: AppTextStyles.bodyMedium.copyWith(fontWeight: FontWeight.bold),
                                  ),
                                  Text(
                                    article.authorTitle,
                                    style: AppTextStyles.bodySmall.copyWith(color: AppColors.textSecondary),
                                  ),
                                ],
                              ),
                              const Spacer(),
                              Text(
                                _formatDate(article.publishedDate),
                                style: AppTextStyles.bodySmall.copyWith(color: AppColors.textSecondary),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          
                          // Read Time & Category
                          Row(
                            children: [
                              const Icon(Icons.access_time, size: 16, color: AppColors.textSecondary),
                              const SizedBox(width: 4),
                              Text(
                                '${article.estimatedReadTime} min read',
                                style: AppTextStyles.bodySmall.copyWith(color: AppColors.textSecondary),
                              ),
                              const SizedBox(width: 16),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                decoration: BoxDecoration(
                                  color: AppColors.primaryLight.withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Text(
                                  article.category,
                                  style: AppTextStyles.bodySmall.copyWith(color: AppColors.primary),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),
                          
                          // Tags
                          if (article.tags.isNotEmpty) ...[
                            Wrap(
                              spacing: 8,
                              runSpacing: 8,
                              children: article.tags.map((tag) => Chip(
                                label: Text(tag),
                                backgroundColor: AppColors.surfaceVariant,
                                labelStyle: AppTextStyles.bodySmall,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(16),
                                ),
                                padding: EdgeInsets.zero,
                                materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                                visualDensity: VisualDensity.compact,
                              )).toList(),
                            ),
                            const SizedBox(height: 16),
                          ],
                          
                          // Summary
                          Text(
                            article.summary,
                            style: AppTextStyles.bodyLarge.copyWith(fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(height: 16),
                          
                          // Content
                          Html(
                            data: article.content,
                            style: {
                              'body': Style(
                                fontSize: FontSize(16.0),
                                fontFamily: 'Poppins',
                                lineHeight: LineHeight.number(1.6),
                                color: AppColors.textPrimary,
                              ),
                              'h1': Style(
                                fontSize: FontSize(24.0),
                                fontWeight: FontWeight.bold,
                              ),
                              'h2': Style(
                                fontSize: FontSize(20.0),
                                fontWeight: FontWeight.bold,
                              ),
                              'h3': Style(
                                fontSize: FontSize(18.0),
                                fontWeight: FontWeight.bold,
                              ),
                              'p': Style(),
                              'li': Style(),
                            },
                          ),
                          
                          // Sources
                          if (article.sources.isNotEmpty) ...[
                            const SizedBox(height: 24),
                            const Divider(),
                            const SizedBox(height: 16),
                            Text(
                              'Sources',
                              style: AppTextStyles.titleMedium,
                            ),
                            const SizedBox(height: 8),
                            ...article.sources.map((source) => Padding(
                              padding: const EdgeInsets.only(bottom: 8.0),
                              child: Text(
                                '• $source',
                                style: AppTextStyles.bodySmall.copyWith(color: AppColors.textSecondary),
                              ),
                            )),
                          ],
                          
                          // Related Articles
                          if (article.relatedArticleIds.isNotEmpty) ...[
                            const SizedBox(height: 24),
                            const Divider(),
                            const SizedBox(height: 16),
                            Text(
                              'Related Articles',
                              style: AppTextStyles.titleMedium,
                            ),
                            const SizedBox(height: 16),
                            ...article.relatedArticleIds.map((relatedId) {
                              final relatedArticle = articles.firstWhere(
                                (a) => a.id == relatedId,
                                orElse: () => Article(
                                  id: relatedId,
                                  title: 'Article not found',
                                  summary: '',
                                  content: '',
                                  author: 'Unknown',
                                  authorTitle: '',
                                  category: '',
                                  tags: const [],
                                  publishedDate: DateTime.now(),
                                  imageUrl: null,
                                  estimatedReadTime: 0,
                                  sources: const [],
                                  relatedArticleIds: const [],
                                ),
                              );
                              
                              return Padding(
                                padding: const EdgeInsets.only(bottom: 16.0),
                                child: ListTile(
                                  contentPadding: EdgeInsets.zero,
                                  leading: relatedArticle.imageUrl != null
                                      ? ClipRRect(
                                          borderRadius: BorderRadius.circular(8),
                                          child: Image.network(
                                            relatedArticle.imageUrl!,
                                            width: 60,
                                            height: 60,
                                            fit: BoxFit.cover,
                                            errorBuilder: (context, error, stackTrace) => Container(
                                              width: 60,
                                              height: 60,
                                              color: AppColors.surfaceVariant,
                                              child: const Icon(Icons.image, color: AppColors.textTertiary),
                                            ),
                                          ),
                                        )
                                      : Container(
                                          width: 60,
                                          height: 60,
                                          decoration: BoxDecoration(
                                            color: AppColors.surfaceVariant,
                                            borderRadius: BorderRadius.circular(8),
                                          ),
                                          child: const Icon(Icons.article, color: AppColors.textTertiary),
                                        ),
                                  title: Text(
                                    relatedArticle.title,
                                    style: AppTextStyles.bodyMedium.copyWith(fontWeight: FontWeight.bold),
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  subtitle: Text(
                                    '${_formatDate(relatedArticle.publishedDate)} • ${relatedArticle.estimatedReadTime} min read',
                                    style: AppTextStyles.bodySmall.copyWith(color: AppColors.textSecondary),
                                  ),
                                  onTap: () {
                                    // Navigate to the related article
                                    Navigator.pushReplacement(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) => ArticleDetailScreen(articleId: relatedId),
                                      ),
                                    );
                                  },
                                ),
                              );
                            }).toList(),
                          ],
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              
              // Bottom Action Bar
              Positioned(
                bottom: 0,
                left: 0,
                right: 0,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.1),
                        blurRadius: 8,
                        offset: const Offset(0, -2),
                      ),
                    ],
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      _buildActionButton(
                        context,
                        icon: isBookmarked ? Icons.bookmark : Icons.bookmark_border,
                        label: isBookmarked ? 'Saved' : 'Save',
                        color: isBookmarked ? AppColors.primary : AppColors.textSecondary,
                        onTap: () {
                          if (isBookmarked) {
                            ref.read(bookmarkedArticlesProvider.notifier).removeBookmark(articleId);
                          } else {
                            ref.read(bookmarkedArticlesProvider.notifier).addBookmark(articleId);
                          }
                        },
                      ),
                      _buildActionButton(
                        context,
                        icon: Icons.share,
                        label: 'Share',
                        onTap: () {
                          Share.share(
                            'Check out this article: ${article.title}\n\n${article.summary}\n\nShared via MamiQ App',
                          );
                        },
                      ),
                      _buildActionButton(
                        context,
                        icon: Icons.text_increase,
                        label: 'Text Size',
                        onTap: () {
                          _showTextSizeDialog(context);
                        },
                      ),
                    ],
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
  
  Widget _buildActionButton(
    BuildContext context, {
    required IconData icon,
    required String label,
    required VoidCallback onTap,
    Color? color,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: color ?? AppColors.textSecondary),
            const SizedBox(height: 4),
            Text(
              label,
              style: AppTextStyles.bodySmall.copyWith(color: color ?? AppColors.textSecondary),
            ),
          ],
        ),
      ),
    );
  }
  
  void _showTextSizeDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(
          'Text Size',
          style: AppTextStyles.titleLarge,
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildTextSizeOption(context, 'Small', 0.8),
            const SizedBox(height: 16),
            _buildTextSizeOption(context, 'Medium', 1.0),
            const SizedBox(height: 16),
            _buildTextSizeOption(context, 'Large', 1.2),
            const SizedBox(height: 16),
            _buildTextSizeOption(context, 'Extra Large', 1.4),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }
  
  Widget _buildTextSizeOption(BuildContext context, String label, double scale) {
    return InkWell(
      onTap: () {
        // TODO: Implement text size changing
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Text size changed to $label')),
        );
      },
      child: Row(
        children: [
          Expanded(
            child: Text(
              'Article Text',
              style: AppTextStyles.bodyMedium.copyWith(
                fontSize: AppTextStyles.bodyMedium.fontSize! * scale,
              ),
            ),
          ),
          Text(
            label,
            style: AppTextStyles.bodySmall,
          ),
        ],
      ),
    );
  }
  
  String _formatDate(DateTime date) {
    final months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
    ];
    return '${months[date.month - 1]} ${date.day}, ${date.year}';
  }
}
