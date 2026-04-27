import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:tendria/common/theme/App_Theme.dart';
import 'package:tendria/features/page/nearbyprofiles/nearby_profiles_controller.dart';



class NearbyProfilesPage extends StatelessWidget {
  const NearbyProfilesPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(NearbyProfilesController());

    return Scaffold(
      backgroundColor: ThemeColor.backgroundColorfondo,
      body: SafeArea(
        child: Column(
          children: [
      
            _buildHeader(controller),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Obx(
                    () => Flexible(
                      child: Text(
                        '${controller.nearbyCount.value} personas cerca',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: GoogleFonts.lato(
                          fontSize: 20,
                          fontWeight: FontWeight.w700,
                          color: ThemeColor.textPrimaryColor,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            
            Expanded(
              child: Obx(
                () => ListView.builder(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),
                  itemCount: controller.profiles.length,
                  itemBuilder: (context, index) {
                    final profile = controller.profiles[index];
                    return _buildProfileCard(context, profile, controller);
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(NearbyProfilesController controller) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Image.asset('assets/logo/logo.png', width: 100,
                          height: 100,),
            ],
          ),
        ],
      ),
    );
  }

  
  Widget _buildProfileCard(
    BuildContext context,
    ProfileModel profile,
    NearbyProfilesController controller,
  ) {
    return GestureDetector(
      onTap: () => controller.onProfileTap(profile),
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: ThemeColor.backgroundColor,
          borderRadius: ThemeColor.mediumBorderRadius,
          boxShadow: [ThemeColor.darkShadow],
        ),
        child: Row(
          children: [
        
            _buildProfileImage(profile.imageUrl),

            const SizedBox(width: 16),

          
            Expanded(child: _buildProfileInfo(profile)),

     
            _buildDistanceBadge(profile.distance),
          ],
        ),
      ),
    );
  }

  Widget _buildProfileImage(String imageUrl) {
    return Container(
      width: 80,
      height: 80,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(color: ThemeColor.secondaryColor, width: 2),
        boxShadow: [ThemeColor.lightShadow],
      ),
      child: ClipOval(
        child: Image.asset(
          imageUrl,
          fit: BoxFit.cover,
          errorBuilder: (context, error, stackTrace) {
            return Container(
              color: ThemeColor.backgroundColorfondo,
              child: Icon(
                Icons.person,
                size: 40,
                color: ThemeColor.textSecondaryColor,
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildProfileInfo(ProfileModel profile) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
     
        Text(
          profile.name,
          style: GoogleFonts.lato(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: ThemeColor.textPrimaryColor,
          ),
        ),

        const SizedBox(height: 20),

     
        Row(
          children: [
            Icon(
              Icons.location_on,
              size: 16,
              color: ThemeColor.textSecondaryColor,
            ),
            const SizedBox(width: 4),
            Text(
              'Ubicación: ${profile.location}',
              style: GoogleFonts.lato(
                fontSize: 14,
                color: ThemeColor.textTertiaryColor,
              ),
            ),
          ],
        ),

        const SizedBox(height: 4),

     
        Text(
          'Edad: ${profile.age} años',
          style: GoogleFonts.lato(
            fontSize: 14,
            color: ThemeColor.textTertiaryColor,
          ),
        ),
      ],
    );
  }


  Widget _buildDistanceBadge(String distance) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: ThemeColor.primaryColor,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [ThemeColor.lightShadow],
      ),
      child: Text(
        distance,
        style: GoogleFonts.lato(
          fontSize: 12,
          fontWeight: FontWeight.w600,
          color: ThemeColor.textLightColor,
        ),
      ),
    );
  }
}
