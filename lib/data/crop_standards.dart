// lib/data/crop_standards.dart

enum CropStage {
  germination,
  seedling,
  vegetative,
  flowering,
  fruiting,
  harvest,
}

class PhotoRequirement {
  final String label;
  final String instruction;
  final bool isMacro; // true = close-up, false = wide field
  final int count; // How many photos needed

  const PhotoRequirement({
    required this.label,
    required this.instruction,
    required this.isMacro,
    required this.count,
  });
}

class CropStandard {
  // Returns the stage based on weeks passed since sowing
  static CropStage getStage(int weeksSinceSowing) {
    if (weeksSinceSowing <= 2) return CropStage.germination;
    if (weeksSinceSowing <= 4) return CropStage.seedling;
    if (weeksSinceSowing <= 8) return CropStage.vegetative;
    if (weeksSinceSowing <= 12) return CropStage.flowering;
    if (weeksSinceSowing <= 16) return CropStage.fruiting;
    return CropStage.harvest;
  }

  // Returns the photo protocols (The "List" you asked for)
  static List<PhotoRequirement> getRequirements(CropStage stage) {
    switch (stage) {
      case CropStage.germination:
        return [
          PhotoRequirement(
            label: "Field Overview",
            instruction: "Take wide angle photos of the land. Focus on weed patches or water stagnation.",
            isMacro: false,
            count: 3,
          ),
        ];
      case CropStage.seedling:
        return [
          PhotoRequirement(
            label: "Field Overview",
            instruction: "Wide shot of rows to check germination consistency.",
            isMacro: false,
            count: 2,
          ),
          PhotoRequirement(
            label: "Seedling Close-up",
            instruction: "Get close to a healthy seedling. Keep it in focus.",
            isMacro: true,
            count: 2,
          ),
        ];
      case CropStage.vegetative:
      case CropStage.flowering:
        return [
          PhotoRequirement(
            label: "Crop Vigor",
            instruction: "Wide shot showing crop height and density.",
            isMacro: false,
            count: 2,
          ),
          PhotoRequirement(
            label: "Leaf Health",
            instruction: "Close-up of leaves. Look for spots, holes, or yellowing (Disease Detection).",
            isMacro: true,
            count: 3,
          ),
        ];
      default:
        return [
           PhotoRequirement(
            label: "General Inspection",
            instruction: "Take photos of the crop status.",
            isMacro: false,
            count: 3,
          ),
        ];
    }
  }
}