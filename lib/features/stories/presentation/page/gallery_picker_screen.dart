import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:tendria/common/theme/App_Theme.dart';
import 'package:tendria/features/stories/presentation/page/create_story_controller.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:photo_manager/photo_manager.dart';

class GalleryPickerScreen extends StatefulWidget {
  const GalleryPickerScreen({Key? key}) : super(key: key);

  @override
  State<GalleryPickerScreen> createState() => _GalleryPickerScreenState();
}

class _GalleryPickerScreenState extends State<GalleryPickerScreen> {
  final CreateStoryController controller = Get.find<CreateStoryController>();
  
  List<AssetPathEntity> albums = [];
  AssetPathEntity? selectedAlbum;
  List<AssetEntity> assets = [];
  bool isLoading = true;
  
  @override
  void initState() {
    super.initState();
    _loadAlbums();
  }

  Future<void> _loadAlbums() async {
    setState(() => isLoading = true);
    
    final PermissionState permission = await PhotoManager.requestPermissionExtend();
    
    if (permission.isAuth) {
      final List<AssetPathEntity> paths = await PhotoManager.getAssetPathList(
        type: RequestType.common,
      );
      
      if (paths.isNotEmpty) {
        albums = paths;
        selectedAlbum = paths[0];
        await _loadAssetsFromAlbum(selectedAlbum!);
      }
    }
    
    setState(() => isLoading = false);
  }

  Future<void> _loadAssetsFromAlbum(AssetPathEntity album) async {
    final assetCount = await album.assetCountAsync;
    final List<AssetEntity> media = await album.getAssetListRange(
      start: 0,
      end: assetCount,
    );
    
    setState(() {
      assets = media;
    });
  }

  Future<void> _selectAsset(AssetEntity asset) async {
    await controller.selectFromGallery(asset);
    Get.back(); // Cerrar galería
  }

  void _showAlbumSelector() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        decoration: BoxDecoration(
          color: ThemeColor.backgroundColor,
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(20),
            topRight: Radius.circular(20),
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(height: 12),
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 20),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Text(
                'Seleccionar álbum',
                style: GoogleFonts.rubik(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            const SizedBox(height: 16),
            Flexible(
              child: ListView.builder(
                shrinkWrap: true,
                itemCount: albums.length,
                itemBuilder: (context, index) {
                  final album = albums[index];
                  return FutureBuilder<int>(
                    future: album.assetCountAsync,
                    builder: (context, snapshot) {
                      final count = snapshot.data ?? 0;
                      return ListTile(
                        leading: FutureBuilder<List<AssetEntity>>(
                          future: album.getAssetListRange(start: 0, end: 1),
                          builder: (context, snapshot) {
                            if (snapshot.hasData && snapshot.data!.isNotEmpty) {
                              return FutureBuilder<Uint8List?>(
                                future: snapshot.data![0].thumbnailDataWithSize(
                                  const ThumbnailSize(80, 80),
                                ),
                                builder: (context, thumbSnapshot) {
                                  if (thumbSnapshot.hasData) {
                                    return ClipRRect(
                                      borderRadius: BorderRadius.circular(8),
                                      child: Image.memory(
                                        thumbSnapshot.data!,
                                        width: 50,
                                        height: 50,
                                        fit: BoxFit.cover,
                                      ),
                                    );
                                  }
                                  return Container(
                                    width: 50,
                                    height: 50,
                                    decoration: BoxDecoration(
                                      color: Colors.grey[300],
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                  );
                                },
                              );
                            }
                            return Container(
                              width: 50,
                              height: 50,
                              decoration: BoxDecoration(
                                color: Colors.grey[300],
                                borderRadius: BorderRadius.circular(8),
                              ),
                            );
                          },
                        ),
                        title: Text(
                          album.name,
                          style: GoogleFonts.rubik(
                            fontWeight: selectedAlbum?.id == album.id
                                ? FontWeight.w600
                                : FontWeight.w400,
                          ),
                        ),
                        subtitle: Text('$count elementos'),
                        trailing: selectedAlbum?.id == album.id
                            ? Icon(Icons.check, color: ThemeColor.primaryColor)
                            : null,
                        onTap: () {
                          setState(() {
                            selectedAlbum = album;
                          });
                          _loadAssetsFromAlbum(album);
                          Get.back();
                        },
                      );
                    },
                  );
                },
              ),
            ),
            SizedBox(height: MediaQuery.of(context).padding.bottom + 20),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        leading: IconButton(
          icon: const Icon(Icons.close, color: Colors.white),
          onPressed: () => Get.back(),
        ),
        title: GestureDetector(
          onTap: _showAlbumSelector,
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                selectedAlbum?.name ?? 'Galería',
                style: GoogleFonts.rubik(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(width: 8),
              const Icon(Icons.arrow_drop_down, color: Colors.white),
            ],
          ),
        ),
        centerTitle: true,
      ),
      body: isLoading
          ? const Center(
              child: CircularProgressIndicator(color: Colors.white),
            )
          : assets.isEmpty
              ? Center(
                  child: Text(
                    'No hay elementos en este álbum',
                    style: GoogleFonts.rubik(color: Colors.white),
                  ),
                )
              : GridView.builder(
                  padding: const EdgeInsets.all(2),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 3,
                    crossAxisSpacing: 2,
                    mainAxisSpacing: 2,
                  ),
                  itemCount: assets.length,
                  itemBuilder: (context, index) {
                    final asset = assets[index];
                    return GestureDetector(
                      onTap: () => _selectAsset(asset),
                      child: Stack(
                        fit: StackFit.expand,
                        children: [
                          FutureBuilder<Uint8List?>(
                            future: asset.thumbnailDataWithSize(
                              const ThumbnailSize(400, 400),
                            ),
                            builder: (context, snapshot) {
                              if (snapshot.connectionState == ConnectionState.done &&
                                  snapshot.hasData) {
                                return Image.memory(
                                  snapshot.data!,
                                  fit: BoxFit.cover,
                                );
                              }
                              return Container(
                                color: Colors.grey[900],
                                child: const Center(
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    color: Colors.white,
                                  ),
                                ),
                              );
                            },
                          ),
                          // Indicador de video
                          // Indicador de video
if (asset.type == AssetType.video)
  Positioned(
    top: 8,
    right: 8,
    child: Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 6,
        vertical: 2,
      ),
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.6),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Row(
        children: [
          const Icon(
            Icons.videocam,
            color: Colors.white,
            size: 14,
          ),
          const SizedBox(width: 4),
          // ✅ CORRECCIÓN: asset.videoDuration es Duration, no Future
          Builder(
            builder: (context) {
              final duration = asset.videoDuration.inSeconds;
              final minutes = duration ~/ 60;
              final seconds = duration % 60;
              return Text(
                '$minutes:${seconds.toString().padLeft(2, '0')}',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 12,
                ),
              );
            },
          ),
        ],
      ),
    ),
  ),
                        ],
                      ),
                    );
                  },
                ),
    );
  }
}