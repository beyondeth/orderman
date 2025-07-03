import 'package:flutter/material.dart';
import 'app_typography.dart';
import 'app_spacing.dart';

/// Typography와 Spacing 시스템을 테스트하고 시연하기 위한 위젯
/// 개발 중에만 사용하며, 실제 앱에서는 제거 예정
class TypographyShowcase extends StatelessWidget {
  const TypographyShowcase({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Typography & Spacing Showcase',
          style: AppTypography.appBarTitle,
        ),
      ),
      body: SingleChildScrollView(
        padding: AppSpacing.screenAll,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Display Styles
            _buildSection(
              'Display Styles',
              [
                _buildTextExample('Display Large', AppTypography.displayLarge),
                _buildTextExample('Display Medium', AppTypography.displayMedium),
                _buildTextExample('Display Small', AppTypography.displaySmall),
              ],
            ),
            
            AppSpacing.verticalGapLG,
            
            // Headline Styles
            _buildSection(
              'Headline Styles',
              [
                _buildTextExample('Headline Large', AppTypography.headlineLarge),
                _buildTextExample('Headline Medium', AppTypography.headlineMedium),
                _buildTextExample('Headline Small', AppTypography.headlineSmall),
              ],
            ),
            
            AppSpacing.verticalGapLG,
            
            // Title Styles
            _buildSection(
              'Title Styles',
              [
                _buildTextExample('Title Large', AppTypography.titleLarge),
                _buildTextExample('Title Medium', AppTypography.titleMedium),
                _buildTextExample('Title Small', AppTypography.titleSmall),
              ],
            ),
            
            AppSpacing.verticalGapLG,
            
            // Body Styles
            _buildSection(
              'Body Styles',
              [
                _buildTextExample('Body Large', AppTypography.bodyLarge),
                _buildTextExample('Body Medium', AppTypography.bodyMedium),
                _buildTextExample('Body Small', AppTypography.bodySmall),
              ],
            ),
            
            AppSpacing.verticalGapLG,
            
            // Label Styles
            _buildSection(
              'Label Styles',
              [
                _buildTextExample('Label Large', AppTypography.labelLarge),
                _buildTextExample('Label Medium', AppTypography.labelMedium),
                _buildTextExample('Label Small', AppTypography.labelSmall),
              ],
            ),
            
            AppSpacing.verticalGapLG,
            
            // App Specific Styles
            _buildSection(
              'App Specific Styles',
              [
                _buildTextExample('Card Title', AppTypography.cardTitle),
                _buildTextExample('Button Text', AppTypography.buttonText),
                _buildTextExample('Caption', AppTypography.caption),
                _buildTextExample('Error Text', AppTypography.error),
                _buildTextExample('Success Text', AppTypography.success),
                _buildTextExample('Price', AppTypography.price),
                _buildTextExample('Status', AppTypography.status),
              ],
            ),
            
            AppSpacing.verticalGapLG,
            
            // Button Examples
            _buildSection(
              'Button Examples',
              [
                Row(
                  children: [
                    FilledButton(
                      onPressed: () {},
                      child: const Text('Filled Button'),
                    ),
                    AppSpacing.horizontalGapMD,
                    ElevatedButton(
                      onPressed: () {},
                      child: const Text('Elevated Button'),
                    ),
                  ],
                ),
                AppSpacing.verticalGapSM,
                Row(
                  children: [
                    OutlinedButton(
                      onPressed: () {},
                      child: const Text('Outlined Button'),
                    ),
                    AppSpacing.horizontalGapMD,
                    TextButton(
                      onPressed: () {},
                      child: const Text('Text Button'),
                    ),
                  ],
                ),
              ],
            ),
            
            AppSpacing.verticalGapLG,
            
            // Card Example
            _buildSection(
              'Card Example',
              [
                Card(
                  child: Padding(
                    padding: AppSpacing.cardAll,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '카드 제목',
                          style: AppTypography.cardTitle,
                        ),
                        AppSpacing.verticalGapSM,
                        Text(
                          '이것은 카드 내용입니다. Body Medium 스타일을 사용합니다.',
                          style: AppTypography.bodyMedium,
                        ),
                        AppSpacing.verticalGapSM,
                        Text(
                          '추가 정보나 캡션',
                          style: AppTypography.caption,
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
            
            AppSpacing.verticalGapLG,
            
            // Spacing Examples
            _buildSection(
              'Spacing Examples',
              [
                Container(
                  padding: AppSpacing.paddingMD,
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey),
                    borderRadius: BorderRadius.circular(AppSpacing.sm),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Padding MD (16dp)', style: AppTypography.titleSmall),
                      AppSpacing.verticalGapSM,
                      Container(
                        padding: AppSpacing.paddingSM,
                        decoration: BoxDecoration(
                          color: Theme.of(context).colorScheme.primaryContainer,
                          borderRadius: BorderRadius.circular(AppSpacing.xs),
                        ),
                        child: Text('Padding SM (8dp)', style: AppTypography.bodySmall),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            
            AppSpacing.verticalGapXXL,
          ],
        ),
      ),
    );
  }
  
  Widget _buildSection(String title, List<Widget> children) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: AppTypography.headlineSmall.copyWith(
            color: Colors.blue,
            fontWeight: FontWeight.w600,
          ),
        ),
        AppSpacing.verticalGapMD,
        ...children,
      ],
    );
  }
  
  Widget _buildTextExample(String label, TextStyle style) {
    return Padding(
      padding: AppSpacing.verticalSM,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '$label (${style.fontSize?.toInt()}sp)',
            style: AppTypography.labelSmall.copyWith(
              color: Colors.grey[600],
            ),
          ),
          AppSpacing.verticalGapXS,
          Text(
            label,
            style: style,
          ),
        ],
      ),
    );
  }
}
