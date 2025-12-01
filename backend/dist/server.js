"use strict";
var __importDefault = (this && this.__importDefault) || function (mod) {
    return (mod && mod.__esModule) ? mod : { "default": mod };
};
Object.defineProperty(exports, "__esModule", { value: true });
const express_1 = __importDefault(require("express"));
const cors_1 = __importDefault(require("cors"));
const uuid_1 = require("uuid");
const app = (0, express_1.default)();
const PORT = 3000;
// Middleware
app.use((0, cors_1.default)()); // Allow Flutter app to connect
app.use(express_1.default.json());
// --- MOCK CONSTANTS ---
const CLOUDINARY_UPLOAD_URL = "https://api.cloudinary.com/v1_1/your-cloud-name/auto/upload";
const CLOUDINARY_API_KEY = "1234567890";
const CLOUDINARY_SECRET = "ShhhhThisIsASecret"; // Not sent to client, just for mock signature
// --- 1. POST /api/uploads/presign (STEP 1) ---
app.post('/api/uploads/presign', (req, res) => {
    // In a real app, we validate user, check file details, and generate signature
    console.log('Received /presign request:', req.body.localUploadId);
    const uploadId = (0, uuid_1.v4)();
    const publicId = `parchi/uploads/${uploadId}`;
    const timestamp = Math.floor(Date.now() / 1000);
    // NOTE: Signature generation is complex. We are mocking the response fields.
    const mockSignature = `mock_sha1_sig_${timestamp}`;
    res.status(200).json({
        uploadId: uploadId,
        upload: {
            uploadUrl: CLOUDINARY_UPLOAD_URL,
            apiKey: CLOUDINARY_API_KEY,
            timestamp: timestamp,
            signature: mockSignature,
            uploadParams: {
                public_id: publicId,
                folder: "parchi/uploads",
                // This is where all signed Cloudinary parameters would go
            }
        }
    });
});
// --- 2. POST /api/uploads/complete (STEP 3) ---
app.post('/api/uploads/complete', (req, res) => {
    // In a real app, this is where the strict verification logic runs
    const { captureLat, captureLon, publicId } = req.body;
    console.log(`Received /complete request for ${publicId}. Capture Coords: ${captureLat}, ${captureLon}`);
    // --- MOCK VERIFICATION LOGIC ---
    const outcomes = [
        { status: 'verified', reason: 'EXIF and capture GPS match perfectly.', distance_m: 12.4 },
        { status: 'low_confidence', reason: 'EXIF and capture GPS are close, but slightly outside the 100m threshold.', distance_m: 350.7 },
        { status: 'flagged', reason: 'Large discrepancy (50km+) between EXIF and capture GPS. Likely spoofed.', distance_m: 65000.0 },
        { status: 'unverified', reason: 'EXIF and capture GPS have a measurable mismatch.', distance_m: 800.2 }
    ];
    // Simulate the server verification outcome (1/4 chance for each status)
    const result = outcomes[Math.floor(Math.random() * outcomes.length)];
    // Simulate rejection (e.g., if server failed to parse EXIF)
    if (Math.random() < 0.1) { // 10% chance of server rejection
        return res.status(400).json({
            status: 'rejected',
            reason: 'no_exif_gps',
            message: 'Server failed to extract EXIF GPS from the uploaded file. Please ensure geotagging is enabled and retake the photo.'
        });
    }
    res.status(200).json({
        imageId: (0, uuid_1.v4)(),
        storageUrl: `https://res.cloudinary.com/your-cloud-name/image/upload/${publicId}.jpg`,
        verification_status: result.status,
        verification_reason: result.reason,
        distance_m: result.distance_m
    });
});
// --- Server Startup ---
app.listen(PORT, () => {
    console.log(`Minimal Backend Stub is running on http://localhost:${PORT}/`);
    console.log(`Use http://10.0.2.2:${PORT}/api in the Flutter emulator.`);
});
//# sourceMappingURL=server.js.map