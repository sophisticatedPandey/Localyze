package com.localyze.service;

import com.cloudinary.Cloudinary;
import com.cloudinary.utils.ObjectUtils;
import com.localyze.exception.FileUploadException;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;
import org.springframework.web.multipart.MultipartFile;

import java.io.IOException;
import java.util.ArrayList;
import java.util.List;
import java.util.Map;

/**
 * Handles image upload and deletion operations via the Cloudinary SDK.
 * All uploads go to the "localyze" folder with auto quality and format optimization.
 */
@Service
@RequiredArgsConstructor
public class CloudinaryService {

    private final Cloudinary cloudinary;

    /**
     * Uploads a single image to Cloudinary and returns the secure URL and public ID.
     *
     * @param file the image file to upload
     * @return a map containing "url" (secure URL) and "publicId"
     * @throws FileUploadException if the upload fails
     */
    @SuppressWarnings("unchecked")
    public Map<String, String> uploadImage(MultipartFile file) {
        try {
            Map<String, Object> uploadResult = cloudinary.uploader().upload(file.getBytes(),
                    ObjectUtils.asMap(
                            "folder", "localyze",
                            "resource_type", "image",
                            "quality", "auto",
                            "fetch_format", "auto"
                    ));
            return Map.of(
                    "url", (String) uploadResult.get("secure_url"),
                    "publicId", (String) uploadResult.get("public_id")
            );
        } catch (IOException e) {
            throw new FileUploadException("Failed to upload image: " + e.getMessage());
        }
    }

    /**
     * Uploads multiple images (maximum 5) to Cloudinary.
     *
     * @param files the list of image files to upload
     * @return a list of maps, each containing "url" and "publicId"
     * @throws FileUploadException if more than 5 files are provided or upload fails
     */
    public List<Map<String, String>> uploadImages(List<MultipartFile> files) {
        if (files.size() > 5) {
            throw new FileUploadException("Maximum 5 images allowed");
        }
        List<Map<String, String>> results = new ArrayList<>();
        for (MultipartFile file : files) {
            results.add(uploadImage(file));
        }
        return results;
    }

    /**
     * Deletes an image from Cloudinary by its public ID.
     *
     * @param publicId the Cloudinary public ID of the image
     * @throws FileUploadException if the deletion fails
     */
    public void deleteImage(String publicId) {
        try {
            cloudinary.uploader().destroy(publicId, ObjectUtils.emptyMap());
        } catch (IOException e) {
            throw new FileUploadException("Failed to delete image: " + e.getMessage());
        }
    }
}
