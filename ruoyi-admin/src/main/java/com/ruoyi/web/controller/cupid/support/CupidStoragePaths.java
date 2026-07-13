package com.ruoyi.web.controller.cupid.support;

import java.net.URI;
import java.nio.file.Path;
import java.util.Optional;
import java.util.regex.Pattern;
import com.ruoyi.common.constant.Constants;

final class CupidStoragePaths
{
    private static final Pattern PUBLIC_IMAGE_KEY = Pattern.compile(
            "upload/\\d{4}/\\d{2}/\\d{2}/[a-f0-9]{32}\\.(jpg|jpeg|png|webp)", Pattern.CASE_INSENSITIVE);

    private CupidStoragePaths()
    {
    }

    static String publicPath(String objectKey)
    {
        return Constants.RESOURCE_PREFIX + "/" + objectKey;
    }

    static String requireObjectKey(String objectKey)
    {
        if (objectKey == null || objectKey.isBlank() || objectKey.startsWith("/") || objectKey.contains("\\"))
        {
            throw new IllegalArgumentException("invalid_file_path");
        }
        Path normalized = Path.of(objectKey).normalize();
        if (normalized.isAbsolute() || normalized.startsWith("..") || !normalized.toString().replace('\\', '/').equals(objectKey))
        {
            throw new IllegalArgumentException("invalid_file_path");
        }
        return objectKey;
    }

    static Optional<URI> publicUri(String baseUrl, String objectKey)
    {
        if (baseUrl == null || baseUrl.isBlank())
        {
            return Optional.empty();
        }
        String normalizedBase = baseUrl.endsWith("/") ? baseUrl.substring(0, baseUrl.length() - 1) : baseUrl;
        return Optional.of(URI.create(normalizedBase + "/" + requirePublicImageKey(objectKey)));
    }

    static String requirePublicImageKey(String objectKey)
    {
        String key = requireObjectKey(objectKey);
        if (!PUBLIC_IMAGE_KEY.matcher(key).matches())
        {
            throw new IllegalArgumentException("invalid_file_path");
        }
        return key;
    }
}
