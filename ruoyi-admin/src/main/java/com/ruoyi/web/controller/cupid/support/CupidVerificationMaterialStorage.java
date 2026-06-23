package com.ruoyi.web.controller.cupid.support;

import java.io.IOException;
import java.nio.file.Files;
import java.nio.file.Path;
import java.nio.file.Paths;
import java.time.LocalDate;
import java.util.Locale;
import org.springframework.stereotype.Component;
import org.springframework.web.multipart.MultipartFile;
import com.ruoyi.common.config.RuoYiConfig;
import com.ruoyi.common.utils.uuid.IdUtils;

/**
 * Cupid Match 认证材料私有文件存储
 */
@Component
public class CupidVerificationMaterialStorage
{
    public static final String PRIVATE_PREFIX = "private://verification/";

    private static final String[] ALLOWED_EXTENSIONS = { "pdf", "jpg", "jpeg", "png", "webp" };

    private static final long MAX_SIZE = 10L * 1024L * 1024L;

    public StoredMaterial upload(String profileId, MultipartFile file) throws IOException
    {
        if (file == null || file.isEmpty())
        {
            throw new IllegalArgumentException("empty_file");
        }
        if (file.getSize() > MAX_SIZE)
        {
            throw new IllegalArgumentException("file_too_large");
        }
        String extension = extensionOf(file.getOriginalFilename());
        if (!isAllowed(extension))
        {
            throw new IllegalArgumentException("invalid_file_type");
        }

        LocalDate today = LocalDate.now();
        String relativePath = profileId + "/" + today.getYear() + "/"
                + String.format("%02d", today.getMonthValue()) + "/"
                + String.format("%02d", today.getDayOfMonth()) + "/"
                + IdUtils.fastSimpleUUID() + "." + extension;
        Path target = resolveRelative(relativePath);
        if (!target.startsWith(baseDir()))
        {
            throw new IllegalArgumentException("invalid_file_path");
        }
        Files.createDirectories(target.getParent());
        file.transferTo(target);
        return new StoredMaterial(PRIVATE_PREFIX + relativePath.replace('\\', '/'),
                file.getOriginalFilename(), file.getContentType(), file.getSize());
    }

    public MaterialFile resolve(String materialUrl)
    {
        if (materialUrl == null || !materialUrl.startsWith(PRIVATE_PREFIX))
        {
            throw new IllegalArgumentException("invalid_material_url");
        }
        String relativePath = materialUrl.substring(PRIVATE_PREFIX.length());
        Path file = resolveRelative(relativePath);
        if (!file.startsWith(baseDir()) || !Files.isRegularFile(file))
        {
            throw new IllegalArgumentException("material_file_not_found");
        }
        return new MaterialFile(file, file.getFileName().toString(), contentType(file));
    }

    private Path resolveRelative(String relativePath)
    {
        return baseDir().resolve(relativePath).normalize();
    }

    private Path baseDir()
    {
        Path profile = Paths.get(RuoYiConfig.getProfile()).toAbsolutePath().normalize();
        Path parent = profile.getParent();
        if (parent == null)
        {
            parent = profile;
        }
        return parent.resolve("cupid-private").resolve("verification").normalize();
    }

    private String extensionOf(String filename)
    {
        if (filename == null)
        {
            return "";
        }
        int dot = filename.lastIndexOf('.');
        return dot >= 0 ? filename.substring(dot + 1).toLowerCase(Locale.ROOT) : "";
    }

    private boolean isAllowed(String extension)
    {
        for (String allowed : ALLOWED_EXTENSIONS)
        {
            if (allowed.equals(extension))
            {
                return true;
            }
        }
        return false;
    }

    private String contentType(Path file)
    {
        try
        {
            String detected = Files.probeContentType(file);
            if (detected != null)
            {
                return detected;
            }
        }
        catch (IOException ignored)
        {
        }
        String name = file.getFileName().toString().toLowerCase(Locale.ROOT);
        if (name.endsWith(".pdf"))
        {
            return "application/pdf";
        }
        if (name.endsWith(".png"))
        {
            return "image/png";
        }
        if (name.endsWith(".webp"))
        {
            return "image/webp";
        }
        return "image/jpeg";
    }

    public record StoredMaterial(String materialUrl, String originalFilename, String contentType, long size)
    {
    }

    public record MaterialFile(Path path, String filename, String contentType)
    {
    }
}
