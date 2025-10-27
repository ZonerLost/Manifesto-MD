import 'dart:io';
import 'package:get/get.dart';
import 'package:manifesto_md/models/auth_model.dart';
import 'package:manifesto_md/models/professional_details_model.dart';
import 'package:manifesto_md/services/profile_service.dart';
import 'package:manifesto_md/services/sahred_preferences_service.dart';
import 'package:manifesto_md/view/widget/show_common_snackbar_widget.dart';

class ProfileController extends GetxController {
  Rx<AuthModel?> profile = Rx<AuthModel?>(null);
  Rx<ProfessionalDetailsModel?> professionalDetails = Rx<ProfessionalDetailsModel?>(null);
  RxBool isLoading = false.obs;
  RxString imageUrl = ''.obs;
  RxString docId = ''.obs;
  RxDouble profileCompletion = 0.0.obs; 


  



  Future<void> fetchProfile() async {
    isLoading.value = true;
    try {
      final userId = await SharePrefService.instance.getUserId();
      if (userId == null || userId.isEmpty) throw Exception("No user ID found");

        print(userId);

      final professionalModelData = await ProfileService.instance.getProfessionalDetails(userId);
      final data = await ProfileService.instance.getProfile(userId);
      profile.value = data;
      imageUrl.value = data?.photoUrl ?? '';
      professionalDetails.value = professionalModelData!['Details'];
      docId.value = professionalModelData['docId'];
      print(professionalDetails.value?.speciality);
      calculateProfileCompletion();
    } catch (e) {
      print("Fetch profile error: $e");
    } finally {
      isLoading.value = false;
    }
  }



Future<void> updateProfile(
    String docID,
    String name,
    String country,
    String speciality,
    String expLevel,
  ) async {
    isLoading.value = true;
    try {
      final userId = await SharePrefService.instance.getUserId();
      if (userId == null || userId.isEmpty) throw Exception("No user ID found");

      final updatedData = {
        'name': name.trim(),
        'country': country.trim(),
      };

      final updatedProfessionalData = {
        'professionalLevel': expLevel.trim(),
        'speciality': speciality.trim(),
      };

      // --- Update Firestore ---
      await ProfileService.instance.updateProfile(
        userId: userId,
        updatedData: updatedData,
      );

      await ProfileService.instance.updateProfessionalDetails(
        docId: docID,
        userId: userId,
        professionalData: updatedProfessionalData,
      );


      if (profile.value != null) {
        profile.value = profile.value!.copyWith(
          name: name.trim(),
          country: country.trim(),
        );
      }

      if (professionalDetails.value != null) {
        professionalDetails.value = professionalDetails.value!.copyWith(
          speciality: speciality.trim(),
          professionalLev: expLevel.trim(),
        );
      }

      calculateProfileCompletion();
      profile.refresh();
      professionalDetails.refresh();
      Get.back();
      showCommonSnackbarWidget("Success", "Profile Updated Successfully");
    } catch (e) {
      print("Update profile error: $e");
        showCommonSnackbarWidget("Error", "Failed to update profile");
    } finally {
      isLoading.value = false;
    }
  }




  Future<void> uploadProfileImage(File imageFile) async {
    isLoading.value = true;
    try {
      final userId = await SharePrefService.instance.getUserId();
      final url = await ProfileService.instance.uploadProfileImage(
        userId: userId!,
        imageFile: imageFile,
      );
      imageUrl.value = url;
    
    } catch (e) {
      print("Upload image error: $e");
    } finally {
      isLoading.value = false;
    }
  }

  /// ✅ Calculate profile completion %
  void calculateProfileCompletion() {
    final data = profile.value;
    if (data == null) {
      profileCompletion.value = 0.0;
      return;
    }

    int totalFields = 5;
    int filledFields = 0;

    if (data.name != null && data.name!.isNotEmpty) filledFields++;
    if (data.email != "" && data.email.isNotEmpty) filledFields++;
    if (data.country != null && data.country!.isNotEmpty) filledFields++;
    if (data.photoUrl != null && data.photoUrl!.isNotEmpty) filledFields++;
    if (data.createdAt != null) filledFields++;

    profileCompletion.value = filledFields / totalFields;
  }
}
