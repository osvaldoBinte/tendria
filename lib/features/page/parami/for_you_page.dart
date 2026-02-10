import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:tendria/common/theme/App_Theme.dart';
import 'package:tendria/features/page/parami/for_you_controller.dart';

class ForYouPage extends StatelessWidget {
  const ForYouPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(ForYouController());

    return Scaffold(
      backgroundColor: ThemeColor.backgroundColorfondo,
      body: SafeArea(
        child: CustomScrollView(
          slivers: [
            _buildAppBar(),
            _buildNewUsersSection(controller),
            _buildRecommendationsSection(controller),
            _buildActiveProfilesSection(controller),
          ],
        ),
      ),
    );
  }

  Widget _buildAppBar() {
    return SliverAppBar(
      backgroundColor: ThemeColor.backgroundColorfondo,
      elevation: 0,
      pinned: true,
      floating: false,
      automaticallyImplyLeading: false,
      title: Row(
        children: [
          Text('NUCLEO' 
          
          , style: GoogleFonts.lato(
              fontSize: 20,
              color: ThemeColor.textPrimaryColor,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(width: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),

            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 10,
                    height: 10,
                    decoration: BoxDecoration(
                      color: ThemeColor.primaryColor,
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: 6),
                  Text(
                    'Para ti',
                    style: GoogleFonts.lato(
                      fontSize: 20,
                      color: ThemeColor.primaryColor,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNewUsersSection(ForYouController controller) {
    return SliverToBoxAdapter(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(
                    color: ThemeColor.primaryColor,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    'Ver gente nueva cada 24 horas',
                    style: GoogleFonts.lato(
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                      color: ThemeColor.textLightColor,
                      letterSpacing: 0.5,
                    ),
                  ),
                ),
                const SizedBox(height: 16),

                Text(
                  'Descubre nuevas personas hoy',
                  style: GoogleFonts.lato(
                    fontSize: 16,
                    fontWeight: FontWeight.w400,
                    color: ThemeColor.textPrimaryColor,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRecommendationsSection(ForYouController controller) {
    return SliverToBoxAdapter(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Text(
              'Recomendadas para ti',
              style: GoogleFonts.lato(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: ThemeColor.textPrimaryColor,
              ),
            ),
          ),
          const SizedBox(height: 16),
          Obx(
            () => SizedBox(
              height: 280,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                itemCount: controller.recommendations.length,
                itemBuilder: (context, index) {
                  final user = controller.recommendations[index];
                  return _buildRecommendationCard(user, controller);
                },
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
            child: Text(
              'Según tu perfil y tus conexiones previas',
              style: GoogleFonts.lato(
                fontSize: 12,
                color: ThemeColor.textSecondaryColor,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRecommendationCard(UserModel user, ForYouController controller) {
    return Container(
      width: 180,
      margin: const EdgeInsets.only(right: 12),
      child: Stack(
        children: [
          Container(
            decoration: BoxDecoration(
              color: ThemeColor.backgroundColor,

              borderRadius: BorderRadius.circular(16),
              boxShadow: [ThemeColor.lightShadow],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.all(8),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: Image.network(
                          user.imageUrl,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) {
                            return Container(
                              color: ThemeColor.backgroundColorfondo,
                              child: Icon(
                                Icons.person,
                                size: 50,
                                color: ThemeColor.textSecondaryColor,
                              ),
                            );
                          },
                        ),
                      ),
                    ),
                  ),

                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: ThemeColor.backgroundColor,
                      borderRadius: const BorderRadius.only(
                        bottomLeft: Radius.circular(16),
                        bottomRight: Radius.circular(16),
                      ),
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Expanded(
                          child: Text(
                            '${user.name}, ${user.age}${user.name}, ${user.age}${user.name}, ${user.age}${user.name}, ${user.age}${user.name}, ${user.age}',
                            style: GoogleFonts.lato(
                              fontSize: 13,
                              fontWeight: FontWeight.bold,
                              color: ThemeColor.textPrimaryColor,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),

                        const SizedBox(width: 8),
                        GestureDetector(
                          onTap: () => controller.toggleFavorite(user.id),
                          child: Container(
                            padding: const EdgeInsets.all(3),
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                colors: user.isFavorite
                                    ? [
                                        ThemeColor.errorColor,
                                        ThemeColor.errorColor.withOpacity(0.8),
                                      ]
                                    : [
                                        ThemeColor.primaryColor,
                                        ThemeColor.primaryColor.withOpacity(
                                          0.8,
                                        ),
                                      ],
                              ),
                              shape: BoxShape.circle,
                              boxShadow: [
                                BoxShadow(
                                  color:
                                      (user.isFavorite
                                              ? ThemeColor.errorColor
                                              : ThemeColor.primaryColor)
                                          .withOpacity(0.4),
                                  blurRadius: 12,
                                  offset: const Offset(0, 4),
                                ),
                              ],
                            ),
                            child: Icon(
                              user.isFavorite
                                  ? Icons.favorite_rounded
                                  : Icons.favorite_border_rounded,
                              color: ThemeColor.textLightColor,
                              size: 10,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActiveProfilesSection(ForYouController controller) {
    return SliverToBoxAdapter(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Text(
              'Perfiles activos actualmente',
              style: GoogleFonts.lato(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: ThemeColor.textPrimaryColor,
              ),
            ),
          ),
          const SizedBox(height: 16),
          Obx(
            () => ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemCount: controller.activeProfiles.length,
              itemBuilder: (context, index) {
                final user = controller.activeProfiles[index];
                return _buildActiveProfileCard(user, controller);
              },
            ),
          ),
          const SizedBox(height: 80),
        ],
      ),
    );
  }

  Widget _buildActiveProfileCard(UserModel user, ForYouController controller) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: ThemeColor.backgroundColor,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [ThemeColor.lightShadow],
      ),
      child: Row(
        children: [
          Stack(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Image.network(
                  user.imageUrl,
                  width: 70,
                  height: 70,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) {
                    return Container(
                      width: 70,
                      height: 70,
                      color: ThemeColor.backgroundColorfondo,
                      child: Icon(
                        Icons.person,
                        color: ThemeColor.textSecondaryColor,
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  user.name,
                  style: GoogleFonts.lato(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: ThemeColor.textPrimaryColor,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  user.location,
                  style: GoogleFonts.lato(
                    fontSize: 13,
                    color: ThemeColor.textSecondaryColor,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Edad: ${user.age} años',
                  style: GoogleFonts.lato(
                    fontSize: 12,
                    color: ThemeColor.textTertiaryColor,
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: ThemeColor.primaryColor,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Text(
              '${user.distance} km',
              style: GoogleFonts.lato(
                fontSize: 12,
                fontWeight: FontWeight.bold,
                color: ThemeColor.textLightColor,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
